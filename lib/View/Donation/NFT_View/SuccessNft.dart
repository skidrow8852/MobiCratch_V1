import 'package:flutter/material.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';

class NftSuccessBottomSheet extends StatelessWidget {
  const NftSuccessBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 720,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(AppImages.ntfSuccess),
            fit: BoxFit.cover,
          )),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 31,
                      width: 31,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray75),
                        shape: BoxShape.circle,
                      ),
                      child: IconButtonWidget(
                        ontap: () {
                          Navigator.pop(context);
                        },
                        height: 31,
                        width: 31,
                        containerColor: AppColors.bgGradient2,
                        widget: Icon(
                          Icons.clear,
                          color: AppColors.mainColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButtonWidget(
                    ontap: () {},
                    height: 73,
                    width: 73,
                    gradient: const LinearGradient(
                      begin: Alignment(-0.5, -0.5),
                      end: Alignment(1.5, 1.5),
                      colors: [
                        Color(0xFFB157B7),
                        Color(0xFF7A57E7),
                      ],
                      stops: [
                        0.1062,
                        0.8693,
                      ],
                      transform: GradientRotation(212.05 * (3.1415926 / 180)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainColor,
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: -4, //extend the shadow
                        offset: const Offset(
                          0.0, // Move to right 10  horizontally
                          4.0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                    widget: Icon(Icons.check_circle_outline_outlined,
                        color: AppColors.whiteA700, size: 35)),
                CustomSizedBoxHeight(height: 10),
                CustomText(
                    textStyle: AppStyle.textStyle16Bold600, title: 'Success!'),
                CustomText(
                    textStyle: AppStyle.textStyle13Regular,
                    title: 'NFT was successfully purchased '),
                CustomSizedBoxHeight(height: 50),
                Image.asset(AppImages.gamingImage2, height: 236, width: 251),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: CustomText(
                    title: 'Let’s see where we can gomoment',
                    textStyle: AppStyle.textStyle16Bold600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
