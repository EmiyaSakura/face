import 'package:face/util/router.dart';
import 'package:flutter/material.dart';

import '../component/iconTextFormField.dart';

class InformationPage extends StatefulWidget {
  final material;

  const InformationPage({
    Key? key,
    this.material,
  }) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController nameController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var medical;
  var healthCode;
  var contact;
  var diagnosed;
  var isolation;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.material['name'] ?? '';
    sexController.text = widget.material['sex'] ?? '';
    ageController.text = widget.material['age'] ?? '';
    descriptionController.text = widget.material['description'] ?? '';
    medical = widget.material['medical'] ?? '否';
    healthCode = widget.material['healthCode'] ?? '绿码';
    contact = widget.material['contact'] ?? '无接触情况';
    diagnosed = widget.material['diagnosed'] ?? '未确诊';
    isolation = widget.material['isolation'] ?? '未处于隔离医学观察';
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
            '患者资料',
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
                              IconTextFormField(
                                controller: nameController,
                                labelText: '姓名',
                                noneBorder: true,
                                clear: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '姓名不能为空'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: IconTextFormField(
                                      controller: sexController,
                                      labelText: '性别',
                                      noneBorder: true,
                                      clear: true,
                                      validator: (value) {
                                        return value == '男' || value == '女'
                                            ? null
                                            : '性别应为男或女';
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconTextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: ageController,
                                      labelText: '年龄',
                                      noneBorder: true,
                                      clear: true,
                                      validator: (value) {
                                        int num;
                                        try {
                                          num = int.parse(value.toString());
                                        } catch (e) {
                                          num = -1;
                                        }
                                        return num < 0 || num > 100
                                            ? '年龄应在0-100范围内'
                                            : null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              IconTextFormField(
                                controller: descriptionController,
                                hintText: '请在此处填写您的症状，以往的手术、检查或治疗情况。',
                                maxLines: 5,
                                maxLength: 300,
                                radius: 10.0,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '病情描述不能为空'
                                      : null;
                                },
                              ),
                              SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('过往是否有重大病史:'),
                            ),
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('否'),
                                      value: '否',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('是'),
                                      value: '是',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('不确定'),
                                      value: '不确定',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      medical = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: medical,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('健康码:'),
                            ),
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('绿码'),
                                      value: '绿码',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('黄码'),
                                      value: '黄码',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('红码'),
                                      value: '红码',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('无码'),
                                      value: '无码',
                                    )
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      healthCode = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: healthCode,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('接触情况:'),
                            ),
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('无接触情况'),
                                      value: '无接触情况',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('最近(14)天有接触情况'),
                                      value: '最近(14)天有接触情况',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('最近(28)天有接触情况'),
                                      value: '最近(28)天有接触情况',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      contact = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: contact,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('确诊情况:'),
                            ),
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('未确诊'),
                                      value: '未确诊',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('疑似病例'),
                                      value: '疑似病例',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('无症状感染者'),
                                      value: '无症状感染者',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('已确诊新冠'),
                                      value: '已确诊新冠',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      diagnosed = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: diagnosed,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('隔离情况:'),
                            ),
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('未处于隔离医学观察'),
                                      value: '未处于隔离医学观察',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('最近(14)天完成隔离医学观察'),
                                      value: '最近(14)天完成隔离医学观察',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('处于隔离(居家)医学观察'),
                                      value: '处于隔离(居家)医学观察',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('处于隔离(集中)医学观察'),
                                      value: '处于隔离(集中)医学观察',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      isolation = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: isolation,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                      ],
                    ))),
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: MaterialButton(
                  minWidth: 180.0,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'name': nameController.text,
                        'sex': sexController.text,
                        'age': ageController.text,
                        'description': descriptionController.text,
                        'medical': medical,
                        'health_code': healthCode,
                        'contact': contact,
                        'diagnosed': diagnosed,
                        'isolation': isolation,
                      });
                    }
                  },
                  color: Colors.green,
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  //按钮颜色
                  child: Text(
                    '提  交',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
            )
          ],
        ));
  }
}
