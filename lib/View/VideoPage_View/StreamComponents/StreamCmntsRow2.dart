import 'dart:convert';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/CreateALiveStream/createStream_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import 'package:http/http.dart' as http;

import '../../../widgets/customtext.dart';

// ignore: must_be_immutable
class StreamCmntsRow2 extends StatefulWidget {
  Function()? ontap;
  Map<String, dynamic> video;
  String token;
  String walletUser;
  String type;

  StreamCmntsRow2(
      {this.ontap,
      required this.video,
      required this.type,
      required this.walletUser,
      required this.token});

  @override
  State<StreamCmntsRow2> createState() => _StreamCmntsRow2State();
}

class _StreamCmntsRow2State extends State<StreamCmntsRow2> {
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  bool isFollowing = false;

  void isFollow() {
    if (widget.video['creator']['followers']
        .contains(widget.walletUser.toLowerCase())) {
      isFollowing = true;
      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
          // Return a loading indicator while waiting for shared preferences to load
          return const CircularProgressIndicator();
        }

        final prefs = snapshot.data!;
        var token = prefs.getString('token') ?? '';
        var address = prefs.getString('wallet_address') ?? '';

        String formattedFollowers = widget.video['creator']['followers'] != null
            ? '${_formatNumber(widget.video['creator']['followers']!.length)}'
            : "";
        String text = widget.video['creator']['followers']?.length > 1
            ? "followers"
            : 'follower';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ProfileView(
                          wallet: widget.video['creator']['userId'],
                          token: token,
                        ),
                      ),
                    );

                    // Navigate to another page or perform some other action
                  },
                  child: CircleAvatar(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: NetworkImage(
                          widget.video['creator']['ProfileAvatar'] ?? ""),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  )),
                ),
                CustomSizedBoxWidth(width: 10.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(
                          textStyle: AppStyle.textStyle12regularWhite,
                          title: widget.video['creator']['username'].length > 10
                              ? "${widget.video['creator']['username'].substring(0, 10)}..."
                              : widget.video['creator']['username'],
                        ),
                        CustomSizedBoxWidth(width: 4),
                        widget.video['creator']['isVerified'] != null &&
                                widget.video['creator']['isVerified']
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
                    CustomSizedBoxHeight(height: 5.h),
                    CustomText(
                        textStyle: AppStyle.textStyle10Regular.copyWith(
                          color: Colors.grey,
                        ),
                        title: "$formattedFollowers $text"),
                  ],
                ),
              ],
            ),
            widget.video['creator']['userId']?.toLowerCase() ==
                    address.toLowerCase()
                ? SizedBox(
                    width: 160,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.type == "video" || widget.type != "live") {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          tabController.jumpToTab(1);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const CreateStream()),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.redAccsent,
                              AppColors.mainColor,
                              AppColors.mainColor,
                              AppColors.redAccsent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.type == "video" ||
                                        widget.type == "stream"
                                    ? 'Manage Videos'
                                    : 'Manage Stream',
                                style: AppStyle.textStyle12regularWhite,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      GestureDetector(
                        onTap: widget.ontap,
                        child: Container(
                          height: 28.h,
                          width: 87.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff2B59FE),
                                    Color(0xff3485FF),
                                  ])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20.w,
                              ),
                              CustomSizedBoxWidth(width: 5.w),
                              CustomText(
                                  textStyle:
                                      AppStyle.textStyle11SemiBoldWhite600,
                                  title: 'Support'),
                            ],
                          ),
                        ),
                      ),
                      CustomSizedBoxWidth(width: 5.w),
                      GestureDetector(
                        onTap: () async {
                          await followUser(widget.walletUser.toLowerCase(),
                              widget.video['creator']['userId'].toLowerCase());
                        },
                        child: Container(
                          height: 28.h,
                          width: 87.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: isFollowing
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF5B40EF),
                                      Color.fromARGB(255, 235, 92, 121),
                                    ],
                                    stops: [
                                      0.2158,
                                      0.9918,
                                    ],
                                    transform:
                                        GradientRotation(269 * (3.14 / 180)),
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFAC5EFA),
                                      Color(0xFF5B40EF),
                                    ],
                                    stops: [
                                      0.0,
                                      1.0,
                                    ],
                                    transform:
                                        GradientRotation(93.8 * (3.14 / 180)),
                                  ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                isFollowing
                                    ? Icons.person_2_outlined
                                    : Icons.person_add,
                                color: Colors.white,
                                size: 20.w,
                              ),
                              CustomSizedBoxWidth(width: 5.w),
                              CustomText(
                                  textStyle:
                                      AppStyle.textStyle11SemiBoldWhite600,
                                  title: isFollowing ? "Following" : 'Follow'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
          ],
        );
      },
    );
  }
}
