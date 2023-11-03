import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  CustomText(
      {Key? key,
      required this.textStyle,
      this.textAlign,
      required this.title,
      this.maxline})
      : super(key: key);
  String title;
  TextStyle? textStyle;
  int? maxline;
  TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: textAlign,
      title,
      style: textStyle,
      maxLines: maxline,
      overflow: TextOverflow.ellipsis,
    );
  }
}
