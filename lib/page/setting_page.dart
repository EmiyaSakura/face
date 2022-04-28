import 'package:face/page/account_setting_page.dart';
import 'package:face/page/login_page.dart';
import 'package:face/page/manage_page.dart';
import 'package:face/page/webView_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_page.dart';
import 'doctor_home_page.dart';
import 'doctor_information_page.dart';

class SettingPage extends StatefulWidget {
  static String tag = 'setting-page';

  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var user = {};

  init() async {
    var res = await Http().get('/normal/getUser');
    setState(() {
      user = res['info'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  handleClick(type) async {
    switch (type) {
      case '关于':
        NavRouter.push(AboutPage.tag);
        break;
      case '清除缓存':
        Toaster().show('清除成功');
        break;
      case '意见反馈':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '意见反馈',
              'https://www.acy.moe/api/404',
            ));
        break;
      case '检查更新':
        var res = await Http().get('/universal/checkUpdates');
        Toaster().show(res['message']);
        break;
      case '个人信息收集清单':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '个人信息收集清单',
              'https://m.bbs.mihoyo.com/ys/?type=noHeader&type=inApp#/agreement?type=collection',
            ));
        break;
      case '第三方共享个人信息清单':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '第三方共享个人信息清单',
              'https://m.bbs.mihoyo.com/ys/?type=noHeader&type=inApp#/agreement?type=sdk',
            ));
        break;
      case '退出登录':
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', '');
        NavRouter.open(LoginPage.tag);
        break;
    }
  }

  Widget divider() {
    return SizedBox(
      height: 8,
      child: Container(
        color: Color.fromRGBO(241, 241, 241, 1),
      ),
    );
  }

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
            '设置',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: ListView(
            controller: new ScrollController(keepScrollOffset: false),
            children: ListTile.divideTiles(context: context, tiles: [
              divider(),
              ListTile(
                  title: Text('账号与安全'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.pushNamed(context, AccountSettingPage.tag)
                        .then((value) => init());
                  }),
              Visibility(
                visible: user['role'].toString() == 'normal',
                child: ListTile(
                    title: Text('医生认证'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorInformationPage(
                                    doctor: {},
                                  ))).then((value) => init());
                    }),
              ),
              Visibility(
                  visible: user['role'].toString() == 'doctor',
                  child: ListTile(
                      title: Text('医生主页'),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DoctorHomePage(
                                      account: user['account'],
                                      edit: true,
                                    )));
                      })),
              Visibility(
                  visible: user['role'].toString() == 'root',
                  child: ListTile(
                      title: Text('管理后台'),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManagePage(
                                      user: user,
                                    )));
                      })),
              divider(),
              ListTile(
                  title: Text('关于Sakura'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('关于');
                  }),
              ListTile(
                  title: Text('清除缓存'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('清除缓存');
                  }),
              ListTile(
                  title: Text('意见反馈'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('意见反馈');
                  }),
              ListTile(
                  title: Text('检查更新'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('检查更新');
                  }),
              divider(),
              ListTile(
                  title: Text('个人信息收集清单'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('个人信息收集清单');
                  }),
              ListTile(
                  title: Text('第三方共享个人信息清单'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    handleClick('第三方共享个人信息清单');
                  }),
              divider(),
              ListTile(
                  title: Center(
                    child: const Text(
                      '退出登录',
                    ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('提示'),
                            content: Text('您确定要退出登录吗？'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('取消'),
                                onPressed: () {
                                  NavRouter.pop();
                                },
                              ),
                              TextButton(
                                child: Text('确认'),
                                onPressed: () {
                                  handleClick('退出登录');
                                },
                              ),
                            ],
                          );
                        });
                  }),
              divider(),
            ]).toList()));
  }
}
