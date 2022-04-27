import 'package:flutter/cupertino.dart';

// 不使用上下文进行路由管理
class NavRouter {
  static final GlobalKey<NavigatorState> navGK =
      new GlobalKey<NavigatorState>();

  static push(routeName, [arguments]) {
    //导航到新路由
    navGK.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static open(routeName) {
    //导航到新路由并清空历史路由
    navGK.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  static pop() {
    //导航到新路由
    navGK.currentState?.pop();
  }
}
