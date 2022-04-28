import 'package:flutter/material.dart';

class NoData {
  static List<Widget> instance() {
    return [
      SizedBox(
        height: 24,
      ),
      Container(
        alignment: Alignment.center,
        child: Image.asset(
          'null.png',
          width: 100,
        ),
      ),
      SizedBox(
        height: 24,
      ),
      Container(
        alignment: Alignment.center,
        child: Text('空空如也'),
      )
    ];
  }
}
