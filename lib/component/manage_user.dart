import 'package:face/component/actionTable.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'actionTable.dart';
import 'iconTextFormField.dart';

class ManageUser extends StatefulWidget {
  const ManageUser({Key? key}) : super(key: key);

  @override
  _ManageUserState createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  List<TableData> tableData = [];

  // 表单标识
  final formKey = GlobalKey<FormState>();

  // 表单数据控制
  TextEditingController accountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  var role = 'normal';

  init() async {
    var res = await Http().get('/root/selectUser');
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
      height: 360,
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
                          controller: accountController,
                          labelText: '账号',
                          noneBorder: true,
                          disable: true,
                        ),
                        SizedBox(
                          height: 24,
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
                          height: 24,
                        ),
                        IconTextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          hintText: '请输入邮箱',
                          labelText: '邮箱',
                          clear: true,
                          noneBorder: true,
                        ),
                        SizedBox(
                          height: 36,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('角色:'),
                            ),
                            Expanded(
                                flex: 4,
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('用户'),
                                      value: 'normal',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('医生'),
                                      value: 'doctor',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('管理员'),
                                      value: 'root',
                                    )
                                  ],
                                  onChanged: (value) {
                                    state(() {
                                      role = value.toString();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  isExpanded: true,
                                  value: role,
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
                          var res = await Http().post('/root/updateUser', {
                            'account': accountController.text,
                            'name': nameController.text,
                            'email': emailController.text,
                            'role': role
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
        {'label': '头像', 'key': 'avatar'},
        {'label': '账号', 'key': 'account'},
        {'label': '名称', 'key': 'nick_name'},
        {'label': '邮箱', 'key': 'email'},
        {'label': '角色', 'key': 'role'},
        {'label': '操作', 'key': 'update,resetPwd'},
      ],
      tableData: tableData,
      delete: (list) async {
        list = list.map((e) => e['account']).join(',');
        var res = await Http().post('/root/deleteUser', {'list': list});
        Toaster().show(res['message']);
        init();
      },
      resetPwd: (row) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text('提示'),
                  content: Text('您确定要重置用户${row['account']}的密码吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('取消'),
                      onPressed: () {
                        NavRouter.pop();
                      },
                    ),
                    TextButton(
                      child: Text('确认'),
                      onPressed: () async {
                        NavRouter.pop();
                        var res = await Http().post(
                            '/root/resetPwd', {'account': row['account']});
                        Toaster().show(res['message']);
                      },
                    ),
                  ]);
            });
      },
      add: () {
        accountController.text = '';
        nameController.text = '';
        emailController.text = '';
        role = 'normal';
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '新增用户');
              });
            });
      },
      edit: (row) {
        accountController.text = row['account'].toString();
        nameController.text = row['nick_name'].toString();
        emailController.text = row['email'].toString();
        role = row['role'];
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, state) {
                return dialog(state, title: '编辑用户');
              });
            });
      },
      search: (search) async {
        var res = await Http().post('/root/searchUser', {'search': search});
        List<TableData> data = [];
        res['info'].forEach((e) => {data.add(TableData(e))});
        setState(() {
          tableData = data;
        });
      },
    );
  }
}
