import 'package:bruno/bruno.dart';
import 'package:face/page/appointment_page.dart';
import 'package:face/page/doctor_home_page.dart';
import 'package:flutter/material.dart';

import '../page/chat_page.dart';
import '../util/http.dart';
import 'iconTextFormField.dart';
import 'no_data.dart';

class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage>
    with AutomaticKeepAliveClientMixin {
  var randomImg = 'https://api.ixiaowai.cn/gqapi/gqapi.php';

  // 表单标识
  final formKey = GlobalKey<FormState>();
  List departmentList = [];
  List doctorList = [];
  bool showDoctor = false;

  // 表单数据控制
  TextEditingController searchController = TextEditingController();

  init() async {
    var res = await Http().get('/normal/findDepartment');
    setState(() {
      departmentList = res['info'];
    });
  }

  findDoctor(search) async {
    var res = await Http().post('/normal/findDoctor', {'search': search});
    setState(() {
      doctorList = res['info'];
      showDoctor = true;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(Color.fromRGBO(115, 178, 156, 1)),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      side: MaterialStateProperty.all(
          const BorderSide(color: Color.fromRGBO(115, 178, 156, 1), width: 1)),
    );
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        showDoctor = false;
                      });
                    },
                    icon: Icon(Icons.home_outlined)),
                Expanded(
                    child: IconTextFormField(
                  controller: searchController,
                  hintText: '输入疾病名或症状',
                  //提示内容
                  clear: true,
                  radius: 16.0,
                  prefixIcon: Icon(Icons.search),
                  onSubmitted: () {
                    findDoctor(searchController.text);
                  },
                ))
              ],
            )),
        Expanded(
            child: Container(
                alignment: Alignment.topCenter,
                child: ListView(
                  shrinkWrap: true,
                  controller: new ScrollController(keepScrollOffset: false),
                  children: showDoctor
                      ? doctorList.length == 0
                          ? NoData.instance()
                          : doctorList
                              .map((e) => Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: BrnShadowCard(
                                      borderWidth: 2,
                                      circular: 15,
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DoctorHomePage(
                                                          doctor: e,
                                                          account: e['account'],
                                                        )));
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                  Container(
                                                      width: 64,
                                                      height: 64,
                                                      decoration: BoxDecoration(
                                                          border:
                                                              new Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(10),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                e['avatar']
                                                                    .toString()),
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
                                                            e['name']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 22),
                                                          ),
                                                          Text(e['level']
                                                              .toString()),
                                                          Text(e['d_name']
                                                              .toString())
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
                                                          Text(e['h_name']
                                                              .toString()),
                                                          Text(e['h_level']
                                                              .toString())
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
                                                height: 12,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    e['count'].toString() +
                                                        '\n问诊量',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        height: 1.5,
                                                        color: Color.fromRGBO(
                                                            115, 178, 156, 1)),
                                                  ),
                                                  Text(
                                                    e['rate'].toString() +
                                                        '\n回复率',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        height: 1.5,
                                                        color: Color.fromRGBO(
                                                            115, 178, 156, 1)),
                                                  ),
                                                  Text(
                                                    e['avg_score'].toString() +
                                                        '\n评分',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        height: 1.5,
                                                        color: Color.fromRGBO(
                                                            115, 178, 156, 1)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => AppointmentPage(
                                                                    doctor: e[
                                                                        'account'],
                                                                    avatar: e[
                                                                        'avatar'],
                                                                    name: e[
                                                                        'name'],
                                                                    level: e[
                                                                        'level'],
                                                                    hLevel: e[
                                                                        'h_level'],
                                                                    hospital: e[
                                                                        'h_name'],
                                                                    department: e[
                                                                        'd_name'],
                                                                    fee: e[
                                                                        'fee'],
                                                                    type:
                                                                        'new')));
                                                      },
                                                      child: Text(
                                                          '预约挂号￥' + e['fee']),
                                                      style: buttonStyle),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ChatPage(
                                                                          account:
                                                                              e['account'],
                                                                        )));
                                                        Http().post(
                                                            '/normal/updateChatTip',
                                                            {
                                                              'chat':
                                                                  e['account']
                                                            });
                                                      },
                                                      child: Text('在线咨询'),
                                                      style: buttonStyle),
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                            ],
                                          )),
                                    ),
                                  ))
                              .toList()
                      : departmentList
                          .map((e) => ListTile(
                                title: Stack(
                                  children: [
                                    Container(
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(randomImg +
                                                    '?id=' +
                                                    e['id'].toString()),
                                                fit: BoxFit.cover),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    Container(
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                          color: Color.fromRGBO(0, 0, 0, 0.4),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    Container(
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          e['name'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  findDoctor(e['name']);
                                },
                              ))
                          .toList(),
                )))
      ],
    );
  }
}
