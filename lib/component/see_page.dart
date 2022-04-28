import 'dart:async';

import 'package:face/page/webView_page.dart';
import 'package:face/util/http.dart';
import 'package:face/util/notification.dart';
import 'package:face/util/router.dart';
import 'package:flutter/material.dart';
import 'package:r_calendar/r_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'no_data.dart';

class SeePage extends StatefulWidget {
  const SeePage({Key? key}) : super(key: key);

  @override
  _SeePageState createState() => _SeePageState();
}

class MyRCalendarCustomWidget extends DefaultRCalendarCustomWidget {
  Widget dot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }

  @override
  Widget buildDateTime(
      BuildContext context, DateTime time, List<RCalendarType> types) {
    TextStyle? childStyle;
    BoxDecoration? decoration;

    if (types.contains(RCalendarType.disable) ||
        types.contains(RCalendarType.differentMonth)) {
      childStyle = TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      );
      decoration = BoxDecoration();
    }
    if (types.contains(RCalendarType.normal)) {
      childStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
      );
      decoration = BoxDecoration();
    }

    if (types.contains(RCalendarType.selected)) {
      childStyle = TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      );
    }
    if (types.contains(RCalendarType.today)) {
      childStyle = TextStyle(
        color: Colors.white,
        fontSize: 18,
      );
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      );
    }
    return Tooltip(
      message: MaterialLocalizations.of(context).formatCompactDate(time),
      child: Container(
          decoration: decoration,
          alignment: Alignment.center,
          child: Text(
            types.contains(RCalendarType.selected) ? '直播' : time.day.toString(),
            style: childStyle,
          )),
    );
  }

  Widget buildTopWidget(BuildContext context, RCalendarController? controller) {
    int current = controller?.displayedMonthDate?.month ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    dot(),
                    dot(),
                    dot(),
                  ])),
          Flexible(
              flex: 3,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      (current > 3 ? current - 3 : current + 9).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      (current > 2 ? current - 2 : current + 10).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      (current > 1 ? current - 1 : current + 11).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ])),
          Text(
            '$current月',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
          Flexible(
              flex: 3,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      (current < 12 ? current + 1 : current - 11).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      (current < 11 ? current + 2 : current - 10).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      (current < 10 ? current + 3 : current - 9).toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ])),
          Flexible(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    dot(),
                    dot(),
                    dot(),
                  ])),
        ],
      ),
    );
  }

  @override
  List<Widget> buildWeekListWidget(
      BuildContext context, MaterialLocalizations localizations) {
    return ['日', '一', '二', '三', '四', '五', '六']
        .map(
          (value) => Expanded(
            child: ExcludeSemantics(
              child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
            ),
          ),
        )
        .toList();
  }

  @override
  double get childHeight => 50;

  @override
  FutureOr<bool> clickInterceptor(BuildContext context, DateTime dateTime) {
    return true;
  }

  @override
  bool isUnable(BuildContext context, DateTime time, bool isSameMonth) {
    return true;
  }
}

class _SeePageState extends State<SeePage> with AutomaticKeepAliveClientMixin {
  // var randomImg = 'https://www.dmoe.cc/random.php';
  var randomImg = 'https://api.ixiaowai.cn/gqapi/gqapi.php';
  late RCalendarController controller =
      RCalendarController.multiple(selectedDates: []);
  int currentView = 0;
  var reservingList = [];
  var pastList = [];
  var reservedList = [];

  formatDate(String date) {
    var list = date.split('-');
    if (int.parse(list[1]) < 10) {
      list[1] = '0' + list[1];
    }
    if (int.parse(list[2]) < 10) {
      list[2] = '0' + list[2];
    }
    return list.join('-');
  }

  isToday(date) {
    var today =
        MaterialLocalizations.of(context).formatCompactDate(DateTime.now());
    var day = MaterialLocalizations.of(context)
        .formatCompactDate(DateTime.parse(formatDate(date)));
    return today == day;
  }

