import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSizedBoxWidth extends StatelessWidget {
  double width;
  CustomSizedBoxWidth({required this.width, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
