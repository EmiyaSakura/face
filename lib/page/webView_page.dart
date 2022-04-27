import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewArgs {
  final String title;
  final String url;

  WebViewArgs(this.title, this.url);
}

class WebViewPage extends StatelessWidget {
  static String tag = 'webView-page';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as WebViewArgs;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          //去除阴影
          centerTitle: true,
          // 标题居中
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                NavRouter.pop();
              },
              icon: Icon(Icons.close)),
          title: Text(
            args.title,
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: WebView(
          initialUrl: args.url,
          //JS执行模式 是否允许JS执行
          javascriptMode: JavascriptMode.unrestricted,
          //网页缩放
          zoomEnabled: true,
        ));
  }
}
