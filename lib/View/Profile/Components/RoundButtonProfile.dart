import 'dart:convert';

import 'package:cratch/View/Messages/ChatView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';
import 'package:http/http.dart' as http;

class RoundButtonProfile extends StatefulWidget {
  final Map<String, dynamic> alluserData;
  final Function()? onTapSupport;
  final Function()? onTapFollow;
  final Function()? onTapMessage;
  final String address;
  final String token;

  const RoundButtonProfile({
    Key? key,
    required this.alluserData,
    required this.token,
    required this.onTapFollow,
    required this.onTapMessage,
    required this.onTapSupport,
    required this.address,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RoundButtonProfileState createState() => _RoundButtonProfileState();
}

class _RoundButtonProfileState extends State<RoundButtonProfile> {
  bool isFollowing = false;
  Map<String, dynamic> currentUser = {};

  void isFollow() {
    if (widget.alluserData['followers']
        .contains(widget.address.toLowerCase())) {
      isFollowing = true;
      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if the user is following when the widget is first created

    isFollow();
  }

  Future<void> followUser(String userWallet, String userDataWallet) async {
    try {
      if (isFollowing == false) {
        setState(() {
          isFollowing = true;
        });
        await http.put(
            Uri.parse(
                'https://account.cratch.io/api/users/follow/${userDataWallet.toLowerCase()}'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: json.encode({"value": userWallet.toLowerCase()}));
      } else if (isFollowing == true) {
        setState(() {
          isFollowing = false;
        });
        await http.put(
            Uri.parse(
                'https://account.cratch.io/api/users/unfollow/${userDataWallet.toLowerCase()}'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: json.encode({"value": userWallet.toLowerCase()}));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Return a loading indicator while waiting for shared preferences
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Get wallet from shared preferences

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButtonWidget(
                      ontap: widget.onTapSupport!,
                      height: 40,
                      width: 40,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff6d59e8),
                          Color(0xff1f15a1),
                        ],
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
                      widget: Icon(
                        Icons.favorite,
                        color: AppColors.whiteA700,
                        size: 18,
                      ),
                    ),
                    CustomSizedBoxHeight(height: 10),
                    CustomText(
                      textAlign: TextAlign.center,
                      title: 'Support',
                      textStyle: AppStyle.textStyle8White600,
                    ),
                  ],
                ),
                CustomSizedBoxWidth(width: 20),
                Column(
                  children: [
                    IconButtonWidget(
                        ontap: () async {
                          await followUser(widget.address.toLowerCase(),
                              widget.alluserData['userId'].toLowerCase());
                        },
                        height: 50,
                        width: 50,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xffc366fc),
                            Color(0xff553eee),
                          ],
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
                        widget: isFollowing
                            ? Icon(Icons.person_2_outlined,
                                color: AppColors.whiteA700, size: 24)
                            : Icon(Icons.person_add,
                                color: AppColors.whiteA700, size: 24)),
                    CustomSizedBoxHeight(height: 10),
                    CustomText(
                      textAlign: TextAlign.center,
                      title: isFollowing ? "Following" : 'Follow',
                      textStyle: AppStyle.textStyle8White600,
                    ),
                  ],
                ),
                CustomSizedBoxWidth(width: 20),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ChatView(userData: widget.alluserData),
                          withNavBar: false,
                        );
                      },
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              20.0), // Set the border radius for rounding
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff6d59e8),
                              Color(0xff1f15a1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainColor,
                              blurRadius: 20.0,
                              spreadRadius: -4,
                              offset: const Offset(
                                0.0,
                                4.0,
                              ),
                            )
                          ],
                        ),
                        child: Center(
                          child:
                              SvgPicture.asset(AppImages.imgSearch, height: 14),
                        ),
                      ),
                    ),
                    CustomSizedBoxHeight(height: 10),
                    CustomText(
                      textAlign: TextAlign.center,
                      title: 'Message',
                      textStyle: AppStyle.textStyle8White600,
                    ),
                  ],
                ),
              ],
            ),
            CustomSizedBoxHeight(height: 10),
          ],
        );
      },
    );
  }
}
