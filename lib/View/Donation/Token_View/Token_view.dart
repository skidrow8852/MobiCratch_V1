import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customButton.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../Utils/color_constant.dart';

class SelectableContainer extends StatefulWidget {
  @override
  _SelectableContainerState createState() => _SelectableContainerState();
}

class _SelectableContainerState extends State<SelectableContainer> {
  int _selectedIndex = -1;
  bool isTapped = false;

  void _selectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> containerTexts = ['10 CRTC', '50 CRTC', '100 CRTC'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            CustomText(
              title: '\t\t\tChoose amount',
              textStyle: AppStyle.textStyle12regularWhite,
            ),
            Container(
              height: 200,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: containerTexts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectItem(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            // color: _selectedIndex == index ? Colors.grey : Colors.indigo,
                            gradient: _selectedIndex == index
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Color(0xff7556eb),
                                        Color(0xffb357b5),
                                      ])
                                : const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                        Color(0xff373953),
                                        Color(0xff373953),
                                        Color(0xff373953)
                                      ]),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              _selectedIndex == index
                                  ? const BoxShadow(
                                      color: Color.fromRGBO(117, 87, 235, 0.19),
                                      offset: Offset(0, 4),
                                      blurRadius: 9,
                                      spreadRadius: 3,
                                    )
                                  : const BoxShadow()
                            ]),
                        child: Center(
                          child: CustomText(
                            title: containerTexts[index],
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: _selectedIndex == index
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomSizedBoxHeight(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: "Other amount",
                            style: AppStyle.textStyle12regularWhite,
                          ),
                        ],
                      ),
                    ),
                    CustomSizedBoxHeight(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TextFormField(
                        initialValue: 1.toString(),
                        enabled: true,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            border: InputBorder.none,
                            hintText: "Enter your donation amount",
                            hintStyle: AppStyle.textStyle12Regular
                                .copyWith(color: Colors.grey),
                            filled: true,
                            fillColor: isTapped
                                ? AppColors.textFieldActive.withOpacity(0.2)
                                : AppColors.fieldUnActive,
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.mainColor),
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.redAccsent))),
                        onTap: () {
                          setState(() {
                            isTapped = true;
                          });
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            isTapped = false;
                          });
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              isTapped = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                )),
            CustomSizedBoxHeight(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomButton(
                  boxshadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(117, 87, 235, 0.19),
                      offset: Offset(0, 4),
                      blurRadius: 9,
                      spreadRadius: 3,
                    )
                  ],
                  title: 'Donate',
                  ontap: () {
                    // Get.to(showModalBottomSheet(
                    //   barrierColor: AppColors.gray.withOpacity(0.4),
                    //   backgroundColor: AppColors.bgGradient2A,
                    //   isDismissible: true,
                    //   useSafeArea: true,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(25.r),
                    //       topRight: Radius.circular(25.r),
                    //     ),
                    //   ),
                    //   isScrollControlled: true,
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return const SuccessBottomSheet();
                    //   },
                    // ));

                    showTopSnackBar(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        Overlay.of(context),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Set width to 80% of the screen width
                          child: CustomSnackBar.error(
                            backgroundColor:
                                const Color.fromRGBO(65, 93, 134, 1),
                            borderRadius: BorderRadius.circular(5),
                            iconPositionLeft: 15,
                            iconRotationAngle: 0,
                            icon: const CircleAvatar(
                              radius: 15,
                              backgroundColor: Color(0xFF1875FF),
                              child: FaIcon(
                                FontAwesomeIcons.info,
                                size: 15,
                              ),
                            ),
                            message: "Coming Soon! Stay Tuned!",
                          ),
                        ));
                  },
                  AppStyle: AppStyle.textStyle12regularWhite,
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff7556eb),
                        Color(0xffb357b5),
                      ])),
            ),
          ],
        ),
      ),
    );
  }
}
