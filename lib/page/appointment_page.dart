import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/toast.dart';
import 'doctor_home_page.dart';
import 'evaluation_page.dart';
import 'information_page.dart';

class AppointmentPage extends StatefulWidget {
  final code;
  final doctor;
  final hCode;
  final dCode;
  final avatar;
  final name;
  final level;
  final hLevel;
  final hospital;
  final department;
  final fee;
  final String type;
  final date;
  final material;
  final evaluation;

  const AppointmentPage(
      {Key? key,
      this.doctor = '',
      this.fee,
      this.hospital,
      this.department,
      this.avatar,
      this.name,
      this.level,
      this.hLevel,
      required this.type,
      this.date,
      this.hCode,
      this.dCode,
      this.material,
      this.code = '',
      this.evaluation})
      : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  var material = {};
  var materialCode = '';
  var evaluationCode = '';
  var date;
  var time;
  List dateList = [];
  List departmentList = [];
  var department = '';

  init() async {
    if (widget.type != 'new') {
      var res =
          await Http().post('/normal/getMaterial', {'code': widget.material});
      setState(() {
        material = res['info'];
        materialCode = material['code'];
      });
    }
    if (widget.type == 'new' && widget.doctor == '') {
      var res = await Http()
          .post('/normal/findHospitalDepartment', {'hospital': widget.hCode});
      if ((res['info'] as List).length == 0) {
        Toaster().show('当前医院暂无可选科室');
      } else {
        setState(() {
          departmentList = res['info'];
          department = departmentList[0]['code'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    evaluationCode = widget.evaluation ?? '';
    DateTime now = DateTime.now();
    dateList = [];
    for (var i = 0; i < 7; i++) {
      dateList.add(now.add(Duration(days: i)).toString().substring(0, 10));
    }
    date = dateList[0];
    time = now.hour < 14 ? '08:00:00' : '14:00:00';
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
            '预约挂号',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            Visibility(
                visible: widget.type == 'edit',
                child: TextButton(
                  onPressed: () async {
                    await Http().post('/normal/updateMaterial', material);
                    NavRouter.pop();
                  },
                  child: Text(
                    '保存',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
            Visibility(
                visible: widget.type == 'read' && widget.doctor != '',
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EvaluationPage(
                                  doctor: widget.doctor,
                                  evaluationCode: evaluationCode,
                                  appointmentCode: widget.code,
                                ))).then((value) {
                      if (value != null) {
                        setState(() {
                          evaluationCode = value;
                        });
                      }
                    });
                  },
                  child: Text(
                    '评价',
                    style: TextStyle(fontSize: 16),
                  ),
                ))
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
                      controller: new ScrollController(keepScrollOffset: false),
                      shrinkWrap: true,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: widget.doctor == ''
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            widget.hospital,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Visibility(
                                              visible: widget.type != 'new',
                                              child: Text(
                                                  widget.department ?? '',
                                                  style:
                                                      TextStyle(fontSize: 18)))
                                        ],
                                      ),
                                      Visibility(
                                          visible: widget.type == 'new',
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 36),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text('科室:'),
                                                ),
                                                Expanded(
                                                    flex: 4,
                                                    child: DropdownButton(
                                                      items: departmentList
                                                          .map((e) =>
                                                              DropdownMenuItem(
                                                                  child: Text(e[
                                                                          'name']
                                                                      .toString()),
                                                                  value: e[
                                                                      'code']))
                                                          .toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          department =
                                                              value.toString();
                                                        });
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      isExpanded: true,
                                                      value: department,
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ))
                                              ],
                                            ),
                                          ))
                                    ],
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (widget.type != 'new') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DoctorHomePage(
                                                      account: widget.doctor,
                                                    )));
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                                border: new Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      widget.avatar),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  widget.name,
                                                  style:
                                                      TextStyle(fontSize: 22),
                                                ),
                                                Text(widget.level),
                                                Text(widget.department)
                                              ],
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(widget.hospital),
                                                Text(widget.hLevel)
                                              ],
                                            )
                                          ],
                                        ))
                                      ],
                                    ),
                                  )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: widget.type == 'new'
                              ? Row(
                                  children: [
                                    Text('预约日期:  '),
                                    Expanded(
                                        child: DropdownButton(
                                      items: dateList
                                          .map((e) => DropdownMenuItem(
                                                child: Text(e),
                                                value: e,
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          date = value.toString();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      isExpanded: true,
                                      value: date,
                                      style: TextStyle(color: Colors.green),
                                    )),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text('预约时间:  '),
                                    Expanded(
                                        child: DropdownButton(
                                      items: [
                                        DropdownMenuItem(
                                          child: Text('08:00:00'),
                                          value: '08:00:00',
                                        ),
                                        DropdownMenuItem(
                                          child: Text('14:00:00'),
                                          value: '14:00:00',
                                        )
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          time = value.toString();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      isExpanded: true,
                                      value: time,
                                      style: TextStyle(color: Colors.green),
                                    ))
                                  ],
                                )
                              : Text('预约日期  ' + widget.date),
                        ),
                        Visibility(
                          visible: widget.type != 'new',
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Text('预约单号 ' + widget.code),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    '患者资料',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  trailing: Visibility(
                                    visible: widget.type != 'read',
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InformationPage(
                                                            material:
                                                                material)))
                                            .then((value) {
                                          if (value != null) {
                                            setState(() {
                                              material = value;
                                              material['code'] = materialCode;
                                            });
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.launch),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                      '个人信息: ${material['name'] ?? '姓名'} ${material['sex'] ?? '年龄'} ${material['age'] ?? '0'}岁'),
                                ),
                                ListTile(
                                  title: Text(
                                      '病情描述: ${material['description'] ?? '暂无'}'),
                                ),
                                ListTile(
                                  title: Text(
                                      '过往是否有重大病史: ${material['medical'] ?? '暂无'}'),
                                ),
                                ListTile(
                                  title: Text(
                                      '健康码: ${material['health_code'] ?? '暂无'}'),
                                ),
                                ListTile(
                                  title: Text(
                                      '接触情况: ${material['contact'] ?? '暂无'}'),
                                ),
                                ListTile(
                                  title: Text(
                                      '确诊情况: ${material['diagnosed'] ?? '暂无'}'),
                                ),
                                ListTile(
                                  title: Text(
                                      '隔离情况: ${material['isolation'] ?? '暂无'}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
            Visibility(
                visible: widget.type == 'new',
                child: Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: MaterialButton(
                    minWidth: 180.0,
                    onPressed: () async {
                      if (widget.type == 'new' && department == '') {
                        Toaster().show('请选择科室');
                      } else if (material['name'] == null) {
                        Toaster().show('请完善患者信息');
                      } else {
                        var res = await Http()
                            .post('/normal/updateMaterial', material);
                        await Http().post('/normal/insertAppointment', {
                          'hospital': widget.hCode,
                          'department':
                              widget.type == 'new' ? department : widget.dCode,
                          'doctor': widget.doctor,
                          'date': '$date $time',
                          'material': res['material']
                        });
                        Http().post('/normal/insertChatTip',
                            {'chat': '预约成功通知：您于$date $time的挂号已成功预约'});
                        NavRouter.pop();
                      }
                    },
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    //按钮颜色
                    child: Text(
                      '立即支付￥' + (widget.fee ?? '0'),
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                ))
          ],
        ));
  }
}
