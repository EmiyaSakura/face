import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageDoctor extends StatefulWidget {
  const ManageDoctor({Key? key}) : super(key: key);

  @override
  _ManageDoctorState createState() => _ManageDoctorState();
}

class _ManageDoctorState extends State<ManageDoctor> {
  List<TableData> tableData = [];
  var hospitalList = [];
  var departmentList = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController accountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  var hospital = '';
  var department = '';

  init() async {
    var res = await Http().get('/root/selectDoctor');
    List<TableData> data = [];
    res['info'].forEach((e) => {data.add(TableData(e))});
    setState(() {
      tableData = data;
    });
  }

  initItems() async {
    var h = await Http().get('/root/selectHospital');
    var d = await Http().get('/root/selectDepartment');
    setState(() {
      hospitalList = h['info'];
      departmentList = d['info'];
      hospital = hospitalList[0]['code'];
      department = departmentList[0]['code'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    initItems();
  }

  Widget dialog(state, {title}) {
    return Dialog(
        child: SizedBox(
      width: 600,
      height: 430,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                  onPressed: () {
                    NavRouter.pop();
                  },
                  icon: Icon(Icons.close))
            ],
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              controller: new ScrollController(keepScrollOffset: false),
              children: [
                Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: accountController,
                                hintText: '请输入账号',
                                labelText: '账号',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '账号不能为空'
                                      : null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: nameController,
                                hintText: '请输入名称',
                                labelText: '名称',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '名称不能为空'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
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
                                            child: Text(e['name'].toString()),
                                            value: e['code'],
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    state(() {
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
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('科室:'),
                            ),
                            Expanded(
                                flex: 4,
                                child: DropdownButton(
                                  items: departmentList
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e['name']),
                                            value: e['code'],
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    state(() {
                                      department = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: department,
                                  style: TextStyle(color: Colors.green),
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: levelController,
                                hintText: '请输入职称',
                                labelText: '职称',
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '职称不能为空'
                                      : null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: feeController,
                                hintText: '请输入挂号费',
                                labelText: '挂号费',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '挂号费不能为空'
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
                          controller: majorController,
                          hintText: '请输入主治',
                          labelText: '主治',
                          clear: true,
                          noneBorder: true,
                          validator: (value) {
                            return value == null || value.isEmpty
                                ? '主治不能为空'
                                : null;
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        IconTextFormField(
                          controller: infoController,
                          hintText: '请输入简介',
                          labelText: '简介',
                          clear: true,
                          noneBorder: true,
                          validator: (value) {
                            return value == null || value.isEmpty
                                ? '简介不能为空'
                                : null;
                          },
                        ),
                      ],
                    )),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      child: Text('取消', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        NavRouter.pop();
                      }),
                  TextButton(
                      child: Text('确认', style: TextStyle(fontSize: 18)),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          var res = await Http().post('/root/updateDoctor', {
                            'account': accountController.text,
                            'name': nameController.text,
                            'level': levelController.text,
                            'fee': feeController.text,
                            'major': majorController.text,
                            'info': infoController.text,
                            'h_code': hospital,
                            'd_code': department
                          });
                          if (res['code'] == 200) {
                            NavRouter.pop();
                            init();
                          }
                        }
                      }),
                ]),
              ],
            ),
          )
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ActionTable(
      columns: [
        {'label': '账号', 'key': 'account'},
        {'label': '名称', 'key': 'name'},
        {'label': '医院', 'key': 'h_name'},
        {'label': '科室', 'key': 'd_name'},
        {'label': '职称', 'key': 'level'},
        {'label': '挂号费', 'key': 'fee'},
        {'label': '主治', 'key': 'major'},
        {'label': '简介', 'key': 'info'},
        {'label': '操作', 'key': 'update'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['code']).join(',');
        var res = await Http().post('/root/deleteDoctor', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      add: () {
        accountController.text = '';
        nameController.text = '';
        levelController.text = '';
        feeController.text = '';
        majorController.text = '';
        infoController.text = '';
        hospital = hospitalList[0]['code'];
        department = departmentList[0]['code'];
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增医生');
              });
            });
      },
      edit: (row) {
        accountController.text = row['account'].toString();
        nameController.text = row['name'].toString();
        levelController.text = row['level'].toString();
        feeController.text = row['fee'].toString();
        majorController.text = row['major'].toString();
        infoController.text = row['info'].toString();
        hospital = row['h_code'].toString();
        department = row['d_code'].toString();
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑医生');
              });
            });
      },
      search: (search) async {
        var res = await Http().post('/root/searchDoctor', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
