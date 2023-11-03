import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'customtext.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  void Function() ontap;
  String title;
  Gradient? gradient;
  List<BoxShadow>? boxshadow;
  String? image;
  Color? color;
  double? height;
  double? width;
  IconData? icon;
  TextStyle? AppStyle;

  CustomButton(
      {Key? key,
      required this.title,
      required this.ontap,
      this.gradient,
      this.boxshadow,
      this.height = 53,
      this.width = double.infinity,
      this.color,
      this.icon,
      this.AppStyle,
      this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          boxShadow: boxshadow,
          gradient: gradient,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null
                  ? Image.asset(
                      image!,
                      height: 40,
                      width: 40,
                    )
                  : const Text(''),
              SizedBox(
                width: 12.w,
              ),
              CustomText(
                textStyle: AppStyle,
                title: title,
              ),
              const SizedBox(width: 6),
              Icon(icon, color: AppColors.whiteA700, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
