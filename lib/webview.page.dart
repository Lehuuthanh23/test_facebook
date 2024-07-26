import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyWebViewPage extends StatefulWidget {
  final String? url;

  const MyWebViewPage({
    Key? key,
    this.url,
  }) : super(key: key);

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late InAppWebViewController _webViewController;
  String? _title;
  double _progress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _title ?? 'Đang tải...',
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
          Expanded(
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _webViewController.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri.uri(Uri.parse(widget.url!))),
                          ),
                          child: Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(widget.url!)),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _hasError = false;
                        _errorMessage = '';
                      });
                    },
                    onLoadStop: (controller, url) async {
                      String? titleString = await controller.getTitle();
                      setState(() {
                        _title = titleString;
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress = progress / 100;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      setState(() {
                        _hasError = true;
                        _errorMessage = 'Lỗi: $message\nĐường dẫn: $url';
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
