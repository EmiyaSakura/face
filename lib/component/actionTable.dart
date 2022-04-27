import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';

import '../util/router.dart';
import 'iconTextFormField.dart';

class ActionTable extends StatefulWidget {
  final List columns;
  final tableData;
  final delete;
  final add;
  final edit;
  final resetPwd;
  final search;

  ActionTable(
      {required this.columns,
      this.tableData,
      this.delete,
      this.add,
      this.edit,
      this.resetPwd,
      this.search});

  @override
  _ActionTableState createState() => _ActionTableState();
}

class TableData {
  TableData(this.data, {this.selected = false});

  final data;
  bool selected;
}

class MyDataTableSource extends DataTableSource {
  MyDataTableSource(this.tableData, this.columns, this.edit, this.resetPwd);

  final List<TableData> tableData;
  List columns;
  final edit;
  final resetPwd;

  @override
  DataRow? getRow(int index) {
    if (index >= tableData.length) {
      return null;
    }
    List<DataCell> cells = [];
    List<Widget> bar = [];
    columns.forEach((e) => {
          if (e['label'] == '操作')
            {
              bar = [],
              if (e['key'].toString().contains('update'))
                {
                  bar.add(TextButton(
                    onPressed: () {
                      edit(tableData[index].data);
                    },
                    child: Text('编辑'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ))
                },
              if (e['key'].toString().contains('resetPwd'))
                {
                  bar.add(TextButton(
                    onPressed: () {
                      resetPwd(tableData[index].data);
                    },
                    child: Text('重置密码'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ))
                },
              cells.add(DataCell(
                  ButtonBar(alignment: MainAxisAlignment.start, children: bar)))
            }
          else
            {
              if (e['key'] == 'avatar')
                {
                  cells.add(DataCell(CircleAvatar(
                    backgroundImage: NetworkImage(
                        tableData[index].data[e['key']].toString()),
                    radius: 12.0,
                  )))
                }
              else
                {
                  cells.add(DataCell(ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Text(
                        tableData[index].data[e['key']].toString(),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ))))
                }
            }
        });
    return DataRow.byIndex(
      index: index,
      selected: tableData[index].selected,
      onSelectChanged: (selected) {
        tableData[index].selected = selected!;
        notifyListeners();
      },
      cells: cells,
    );
  }

  @override
  int get selectedRowCount {
    return 0;
  }

  @override
  bool get isRowCountApproximate {
    return false;
  }

  @override
  int get rowCount {
    return tableData.length;
  }
}

class _ActionTableState extends State<ActionTable> {
  var rowsPerPage = 10;
  List<DataColumn> columns = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.columns.forEach(
        (e) => columns.add(DataColumn(label: Text(e['label'].toString()))));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: PaginatedDataTable(
      header: Row(
        children: [
          Container(
            height: 36,
            width: 360,
            child: IconTextFormField(
              controller: searchController,
              hintText: '输入关键字搜索',
              //提示内容
              clear: true,
              radius: 0.0,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Container(
            height: 36,
            width: 60,
            child: ElevatedButton(
              onPressed: () {
                widget.search(searchController.text);
              },
              child: Text('搜索'),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
          )
        ],
      ),
      columnSpacing: 10,
      showFirstLastButtons: true,
      showCheckboxColumn: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            widget.add();
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            var list = [];
            widget.tableData.forEach((TableData e) => {
                  if (e.selected) {list.add(e.data)}
                });
            if (list.length == 0) {
              Toaster().show('请选择需要删除的数据线');
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('提示'),
                      content: Text('您确定要删除选中的${list.length}项吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('取消'),
                          onPressed: () {
                            NavRouter.pop();
                          },
                        ),
                        TextButton(
                          child: Text('确认'),
                          onPressed: () {
                            NavRouter.pop();
                            widget.delete(list);
                          },
                        ),
                      ],
                    );
                  });
            }
          },
        ),
      ],
      columns: columns,
      source: MyDataTableSource(
          widget.tableData, widget.columns, widget.edit, widget.resetPwd),
      onRowsPerPageChanged: (v) {
        setState(() {
          rowsPerPage = v!;
        });
      },
      availableRowsPerPage: [5, 10, 20],
      rowsPerPage: rowsPerPage,
      // onPageChanged: (page) {
      //   print('onPageChanged:$page');
      // },
      // onSelectAll: (all) {
      //   setState(() {
      //     data.forEach((f) {
      //       f.selected = all!;
      //     });
      //   });
      // },
    ));
  }
}
