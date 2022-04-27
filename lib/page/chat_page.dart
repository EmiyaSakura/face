import 'dart:async';

import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../component/iconTextFormField.dart';
import '../util/http.dart';
import 'doctor_home_page.dart';

class ChatPage extends StatefulWidget {
  final String account;

  const ChatPage({Key? key, required this.account}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var user = {};
  var chat = {};
  var chats = [];
  late Timer timer;

  TextEditingController infoController = TextEditingController();

  init() async {
    var u = await Http().get('/normal/getUser');
    var c;
    if (u['info']['role'] == 'doctor') {
      c = await Http().post('/normal/findUser', {'account': widget.account});
    } else {
      c = await Http().post('/normal/getDoctor', {'account': widget.account});
    }
    setState(() {
      user = u['info'];
      chat = c['info'];
    });
    load();
  }

  load() async {
    var res = await Http().post('/normal/findChat', {'chat': widget.account});
    setState(() {
      chats = res['info'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => load());
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
          centerTitle: false,
          // 标题居中
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                NavRouter.pop();
              },
              icon: Icon(Icons.arrow_back)),
          title: Text(
            '咨询',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Container(
                    //列表内容少的时候靠上
                    alignment: Alignment.topCenter,
                    child: ListView(
                      reverse: true,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      controller: new ScrollController(keepScrollOffset: false),
                      children: chats
                          .map((e) => e['from_chat'] == user['account']
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(user['nick_name'].toString()),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 24),
                                          padding: EdgeInsets.fromLTRB(
                                              10, 6, 10, 10),
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Text(
                                            e['info'],
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                height: 1.5),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(e['createTime'].toString()),
                                        SizedBox(
                                          height: 12,
                                        ),
                                      ],
                                    )),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            user['avatar'].toString()),
                                        radius: 22.0),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (user['role'] == 'normal') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DoctorHomePage(
                                                        account:
                                                            chat['account'],
                                                      )));
                                        }
                                      },
                                      child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              chat['avatar'].toString()),
                                          radius: 22.0),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(chat['name'].toString()),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 24),
                                          padding: EdgeInsets.fromLTRB(
                                              10, 6, 10, 10),
                                          decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  237, 212, 212, 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Text(
                                            e['info'],
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                height: 1.5),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(e['createTime'].toString()),
                                        SizedBox(
                                          height: 12,
                                        ),
                                      ],
                                    )),
                                  ],
                                ))
                          .toList(),
                    ))),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Icons.satellite)),
                    Expanded(
                        child: IconTextFormField(
                      controller: infoController,
                      clear: true,
                      radius: 32.0,
                      suffixButton: ElevatedButton(
                          onPressed: () async {
                            if (infoController.text != '') {
                              var res = await Http().post(
                                  '/normal/insertChat', {
                                'to_chat': widget.account,
                                'type': 'text',
                                'info': infoController.text
                              });
                              if (res['code'] == 200) {
                                infoController.text = '';
                                load();
                              }
                            }
                          },
                          child: Text('发送'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32))),
                          )),
                    )),
                  ],
                )),
          ],
        ));
  }
}
