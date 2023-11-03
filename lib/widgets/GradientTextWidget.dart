import 'package:flutter/material.dart';
import 'package:cratch/Utils/color_constant.dart';

// ignore: must_be_immutable
class GradientTextWidget extends StatelessWidget {
  GradientTextWidget({Key? key, this.text, this.size}) : super(key: key);

  String? text;
  double? size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xffFFBDBD),
              const Color(0xffFFBDBD),
              AppColors.mainColor,
            ],
          ).createShader(
            const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
          ),
      ),
    );
  }
}
