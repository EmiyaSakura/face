import 'dart:async';

import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/iconTextFormField.dart';
import '../util/http.dart';
import 'login_page.dart';

class UserSettingPage extends StatefulWidget {
  final user;
  final type;

  const UserSettingPage({Key? key, this.user, this.type}) : super(key: key);

  @override
  _UserSettingPageState createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  late Timer timer = Timer(const Duration(), () => {});

  var countdownTime = 0;

  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController surePwdController = TextEditingController();
  TextEditingController validController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user['nick_name'] ?? '';
    emailController.text = widget.user['email'] ?? '';
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
            widget.type,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Visibility(
                visible: widget.type == '昵称',
                child: TextButton(
                  onPressed: () async {
                    if (nameController.text == '') {
                      Toaster().show('请填写昵称');
                    } else {
                      await Http().post('/normal/updateNickName',
                          {'name': nameController.text});
                      NavRouter.pop();
                    }
                  },
                  child: Text(
                    '保存',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
            Visibility(
                visible: widget.type == '邮箱',
                child: TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      var res = await Http().post('/normal/updateEmail', {
                        'email': emailController.text,
                        'code': validController.text,
                      });
                      if (res['code'] == 200) {
                        NavRouter.pop();
                      } else {
                        Toaster().show(res['message']);
                      }
                    }
                  },
                  child: Text(
                    '更换邮箱',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
            Visibility(
                visible: widget.type == '密码',
                child: TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      var res = await Http().post('/normal/updatePassword', {
                        'password': passwordController.text,
                        'pwd': pwdController.text,
                      });
                      if (res['code'] == 200) {
                        Toaster().show('修改成功，请重新登录');
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('token', '');
                        NavRouter.open(LoginPage.tag);
                      } else {
                        Toaster().show(res['message']);
                      }
                    }
                  },
                  child: Text(
                    '修改密码',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Visibility(
                  visible: widget.type == '昵称',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      IconTextFormField(
                        controller: nameController,
                        labelText: '真实姓名',
                        clear: true,
                        validator: (value) {
                          return value == null || value.isEmpty
                              ? '真实姓名不能为空'
                              : null;
                        },
                      )
                    ],
                  )),
              Visibility(
                  visible: widget.type == '邮箱',
                  child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          IconTextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              hintText: '请输入邮箱',
                              labelText: '邮箱',
                              //提示内容
                              clear: true,
                              validator: (value) {
                                if (value != null &&
                                    RegExp(r'^[a-z0-9A-Z]+[-|a-z0-9A-Z._]+@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\.)+[a-z]{2,}$')
                                        .hasMatch(value)) {
                                  return null;
                                } else {
                                  return '邮箱格式不合法';
                                }
                              }),
                          SizedBox(height: 12),
                          Row(children: <Widget>[
                            Expanded(
                                flex: 3,
                                child: IconTextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: validController,
                                  hintText: '请输入验证码',
                                  labelText: '验证码',
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
                                              bottomRight:
                                                  Radius.circular(26.0),
                                              topRight:
                                                  Radius.circular(26.0)))),
                                ),
                                child: Text(
                                  countdownTime > 0
                                      ? '${countdownTime}s'
                                      : '获取验证码',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                onPressed: () async {
                                  if (emailController.text ==
                                      widget.user['email'].toString()) {
                                    Toaster().show('此邮箱与当前账户的邮箱一致，请更换');
                                    return;
                                  }
                                  var msg = '邮箱格式不合法';
                                  if (emailController.selection.isValid) {
                                    var res = await Http().post(
                                        '/universal/verify',
                                        {'email': emailController.text});
                                    msg = res['message'];
                                    if (countdownTime == 0) {
                                      // 倒计时
                                      countdownTime = 60;
                                      timer = Timer.periodic(
                                          const Duration(seconds: 1), (_timer) {
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
                                },
                              ),
                            )
                          ]),
                        ],
                      ))),
              Visibility(
                  visible: widget.type == '密码',
                  child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          IconTextFormField(
                            controller: passwordController,
                            hintText: '请输入旧密码',
                            labelText: '旧密码',
                            obscureText: true,
                            show: true,
                            clear: true,
                            validator: (value) {
                              return value == null || value.isEmpty
                                  ? '旧密码不能为空'
                                  : null;
                            },
                          ),
                          SizedBox(height: 12),
                          IconTextFormField(
                              controller: pwdController,
                              hintText: '请输入新密码',
                              labelText: '新密码',
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
                                  if (RegExp(r'[0-9]').hasMatch(value)) {
                                    count++;
                                  }
                                  if (count < 2) {
                                    return '密码因包含大小写字母、数字中的两种及以上';
                                  }
                                }
                                return null;
                              }),
                          SizedBox(height: 12),
                          IconTextFormField(
                              controller: surePwdController,
                              hintText: '请确认新密码',
                              labelText: '确认密码',
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
                        ],
                      )))
            ],
          ),
        ));
  }
}
