import 'package:face/component/manage_department.dart';
import 'package:face/component/manage_doctor.dart';
import 'package:face/component/manage_hospital.dart';
import 'package:face/component/manage_hospital_department.dart';
import 'package:face/component/manage_user.dart';
import 'package:face/component/manage_video.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/http.dart';
import '../util/router.dart';
import 'login_page.dart';

//登录后的主界面
class ManagePage extends StatefulWidget {
  static String tag = "manage_page";

  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> with ChangeNotifier {
  int currentIndex = 0;
  late List<Widget> pageList;
  late List<ExpansionPanelRadio> expansionPanelRadioList;
  late PageController pageController;
  late ValueNotifier<List<bool>> isFocus;
  var user = {};

  init() async {
    var res = await Http().get('/normal/getUser');
    setState(() {
      user = res['info'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    pageList = [
      Text('欢迎'),
      ManageUser(),
      ManageVideo(),
      ManageHospital(),
      ManageDepartment(),
      ManageHospitalDepartment(),
      ManageDoctor(),
    ];
    pageController = PageController(initialPage: currentIndex, keepPage: true);
    isFocus = ValueNotifier(List.filled(pageList.length, false));
    focusItem(0);
    expansionPanelRadioList = [
      ExpansionPanelRadio(
        value: 0,
        headerBuilder: (context, isExpanded) {
          return Center(
            child: Text('用户管理'),
          );
        },
        body: Column(
          children: [
            divider(),
            actionButton(1, '用户信息管理'),
            divider(),
          ],
        ),
        canTapOnHeader: true,
      ),
      ExpansionPanelRadio(
        value: 1,
        headerBuilder: (context, isExpanded) {
          return Center(
            child: Text('直播管理'),
          );
        },
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            divider(),
            actionButton(2, '视频资料管理'),
            divider(),
          ],
        ),
        canTapOnHeader: true,
      ),
      ExpansionPanelRadio(
        value: 2,
        headerBuilder: (context, isExpanded) {
          return Center(
            child: Text('医疗管理'),
          );
        },
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            divider(),
            actionButton(3, '医院信息管理'),
            divider(),
            actionButton(4, '科室信息管理'),
            divider(),
            actionButton(5, '医院科室管理'),
            divider(),
            actionButton(6, '医生信息管理'),
            divider(),
          ],
        ),
        canTapOnHeader: true,
      )
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget divider() {
    return SizedBox(
      height: 1,
      child: Container(
        color: Color.fromRGBO(241, 241, 241, 1),
      ),
    );
  }

  Widget actionButton(index, action) {
    return ValueListenableBuilder(
        valueListenable: isFocus,
        builder: (BuildContext context, dynamic value, Widget? child) {
          return TextButton(
            onPressed: () {
              focusItem(index);
              setState(() {
                currentIndex = index;
              });
              pageController.jumpToPage(currentIndex);
            },
            child: Center(
              child: Text(action),
            ),
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 20)),
                backgroundColor: MaterialStateProperty.all(
                    isFocus.value[index] ? Colors.blue : Colors.white),
                foregroundColor: MaterialStateProperty.all(
                    isFocus.value[index] ? Colors.white : Colors.black)),
          );
        });
  }

  void focusItem(index) {
    for (var i = 0; i < pageList.length; i++) {
      isFocus.value[i] = false;
    }
    isFocus.value[index] = true;
    isFocus.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Image.asset('title.png'),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      '工作台',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '欢迎您！管理员: ' + user['nick_name'].toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            border:
                                new Border.all(color: Colors.white, width: 1),
                            borderRadius: new BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(user['avatar'].toString()),
                              fit: BoxFit.fill,
                            ))),
                    SizedBox(
                      width: 16,
                    ),
                    IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          NavRouter.open(LoginPage.tag);
                        },
                        icon: Icon(Icons.power_settings_new)),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        actionButton(0, '首页'),
                        divider(),
                        SingleChildScrollView(
                          child: ExpansionPanelList.radio(
                            children: expansionPanelRadioList,
                            initialOpenPanelValue: expansionPanelRadioList[0],
                            elevation: 0,
                            dividerColor: Color.fromRGBO(241, 241, 241, 1),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  flex: 8,
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: PageView(
                        //禁用横向滑动切换
                        physics: NeverScrollableScrollPhysics(),
                        controller: pageController,
                        children: pageList,
                      )),
                )
              ],
            ))
          ],
        ));
  }
}
