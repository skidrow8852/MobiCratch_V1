import 'dart:convert';
import 'package:cratch/View/Content/content_View.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/color_constant.dart';
import '../../Utils/app_style.dart';
import '../Donation/BottomSheet.dart';
import '../Donation/NFT_View/SuccessNft.dart';
import '../Donation/NFT_View/donationDetailScreen.dart';
import 'Components/ProfileDetails.dart';
import 'Components/RoundButtonProfile.dart';
import 'Components/circularProfile.dart';
import 'Components/profileListView.dart';
import 'package:http/http.dart' as http;
import 'Components/SavedLives.dart';
import 'Components/Live.dart';

class ProfileView extends StatefulWidget {
  final String wallet;
  final String token;

  const ProfileView({Key? key, required this.wallet, required this.token})
      : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String address = "";
  Map<String, dynamic> alluserData = {};
  Map<String, dynamic> profileLive = {};
  List<dynamic> userVideos = [];
  bool isFollowing = false;

  void handleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  List<dynamic> userSavedLives = []; // change data type to List<dynamic>
  bool isLoading = true; // Add a boolean flag to track loading state
  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/users/profile/${widget.wallet.toLowerCase()}/${address.toLowerCase()}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      final userData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final response1 = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/video/user/${userData['_id']}/${address.toLowerCase()}'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
        final response2 = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/live/user/saved/public/${userData['_id']}/$address'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );

        final response3 = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/live/profile/user/${userData['_id']}/$address'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );

