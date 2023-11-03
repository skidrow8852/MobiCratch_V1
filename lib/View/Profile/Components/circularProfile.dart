import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/color_constant.dart';

class CircularProfile extends StatelessWidget {
  final String? profileCover;
  const CircularProfile({Key? key, this.profileCover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: 140.h,
        ),
        child: InkWell(
          onTap: () {
            // _getFromGallery();
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainColor,
                    blurRadius: 10.0, // soften the shadow
                    spreadRadius: 2.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      4.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                borderRadius: BorderRadius.circular(90),
                border: Border.all(color: AppColors.bgGradient2, width: 2)),
            child: Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: SizedBox(
                  height: 110.h,
                  width: 110.w,
                  child: CircleAvatar(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: NetworkImage(profileCover ?? ""),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
