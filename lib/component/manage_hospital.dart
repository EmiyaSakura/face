import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageHospital extends StatefulWidget {
  const ManageHospital({Key? key}) : super(key: key);

  @override
  _ManageHospitalState createState() => _ManageHospitalState();
}

class _ManageHospitalState extends State<ManageHospital> {
  List<TableData> tableData = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController feeController = TextEditingController();

  init() async {
    var res = await Http().get('/root/selectHospital');
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
      height: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 12,
            ),
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
            Spacer(),
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
                        return value == null || value.isEmpty ? '名称不能为空' : null;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    IconTextFormField(
                      controller: levelController,
                      hintText: '请输入级别',
                      labelText: '级别',
                      clear: true,
                      noneBorder: true,
                      validator: (value) {
                        return value == null || value.isEmpty ? '级别不能为空' : null;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    IconTextFormField(
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
                  ],
                )),
            Spacer(),
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
                      var res = await Http().post('/root/updateHospital', {
                        'code': codeController.text,
                        'name': nameController.text,
                        'level': levelController.text,
                        'fee': feeController.text,
                      });
                      if (res['code'] == 200) {
                        NavRouter.pop();
                        init();
                      }
                    }
                  }),
            ]),
            SizedBox(
              height: 36,
            ),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ActionTable(
      columns: [
        {'label': '编号', 'key': 'code'},
        {'label': '名称', 'key': 'name'},
        {'label': '级别', 'key': 'level'},
        {'label': '挂号费', 'key': 'fee'},
        {'label': '操作', 'key': 'update'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['code']).join(',');
        var res = await Http().post('/root/deleteHospital', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      add: () {
        codeController.text = '';
        nameController.text = '';
        levelController.text = '';
        feeController.text = '';
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增医院');
              });
            });
      },
      edit: (row) {
        codeController.text = row['code'];
        nameController.text = row['name'];
        levelController.text = row['level'];
        feeController.text = row['fee'];
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑医院');
              });
            });
      },
      search: (search) async {
        var res = await Http().post('/root/searchHospital', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
