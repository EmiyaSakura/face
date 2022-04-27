import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../component/iconTextFormField.dart';
import '../util/http.dart';

class DoctorInformationPage extends StatefulWidget {
  final doctor;
  final edit;

  const DoctorInformationPage({
    Key? key,
    this.doctor,
    this.edit = false,
  }) : super(key: key);

  @override
  _DoctorInformationPageState createState() => _DoctorInformationPageState();
}

class _DoctorInformationPageState extends State<DoctorInformationPage> {
  var hospitalList = [];
  var departmentList = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController nameController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController introductionController = TextEditingController();
  var hospital = '';
  var department = '';
  var level = '';

  init() async {
    var h = await Http().get('/normal/findHospital');
    var d = await Http().get('/normal/findDepartment');
    setState(() {
      hospitalList = h['info'];
      departmentList = d['info'];

      hospital = widget.doctor['h_code'] ?? hospitalList[0]['code'];
      department = widget.doctor['d_code'] ?? departmentList[0]['code'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    nameController.text = widget.doctor['name'] ?? '';
    feeController.text = widget.doctor['fee'] ?? '';
    majorController.text = widget.doctor['major'] ?? '';
    introductionController.text = widget.doctor['introduction'] ?? '';
    level = widget.doctor['level'] ?? '助理医师';
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
            widget.edit ? '医生资料' : '医生认证',
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
                      controller: new ScrollController(keepScrollOffset: false),
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      children: [
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: IconTextFormField(
                                      controller: nameController,
                                      labelText: '真实姓名',
                                      noneBorder: true,
                                      clear: true,
                                      validator: (value) {
                                        return value == null || value.isEmpty
                                            ? '真实姓名不能为空'
                                            : null;
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconTextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: feeController,
                                      labelText: '挂号费',
                                      noneBorder: true,
                                      clear: true,
                                      validator: (value) {
                                        double num;
                                        try {
                                          num = double.parse(value.toString());
                                        } catch (e) {
                                          num = -1;
                                        }
                                        return num < 0 ? '挂号费应为非负数' : null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text('医院:'),
                                  ),
                                  Expanded(
                                      flex: 4,
                                      child: DropdownButton(
                                        items: hospitalList
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(
                                                      e['name'].toString()),
                                                  value: e['code'],
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            hospital = value.toString();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        isExpanded: true,
                                        value: hospital,
                                        style: TextStyle(color: Colors.green),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('科室:'),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: DropdownButton(
                                        items: departmentList
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(
                                                      e['name'].toString()),
                                                  value: e['code'],
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            department = value.toString();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        isExpanded: true,
                                        value: department,
                                        style: TextStyle(color: Colors.green),
                                      )),
                                  Expanded(
                                    flex: 2,
                                    child: Text('职称:'),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: DropdownButton(
                                        items: [
                                          '助理医师',
                                          '住院医师',
                                          '主治医师',
                                          '副主任医师',
                                          '主任医师'
                                        ]
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(e),
                                                  value: e,
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            level = value.toString();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        isExpanded: true,
                                        value: level,
                                        style: TextStyle(color: Colors.green),
                                      ))
                                ],
                              ),
                              SizedBox(height: 12),
                              IconTextFormField(
                                controller: majorController,
                                labelText: '主治',
                                maxLines: 5,
                                maxLength: 300,
                                radius: 10.0,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '主治不能为空'
                                      : null;
                                },
                              ),
                              SizedBox(height: 12),
                              IconTextFormField(
                                controller: introductionController,
                                labelText: '简介',
                                maxLines: 5,
                                maxLength: 300,
                                radius: 10.0,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '简介不能为空'
                                      : null;
                                },
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ))),
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: MaterialButton(
                  minWidth: 180.0,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await Http().post('/normal/updateDoctor', {
                        'name': nameController.text,
                        'h_code': hospital,
                        'd_code': department,
                        'level': level,
                        'fee': feeController.text,
                        'major': majorController.text,
                        'introduction': introductionController.text,
                      });
                      NavRouter.pop();
                    }
                  },
                  color: Colors.green,
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  //按钮颜色
                  child: Text(
                    widget.edit ? '保  存' : '认  证',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
            )
          ],
        ));
  }
}
