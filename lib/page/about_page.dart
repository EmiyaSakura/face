import 'package:face/page/webView_page.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  static String tag = 'about-page';

  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.arrow_back)),
          title: Text(
            '关于Sakura',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: ListView(
            controller: new ScrollController(keepScrollOffset: false),
            children: [
              ListTile(
                  title: Center(
                child: Image.asset('logo.png'),
              )),
              ListTile(
                  title: Center(
                child: Image.asset('title.png'),
              )),
              ListTile(
                  title: Center(
                child: Text('Version 2.6.0'),
              )),
              ListTile(title: Text('QQ'), trailing: Text('870700759')),
              ListTile(
                  title: Text('邮箱'), trailing: Text('emiya.sakura@qq.com')),
              const SizedBox(height: 200),
              ListTile(
                  title: Center(
                child: TextButton(
                  child: const Text(
                    '用户使用守则与服务协议',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    NavRouter.push(
                        WebViewPage.tag,
                        WebViewArgs(
                          '用户使用守则与服务协议',
                          'https://user.mihoyo.com/#/agreement?hideBack=true',
                        ));
                  },
                ),
              )),
              ListTile(
                  title: Center(
                child: Text(
                  'Sakura: @2022 sakura版权所有',
                  style: TextStyle(fontSize: 12),
                ),
              )),
            ]));
  }
}
