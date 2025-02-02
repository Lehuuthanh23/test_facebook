import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'positioned_auto_click_widget.dart';

class WebViewPage extends StatefulWidget {
  final String? url;

  const WebViewPage({super.key, this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  final ValueNotifier<bool> _clickYoutubeNotifier = ValueNotifier<bool>(false);
  Widget? _title;
  double _progress = 0;
  bool _hasError = false;
  String _errorMessage = '';
  String _htmlContent = '';

  static const String desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(desktopUserAgent)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _hasError = false;
              _errorMessage = '';
            });
            print('Bắt đầu tải URL: $url');
          },
          onPageFinished: (String url) async {
            String? titleString = await _controller.getTitle();
            setState(() {
              _title = Text(
                titleString ?? 'Đang tải...',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              );
            });
            await Future.delayed(const Duration(seconds: 5));
            print('Đợi xong');
            //await _getHtmlContent();
            // await likeFacebook();
            // await disLikeYoutube();
            await followTiktok();
            //await followFacebook();
            // await likeTiktok();
            //await likeYoutube();
            //await commentFacebook();
            print('Hoàn thành tải URL: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage =
                  'Lỗi: ${error.description}\nĐường dẫn: ${error.url}';
              print('Lỗi: ${error.description}\nĐường dẫn: ${error.url}');
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            String url = request.url;
            if (url.startsWith('intent://') ||
                url.startsWith('fb://') ||
                url.startsWith('snssdk1180://') ||
                url.startsWith('snssdk1340://') ||
                url.startsWith('https://v16-web-newkey.tiktokcdn.com') ||
                url.startsWith('https://v19-web-newkey.tiktokcdn.com/')) {
              print('Chặn: $url');
              if (url.startsWith('intent://') || url.startsWith('fb://')) {
                url =
                    url.replaceFirst('intent://', 'https://www.facebook.com/');
                url = url.replaceFirst('fb://', 'https://www.facebook.com/');
              } else if (url.startsWith('snssdk1180://') ||
                  url.startsWith('snssdk1340://')) {
                url = url.replaceFirst(
                    'snssdk1180://', 'https://www.tiktok.com/');
                url = url.replaceFirst(
                    'snssdk1340://', 'https://www.tiktok.com/');
              }
              return NavigationDecision.prevent;
            }
            print('Cho phép tải URL: $url');
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    if (widget.url != null && widget.url!.isNotEmpty) {
      String url = widget.url!;
      if (url.startsWith("intent://") ||
          url.startsWith("fb://") ||
          url.startsWith("snssdk1180://") ||
          url.startsWith("snssdk1340://")) {
        url = url
            .replaceFirst("intent://", "https://www.facebook.com/")
            .replaceFirst('fb://', 'https://www.facebook.com/')
            .replaceFirst('snssdk1180://', 'https://www.tiktok.com/')
            .replaceFirst('snssdk1340://', 'https://www.tiktok.com/');
      }
      _controller.loadRequest(Uri.parse(url));
    } else {
      String fileText = await rootBundle.loadString('assets/index.html');
      print('Load trong assets');
      _controller.loadHtmlString(fileText);
    }
  }

  Future<void> likeFacebook() async {
    try {
      print('Thực hiện nhấn');
      await _controller.runJavaScript(
        """
      (function() {
        var likeButton = document.querySelector('div[aria-label="Thích"]');
        if (likeButton) {
          likeButton.click();
          return 'Click event sent to like button.';
        } else {
          return 'Like button not found.';
        }
      })();
      """,
      ).then((result) {
        print('Nhấn like facebook xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> followFacebook() async {
    try {
      print('Thực hiện nhấn');
      await _controller.runJavaScript(
        """
      (function() {
        var likeButton = document.querySelector('div[aria-label="Theo dõi"]');
        if (likeButton) {
          likeButton.click();
          return 'Click event sent to like button.';
        } else {
          return 'Like button not found.';
        }
      })();
      """,
      ).then((result) {
        print('Nhấn theo dõi facebook xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> commentFacebook() async {
    try {
      print('Thực hiện nhấn');
      await _controller.runJavaScript(
        """
      (function() {
        var likeButton = document.querySelector('div[aria-label="Viết bình luận"]');
        if (likeButton) {
          likeButton.click();
          return 'Click event sent to like button.';
        } else {
          return 'Like button not found.';
        }
      })();
      """,
      ).then((result) {
        print('Nhấn viết bình luận facebook xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> likeTiktok() async {
    try {
      print('Thực hiện nhấn');
      await _controller.runJavaScript("""
        setTimeout(function() {
          console.log('Đang tìm nút...');
          var likeButton = document.querySelector('span[data-e2e="like-icon"]');
          console.log('Nút:', likeButton);
          if (likeButton) {
            likeButton.click();
            console.log('Click event sent to like button.');
            return 'Click event sent to like button.';
          } else {
            console.log('Like button not found.');
            return 'Like button not found.';
          }
        }, 1000);
      """).then((result) {
        //print(result);
        print('Nhấn like tiktok xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> followTiktok() async {
    try {
      print('Thực hiện nhấn');
      await _controller.runJavaScript(
        """
          setTimeout(function() {
          console.log('Đang tìm nút...');
          var likeButton = document.querySelector('button[data-e2e="follow-button"]');
          console.log('Nút:', likeButton);
          if (likeButton) {
            likeButton.click();
            console.log('Click event sent to like button.');
            return 'Click event sent to like button.';
          } else {
            console.log('Like button not found.');
            return 'Like button not found.';
          }
        }, 3000);

      """,
      ).then((result) {
        print('Nhấn theo dõi tiktok xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  // _clickYoutubeNotifier.value = true;
  // await Future.delayed(Duration(milliseconds: 300));
  // _clickYoutubeNotifier.value = true;

  Future<void> likeYoutube() async {
    try {
      print('Nhấn like youtube');
      await _controller.runJavaScript(
        """
      (function() {
         var likeButton = document.querySelector('button.yt-spec-button-shape-next[aria-label*="thích video này"], button.yt-spec-button-shape-next[title="Tôi thích video này"]');
        if (likeButton) {
          likeButton.click();
          return 'Click event sent to like button.';
        } else {
          return 'Like button not found.';
        }
      })();
      """,
      ).then((result) {
        print('Nhấn like youtube xong rồi');
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> disLikeYoutube() async {
    try {
      print('Nhấn dislike youtube');
      await _controller.runJavaScript(
        """
      (function() {
         var likeButton = document.querySelector('button.yt-spec-button-shape-next[aria-label*="Không thích video này"], button.yt-spec-button-shape-next[title="Tôi không thích video này"]');
        if (likeButton) {
          likeButton.click();
          return 'Click event sent to like button.';
        } else {
          return 'Like button not found.';
        }
      })();
      """,
      ).then((result) {
        //print(result);
      });
    } catch (e) {
      print('Lỗi khi gửi sự kiện click: $e');
    }
  }

  Future<void> _getHtmlContent() async {
    try {
      final Object html = await _controller.runJavaScriptReturningResult(
          "window.document.getElementsByTagName('html')[0].outerHTML;");
      setState(() {
        _htmlContent = html.toString();
      });
      // Đếm số lần xuất hiện của "Thích video"
      final RegExp likeRegex = RegExp('Thích video');
      final matches = likeRegex.allMatches(_htmlContent);
      final likeCount = matches.length;
      print('Số lần xuất hiện của "Thích video": $likeCount');
      print('Nội dung HTML: $html');
      if (_htmlContent.contains('Thích video')) {
        print('Nút like có trong HTML');
        int indexLikeButton = _htmlContent.indexOf('Thích video');
        String nutLike =
            _htmlContent.substring(indexLikeButton - 50, indexLikeButton + 50);
        print('Nút like là: $nutLike');
      } else {
        print('Nút like không có trong HTML');
      }
    } catch (e) {
      print('Lỗi khi lấy nội dung HTML: $e');
    }
  }

  @override
  void dispose() {
    _controller.clearCache();
    _controller.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: _title ??
            Text('Đang tải...',
                style: const TextStyle(fontSize: 14, color: Colors.white)),
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
      body: Stack(
        children: [
          Column(
            children: [
              if (_progress > 0 && _progress < 1)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                              onPressed: () => _loadHtmlFromAssets(),
                              child: Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : WebViewWidget(controller: _controller),
              ),
            ],
          ),
          // PositionedAutoClickWidget(
          //   clickNotifier: _clickYoutubeNotifier,
          //   position: Offset(width / 2, height / 2),
          // )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.abc),
          onPressed: () async {
            // print('Nhấn like tiktok');
            //await likeTiktok();
            _getHtmlContent();
          }),
    );
  }
}
