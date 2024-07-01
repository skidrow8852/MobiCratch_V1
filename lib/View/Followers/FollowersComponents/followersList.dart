import 'package:cratch/Provider/following_provider.dart';
import 'package:cratch/View/Messages/ChatView.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../../../Utils/app_style.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/customtext.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: must_be_immutable
class FollowersList extends StatelessWidget {
  dynamic user;

  final String token;
  final String wallet;

  FollowersList({
    Key? key,
    required this.user,
    required this.token,
    required this.wallet,
  }) : super(key: key);

  Future<void> followUser(String userWallet, String userDataWallet) async {
    try {
      await http.put(
          Uri.parse(
              'https://account.cratch.io/api/users/follow/${userDataWallet.toLowerCase()}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          },
          body: json.encode({"value": userWallet.toLowerCase()}));
    } catch (e) {
      print(e);
    }
  }

  Future<void> unfollowUser(String userWallet, String userDataWallet) async {
    try {
      await http.put(
          Uri.parse(
              'https://account.cratch.io/api/users/unfollow/${userDataWallet.toLowerCase()}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          },
          body: json.encode({"value": userWallet.toLowerCase()}));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final followingsState = Provider.of<FollowingProvider>(context);
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          followingsState.followings.contains(user['userId'])
                              ? const [
                                  Color.fromARGB(255, 24, 186, 255),
                                  Color.fromRGBO(174, 81, 255, 1),
                                ]
                              : const [
                                  Color(0xff2B59FE),
                                  Color(0xff3485FF),
                                ],
                    ),
                  ),
                  child: followingsState.followings.contains(user['userId'])
                      ? IconButton(
                          onPressed: () async {
                            followingsState.removeFollowings(user['userId']);
                            await unfollowUser(wallet.toLowerCase(),
                                user['userId'].toLowerCase());
                          },
                          icon: Icon(
                            Icons.person_2_outlined,
                            color: Colors.white,
                            size: 22.w,
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            followingsState.addFollowings(user['userId']);
                            await followUser(wallet.toLowerCase(),
                                user['userId'].toLowerCase());
                          },
                          icon: Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 22.w,
                          ),
                        )),
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
