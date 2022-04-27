import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeSettingPage extends StatefulWidget {
  static String tag = 'notice-setting-page';

  const NoticeSettingPage({Key? key}) : super(key: key);

  @override
  _NoticeSettingPageState createState() => _NoticeSettingPageState();
}

class _NoticeSettingPageState extends State<NoticeSettingPage> {
  bool systemNotice = true;

  init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      systemNotice = prefs.getBool('systemNotice') ?? true;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
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
            '消息设置',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: SwitchListTile(
            title: Text("系统信息栏通知"),
            value: systemNotice,
            onChanged: (value) async {
              setState(() {
                systemNotice = value;
              });
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('systemNotice', value);
            }));
  }
}
