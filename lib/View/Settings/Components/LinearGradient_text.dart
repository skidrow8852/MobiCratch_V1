import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LinearGradientText extends StatelessWidget {
  FontWeight? fontWeight;
  double? fontSize;
  List<Color> colors;
  Paint foreground;
  String title;
  String? fontFamily;
  Shader? value;
  LinearGradientText({
    Key? key,
    this.fontWeight,
    this.fontSize,
    required this.colors,
    required this.foreground,
    required this.title,
    this.fontFamily,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        // foreground: foreground,
        fontFamily: fontFamily,
        foreground: Paint()..shader = value,
      ),
    );
  }
}


//  foreground: Paint()
//           ..shader = LinearGradient(
//             colors: <Color>[
//               Colors.pinkAccent,
//               Colors.deepPurpleAccent,
//               Colors.red
//               //add more color here.
//             ],
//           ).createShader(
//             Rect.fromLTWH(0.0, 0.0, 200.0, 100.0),
//           ),