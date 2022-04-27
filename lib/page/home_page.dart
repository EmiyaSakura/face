import 'package:face/component/ask_page.dart';
import 'package:face/component/find_page.dart';
import 'package:face/component/mine_page.dart';
import 'package:face/component/see_page.dart';
import 'package:flutter/material.dart';

//登录后的主界面
class HomePage extends StatefulWidget {
  static String tag = "home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class NavigationIconView {
  NavigationIconView(
      {required String title,
      required Widget icon,
      required TickerProvider vsync})
      : item = BottomNavigationBarItem(
          icon: icon,
          label: title,
        ),
        controller = AnimationController(
            duration: kThemeAnimationDuration, vsync: vsync);

  final BottomNavigationBarItem item;
  final AnimationController controller;
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int currentIndex = 0;
  late List<NavigationIconView> navigationViews;
  late List<StatefulWidget> pageList;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageList = <StatefulWidget>[SeePage(), FindPage(), AskPage(), MinePage()];
    pageController = PageController(initialPage: currentIndex, keepPage: true);
    navigationViews = [
      NavigationIconView(
        icon: const Icon(Icons.assignment),
        title: "望一望",
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.all_inclusive),
        title: "找医生",
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.add_shopping_cart),
        title: "问医生",
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.perm_identity),
        title: "我的",
        vsync: this,
      ),
    ];
    for (NavigationIconView view in navigationViews) {
      view.controller.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    for (NavigationIconView view in navigationViews) {
      view.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          top: true,
          child: PageView(
            //禁用横向滑动切换
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: pageList,
          )),
      bottomNavigationBar: BottomNavigationBar(
          items: navigationViews
              .map((NavigationIconView navigationIconView) =>
                  navigationIconView.item)
              .toList(),
          currentIndex: currentIndex,
          fixedColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              navigationViews[currentIndex].controller.reverse();
              currentIndex = index;
              navigationViews[currentIndex].controller.forward();
              pageController.jumpToPage(currentIndex);
            });
          }),
    );
  }
}
