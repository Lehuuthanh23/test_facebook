import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'test/webview.dart';
import 'webview.page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //_checkIfisLoggedIn();
  }

  _checkIfisLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print(accessToken.toJson());
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      print('Token: ${accessToken.tokenString}');
      setState(() {
        _userData = userData;
      });
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;

      final userData = await FacebookAuth.instance.getUserData();
      setState(() {
        _userData = userData;
        _checking = false;
      });
      //_syncCookies();
    } else {
      print(result.status);
      print(result.message);
      setState(() {
        _checking = false;
      });
    }
  }

  _syncCookies() async {
    final cookies = await CookieManager.instance()
        .getCookies(url: WebUri.uri(Uri.parse('https://www.facebook.com')));
    for (var cookie in cookies) {
      await CookieManager.instance().setCookie(
        url: WebUri.uri(Uri.parse(
            'https://www.facebook.com')), //WebUri('https://www.facebook.com'),
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path!,
        expiresDate: cookie.expiresDate,
        isSecure: cookie.isSecure,
        sameSite: cookie.sameSite,
      );
    }
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  _openFanPage() async {
    final url = _urlController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_userData);
    _urlController.text = 'https://www.tiktok.com/@anatoly.098';
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _userData != null
              ? Column(
                  children: [
                    Text('name: ${_userData!['name']}'),
                    Text('email: ${_userData!['email']}'),
                    Image.network(_userData!['picture']['data']['url']),
                    SizedBox(height: 20),
                  ],
                )
              : Container(),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter Facebook fanpage URL',
            ),
          ),
          SizedBox(height: 10),
          CupertinoButton(
            color: Colors.blue,
            child: Text(
              'Open Fanpage',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _openFanPage,
          ),
          SizedBox(height: 20),
          CupertinoButton(
            color: Colors.blue,
            child: Text(
              _userData != null ? 'LOGOUT' : 'LOGIN',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _userData != null ? _logout : _login,
          ),
          CupertinoButton(
            color: Colors.blue,
            child: Text(
              'Like bài viết',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              final postId =
                  'pfbid0kqGBYjJ1NdqH95MD3RqRAmyggyoCMn6toJ98XSPRfhcrC4GL665pA8LbickjB9prl'; // ID của bài viết bạn muốn thích
              final accessToken =
                  'EAARZAZBgJNGdwBOxKZAxI5gzFm18NCIEIwm4T3bfaAZACjKUSHo5AUJKsbZC79TvgctAUsDc78JoxHbWZAjZAt34ZBFxOPOMsSZCWcwaYfBz4ZCxrygZAOetpPvnXqcEtQ5SrVF0hD32duHDdzzZAnZANpT3eainncNAnKrUQx0z7akJ0BvIjRmfsgMepLG82GfS2a4SlVV7DjxKeZCjX672AuHXNVqhFTqIAcAZBpb9FbAg5gZBR9PIZCdhktGgRhx5GRMJDYf3j2ZA5sZAXgORsSO'; // Access token của bạn

              likePost(postId, accessToken);
            },
          ),
        ],
      )),
      // body: WebViewPage(
      //     url:
      //         'https://www.tiktok.com/@do_toc_do/video/7394320708400106760?is_from_webapp=1&sender_device=pc'),
    );
  }

  Future<void> likePost(String postId, String accessToken) async {
    final url = 'https://graph.facebook.com/v20.0/$postId/likes';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('Post liked successfully!');
    } else {
      final responseData = json.decode(response.body);
      print('Failed to like post: ${responseData['error']['message']}');
    }
  }
}
