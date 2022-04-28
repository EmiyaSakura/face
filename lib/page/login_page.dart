import 'package:face/page/forget_page.dart';
import 'package:face/page/manage_page.dart';
import 'package:face/page/register_page.dart';
import 'package:face/page/webView_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/iconTextFormField.dart';
import 'home_page.dart';

//登录界面
class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> animation;

  // 用户协议同意标识
  bool agree = false;

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
    });
    animation = Tween(begin: Offset.zero, end: const Offset(0.1, 0))
        .animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // 处理点击事件
  handleClick(type) async {
    switch (type) {
      case '登录':
        if (agree || kIsWeb) {
          if (formKey.currentState!.validate()) {
            var res = await Http().post('/universal/login', {
              'account': accountController.text,
              'password': pwdController.text,
            });
            if (res['code'] == 200) {
              final prefs = await SharedPreferences.getInstance();
              if (await prefs.setString('token', res['info']['token'])) {
                //点击跳转界面
                if (res['info']['role'] == 'root') {
                  if (kIsWeb) {
                    NavRouter.open(ManagePage.tag);
                  } else {
                    Toaster().show('管理员请使用web登录');
                  }
                } else {
                  NavRouter.open(HomePage.tag);
                }
              }
            } else {
              Toaster().show(res['message']);
            }
          }
        } else {
          animationController.forward();
        }
        break;
      case '注册':
        NavRouter.push(RegisterPage.tag);
        break;
      case '忘记密码':
        NavRouter.push(ForgetPage.tag);
        break;
      case '用户协议':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '用户使用守则与服务协议',
              'https://user.mihoyo.com/#/agreement?hideBack=true',
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
            ),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(
                      flex: 4,
                    ),
                    Image.asset("title.png"), //图片
                    const Spacer(),
                    IconTextFormField(
                      //用户名
                      keyboardType: TextInputType.emailAddress,
                      controller: accountController,
                      hintText: kIsWeb ? '请输入管理员账号' : '请输入账号或邮箱',
                      clear: true,
                      style: const TextStyle(fontSize: 18),
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? '账号或邮箱不能为空'
                            : null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    IconTextFormField(
                      //密码
                      controller: pwdController,
                      hintText: '请输入密码',
                      obscureText: true,
                      show: true,
                      clear: true,
                      style: const TextStyle(fontSize: 18),
                      validator: (value) {
                        return value == null || value.isEmpty ? '密码不能为空' : null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Visibility(
                        visible: !kIsWeb,
                        child: SlideTransition(
                          position: animation,
                          //将要执行动画的子view
                          child: Row(children: [
                            Checkbox(
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = !agree;
                                });
                              },
                            ),
                            const Text('已阅读并同意'),
                            TextButton(
                              child: const Text(
                                '<<用户使用守则与服务协议>>',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                handleClick('用户协议');
                              },
                            )
                          ]),
                        )),
                    const Spacer(),
                    MaterialButton(
                      minWidth: 180.0,
                      height: 42.0,
                      onPressed: () {
                        handleClick('登录');
                      },
                      color: Colors.green,
                      //按钮颜色
                      child: const Text(
                        '登  录',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    const Spacer(
                      flex: 4,
                    ),
                    Visibility(
                        visible: !kIsWeb,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              child: const Text(
                                '忘记密码',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 18.0),
                              ),
                              onPressed: () {
                                handleClick('忘记密码');
                              },
                            ),
                            TextButton(
                              child: const Text(
                                '注册新账号',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 18.0),
                              ),
                              onPressed: () {
                                handleClick('注册');
                              },
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
