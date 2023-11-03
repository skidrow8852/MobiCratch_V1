import 'package:flutter/material.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/customButton.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';

// ignore: must_be_immutable
class DonationDetailView extends StatelessWidget {
  DonationDetailView({Key? key, this.onTapMint}) : super(key: key);

  Function()? onTapMint;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.greenAccent,
      height: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  height: 366,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: AssetImage(AppImages.gamingImage2),
                          fit: BoxFit.fill)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 31,
                              width: 31,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.gray75),
                                shape: BoxShape.circle,
                              ),
                              child: IconButtonWidget(
                                ontap: () {
                                  // Get.back();
                                  Navigator.pop(context);
                                },
                                height: 31,
                                width: 31,
                                containerColor: AppColors.bgGradient2,
                                widget: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: AppColors.mainColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                  // Get.back();
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
                      ],
                    ),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSizedBoxHeight(height: 15),
                CustomText(
                    textStyle: AppStyle.textStyle17Bold,
                    title: 'Let’s see where we can go'),
                CustomSizedBoxHeight(height: 15),
                Row(
                  children: [
                    Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: Image.asset("")),
                    CustomSizedBoxWidth(width: 5),
                    CustomText(
                        textStyle: AppStyle.textStyle11SemiBoldWhite600,
                        title: 'SpShark'),
                  ],
                ),
                CustomSizedBoxHeight(height: 15),
                CustomText(
                    textAlign: TextAlign.start,
                    textStyle: AppStyle.textStyle11SemiBoldWhite600,
                    title:
                        'New cool NFT ready for a mint! Support my channel for \ncreating a lot of new high-quality content!'),
                CustomSizedBoxHeight(height: 13),
                CustomText(
                    textAlign: TextAlign.start,
                    textStyle: AppStyle.textStyle11SemiBoldWhite600,
                    title: 'Price'),
                CustomSizedBoxHeight(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.logopng, height: 25, width: 25),
                        CustomSizedBoxWidth(width: 5),
                        CustomText(
                            textStyle: AppStyle.textStyle12Regular, title: '1')
                      ],
                    ),
                    CustomButton(
                      width: 98,
                      height: 29,
                      title: 'Mint',
                      icon: Icons.arrow_forward_ios,
                      ontap: onTapMint!,
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFFBD64FC),
                          Color(0xFF6644F1),
                        ],
                        stops: [
                          0.118,
                          0.9035,
                        ],
                        transform: GradientRotation(254.96 * (3.1415926 / 180)),
                      ),
                      AppStyle: AppStyle.textStyle13SemiBold,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
