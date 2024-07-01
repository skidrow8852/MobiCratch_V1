import 'dart:convert';
import 'dart:io';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/customtext.dart';
import 'FollowersComponents/followersList.dart';
import 'package:http/http.dart' as http;

class Followers extends StatefulWidget {
  const Followers({Key? key}) : super(key: key);

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  late File imageFile;
  get tabController => null;
  bool loading = true;
  bool isVisible2 = false;
  String wallet = "";
  int userFollwersCount = 0;
  int followersOnline = 0;
  String token = "";
  List<dynamic> allUsers = [];
  List<dynamic> allFollowers = [];
  List<dynamic> allFollowersOnline = [];

  Future<void> getUsersData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var tokena = prefs.getString('token') ?? '';
      var walleta = prefs.getString('wallet_address') ?? '';
      setState(() {
        wallet = walleta;
        token = tokena;
      });
      final response = await http.get(
          Uri.parse('https://account.cratch.io/api/users/all/$walleta'),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line// Add this line
          });
      if (response.statusCode == 200 &&
          json.decode(response.body) is List &&
          json.decode(response.body).length > 0) {
        var data = jsonDecode(response.body);
        var userData = data.firstWhere((object) =>
            object['userId']?.toLowerCase() == walleta.toLowerCase());

        for (var dt in userData['followers']) {
          var dbs = data.firstWhere(
              (object) => object['userId']?.toLowerCase() == dt?.toLowerCase());

          allFollowers.add(dbs);
          if (dbs['isOnline']) {
            allFollowersOnline.add(dbs);
            setState(() {
              followersOnline++;
            });
          }
        }

        setState(() {
          userFollwersCount = userData['followers']?.length ?? 0;
          allUsers = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        print('Failed to delete video');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUsersData();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWithNavBar(
      screen: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgGradient2,
                AppColors.bgGradient2,
                AppColors.bgGradient1,
              ],
            ),
          ),
          child: Scaffold(
              extendBody: true,
              backgroundColor: Colors.transparent,
              appBar: const TopBar(),
              body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23.w),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      CustomSizedBoxHeight(height: 30.h),
                      Text("Followers",
                          style: TextStyle(
                              fontSize: 17.h,
                              fontWeight: FontWeight.w700,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: <Color>[
                                    AppColors.txtGradient1,
                                    AppColors.txtGradient2
                                    //add more color here.
                                  ],
                                ).createShader(const Rect.fromLTWH(
                                    0.0, 0.0, 200.0, 100.0)))),
                      CustomSizedBoxHeight(height: 25.h),
                      DefaultTabController(
                        length: 3,
                        initialIndex: 0,
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TabBar(
                              labelColor: Colors.white,
                              // unselectedLabelColor: Colors.black,
                              unselectedLabelStyle: TextStyle(
                                color: AppColors.whiteA700,
                              ),
                              labelPadding: const EdgeInsets.all(10),
                              labelStyle: TextStyle(
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      tileMode: TileMode.repeated,
                                      colors: [
                                        AppColors.redAccsent,
                                        AppColors.mainColor,
                                        AppColors.mainColor,
                                        AppColors.txtGradient4,
                                        AppColors.txtGradient4,
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(
                                          0.0, 0.0, 150.0, 70.0),
                                    ),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700),
                              controller: tabController,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.redAccsent,
                                      AppColors.mainColor,
                                      AppColors.bgGradient3,
                                    ],
                                  )),
                              indicatorPadding: const EdgeInsets.only(
                                  left: 30, right: 30, bottom: 20, top: 44),
                              tabs: [
                                Tab(
                                  child: Column(
                                    children: [
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite600,
                                          title: "All Followers"),
                                      CustomSizedBoxHeight(height: 3.w),
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite400,
                                          title: "$userFollwersCount"),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Column(
                                    children: [
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite600,
                                          title: "Followers Online"),
                                      CustomSizedBoxHeight(height: 3.w),
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite400,
                                          title: "$followersOnline"),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Column(
                                    children: [
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite600,
                                          title: "Connect"),
                                      CustomSizedBoxHeight(height: 3.w),
                                      CustomText(
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite400,
                                          title: "+"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            loading
                                ? Container(
                                    height: 500.h,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Container(
                                      height: 550.h,
                                      padding: const EdgeInsets.only(
                                          left: 23,
                                          right: 23,
                                          top: 10,
                                          bottom: 100),
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Color(0xFF373953)))),
                                      child: TabBarView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          Column(
                                            children: [
                                              Expanded(
                                                  child: ListView.builder(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount:
                                                          allFollowers.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FollowersList(
                                                            user: allFollowers[
                                                                index],
                                                            token: token,
                                                            wallet: wallet);
                                                      })),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Expanded(
                                                  child: ListView.builder(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount:
                                                          allFollowersOnline
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FollowersList(
                                                            user:
                                                                allFollowersOnline[
                                                                    index],
                                                            token: token,
                                                            wallet: wallet);
                                                      })),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Expanded(
                                                  child: ListView.builder(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount:
                                                          allUsers.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FollowersList(
                                                            user:
                                                                allUsers[index],
                                                            token: token,
                                                            wallet: wallet);
                                                      })),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ))
                          ],
                        ),
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }
}
