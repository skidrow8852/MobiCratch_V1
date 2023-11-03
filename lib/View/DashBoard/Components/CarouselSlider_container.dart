import 'package:flutter/material.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/View/ViewAllVideo&Stream/viewAllLiveStream_view.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customButton.dart';
import 'package:cratch/widgets/customtext.dart';

import '../../../Utils/color_constant.dart';

class CarouselSliderContainer extends StatelessWidget {
  final String title;
  final String description;
  final String myImage;
  final Gradient grad;
  final double paddin;
  const CarouselSliderContainer(
      {Key? key,
      required this.title,
      required this.description,
      required this.grad,
      required this.paddin,
      required this.myImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 167,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(14),
          color: Colors.blue, // Replace with your desired background color
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                myImage, // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Modified this line
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                          textStyle: AppStyle.textStyle12regularWhite,
                          title: title),
                      CustomSizedBoxHeight(height: 20),
                      CustomText(
                          textStyle: AppStyle.textStyle9SemiBoldWhite,
                          title: description),
                      CustomSizedBoxHeight(height: 15),
                      CustomButton(
                        height: 27,
                        width: 100,
                        color: AppColors.whiteA700,
                        AppStyle: AppStyle.textStyle10SemiBoldBlack,
                        title: 'Watch Now',
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllLivesView(),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
