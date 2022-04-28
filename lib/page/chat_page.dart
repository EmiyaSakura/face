import 'dart:async';
import 'dart:io';

import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../component/iconTextFormField.dart';
import '../util/http.dart';
import 'cropping_page.dart';
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

  TextEditingController contentController = TextEditingController();

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
                                        e['type'].toString() == 'image'
                                            ? ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 150,
                                                    maxHeight: 400),
                                                child: Image.network(
                                                    e['content'].toString()))
                                            : Container(
                                                margin:
                                                    EdgeInsets.only(left: 24),
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 6, 10, 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Text(
                                                  e['content'],
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
                                    Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                new BorderRadius.circular(10),
                                            image: user['avatar'].toString() ==
                                                    ''
                                                ? DecorationImage(
                                                    image:
                                                        AssetImage('error.png'),
                                                    fit: BoxFit.fill,
                                                  )
                                                : DecorationImage(
                                                    image: NetworkImage(
                                                        user['avatar']),
                                                    fit: BoxFit.fill,
                                                  ))),
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
                                      child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                              border: new Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                              borderRadius:
                                                  new BorderRadius.circular(10),
                                              image:
                                                  chat['avatar'].toString() ==
                                                          ''
                                                      ? DecorationImage(
                                                          image: AssetImage(
                                                              'error.png'),
                                                          fit: BoxFit.fill,
                                                        )
                                                      : DecorationImage(
                                                          image: NetworkImage(
                                                              chat['avatar']),
                                                          fit: BoxFit.fill,
                                                        ))),
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
                                        e['type'].toString() == 'image'
                                            ? ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 150,
                                                    maxHeight: 400),
                                                child: Image.network(
                                                    e['content'].toString()))
                                            : Container(
                                                margin:
                                                    EdgeInsets.only(right: 24),
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 6, 10, 10),
                                                decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        237, 212, 212, 1.0),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Text(
                                                  e['content'],
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
                        onPressed: () async {
                          XFile? file = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (file != null) {
                            File image = File(file.path);
                            var name = user['account'] +
                                '-chat-' +
                                basename(image.path);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CroppingPage(
                                          image: image,
                                          name: name,
                                          square: false,
                                        ))).then((value) async {
                              if (value != null) {
                                var res = await Http().post(
                                    '/normal/insertChat', {
                                  'to_chat': widget.account,
                                  'type': 'image',
                                  'content': value
                                });
                                if (res['code'] == 200) {
                                  load();
                                }
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.satellite)),
                    Expanded(
                        child: IconTextFormField(
                      controller: contentController,
                      clear: true,
                      radius: 32.0,
                      suffixButton: ElevatedButton(
                          onPressed: () async {
                            if (contentController.text != '') {
                              var res = await Http().post(
                                  '/normal/insertChat', {
                                'to_chat': widget.account,
                                'type': 'text',
                                'content': contentController.text
                              });
                              if (res['code'] == 200) {
                                contentController.text = '';
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
