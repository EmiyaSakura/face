import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageVideo extends StatefulWidget {
  const ManageVideo({Key? key}) : super(key: key);

  @override
  _ManageVideoState createState() => _ManageVideoState();
}

class _ManageVideoState extends State<ManageVideo> {
  List<TableData> tableData = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController codeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController identityController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  init() async {
    var res = await Http().get('/root/selectVideo');
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
      width: 600,
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
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: codeController,
                                labelText: '编号',
                                noneBorder: true,
                                disable: true,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: titleController,
                                hintText: '请输入标题',
                                labelText: '标题',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '标题不能为空'
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
                              child: IconTextFormField(
                                controller: authorController,
                                hintText: '请输入作者',
                                labelText: '作者',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '作者不能为空'
                                      : null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: identityController,
                                hintText: '请输入头衔',
                                labelText: '头衔',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '头衔不能为空'
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
                              child: IconTextFormField(
                                controller: dateController,
                                hintText: '请输入日期',
                                labelText: '日期',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '日期不能为空'
                                      : null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconTextFormField(
                                controller: urlController,
                                hintText: '请输入地址',
                                labelText: '地址',
                                clear: true,
                                noneBorder: true,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? '地址不能为空'
                                      : null;
                                },
                              ),
                            ),
                          ],
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
                          var res = await Http().post('/root/updateVideo', {
                            'code': codeController.text,
                            'title': titleController.text,
                            'author': authorController.text,
                            'identity': identityController.text,
                            'date': dateController.text,
                            'url': urlController.text,
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
        {'label': '标题', 'key': 'title'},
        {'label': '作者', 'key': 'author'},
        {'label': '头衔', 'key': 'identity'},
        {'label': '日期', 'key': 'date'},
        {'label': '地址', 'key': 'url'},
        {'label': '操作', 'key': 'update'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['code']).join(',');
        var res = await Http().post('/root/deleteVideo', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      add: () {
        codeController.text = '';
        titleController.text = '';
        authorController.text = '';
        identityController.text = '';
        dateController.text = '';
        urlController.text = '';
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增直播');
              });
            });
      },
      edit: (row) {
        codeController.text = row['code'].toString();
        titleController.text = row['title'].toString();
        authorController.text = row['author'].toString();
        identityController.text = row['identity'].toString();
        dateController.text = row['date'].toString();
        urlController.text = row['url'].toString();
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑直播');
              });
            });
      },
      search: (search) async {
        var res = await Http().post('/root/searchVideo', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
