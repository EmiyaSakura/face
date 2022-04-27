import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
import 'package:left_scroll_actions/global/actionListener.dart';
import 'package:left_scroll_actions/leftScroll.dart';

import '../component/no_data.dart';
import '../util/http.dart';
import 'appointment_page.dart';

class MineAppointmentPage extends StatefulWidget {
  final currentView;

  const MineAppointmentPage({Key? key, this.currentView}) : super(key: key);

  @override
  _MineAppointmentPageState createState() => _MineAppointmentPageState();
}

class _MineAppointmentPageState extends State<MineAppointmentPage> {
  int currentView = 0;
  List reservingList = [];
  List reservedList = [];
  bool reverse = false;

  load() async {
    var res = await Http().get('/normal/getAppointment');
    setState(() {
      reservingList = res['info']['reserving'];
      reservedList = res['info']['reserved'];
    });
  }

  @override
  void initState() {
    super.initState();
    currentView = widget.currentView ?? 0;
    load();
  }

  List<Widget> listItem() {
    var list = [];
    if (currentView == 0) {
      list = reservingList;
    } else if (currentView == 1) {
      list = reservedList;
    }

    if (list.length == 0) {
      return NoData.instance();
    }
    return list
        .map((e) => Padding(
              padding: EdgeInsets.only(bottom: 24),
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
                                                : 'read'))).then((value) => load());
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
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            e['avatar'].toString()),
                                        radius: 32.0, // --> 半径越大，图片越大
                                      ),
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
                        ]),
            ))
        .toList();
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
            '我的预约',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  reverse = !reverse;
                });
              },
              icon: Icon(Icons.swap_vert),
            )
          ],
        ),
        body: Column(
          children: [
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
            Expanded(
                child: Container(
                    //列表内容少的时候靠上
                    alignment: Alignment.topCenter,
                    child: ListView(
                      shrinkWrap: true,
                      reverse: reverse,
                      controller: new ScrollController(keepScrollOffset: false),
                      children: listItem(),
                    )))
          ],
        ));
  }
}
