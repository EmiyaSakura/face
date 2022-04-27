import 'package:face/component/no_data.dart';
import 'package:face/page/notice_setting_page.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
import 'package:left_scroll_actions/global/actionListener.dart';
import 'package:left_scroll_actions/leftScroll.dart';

import '../page/chat_page.dart';
import '../util/http.dart';

class AskPage extends StatefulWidget {
  const AskPage({Key? key}) : super(key: key);

  @override
  _AskPageState createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> with AutomaticKeepAliveClientMixin {
  int currentView = 0;
  var user = {};
  var normalList = [];
  var doctorList = [];
  var systemList = [];

  init() async {
    var res = await Http().get('/normal/getUser');
    setState(() {
      user = res['info'];
    });
  }

  load() async {
    var res = await Http().get('/normal/findChatTip');
    setState(() {
      normalList = res['info']['normal'];
      doctorList = res['info']['doctor'];
      systemList = res['info']['system'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    load();
  }

  @override
  bool get wantKeepAlive => false;

  List<Widget> listItem() {
    var list = [];
    if (currentView == 0) {
      list = normalList;
    } else if (currentView == 1) {
      list = doctorList;
    } else if (currentView == 2) {
      list = systemList;
    }

    if (list.length == 0) {
      return NoData.instance();
    }
    return list
        .map((e) => CupertinoLeftScroll(
              key: Key(e['code'].toString()),
              closeTag: LeftScrollCloseTag('chatTip'),
              buttonWidth: 80,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                  child: currentView == 2
                      ? Text(
                          e['chat'].toString(),
                          style: TextStyle(fontSize: 16, height: 1.5),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          account: e['chat'],
                                        )));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(e['avatar'].toString()),
                                  radius: 22.0),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                e['name'].toString(),
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        )),
              buttons: <Widget>[
                LeftScrollItem(
                  text: '删除',
                  color: Colors.red,
                  onTap: () async {
                    await Http()
                        .post('/normal/deleteChatTip', {'code': e['code']});
                    load();
                  },
                ),
              ],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonBar(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            currentView = 0;
                          });
                        },
                        child: Text(
                          '消息',
                          style: TextStyle(
                              fontSize: 16,
                              color: currentView == 0
                                  ? Colors.green
                                  : Colors.black),
                        )),
                    Visibility(
                      visible: user['role'].toString() == 'doctor',
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              currentView = 1;
                            });
                          },
                          child: Text(
                            '咨询',
                            style: TextStyle(
                                fontSize: 16,
                                color: currentView == 1
                                    ? Colors.green
                                    : Colors.black),
                          )),
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            currentView = 2;
                          });
                        },
                        child: Text(
                          '系统',
                          style: TextStyle(
                              fontSize: 16,
                              color: currentView == 2
                                  ? Colors.green
                                  : Colors.black),
                        ))
                  ],
                ),
                IconButton(
                    onPressed: () {
                      NavRouter.push(NoticeSettingPage.tag);
                    },
                    icon: Icon(Icons.settings))
              ],
            )),
        Expanded(
          child: ListView(
            controller: new ScrollController(keepScrollOffset: false),
            children: listItem(),
          ),
        ),
      ],
    );
  }
}
