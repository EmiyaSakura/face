import 'package:flutter/material.dart';

class IconTextFormField extends StatefulWidget {
  final controller; //文本内容
  final TextStyle style; //输入框中文字样式
  final onChanged; //输入监听
  final onSubmitted; //键盘回车监听
  final hintText; //提示文字
  final obscureText; //星号显示
  final show; //显示密码
  final clear; //星号清除
  final radius; //圆角
  final validator;
  final prefixIcon;
  final leftOnly;
  final labelText;
  final noneBorder;
  final disable;
  final suffixButton;

  //设置键盘弹出时类型
  final TextInputType keyboardType; //文本框属性
  final int maxLines; //最大显示行
  final maxLength;

  IconTextFormField({
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.style = const TextStyle(fontSize: 16),
    this.obscureText = false,
    this.show = false,
    this.clear = false,
    this.radius = 30.0,
    this.validator,
    this.prefixIcon,
    this.leftOnly = false,
    this.labelText,
    this.noneBorder = false,
    this.disable = false,
    this.suffixButton,
  });

  @override
  _IconTextFormFieldState createState() => _IconTextFormFieldState();
}

class _IconTextFormFieldState extends State<IconTextFormField> {
  TextEditingController controller = new TextEditingController();
  late bool clearState;
  late bool showState;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller;
    }
    showState = widget.obscureText;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      enabled: !widget.disable,
      obscureText: showState,
      controller: controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onEditingComplete: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        fillColor: Colors.white,
        //提示内容
        contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 5),
        //上下左右边距设置
        border: widget.noneBorder
            ? null
            : widget.leftOnly
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(widget.radius),
                        topLeft: Radius.circular(widget.radius)))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius)),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.show || widget.clear || widget.suffixButton != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Visibility(
                        visible: widget.show,
                        child: Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showState = !showState;
                              });
                            },
                            child: Icon(showState
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        )),
                    Visibility(
                        visible: widget.clear && controller.text != '',
                        child: Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                controller.text = "";
                              });
                            },
                            child: Icon(Icons.cancel),
                          ),
                        )),
                    Visibility(
                        visible: widget.suffixButton != null,
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: widget.suffixButton,
                        ))
                  ])
            : null,
      ),
      style: widget.style,
      validator: widget.validator,
      onChanged: (string) {
        setState(() {
          clearState = controller.text != '';
        });
      },
    );
  }
}
