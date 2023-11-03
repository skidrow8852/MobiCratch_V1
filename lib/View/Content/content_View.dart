import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/Provider/EditNfts_provider.dart';
import 'package:cratch/Provider/uploadVideo.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../Utils/image_constant.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/Sizebox/sizedboxheight.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/customButton.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/customtext.dart';
import '../Profile/profile_view.dart';
import 'BottomSheet/BottomSheet_View.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomSheet/EditNFT.dart';
import 'BottomSheet/EditVideo.dart';
import 'BottomSheet/staticsBottomSheet.dart';

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class ContentView extends StatefulWidget {
  ContentView({Key? key}) : super(key: key);

  @override
  _ContentViewState createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView>
    with TickerProviderStateMixin {
  late TabController tabController;
  late TabController nestedTabController;
  bool loading = false;
  bool isVisible2 = false;
  bool isVideosLoading = true;
  bool isNftsLoading = true;
  bool isNftsLoadingOwned = true;
  bool isLivesLoading = true;
  int selectedContainer = 1;

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  List<dynamic> userLives = [];
  List<dynamic> userOwnedNfts = [];
  String streamId = "";

  Future<void> getUserVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var userId = prefs.getString('userId') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      final response1 = await http.get(
        Uri.parse('https://account.cratch.io/api/video/user/$userId/$wallet'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response1.statusCode == 200) {
        try {
          final videostate =
              Provider.of<UploadVideoProvider>(context, listen: false);
          videostate.setUploadVideo(json.decode(response1.body) is List
              ? json.decode(response1.body)
              : []);
          setState(() {
            isVideosLoading = false;
          });
        } catch (e) {
          setState(() {
            isVideosLoading = false;
          });
        }
      }
      final response2 = await http.get(
        Uri.parse('https://account.cratch.io/api/live/user/saved/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response2.statusCode == 200) {
        isLivesLoading = false;
        userLives = json.decode(response2.body) is List
            ? json.decode(response2.body)
            : [];
        setState(() {
          isLivesLoading = false;
          userLives = json.decode(response2.body) is List
              ? json.decode(response2.body)
              : [];
        });
      }
      setState(() {
        isVideosLoading = false;
        isNftsLoading = false;
        isLivesLoading = false;
      });
    } catch (e) {
      setState(() {
        isVideosLoading = false;
        isNftsLoading = false;
        isLivesLoading = false;
      });
      print(e);
    }
  }

  Future<String>? getOwnerTokenId(dynamic video) async {
    final prefs = await SharedPreferences.getInstance();
    var wallet = prefs.getString('wallet_address') ?? '';
    if (video['owners'] != null) {
      final owner = video['owners'].firstWhere(
        (data) => data['userId']?.toLowerCase() == wallet.toLowerCase(),
        orElse: () => null,
      );
      return owner['tokenId'].toString();
    }
    return "1";
  }

  Future<void> getNfts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      final response3 = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/nft/user/${wallet.toLowerCase()}/${wallet.toLowerCase()}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response3.statusCode == 200) {
        try {
          final responseData = json.decode(response3.body);

          if (responseData.isNotEmpty) {
            try {
              final nftstate =
                  Provider.of<EditNftsProvider>(context, listen: false);
              nftstate.setEditNfts(responseData is List ? responseData : []);
              setState(() {
                isNftsLoading = false;
              });
            } catch (e) {
              print(e);
              setState(() {
                isNftsLoading = false;
              });
            }
          } else {
            // Handle the case where the API response is not a list
            setState(() {
              isNftsLoading = false;
            });
          }
        } catch (e) {
          // Handle JSON decoding error
          setState(() {
            isNftsLoading = false;
          });
        }
      } else {
        // Handle the API response status code other than 200
        setState(() {
          isNftsLoading = false;
        });
      }

      final response4 = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/nft/all/${wallet.toLowerCase()}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      var data = json.decode(response4.body);
      if (response4.statusCode == 200) {
        setState(() {
          isNftsLoadingOwned = false;
          userOwnedNfts = data is List
              ? data.where((element) => element["videoId"] != null).toList()
              : [];
        });
      } else {
        setState(() {
          isNftsLoadingOwned = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: 3, vsync: this); // Updated length to 3
    nestedTabController =
        TabController(length: 2, vsync: this); // Added nestedTabController
    getUserVideos();
    getNfts();
  }

  @override
  void dispose() {
    tabController.dispose();
    nestedTabController.dispose(); // Dispose of nestedTabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videostate = Provider.of<UploadVideoProvider>(context);
    final nftstate = Provider.of<EditNftsProvider>(context);
    return DrawerWithNavBar(
        screen: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  AppColors.bgGradient2,
                  AppColors.bgGradient2,
                  AppColors.bgGradient1,
                ])),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopBar(),
                  CustomSizedBoxHeight(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientTextWidget(
                          size: 17.h,
                          text: 'Content',
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              barrierColor: AppColors.gray.withOpacity(0.4),
                              backgroundColor: AppColors.bgGradient2A,
                              isDismissible: true,
                              useSafeArea: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25.r),
                                  topRight: Radius.circular(25.r),
                                ),
                              ),
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomSheetContentCreateNFt(
                                    nfts: videostate.allVideos);
                              },
                            );
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
                                  ]),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10),
                              child: Text(
                                '+ NFT collection',
                                style: AppStyle.textStyle12regularWhite,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                                  const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                                ),
                              fontSize: 14.sp,
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
                              left: 40, right: 40, bottom: 20, top: 44),
                          tabs: const [
                            Tab(text: 'Videos'),
                            Tab(text: 'Lives'),
                            Tab(text: 'NFTs'),
                          ],
                        ),
                        // const SizedBox(height: 20),
                        SizedBox(
                          // height: 480,
                          height: MediaQuery.of(context).size.height * 0.74,
                          child: TabBarView(
                            physics: const BouncingScrollPhysics(),
                            controller: tabController,
                            children: [
                              ///Vides
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: isVideosLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : videostate.allVideos.isNotEmpty
                                          ? ListView.builder(
                                              padding: const EdgeInsets.only(
                                                  bottom: 50),
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount:
                                                  videostate.allVideos.length,
                                              itemBuilder: (context, index) {
                                                var viewsCount = videostate
                                                    .allVideos[index]['views'];
                                                var createdAt = DateTime.parse(
                                                    videostate.allVideos[index]
                                                        ['createdAt']);
                                                var formattedViews;
                                                if (viewsCount >= 1000000) {
                                                  formattedViews =
                                                      '${(viewsCount / 1000000).toStringAsFixed(1)}M';
                                                } else if (viewsCount >= 1000) {
                                                  formattedViews =
                                                      '${(viewsCount / 1000).toStringAsFixed(1)}K';
                                                } else {
                                                  formattedViews =
                                                      '$viewsCount';
                                                }
                                                return Container(
                                                  width: 340,
                                                  height: 206,
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Stack(
                                                      children: [
                                                        CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          imageUrl: videostate
                                                                      .allVideos[
                                                                  index]
                                                              ['thumbnail'],
                                                          progressIndicatorBuilder:
                                                              (context, url,
                                                                      downloadProgress) =>
                                                                  Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress,
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  downloadProgress
                                                                              .progress !=
                                                                          null
                                                                      ? '${(downloadProgress.progress! * 100).toInt()}%'
                                                                      : "...",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color(
                                                                          0xFF757575)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                        Positioned(
                                                          bottom: 20.h,
                                                          right: 12.w,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
                                                            ),
                                                            child: Text(
                                                              videostate.allVideos[
                                                                      index]
                                                                  ['duration'],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white, // Change the text color to white
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter,
                                                                        colors: [
                                                                  Colors
                                                                      .transparent,
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.25),
                                                                  AppColors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                  AppColors
                                                                      .black,
                                                                ])),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 12.h,
                                                          right: 11.w,
                                                          child:
                                                              IconButtonWidget(
                                                            ontap: () {
                                                              showModalBottomSheet(
                                                                barrierColor:
                                                                    AppColors
                                                                        .gray
                                                                        .withOpacity(
                                                                            0.4),
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
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return BottomSheetContentEditVideo(
                                                                    video: videostate
                                                                            .allVideos[
                                                                        index],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            height: 37,
                                                            width: 37,
                                                            containerColor:
                                                                AppColors
                                                                    .tagCancel
                                                                    .withOpacity(
                                                                        0.7),
                                                            widget: Icon(
                                                              Icons.edit,
                                                              color: AppColors
                                                                  .mainColor,
                                                              size: 18,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 12.h,
                                                          right: 55.w,
                                                          child:
                                                              IconButtonWidget(
                                                            ontap: () {
                                                              showModalBottomSheet(
                                                                barrierColor:
                                                                    AppColors
                                                                        .gray
                                                                        .withOpacity(
                                                                            0.4),
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
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return BottomSheetContentStatic(
                                                                    video: videostate
                                                                            .allVideos[
                                                                        index],
                                                                    imageType:
                                                                        "video",
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            height: 37,
                                                            width: 37,
                                                            containerColor:
                                                                AppColors
                                                                    .tagCancel
                                                                    .withOpacity(
                                                                        0.7),
                                                            widget: SvgPicture
                                                                .asset(AppImages
                                                                    .Vectorsvg),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 16.h,
                                                          left: 12.w,
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        320, // replace with your preferred max width
                                                                    child: Text(
                                                                      videostate.allVideos[index]
                                                                              [
                                                                              'title'] ??
                                                                          "",
                                                                      softWrap:
                                                                          true,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: AppStyle
                                                                          .textStyle12Regular,
                                                                    ),
                                                                  ),
                                                                  CustomText(
                                                                      textStyle:
                                                                          AppStyle
                                                                              .textStyle10Regular,
                                                                      title:
                                                                          '$formattedViews views • ${timeago.format(createdAt, locale: 'en')}'),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              child: Column(children: [
                                                Container(
                                                  height: 20,
                                                ),
                                                const Text(
                                                  "You didn't share any videos yet!",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ]),
                                            )),

                              ///Lives
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: isLivesLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : userLives.isNotEmpty
                                          ? ListView.builder(
                                              padding: const EdgeInsets.only(
                                                  bottom: 50),
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: userLives.length,
                                              itemBuilder: (context, index) {
                                                var viewsCount =
                                                    userLives[index]['views'];
                                                var createdAt = DateTime.parse(
                                                    userLives[index]
                                                        ['createdAt']);
                                                var formattedViews;
                                                if (viewsCount >= 1000000) {
                                                  formattedViews =
                                                      '${(viewsCount / 1000000).toStringAsFixed(1)}M';
                                                } else if (viewsCount >= 1000) {
                                                  formattedViews =
                                                      '${(viewsCount / 1000).toStringAsFixed(1)}K';
                                                } else {
                                                  formattedViews =
                                                      '$viewsCount';
                                                }

                                                return Container(
                                                  width: 340,
                                                  height: 206,
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Stack(
                                                      children: [
                                                        CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          imageUrl: userLives[
                                                                      index][
                                                                  'thumbnail'] ??
                                                              "" ??
                                                              "",
                                                          progressIndicatorBuilder:
                                                              (context, url,
                                                                      downloadProgress) =>
                                                                  Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress,
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  downloadProgress
                                                                              .progress !=
                                                                          null
                                                                      ? '${(downloadProgress.progress! * 100).toInt()}%'
                                                                      : "...",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color(
                                                                          0xFF757575)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                        Positioned(
                                                          bottom: 20.h,
                                                          right: 12.w,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
                                                            ),
                                                            child: Text(
                                                              userLives[index]
                                                                  ['duration'],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white, // Change the text color to white
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter,
                                                                        colors: [
                                                                  Colors
                                                                      .transparent,
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.25),
                                                                  AppColors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                  AppColors
                                                                      .black,
                                                                ])),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 12.h,
                                                          right: 11.w,
                                                          child:
                                                              IconButtonWidget(
                                                            ontap: () {
                                                              setState(() {
                                                                streamId = userLives[
                                                                            index]
                                                                        [
                                                                        'streamId']
                                                                    .toString();
                                                              });
                                                              editStreamAlertDialog(
                                                                  context,
                                                                  int.tryParse(userLives[
                                                                              index]
                                                                          [
                                                                          'visibility']) ??
                                                                      0,
                                                                  userLives[
                                                                      index]);
                                                            },
                                                            height: 37,
                                                            width: 37,
                                                            containerColor:
                                                                AppColors
                                                                    .tagCancel
                                                                    .withOpacity(
                                                                        0.7),
                                                            widget: Icon(
                                                              Icons.edit,
                                                              color: AppColors
                                                                  .mainColor,
                                                              size: 18,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 12.h,
                                                          right: 55.w,
                                                          child:
                                                              IconButtonWidget(
                                                            ontap: () {
                                                              showModalBottomSheet(
                                                                barrierColor:
                                                                    AppColors
                                                                        .gray
                                                                        .withOpacity(
                                                                            0.4),
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
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return BottomSheetContentStatic(
                                                                    video: userLives[
                                                                        index],
                                                                    imageType:
                                                                        "live",
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            height: 37,
                                                            width: 37,
                                                            containerColor:
                                                                AppColors
                                                                    .tagCancel
                                                                    .withOpacity(
                                                                        0.7),
                                                            widget: SvgPicture
                                                                .asset(AppImages
                                                                    .Vectorsvg),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 16.h,
                                                          left: 12.w,
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        320, // replace with your preferred max width
                                                                    child: Text(
                                                                      userLives[index]
                                                                              [
                                                                              'title'] ??
                                                                          "",
                                                                      softWrap:
                                                                          true,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: AppStyle
                                                                          .textStyle12Regular,
                                                                    ),
                                                                  ),
                                                                  CustomText(
                                                                      textStyle:
                                                                          AppStyle
                                                                              .textStyle10Regular,
                                                                      title:
                                                                          '$formattedViews views • streamed ${timeago.format(createdAt, locale: 'en')}'),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              child: Column(children: [
                                                Container(
                                                  height: 20,
                                                ),
                                                const Text(
                                                  "You didn't create any livestream yet!",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ]),
                                            )),

                              ///NFTs
                              DefaultTabController(
                                length: 2,
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
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700),
                                      controller: nestedTabController,
                                      indicator: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.redAccsent,
                                              AppColors.mainColor,
                                              AppColors.bgGradient3,
                                            ],
                                          )),
                                      indicatorPadding: const EdgeInsets.only(
                                          left: 65,
                                          right: 65,
                                          bottom: 20,
                                          top: 44),
                                      tabs: const [
                                        Tab(
                                          text: 'Created',
                                        ),
                                        Tab(text: 'Holding'),
                                      ],
                                    ),
                                    Expanded(
                                        // height: MediaQuery.of(context).size.height * 0.54,
                                        child: isNftsLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : TabBarView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                controller: nestedTabController,
                                                children: [
                                                  ///Created
                                                  nftstate.allVideos.isNotEmpty
                                                      ? SizedBox(
                                                          // height: 480,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                          child:
                                                              ListView.builder(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 50),
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemCount: nftstate
                                                                .allVideos
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                width: 340,
                                                                height: 206,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child: Stack(
                                                                    children: [
                                                                      nftstate.allVideos[index]['ipfsThumbnail'].length >
                                                                              2
                                                                          ? Image(
                                                                              image: NetworkImage(nftstate.allVideos[index]['ipfsThumbnail']),
                                                                              fit: BoxFit.cover,
                                                                              width: double.infinity,
                                                                            )
                                                                          : nftstate.allVideos[index]['videoId']['thumbnail'].length > 100
                                                                              ? Image.memory(
                                                                                  base64Decode(
                                                                                    nftstate.allVideos[index]['videoId']['thumbnail'].substring(nftstate.allVideos[index]['videoId']['thumbnail'].indexOf(',') + 1),
                                                                                  ),
                                                                                  fit: BoxFit.cover,
                                                                                  width: double.infinity,
                                                                                )
                                                                              : CachedNetworkImage(
                                                                                  fit: BoxFit.cover,
                                                                                  width: double.infinity,
                                                                                  imageUrl: nftstate.allVideos[index]['videoId']['thumbnail'] ?? "",
                                                                                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        CircularProgressIndicator(
                                                                                          value: downloadProgress.progress,
                                                                                        ),
                                                                                        const SizedBox(height: 8),
                                                                                        Text(
                                                                                          downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              50,
                                                                          decoration: BoxDecoration(
                                                                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                            Colors.transparent,
                                                                            Colors.black.withOpacity(0.25),
                                                                            AppColors.black.withOpacity(0.6),
                                                                            AppColors.black,
                                                                          ])),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 12
                                                                            .h,
                                                                        left: 11
                                                                            .w,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              58,
                                                                          height:
                                                                              33,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black54,
                                                                            border:
                                                                                Border.all(color: AppColors.mainColor),
                                                                            borderRadius:
                                                                                BorderRadius.circular(4),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Image.asset(AppImages.logopng, height: 25, width: 25),
                                                                              CustomSizedBoxWidth(width: 5),
                                                                              Text(
                                                                                nftstate.allVideos[index]['price'].toString(),
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 12
                                                                            .h,
                                                                        right:
                                                                            11.w,
                                                                        child:
                                                                            IconButtonWidget(
                                                                          ontap:
                                                                              () {
                                                                            showModalBottomSheet(
                                                                              barrierColor: AppColors.gray.withOpacity(0.4),
                                                                              backgroundColor: AppColors.bgGradient2A,
                                                                              isDismissible: true,
                                                                              useSafeArea: true,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(25.r),
                                                                                  topRight: Radius.circular(25.r),
                                                                                ),
                                                                              ),
                                                                              isScrollControlled: true,
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return BottomSheetContentEditNFt(nft: nftstate.allVideos[index]);
                                                                              },
                                                                            );
                                                                          },
                                                                          height:
                                                                              37,
                                                                          width:
                                                                              37,
                                                                          containerColor: AppColors
                                                                              .tagCancel
                                                                              .withOpacity(0.7),
                                                                          widget:
                                                                              Icon(
                                                                            Icons.edit,
                                                                            color:
                                                                                AppColors.mainColor,
                                                                            size:
                                                                                18,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 12
                                                                            .h,
                                                                        right:
                                                                            55.w,
                                                                        child:
                                                                            IconButtonWidget(
                                                                          ontap:
                                                                              () {
                                                                            var url =
                                                                                'https://bscscan.com/address/${userOwnedNfts[index]['contract']}'; // Replace with your desired URL
                                                                            launch(url);
                                                                          },
                                                                          height:
                                                                              37,
                                                                          width:
                                                                              37,
                                                                          containerColor: AppColors
                                                                              .tagCancel
                                                                              .withOpacity(0.7),
                                                                          widget:
                                                                              SvgPicture.asset(AppImages.nftexport),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        bottom:
                                                                            16.h,
                                                                        left: 12
                                                                            .w,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  width: 320, // replace with your preferred max width
                                                                                  child: Text(
                                                                                    nftstate.allVideos[index]['name'] ?? "",
                                                                                    softWrap: true,
                                                                                    maxLines: 2,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: AppStyle.textStyle12Regular,
                                                                                  ),
                                                                                ),
                                                                                CustomText(textStyle: AppStyle.textStyle10Regular, title: '${nftstate.allVideos[index]['available']} available . ${nftstate.allVideos[index]['minted']} minted'),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : Container(
                                                          child:
                                                              Column(children: [
                                                            Container(
                                                              height: 20,
                                                            ),
                                                            Text(
                                                              "You didn't create an NFT collection yet!",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          ]),
                                                        ),

                                                  ///Holding
                                                  ///us
                                                  ///
                                                  isNftsLoadingOwned
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                      : userOwnedNfts.isNotEmpty
                                                          ? SizedBox(
                                                              // height: 480,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.4,
                                                              child: ListView
                                                                  .builder(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            50),
                                                                physics:
                                                                    const BouncingScrollPhysics(),
                                                                itemCount: 2,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Container(
                                                                    width: 340,
                                                                    height: 206,
                                                                    margin:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          userOwnedNfts[index]['ipfsThumbnail'].length > 2
                                                                              ? Image(
                                                                                  image: NetworkImage(userOwnedNfts[index]['ipfsThumbnail']),
                                                                                  fit: BoxFit.cover,
                                                                                  width: double.infinity,
                                                                                )
                                                                              : userOwnedNfts[index]['videoId']['thumbnail'].length > 100
                                                                                  ? Image.memory(
                                                                                      base64Decode(
                                                                                        userOwnedNfts[index]['videoId']['thumbnail'].substring(userOwnedNfts[index]['videoId']['thumbnail'].indexOf(',') + 1),
                                                                                      ),
                                                                                      fit: BoxFit.cover,
                                                                                      width: double.infinity,
                                                                                    )
                                                                                  : CachedNetworkImage(
                                                                                      fit: BoxFit.cover,
                                                                                      width: double.infinity,
                                                                                      imageUrl: userOwnedNfts[index]['videoId']['thumbnail'] ?? "",
                                                                                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            CircularProgressIndicator(
                                                                                              value: downloadProgress.progress,
                                                                                            ),
                                                                                            const SizedBox(height: 8),
                                                                                            Text(
                                                                                              downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                    ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Container(
                                                                              width: double.infinity,
                                                                              height: 50,
                                                                              decoration: BoxDecoration(
                                                                                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                                Colors.transparent,
                                                                                Colors.black.withOpacity(0.25),
                                                                                AppColors.black.withOpacity(0.6),
                                                                                AppColors.black,
                                                                              ])),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                12.h,
                                                                            right:
                                                                                11.w,
                                                                            child:
                                                                                IconButtonWidget(
                                                                              ontap: () {
                                                                                var url = 'https://bscscan.com/token/${userOwnedNfts[index]['contract']}?a=${getOwnerTokenId(userOwnedNfts[index])}'; // Replace with your desired URL
                                                                                launch(url);
                                                                              },
                                                                              height: 37,
                                                                              width: 37,
                                                                              containerColor: AppColors.tagCancel.withOpacity(0.7),
                                                                              widget: SvgPicture.asset(AppImages.nftexport),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            bottom:
                                                                                20.h,
                                                                            left:
                                                                                12.w,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        SharedPreferences prefs = await SharedPreferences.getInstance();

                                                                                        String? token = prefs.getString('token');
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => ProfileView(
                                                                                              wallet: userOwnedNfts[index]['creator'],
                                                                                              token: token ?? '',
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 40,
                                                                                        height: 40,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                          border: Border.all(
                                                                                            color: AppColors.whiteA700,
                                                                                            width: 1.5,
                                                                                          ),
                                                                                        ),
                                                                                        child: ClipOval(
                                                                                          child: CachedNetworkImage(
                                                                                            fit: BoxFit.cover,
                                                                                            imageUrl: userOwnedNfts[index]['videoId']['creator']['ProfileAvatar'] ?? "",
                                                                                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  CircularProgressIndicator(
                                                                                                    value: downloadProgress.progress,
                                                                                                  ),
                                                                                                  const SizedBox(height: 8),
                                                                                                  Text(
                                                                                                    downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    Row(
                                                                                      children: [
                                                                                        GestureDetector(
                                                                                          onTap: () {
                                                                                            // Navigate to the desired page when the user taps the username
                                                                                          },
                                                                                          child: CustomText(
                                                                                            textStyle: AppStyle.textStyle10Regular,
                                                                                            title: userOwnedNfts[index]['videoId']['creator']['username'],
                                                                                          ),
                                                                                        ),
                                                                                        CustomSizedBoxWidth(width: 4),
                                                                                        userOwnedNfts[index]['videoId']['creator']['isVerified'] != null && userOwnedNfts[index]['videoId']['creator']['isVerified']
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
                                                                                const SizedBox(height: 8),
                                                                                Container(
                                                                                  width: 300, // replace with your preferred max width
                                                                                  child: Text(
                                                                                    userOwnedNfts[index]['videoId']['title'] ?? "",
                                                                                    softWrap: true,
                                                                                    maxLines: 2,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: AppStyle.textStyle12Regular,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    const Text(
                                                                      "You didn't create an NFT collection yet!",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  ]),
                                                            ),
                                                ],
                                              )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  /////////////////////////////
                ],
              ),
            )));
  }

  void editStreamAlertDialog(BuildContext context, int visi, dynamic liv) {
    setState(() {
      selectedContainer = visi;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: AppColors.bgGradient1,
          backgroundColor: AppColors.bgGradient3,
          contentPadding: const EdgeInsets.all(0),
          content: SizedBox(
            height: 420.h,
            width: 380.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Edit Live',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [
                                AppColors.indigo,
                                AppColors.mainColor,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(20.0, 0.0, 120.0, 70.0),
                            ),
                        ),
                      ),
                    ),
                  ),
                  CustomSizedBoxHeight(height: 30),
                  CustomText(
                      textStyle: AppStyle.textStyle12Regular,
                      title: 'Visibility'),
                  CustomSizedBoxHeight(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          selectContainer(1);
                        },
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: selectedContainer == 1
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFBD64FC),
                                        Color(0xFF6644F1),
                                      ],
                                      stops: [
                                        0.118,
                                        0.9035,
                                      ],
                                      transform:
                                          GradientRotation(254.96 * 3.14 / 180),
                                    )
                                  : LinearGradient(colors: [
                                      AppColors.fieldUnActive,
                                      AppColors.fieldUnActive,
                                    ])),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                    textStyle:
                                        AppStyle.textStyle11SemiBoldWhite600,
                                    title: 'Public'),
                                const Spacer(),
                                CustomText(
                                    textStyle: AppStyle.textStyle8White600,
                                    title: 'Visible to all'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CustomSizedBoxHeight(height: 15),
                      GestureDetector(
                        onTap: () {
                          selectContainer(2);
                        },
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: selectedContainer == 2
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFBD64FC),
                                        Color(0xFF6644F1),
                                      ],
                                      stops: [
                                        0.118,
                                        0.9035,
                                      ],
                                      transform:
                                          GradientRotation(254.96 * 3.14 / 180),
                                    )
                                  : LinearGradient(colors: [
                                      AppColors.fieldUnActive,
                                      AppColors.fieldUnActive,
                                    ])),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                    textStyle:
                                        AppStyle.textStyle11SemiBoldWhite600,
                                    title: 'Private'),
                                const Spacer(),
                                CustomText(
                                    textStyle: AppStyle.textStyle8White600,
                                    title: 'Visible only to you'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CustomSizedBoxHeight(height: 15),
                      GestureDetector(
                        onTap: () {
                          selectContainer(0);
                        },
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              gradient: selectedContainer == 3
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFBD64FC),
                                        Color(0xFF6644F1),
                                      ],
                                      stops: [0.118, 0.9035],
                                      tileMode: TileMode.repeated,
                                      transform:
                                          GradientRotation(254.96 * 3.14 / 180),
                                    )
                                  : LinearGradient(colors: [
                                      AppColors.fieldUnActive,
                                      AppColors.fieldUnActive,
                                    ])),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                    textStyle:
                                        AppStyle.textStyle11SemiBoldWhite600,
                                    title: 'NFT holders'),
                                const Spacer(),
                                CustomText(
                                    textStyle: AppStyle.textStyle8White600,
                                    title: 'Only NFT holders'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomSizedBoxHeight(height: 30),
                  CustomButton(
                    width: double.infinity,
                    title: 'Save Changes',
                    ontap: () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('token') ?? '';
                        Map<String, dynamic> data = {};

                        if (selectedContainer != visi) {
                          data["visibility"] = selectedContainer;
                        }

                        if (data.isNotEmpty) {
                          final response = await http.put(
                              Uri.parse(
                                  'https://account.cratch.io/api/live/edit/saved/$streamId'),
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                                'Connection': 'keep-alive',
                              },
                              body: json.encode(data));

                          if (response.statusCode == 200) {
                            showTopSnackBar(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              Overlay.of(context),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Set width to 80% of the screen width
                                child: CustomSnackBar.error(
                                  backgroundColor: const Color(0xFF165E54),
                                  borderRadius: BorderRadius.circular(5),
                                  iconPositionLeft: 12,
                                  iconRotationAngle: 0,
                                  icon: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xff36A697),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                      weight: 100,
                                    ),
                                  ),
                                  message: "Change Saved Successfully",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      } catch (e) {
                        showTopSnackBar(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            Overlay.of(context),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.8, // Set width to 80% of the screen width
                              child: CustomSnackBar.error(
                                backgroundColor: const Color(0xFF532B48),
                                borderRadius: BorderRadius.circular(5),
                                iconPositionLeft: 12,
                                iconRotationAngle: 0,
                                icon: const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Color(0xFFFF1818),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                    weight: 100,
                                  ),
                                ),
                                message: "Ooops, There was an Error",
                              ),
                            ));
                      }
                    },
                    AppStyle: AppStyle.textStyle12regularWhite,
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7356EC),
                          Color(0xFFF6587A),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
