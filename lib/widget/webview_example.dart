import 'package:flutter/material.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// แสดงหน้าเว็บใน WebView ของแอป รับ url ที่ resolve มาแล้วจากหน้าที่เรียกใช้โดยตรง
/// (เดิมมีโค้ดหน้าตาเดียวกันนี้ซ้ำกันอยู่ 5 ที่ ในแต่ละไฟล์: home.dart, my_service.dart,
/// detail_notify.dart, detail_news.dart, detail_popup_page.dart)
class WebViewExample extends StatefulWidget {
  final String url;
  const WebViewExample({super.key, required this.url});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    // #enddocregion webview_controller
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyStyle().bgColor,
          iconTheme: IconThemeData(color: Colors.white),
          title:
              const Text('PTN Pharma', style: TextStyle(color: Colors.white))),
      body: WebViewWidget(controller: controller),
    );
  }
  // #enddocregion webview_widget
}
