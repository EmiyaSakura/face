import 'package:bruno/bruno.dart';
import 'package:face/page/chat_page.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../component/no_data.dart';
import '../util/http.dart';
import 'appointment_page.dart';
import 'doctor_information_page.dart';

class DoctorHomePage extends StatefulWidget {
  final doctor;
  final account;
  final edit;

  const DoctorHomePage({Key? key, this.doctor, this.account, this.edit = false})
      : super(key: key);

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  var doctor = {};
  List evaluationList = [];

  init() async {
    var res =
        await Http().post('/normal/findEvaluation', {'doctor': widget.account});
    setState(() {
      evaluationList = res['info'];
    });
    if (widget.doctor == null) {
      res = await Http().post('/normal/getDoctor', {'account': widget.account});
      setState(() {
        doctor = res['info'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    doctor = widget.doctor ?? {};
    init();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(Color.fromRGBO(115, 178, 156, 1)),
      foregroundColor: MaterialStateProperty.all(Colors.white),
    );
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
            '医生详情',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            Visibility(
                visible: widget.edit,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DoctorInformationPage(
                                  doctor: doctor,
                                  edit: true,
                                ))).then((value) => init());
                  },
                  child: Text(
                    '更新信息',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Container(
                    //列表内容少的时候靠上
                    alignment: Alignment.topCenter,
                    child: ListView(
                      shrinkWrap: true,
                      controller: new ScrollController(keepScrollOffset: false),
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                    ),
                                    CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            doctor['avatar'].toString()),
                                        radius: 32.0),
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
                                              doctor['name'].toString(),
                                              style: TextStyle(fontSize: 22),
                                            ),
                                            Text(doctor['level'].toString()),
                                            Text(doctor['d_name'].toString())
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(doctor['h_name'].toString()),
                                            Text(doctor['h_level'].toString())
                                          ],
                                        )
                                      ],
                                    )),
                                    SizedBox(
                                      width: 24,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      doctor['count'].toString() + '\n问诊量',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          height: 1.5,
                                          color:
                                              Color.fromRGBO(115, 178, 156, 1)),
                                    ),
                                    Text(
                                      doctor['rate'].toString() + '\n回复率',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          height: 1.5,
                                          color:
                                              Color.fromRGBO(115, 178, 156, 1)),
                                    ),
                                    Text(
                                      doctor['avg_score'].toString() + '\n评分',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          height: 1.5,
                                          color:
                                              Color.fromRGBO(115, 178, 156, 1)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 12,
                          child: Container(
                            color: Color.fromRGBO(240, 242, 241, 1),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                                title: Text(
                              '主治',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(115, 178, 156, 1)),
                            )),
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: Text(
                                doctor['major'].toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            ListTile(
                                title: Text(
                              '简介',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(115, 178, 156, 1)),
                            )),
                            Padding(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                                child: Text(
                                  doctor['introduction'].toString(),
                                  style: TextStyle(fontSize: 18),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                          child: Container(
                            color: Color.fromRGBO(240, 242, 241, 1),
                          ),
                        ),
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                '评价(${evaluationList.length})',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromRGBO(115, 178, 156, 1)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Column(
                              children: evaluationList.length == 0
                                  ? NoData.instance()
                                  : evaluationList
                                      .map((e) => Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20, 0, 20, 10),
                                            child: Column(children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    e['name'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromRGBO(
                                                            115, 178, 156, 1)),
                                                  ),
                                                  BrnRatingStar(
                                                    selectedCount: double.parse(
                                                        e['score'].toString()),
                                                    space: 5,
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Text(
                                                    e['comment'].toString(),
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    e['createTime']
                                                        .toString()
                                                        .substring(0, 10),
                                                  )
                                                ],
                                              )
                                            ]),
                                          ))
                                      .toList(),
                            ),
                          ],
                        ),
                      ],
                    ))),
            Visibility(
                visible: !widget.edit,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AppointmentPage(
                                          doctor: doctor['account'],
                                          avatar: doctor['avatar'],
                                          name: doctor['name'],
                                          level: doctor['level'],
                                          hLevel: doctor['h_level'],
                                          hospital: doctor['h_name'],
                                          department: doctor['d_name'],
                                          fee: doctor['fee'],
                                          type: 'new',
                                        )));
                          },
                          child: Text('预约挂号￥' + (doctor['fee'].toString())),
                          style: buttonStyle),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                            account: widget.account,
                                          )));
                              Http().post('/normal/updateChatTip',
                                  {'chat': widget.account});
                            },
                            child: Text('在线咨询'),
                            style: buttonStyle))
                  ]),
                ))
          ],
        ));
  }
}
