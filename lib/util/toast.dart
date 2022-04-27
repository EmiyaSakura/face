import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 消息悬浮框
class Toaster {
  show(msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
