import 'package:flutter/material.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({Key? key}) : super(key: key);

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
            image: AssetImage(AppImages.success),
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
                Padding(
                  padding: const EdgeInsets.only(top: 400),
                  child: CustomText(
                    textAlign: TextAlign.center,
                    title: 'Success!',
                    textStyle: AppStyle.textStyle16Bold600,
                  ),
                ),
                CustomSizedBoxHeight(height: 7),
                CustomText(
                  textAlign: TextAlign.center,
                  title: 'Your donation was sent to skidrowgames ',
                  textStyle: AppStyle.textStyle12regularWhite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
