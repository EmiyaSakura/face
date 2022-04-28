import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageHospitalDepartment extends StatefulWidget {
  const ManageHospitalDepartment({Key? key}) : super(key: key);

  @override
  _ManageHospitalDepartmentState createState() =>
      _ManageHospitalDepartmentState();
}

class _ManageHospitalDepartmentState extends State<ManageHospitalDepartment> {
  List<TableData> tableData = [];
  var hospitalList = [];
  var departmentList = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController codeController = TextEditingController();
  var hospital = '';
  var department = '';

  init() async {
    var res = await Http().get('/root/selectHospitalDepartment');
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
      width: 400,
      height: 250,
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
                        IconTextFormField(
                          controller: codeController,
                          labelText: '编号',
                          noneBorder: true,
                          disable: true,
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
                                            child: Text(e['name'].toString()),
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
                          height: 6,
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
                          var res = await Http().post(
                              '/root/updateHospitalDepartment', {
                            'code': codeController.text,
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
        {'label': '编号', 'key': 'code'},
        {'label': '医院', 'key': 'h_name'},
        {'label': '科室', 'key': 'd_name'},
        {'label': '操作', 'key': 'update'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['code']).join(',');
        var res =
            await Http().post('/root/deleteHospitalDepartment', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      add: () {
        codeController.text = '';
        hospital = hospitalList[0]['code'];
        department = departmentList[0]['code'];
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增医院科室');
              });
            });
      },
      edit: (row) {
        codeController.text = row['code'].toString();
        hospital = row['h_code'].toString();
        department = row['d_code'].toString();
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑医院科室');
              });
            });
      },
      search: (search) async {
        var res = await Http()
            .post('/root/searchHospitalDepartment', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