        if (response1.statusCode == 200 &&
            response2.statusCode == 200 &&
            response3.statusCode == 200) {
          final userVideo = jsonDecode(response1.body);
          final userSaved = jsonDecode(response2.body);
          final live = jsonDecode(response3.body);
          setState(() {
            alluserData = userData.containsKey('status') ? {} : userData;
            userVideos = userVideo is Map<String, dynamic> ? [] : userVideo;
            userSavedLives = userSaved is Map<String, dynamic> ? [] : userSaved;
            if (!live.containsKey('status')) {
              profileLive = live;
            } else {
              profileLive = {};
            }

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          throw Exception('Failed to load user video data');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<Map<String, String>> _getWalletAddressAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    var addressa = prefs.getString('wallet_address') ?? '';
    setState(() {
      address = addressa.toLowerCase();
    });
    return {'address': addressa};
  }

  @override
  void initState() {
    super.initState();
    _getWalletAddressAndToken().then((value) {
      getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var totalElements =
        userSavedLives.length + userVideos.length + [profileLive].length;
    var hasMultipleElements = totalElements > 1;
    return DrawerWithNavBar(
      screen: Container(
        color: const Color.fromRGBO(28, 31, 32, 1),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: alluserData['ProfileCover'] != null
                  ? DecorationImage(
                      image: NetworkImage(alluserData['ProfileCover'] ?? ""),
                      alignment: Alignment.topCenter,
                    )
                  : null, // handle null value
            ),
            child: Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: const TopBar(),
                body: isLoading
                    ? Container(
                        color: AppColors.bgGradient2,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ))
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          SingleChildScrollView(
                            child: Stack(children: [
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: 200.h, bottom: 50.h),
                                  child: Container(
                                      height: (userSavedLives.isNotEmpty ||
                                              userVideos.isNotEmpty ||
                                              profileLive.isNotEmpty)
                                          ? (hasMultipleElements ? null : 631.h)
                                          : 631.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30.r)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.bgGradient2,
                                              AppColors.bgGradient2,
                                              AppColors.bgGradient1,
                                            ]),
                                      ),
                                      child: Column(
                                        children: [
                                          ///All details
                                          ProfileDetails(
                                            username:
                                                alluserData['username'] ?? "",
                                            description:
                                                alluserData['about'] ?? "",
                                            followers:
                                                alluserData['followers'] != null
                                                    ? alluserData['followers']
                                                        .length
                                                    : 0,
                                          ),

                                          ///All Round Buttons
                                          alluserData['userId']
                                                      ?.toLowerCase() ==
                                                  address.toLowerCase()
                                              ? Center(
                                                  child: SizedBox(
                                                    width: 160,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (tabController
                                                                .index ==
                                                            1) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    ContentView()),
                                                          );
                                                        } else {
                                                          tabController
                                                              .jumpToTab(1);
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              AppColors
                                                                  .redAccsent,
                                                              AppColors
                                                                  .mainColor,
                                                              AppColors
                                                                  .mainColor,
                                                              AppColors
                                                                  .redAccsent,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 10),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.settings,
                                                                color: Colors
                                                                    .white,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Manage Videos',
                                                                style: AppStyle
                                                                    .textStyle12regularWhite,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : RoundButtonProfile(
                                                  token: widget.token,
                                                  address: address,
                                                  alluserData: alluserData,
                                                  onTapFollow: handleFollow,
                                                  onTapMessage: () {},
                                                  onTapSupport: () {
                                                    showModalBottomSheet(
                                                      barrierColor: AppColors
                                                          .gray
                                                          .withOpacity(0.4),
                                                      backgroundColor: AppColors
                                                          .bgGradient2A,
                                                      isDismissible: true,
                                                      useSafeArea: true,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25.r),
                                                          topRight:
                                                              Radius.circular(
                                                                  25.r),
                                                        ),
                                                      ),
                                                      isScrollControlled: true,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return BottomSheetView(
                                                          wallet: alluserData[
                                                                  'userId']
                                                              .toLowerCase(),
                                                          onTapNft: () {
                                                            Get.to(
                                                                showModalBottomSheet(
                                                              barrierColor:
                                                                  AppColors.gray
                                                                      .withOpacity(
                                                                          0.4),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .bgGradient2A,
                                                              isDismissible:
                                                                  true,
                                                              useSafeArea: true,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          25.r),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          25.r),
                                                                ),
                                                              ),
                                                              isScrollControlled:
                                                                  true,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return DonationDetailView(
                                                                    onTapMint:
                                                                        () {
                                                                  Get.to(
                                                                      showModalBottomSheet(
                                                                    barrierColor:
                                                                        AppColors
                                                                            .gray
                                                                            .withOpacity(0.4),
                                                                    backgroundColor:
                                                                        AppColors
                                                                            .bgGradient2A,
                                                                    isDismissible:
                                                                        true,
                                                                    useSafeArea:
                                                                        true,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(25.r),
                                                                        topRight:
                                                                            Radius.circular(25.r),
                                                                      ),
                                                                    ),
                                                                    isScrollControlled:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return const NftSuccessBottomSheet();
                                                                    },
                                                                  ));
                                                                });
                                                              },
                                                            ));
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),

                                          profileLive.isNotEmpty &&
                                                  profileLive.isNotEmpty
                                              ? LiveViewProfile(
                                                  token: widget.token,
                                                  userWallet: address,
                                                  video: profileLive)
                                              : const Center(),

                                          if (userSavedLives.isNotEmpty)
                                            Column(
                                              children: List<Widget>.generate(
                                                  userSavedLives.length,
                                                  (index) {
                                                return Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              bottom: 5),
                                                      child: SavedLives(
                                                          userWallet: address,
                                                          token: widget.token,
                                                          video: userSavedLives[
                                                                  index] ??
                                                              []),
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          if (userVideos.isNotEmpty)
                                            Column(
                                              children: List<Widget>.generate(
                                                  userVideos.length, (index) {
                                                return Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              bottom: 5),
                                                      child: ProfileListView(
                                                          video: userVideos[
                                                                  index] ??
                                                              []),
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                        ],
                                      ))),

                              /// Profile image widget
                              CircularProfile(
                                profileCover: alluserData['ProfileAvatar'] ??
                                    '', // provide default value
                              ),
                            ]),
                          ),
                        ],
                      )),
          ),
        ),
      ),
    );
  }

  /// Get from gallery
}
