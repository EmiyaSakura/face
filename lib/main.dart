import 'package:face/page/about_page.dart';
import 'package:face/page/account_setting_page.dart';
import 'package:face/page/forget_page.dart';
import 'package:face/page/home_page.dart';
import 'package:face/page/hospital_service_page.dart';
import 'package:face/page/login_page.dart';
import 'package:face/page/manage_page.dart';
import 'package:face/page/mine_appointment_page.dart';
import 'package:face/page/notice_setting_page.dart';
import 'package:face/page/register_page.dart';
import 'package:face/page/setting_page.dart';
import 'package:face/page/webView_page.dart';
import 'package:face/util/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  //routes需要Map<String, WidgetBuilder>类型参数，所以这里定义了一个这个类型的常量，将刚才两个页面添加进去
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    ManagePage.tag: (context) => ManagePage(),
    HomePage.tag: (context) => HomePage(),
    RegisterPage.tag: (context) => RegisterPage(),
    ForgetPage.tag: (context) => ForgetPage(),
    WebViewPage.tag: (context) => WebViewPage(),
    SettingPage.tag: (context) => SettingPage(),
    AccountSettingPage.tag: (context) => AccountSettingPage(),
    NoticeSettingPage.tag: (context) => NoticeSettingPage(),
    AboutPage.tag: (context) => AboutPage(),
    HospitalServicePage.tag: (context) => HospitalServicePage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakura',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavRouter.navGK,
      // 设置navigatorKey
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: kIsWeb ? ManagePage() : HomePage(),
      routes: routes,
    );
  }
}
