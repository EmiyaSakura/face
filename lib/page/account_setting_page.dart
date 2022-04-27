import 'package:face/page/user_setting_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountSettingPage extends StatefulWidget {
  static String tag = 'account-setting-page';

  const AccountSettingPage({Key? key}) : super(key: key);

  @override
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  var user = {};
  var emailSuffix = '';

  init() async {
    var res = await Http().get('/normal/getUser');
    setState(() {
      user = res['info'];
      emailSuffix = user['email'].toString().split('@')[1];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
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
            '账号与安全',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: ListView(
            controller: new ScrollController(keepScrollOffset: false),
            children: ListTile.divideTiles(context: context, tiles: [
              divider(),
              ListTile(
                title: Text('账号'),
                trailing: Text(user['account'].toString()),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('昵称'), Text(user['nick_name'].toString())],
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserSettingPage(
                                user: user,
                                type: '昵称',
                              ))).then((value) => init());
                },
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('邮箱'),
                    Text(user['email'].toString().substring(0, 3) +
                        '*****@' +
                        emailSuffix)
                  ],
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserSettingPage(
                            user: user,
                            type: '邮箱',
                          ))).then((value) => init());
                },
              ),
              divider(),
              ListTile(
                  title: Text(
                    '修改密码',
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserSettingPage(
                              user: user,
                              type: '密码',
                            ))).then((value) => init());
                  }),
              divider(),
            ]).toList()));
  }
}