  init() async {
    var res = await Http().get('/normal/getVideo');
    setState(() {
      reservingList = res['info']['reserving'];
      pastList = res['info']['past'];
      reservedList = res['info']['reserved'];
    });
    controller.selectedDates = reservingList
        .map((e) => DateTime.parse(formatDate(e['date'])))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('systemNotice') ?? true) {
      reservedList.forEach((element) {
        if (element['remind'] && isToday(element['date'])) {
          Notificator().send('直播提醒', '您预约的直播"${element['title']}"已开始放送');
          Http().post('/normal/remindVideo',
              {'code': element['code'], 'remind': false});
          Http().post('/normal/insertChatTip',
              {'chat': '您预约的直播"${element['title']}"已开始放送'});
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  handleClick(type, [value]) async {
    switch (type) {
      case '预约直播':
        setState(() {
          currentView = 0;
        });
        break;
      case '往日回看':
        setState(() {
          currentView = 1;
        });
        break;
      case '我的预约':
        setState(() {
          currentView = 2;
        });
        break;
      case '预约':
        await Http().post('/normal/reserveVideo',
            {'code': value['code'], 'reserve': !value['reserved']});
        init();
        break;
      case '观看':
        NavRouter.push(
            WebViewPage.tag,
            WebViewArgs(
              value['title'],
              value['url'],
            ));
        break;
      case '提醒':
        await Http().post('/normal/remindVideo',
            {'code': value['code'], 'remind': !value['remind']});
        init();
        break;
    }
  }

  List<Widget> listVideos() {
    ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(20, 5, 20, 5)),
      backgroundColor:
          MaterialStateProperty.all(const Color.fromRGBO(115, 178, 156, 1)),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      side: MaterialStateProperty.all(
          const BorderSide(color: Color.fromRGBO(115, 178, 156, 1), width: 1)),
    );

    var list = [];
    if (currentView == 0) {
      list = reservingList;
    } else if (currentView == 1) {
      list = pastList;
    } else if (currentView == 2) {
      list = reservedList;
    }

    if (list.length == 0) {
      return NoData.instance();
    }
    return list
        .map((e) => Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Stack(children: [
                Container(
                    height: 160.0,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                randomImg + '?id=' + e['id'].toString()),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10))),
                Container(
                  height: 160.0,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                      borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  height: 160.0,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['title'],
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                e['author'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                e['identity'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e['date'],
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          currentView == 0
                              ? OutlinedButton(
                                  onPressed: () {
                                    handleClick(
                                        isToday(e['date']) ? '观看' : '预约', e);
                                  },
                                  child: Text(isToday(e['date'])
                                      ? '观看'
                                      : e['reserved']
                                          ? '已预约'
                                          : '预约'),
                                  style: buttonStyle)
                              : currentView == 1
                                  ? OutlinedButton(
                                      onPressed: () {
                                        handleClick('观看', e);
                                      },
                                      child: const Text('回看'),
                                      style: buttonStyle)
                                  : currentView == 2
                                      ? OutlinedButton(
                                          onPressed: () {
                                            handleClick(
                                                isToday(e['date'])
                                                    ? '观看'
                                                    : '提醒',
                                                e);
                                          },
                                          child: Text(isToday(e['date'])
                                              ? '观看'
                                              : e['remind']
                                                  ? '取消提醒'
                                                  : '设置提醒'),
                                          style: buttonStyle)
                                      : SizedBox.shrink()
                        ],
                      )
                    ],
                  ),
                ),
              ]),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      controller: new ScrollController(keepScrollOffset: false),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: RCalendarWidget(
            controller: controller,
            customWidget: MyRCalendarCustomWidget(),
            firstDate: DateTime(1970, 1, 1), //当前日历的最小日期
            lastDate: DateTime(2055, 12, 31), //当前日历的最大日期
          ),
        ),
        SizedBox(
          height: 12,
          child: Container(
            color: Color.fromRGBO(241, 241, 241, 1),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      handleClick('预约直播');
                    },
                    child: Text(
                      '预约直播',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              currentView == 0 ? Colors.green : Colors.black),
                    )),
                const Text('|'),
                TextButton(
                    onPressed: () {
                      handleClick('往日回看');
                    },
                    child: Text(
                      '往日回看',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              currentView == 1 ? Colors.green : Colors.black),
                    )),
                const Text('|'),
                TextButton(
                    onPressed: () {
                      handleClick('我的预约');
                    },
                    child: Text(
                      '我的预约',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              currentView == 2 ? Colors.green : Colors.black),
                    ))
              ],
            )),
        Column(
          children: listVideos(),
        ),
      ],
    );
  }
}
