import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageDepartment extends StatefulWidget {
  const ManageDepartment({Key? key}) : super(key: key);

  @override
  _ManageDepartmentState createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  List<TableData> tableData = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController typicalController = TextEditingController();

  init() async {
    var res = await Http().get('/root/selectDepartment');
    List<TableData> data = [];
    res['info'].forEach((e) => {data.add(TableData(e))});
    setState(() {
      tableData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
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
                              IconTextFormField(
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
                              SizedBox(
                                height: 12,
                              ),
                              IconTextFormField(
                                controller: typicalController,
                                hintText: '请输入典型症状',
                                labelText: '典型症状',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '典型症状不能为空'
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
                                var res = await Http()
                                    .post('/root/updateDepartment', {
                                  'code': codeController.text,
                                  'name': nameController.text,
                                  'typical': typicalController.text
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
            )));
  }

  @override
  Widget build(BuildContext context) {
    return ActionTable(
      columns: [
        {'label': '编号', 'key': 'code'},
        {'label': '名称', 'key': 'name'},
        {'label': '典型症状', 'key': 'typical'},
        {'label': '操作', 'key': 'update'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['code']).join(',');
        var res = await Http().post('/root/deleteDepartment', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      add: () {
        codeController.text = '';
        nameController.text = '';
        typicalController.text = '';
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增科室');
              });
            });
      },
      edit: (row) {
        codeController.text = row['code'].toString();
        nameController.text = row['name'].toString();
        typicalController.text = row['typical'].toString();
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑科室');
              });
            });
      },
      search: (search) async {
        var res =
            await Http().post('/root/searchDepartment', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
