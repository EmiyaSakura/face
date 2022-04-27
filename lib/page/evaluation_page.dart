import 'package:bruno/bruno.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../component/iconTextFormField.dart';
import '../util/http.dart';

class EvaluationPage extends StatefulWidget {
  final doctor;
  final evaluationCode;
  final appointmentCode;

  const EvaluationPage(
      {Key? key, this.doctor, this.evaluationCode = '', this.appointmentCode})
      : super(key: key);

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  bool anonymity = false;
  double score = 5;

  // 表单数据控制
  TextEditingController commentController = TextEditingController();

  load() async {
    var res = await Http()
        .post('/normal/getEvaluation', {'code': widget.evaluationCode});
    setState(() {
      commentController.text = res['info']['comment'] ?? '';
      score = double.parse(res['info']['score'] ?? '5');
      anonymity = res['info']['anonymity'] == 'true';
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
            '评价',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              IconTextFormField(
                  controller: commentController,
                  labelText: '评价',
                  maxLines: 5,
                  radius: 10.0),
              SizedBox(height: 24),
              ListTile(
                  title: Text("评分"),
                  trailing: BrnRatingStar(
                    selectedCount: score,
                    space: 5,
                    onSelected: (count) {
                      score = count.ceilToDouble();
                    },
                  )),
              SwitchListTile(
                  title: Text("匿名评价"),
                  value: anonymity,
                  onChanged: (value) async {
                    setState(() {
                      anonymity = value;
                    });
                  }),
              SizedBox(height: 24),
              ListTile(
                title: ElevatedButton(
                  onPressed: () async {
                    var res = await Http().post('/normal/updateEvaluation', {
                      'code': widget.evaluationCode,
                      'appCode': widget.appointmentCode,
                      'doctor': widget.doctor,
                      'comment': commentController.text,
                      'score': score,
                      'anonymity': anonymity ? 'true' : 'false',
                    });
                    Navigator.pop(context, res['info']);
                  },
                  child: Text(
                    '提交评价',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                ),
              )
            ],
          ),
        ));
  }
}
