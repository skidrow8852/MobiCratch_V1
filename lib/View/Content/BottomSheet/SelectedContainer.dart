import 'package:flutter/material.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/widgets/customtext.dart';
import '../../../Utils/color_constant.dart';

class SelectableContainersContent extends StatefulWidget {
  const SelectableContainersContent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectableContainersContentState createState() =>
      _SelectableContainersContentState();
}

class _SelectableContainersContentState
    extends State<SelectableContainersContent> {
  int selectedContainer = 1;

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                selectContainer(1);
              },
              child: Container(
                height: 65,
                width: 95,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: selectedContainer == 1
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFBD64FC),
                              Color(0xFF6644F1),
                            ],
                            stops: [
                              0.118,
                              0.9035,
                            ],
                            transform: GradientRotation(254.96 * 3.14 / 180),
                          )
                        : LinearGradient(colors: [
                            AppColors.fieldUnActive,
                            AppColors.fieldUnActive,
                          ])),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                          textStyle: AppStyle.textStyle11SemiBoldWhite600,
                          title: 'Public'),
                      const Spacer(),
                      CustomText(
                          textStyle: AppStyle.textStyle8White600,
                          title: 'Visible to all'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectContainer(2);
              },
              child: Container(
                height: 65,
                width: 95,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: selectedContainer == 2
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFBD64FC),
                              Color(0xFF6644F1),
                            ],
                            stops: [
                              0.118,
                              0.9035,
                            ],
                            transform: GradientRotation(254.96 * 3.14 / 180),
                          )
                        : LinearGradient(colors: [
                            AppColors.fieldUnActive,
                            AppColors.fieldUnActive,
                          ])),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                          textStyle: AppStyle.textStyle11SemiBoldWhite600,
                          title: 'Private'),
                      const Spacer(),
                      CustomText(
                          textStyle: AppStyle.textStyle8White600,
                          title: 'Visible only to you'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectContainer(3);
              },
              child: Container(
                height: 65,
                width: 95,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: selectedContainer == 3
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFBD64FC),
                              Color(0xFF6644F1),
                            ],
                            stops: [0.118, 0.9035],
                            tileMode: TileMode.repeated,
                            transform: GradientRotation(254.96 * 3.14 / 180),
                          )
                        : LinearGradient(colors: [
                            AppColors.fieldUnActive,
                            AppColors.fieldUnActive,
                          ])),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                          textStyle: AppStyle.textStyle11SemiBoldWhite600,
                          title: 'NFT holders'),
                      const Spacer(),
                      CustomText(
                          textStyle: AppStyle.textStyle8White600,
                          title: 'Only NFT holders'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
