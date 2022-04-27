import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import 'appointment_page.dart';

class HospitalServicePage extends StatefulWidget {
  static String tag = 'hospital-service-page';

  const HospitalServicePage({Key? key}) : super(key: key);

  @override
  _HospitalServicePageState createState() => _HospitalServicePageState();
}

class _HospitalServicePageState extends State<HospitalServicePage> {
  bool reverse = false;
  List hospitalList = [];

  load() async {
    var res = await Http().get('/normal/findHospital');
    setState(() {
      hospitalList = res['info'];
    });
  }

  @override
  void initState() {
    super.initState();
    load();
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
            '医院服务',
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
        body: ListView(
          shrinkWrap: true,
          reverse: reverse,
          controller: new ScrollController(keepScrollOffset: false),
          padding: EdgeInsets.symmetric(horizontal: 10),
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
              .toList(),
        ));
  }
}
