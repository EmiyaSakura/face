import 'dart:async';

import 'package:face/page/login_page.dart';
import 'package:face/page/webView_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../component/iconTextFormField.dart';

//注册界面
class RegisterPage extends StatefulWidget {
  static String tag = 'register-page';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> animation;
  late Timer timer = Timer(const Duration(), () => {});

  //倒计时数值
  var countdownTime = 0;

  // 用户协议同意标识
  bool agree = false;

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController surePwdController = TextEditingController();
  TextEditingController validController = TextEditingController();

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
    timer.cancel();
    super.dispose();
  }

  // 处理点击事件
  handleClick(type) async {
    switch (type) {
      case '获取验证码':
        var msg = '邮箱格式不合法';
        if (emailController.selection.isValid) {
          var res = await Http()
              .post('/universal/verify', {'email': emailController.text});
          msg = res['message'];
          if (countdownTime == 0) {
            // 倒计时
            countdownTime = 60;
            timer = Timer.periodic(const Duration(seconds: 1), (_timer) {
              setState(() {
                if (countdownTime < 1) {
                  _timer.cancel();
                } else {
                  countdownTime -= 1;
                }
              });
            });
          }
        }
        Toaster().show(msg);
        break;
      case '注册':
        if (agree) {
          if (formKey.currentState!.validate()) {
            var res = await Http().post('/universal/register', {
              'email': emailController.text,
              'password': pwdController.text,
              'code': validController.text
            });
            if (res['code'] == 200) {
              NavRouter.push(LoginPage.tag);
            }
            Toaster().show(res['message']);
          }
        } else {
          animationController.forward();
        }
        break;
      case '返回登录':
        NavRouter.pop();
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
      body: SafeArea(
        child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Center(
              child: ListView(
                  shrinkWrap: true,
                  controller: new ScrollController(keepScrollOffset: false),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 50,
                          onPressed: () {
                            handleClick('返回登录');
                          },
                        ),
                        Image.asset("title.png"), //图片
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    IconTextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      hintText: '请输入邮箱',
                      //提示内容
                      clear: true,
                      validator: (value) {
                        if (value != null &&
                            RegExp(r'^[a-z\dA-Z]+[-|a-z\dA-Z._]+@([a-z\dA-Z]+(-[a-z\dA-Z]+)?\.)+[a-z]{2,}$')
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return '邮箱格式不合法';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: IconTextFormField(
                              keyboardType: TextInputType.number,
                              controller: validController,
                              hintText: '请输入验证码',
                              clear: true,
                              leftOnly: true,
                              validator: (value) {
                                return value == null || value.isEmpty
                                    ? '验证码不能为空'
                                    : null;
                              },
                            )),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(15)),
                              shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(26.0),
                                          topRight: Radius.circular(26.0)))),
                            ),
                            child: Text(
                              countdownTime > 0 ? '${countdownTime}s' : '获取验证码',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              handleClick('获取验证码');
                            },
                          ),
                        )
                      ],
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
                      validator: (value) {
                        if (value == null) return null;
                        if (value.length < 8 || value.length > 16) {
                          return '密码的长度应在8至16位';
                        } else {
                          var count = 0;
                          if (RegExp(r'[a-z]').hasMatch(value)) {
                            count++;
                          }
                          if (RegExp(r'[A-Z]').hasMatch(value)) {
                            count++;
                          }
                          if (RegExp(r'\d').hasMatch(value)) {
                            count++;
                          }
                          if (count < 2) {
                            return '密码因包含大小写字母、数字中的两种及以上';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    IconTextFormField(
                        controller: surePwdController,
                        hintText: '请确认密码',
                        obscureText: true,
                        show: true,
                        clear: true,
                        validator: (value) {
                          if (value != pwdController.text) {
                            return '确认密码因与密码一致';
                          } else {
                            return null;
                          }
                        }),
                    SlideTransition(
                      position: animation,
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
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    OutlinedButton(
                      child: const Text(
                        '注  册',
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 100)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                        side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.blue, width: 1)),
                      ),
                      onPressed: () {
                        handleClick('注册');
                      },
                    ),
                  ]),
            )),
      ),
    );
  }
}
