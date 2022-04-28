import 'package:face/page/about_page.dart';
import 'package:face/page/mine_appointment_page.dart';
import 'package:face/page/setting_page.dart';
import 'package:face/page/webView_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
import 'package:left_scroll_actions/global/actionListener.dart';
import 'package:left_scroll_actions/leftScroll.dart';

import '../page/appointment_page.dart';
import '../page/hospital_service_page.dart';
import '../page/user_setting_page.dart';
import 'no_data.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  var user = {};
  int currentView = 0;
  List reservingList = [];
  List reservedList = [];
  List hospitalList = [];

  init() async {
    var res = await Http().get('/normal/getUser');
    setState(() {
      user = res['info'];
    });
  }

  load() async {
    var res = await Http().get('/normal/getAppointment');
    setState(() {
      reservingList = res['info']['reserving'];
      reservedList = res['info']['reserved'];
    });
  }

  loadHospital() async {
    var res = await Http().get('/normal/findHospital');
    setState(() {
      hospitalList = res['info'];
      hospitalList =
          hospitalList.length > 2 ? hospitalList.sublist(0, 2) : hospitalList;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    init();
    load();
    loadHospital();
  }

  // 处理点击事件
  handleClick(type) async {
    switch (type) {
      case '设置':
        Navigator.pushNamed(context, SettingPage.tag).then((value) => init());
        break;
      case '用户协议':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '用户使用守则与服务协议',
              'https://user.mihoyo.com/#/agreement?hideBack=true',
            ));
        break;
      case '意见反馈':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              '意见反馈',
              'https://www.acy.moe/api/404',
            ));
        break;
      case '关于':
        NavRouter.push(AboutPage.tag);
        break;
    }
  }

  Widget mineCard() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserSettingPage(
                                      user: user,
                                      type: '头像',
                                    ))).then((value) => init());
                      },
                      child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              border:
                                  new Border.all(color: Colors.white, width: 1),
                              borderRadius: new BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(user['avatar'].toString()),
                                fit: BoxFit.fill,
                              ))),
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nick_name'].toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                          Visibility(
                              visible: user['role'].toString() == 'doctor',
                              child: Text(
                                  user['name'].toString() +
                                      '  ' +
                                      user['level'].toString(),
                                  style: TextStyle(height: 1.5)))
                        ]),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    handleClick('设置');
                  },
                  child: const Text(
                    '设置',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('账号 ' + user['account'].toString()),
                )
              ],
            )
          ],
        ));
  }

  List<Widget> listItem() {
    var list = [];
    if (currentView == 0) {
      list = reservingList.length > 2
          ? reservingList.sublist(0, 2)
          : reservingList;
    } else if (currentView == 1) {
      list =
          reservedList.length > 2 ? reservedList.sublist(0, 2) : reservedList;
    }

    if (list.length == 0) {
      return NoData.instance();
    }
    return list
        .map((e) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CupertinoLeftScroll(
                key: Key(e['code'].toString()),
                closeTag: LeftScrollCloseTag('appointment'),
                buttonWidth: 80,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
                    child: e['doctor'].toString() == ''
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AppointmentPage(
                                          code: e['code'],
                                          hCode: e['h_code'],
                                          dCode: e['d_code'],
                                          hospital: e['h_name'],
                                          department: e['d_name'],
                                          date: e['date'],
                                          material: e['material'],
                                          type: (currentView == 0
                                              ? 'edit'
                                              : 'read'))));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('预约单号 ' + e['code'].toString()),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e['h_name'].toString(),
                                        style: TextStyle(fontSize: 18)),
                                    Text(e['d_name'].toString(),
                                        style: TextStyle(fontSize: 18))
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e['date'].toString()),
                                    Text(
                                      '￥' + e['fee'].toString(),
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                )
                              ],
                            ))
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AppointmentPage(
                                              code: e['code'],
                                              doctor: e['doctor'],
                                              avatar: e['avatar'],
                                              name: e['name'],
                                              level: e['level'],
                                              hLevel: e['h_level'],
                                              hospital: e['h_name'],
                                              department: e['d_name'],
                                              date: e['date'],
                                              material: e['material'],
                                              evaluation: e['evaluation'],
                                              type: currentView == 0
                                                  ? 'edit'
                                                  : 'read')))
                                  .then((value) => load());
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('预约单号 ' + e['code'].toString()),
                                SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                new BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  e['avatar'].toString()),
                                              fit: BoxFit.fill,
                                            ))),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              e['name'].toString(),
                                              style: TextStyle(fontSize: 22),
                                            ),
                                            Text(e['level'].toString()),
                                            Text(e['d_name'].toString())
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(e['h_name'].toString()),
                                            Text(e['h_level'].toString())
                                          ],
                                        )
                                      ],
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e['date'].toString()),
                                    Text(
                                      '￥' + e['fee'].toString(),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                )
                              ],
                            ))),
                buttons: currentView == 0
                    ? [
                        LeftScrollItem(
                          text: '申请退款',
                          color: Colors.green,
                          onTap: () async {
                            await Http().post('/normal/deleteAppointment',
                                {'code': e['code']});
                            load();
                          },
                        ),
                      ]
                    : [
                        LeftScrollItem(
                          text: '删除',
                          color: Colors.red,
                          onTap: () async {
                            await Http().post('/normal/deleteAppointment',
                                {'code': e['code']});
                            load();
                          },
                        ),
                      ])))
        .toList();
  }

  Widget appointmentCard() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '我的预约',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(115, 178, 156, 1)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MineAppointmentPage(
                                      currentView: currentView,
                                    )));
                      },
                      child: Text('查看全部>'),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ]),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          currentView = 0;
                        });
                      },
                      child: Text(
                        '预约中',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                currentView == 0 ? Colors.green : Colors.black),
                      )),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          currentView = 1;
                        });
                      },
                      child: Text(
                        '已完成',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                currentView == 1 ? Colors.green : Colors.black),
                      )),
                )
              ],
            ),
            Column(
              children: listItem(),
            )
          ],
        ));
  }

  Widget hospitalCard() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '医院服务',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(115, 178, 156, 1)),
                    ),
                    TextButton(
                      onPressed: () {
                        NavRouter.push(HospitalServicePage.tag);
                      },
                      child: Text('更多>'),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                  children: hospitalList
                      .map((e) => ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e['name'].toString()),
                                Text(e['level'].toString())
                              ],
                            ),
                            trailing: Text(
                              '预约挂号￥' + e['fee'].toString(),
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AppointmentPage(
                                            hCode: e['code'],
                                            hospital: e['name'],
                                            fee: e['fee'],
                                            type: 'new',
                                          ))).then((value) => load());
                            },
                          ))
                      .toList()),
            )
          ],
        ));
  }

  Widget moreCard() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  handleClick('用户协议');
                },
                child: const Text('相关协议')),
            const Text('|'),
            TextButton(
                onPressed: () {
                  handleClick('意见反馈');
                },
                child: const Text('意见反馈')),
            const Text('|'),
            TextButton(
                onPressed: () {
                  handleClick('关于');
                },
                child: const Text('关于我们'))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      controller: new ScrollController(keepScrollOffset: false),
      children: [
        mineCard(),
        SizedBox(
          height: 12,
          child: Container(
            color: Color.fromRGBO(240, 242, 241, 1),
          ),
        ),
        appointmentCard(),
        SizedBox(
          height: 12,
          child: Container(
            color: Color.fromRGBO(240, 242, 241, 1),
          ),
        ),
        hospitalCard(),
        SizedBox(
          height: 12,
          child: Container(
            color: Color.fromRGBO(240, 242, 241, 1),
          ),
        ),
        moreCard()
      ],
    );
  }
}
