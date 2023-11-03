import 'package:cratch/View/Messages/ChatView.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../../Utils/app_style.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/customtext.dart';

// ignore: must_be_immutable
class FollowersList extends StatelessWidget {
  dynamic user;

  final String token;

  FollowersList({
    Key? key,
    required this.user,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0), // Adjust the vertical padding value as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ProfileView(
                      wallet: user['userId'],
                      token: token,
                    ),
                    withNavBar: true,
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(user['ProfileAvatar']),
                      ),
                    ),
                    CustomSizedBoxWidth(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  textStyle: AppStyle.textStyle12regularWhite,
                                  title: user['username'].length >= 12
                                      ? "${user['username'].substring(0, 12)}..."
                                      : "${user['username']}",
                                ),
                                CustomSizedBoxWidth(width: 4),
                                user['isVerified'] != null && user['isVerified']
                                    ? const Center(
                                        child: Icon(
                                          FontAwesomeIcons.solidCircleCheck,
                                          color: Color(0xffeec716),
                                          size: 12,
                                        ),
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ],
                        ),
                        CustomSizedBoxHeight(height: 3.w),
                        CustomText(
                          textStyle: AppStyle.textStyle11SemiBoldBlack,
                          title: "${user['followers'].length} Followers",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff2B59FE),
                      Color(0xff3485FF),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 22.w,
                ),
              ),
              CustomSizedBoxWidth(width: 10.w),
              Container(
                height: 40.h,
                width: 40.w,
                child: GestureDetector(
                  onTap: () {
                    // Handle the tap event here
                    // Add your desired functionality

                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ChatView(userData: user),
                      withNavBar: false,
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFA95DFA),
                          Color(0xFF6243E9),
                        ],
                        stops: [
                          0.15,
                          0.8437,
                        ],
                        transform: GradientRotation(138.25 / 360),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: SvgPicture.asset(
                        AppImages.imgSearch,
                        height: 5,
                        width: 5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
