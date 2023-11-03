import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/customtext.dart';

class SaveChanges extends StatelessWidget {
  const SaveChanges({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xff165E54),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              child: Row(
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      //color: Color(0xff85C8BF),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r)),
                      child: Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.white,
                      )),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Changes was saved successfully!',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
          height: 41.h,
          width: 310.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: AppColors.textField),
          child: Center(
              child: CustomText(
            textStyle: AppStyle.textStyle12offWhite,
            title: "Save Changes",
          ))),
    );
  }
}
