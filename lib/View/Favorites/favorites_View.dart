import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/Provider/favorites_provider.dart';
import 'package:cratch/View/Profile/Components/SavedComments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/View/VideoPage_View/VideoComponent.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/Sizebox/sizedboxheight.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/customtext.dart';
import '../Profile/profile_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  bool isVideosLoading = true;
  String token = "";
  String wallet = "";

  Future<void> fetchVideos() async {
    final prefs = await SharedPreferences.getInstance();
    var tokena = prefs.getString('token') ?? '';
    var walleta = prefs.getString('wallet_address') ?? '';
    var userId = prefs.getString('userId') ?? '';

    setState(() {
      token = tokena;
      wallet = walleta;
    });
    if (userId.isNotEmpty) {
      var bd = json.encode({"userId": userId});
      var response = await http.post(
        Uri.parse(
            'https://account.cratch.io/api/video/likes/user/getVideolikes'),
        headers: {
          'Authorization': 'Bearer $tokena',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive', // Add this line// Add this line
        },
        body: bd,
      );

      var session = await http.post(
        Uri.parse(
            'https://account.cratch.io/api/video/likes/user/getSessionsLikes'),
        headers: {
          'Authorization': 'Bearer $tokena',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive', // Add this line// Add this line
        },
        body: bd,
      );

      final userVideo = json.decode(response.body);

      if (userVideo is List<dynamic> && userVideo.isNotEmpty) {
        var sessions =
            jsonDecode(session.body) is List ? jsonDecode(session.body) : [];

        sessions.removeWhere((video) => video['streamId'] == null);
        // API returns an array of videos
        userVideo.removeWhere((video) => video['videoId'] == null);
        var all = [...userVideo, ...sessions];
        setState(() {
          isVideosLoading = false;
        });

        final favoritestate =
            Provider.of<FavoritesProvider>(context, listen: false);
        favoritestate.setFavorites(all);
      } else {
        setState(() {
          isVideosLoading = false;
        });
      }
    } else {
      setState(() {
        isVideosLoading = false;
      });
    }
  }

  Future<void> deleteVideo(String videoId, String type, String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var tokena = prefs.getString('token') ?? '';
      var userId = prefs.getString('userId') ?? '';
      String videoType = type == "video" ? "videoId" : "streamId";
      String url = type == "video"
          ? 'https://account.cratch.io/api/video/likes/user/deleteVideolikes'
          : 'https://account.cratch.io/api/video/likes/user/deleteSessionLikes';

      await http.post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line// Add this line
          },
          body: json.encode({videoType: videoId}));

      await http.post(
          Uri.parse('https://account.cratch.io/api/video/likes/unLike'),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line
          },
          body: json.encode({"userId": userId, videoType: id}));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    setupIntl();

    String formatNumber(int number) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    }

    final favoritestate = Provider.of<FavoritesProvider>(context);

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
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(),
            CustomSizedBoxHeight(height: 35),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 20, right: 20),
              child: GradientTextWidget(
                size: 17.h,
                text: 'Favorites',
              ),
            ),
            isVideosLoading
                ? const Expanded(

                    // color: AppColors.bgGradient2,
                    child: Center(
                    child: CircularProgressIndicator(),
                  ))
                : favoritestate.allVideos.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 40),
                          physics: const BouncingScrollPhysics(),
                          itemCount: favoritestate.allVideos.length,
                          itemBuilder: (context, index) {
                            var type = favoritestate.allVideos[index]
                                    ['videoId'] ??
                                favoritestate.allVideos[index]['streamId'];

                            String text =
                                type['creator']['followers'] != null &&
                                        type['creator']['followers']?.length > 1
                                    ? "followers"
                                    : 'follower';

                            String formattedFollowers =
                                type['creator']['followers'] != null
                                    ? formatNumber(
                                        type['creator']['followers']!.length)
                                    : "";

                            final viewsCount = type['views'] ?? 0;

                            final createdAt =
                                type['createdAt'] ?? DateTime.now().toString();
                            String formattedViews;
                            if (viewsCount >= 1000000) {
                              formattedViews =
                                  '${(viewsCount / 1000000).toStringAsFixed(1)}M';
                            } else if (viewsCount >= 1000) {
                              formattedViews =
                                  '${(viewsCount / 1000).toStringAsFixed(1)}K';
                            } else {
                              formattedViews = '$viewsCount';
                            }
                            return GestureDetector(
                              onTap: () {
                                if (favoritestate.allVideos[index]['videoId'] !=
                                    null) {
                                  Get.to(() => VideoComponent(
                                        videoId: favoritestate.allVideos[index]
                                            ['videoId']['videoId'],
                                      ));
                                } else {
                                  Get.to(() => SavedComments(
                                        token: token,
                                        userWallet: wallet,
                                        streamId: favoritestate.allVideos[index]
                                            ['streamId']['streamId'],
                                      ));
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 220,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Stack(
                                    children: [
                                      favoritestate.allVideos[index]
                                                  ['videoId'] !=
                                              null
                                          ? type['thumbnail'].length > 100
                                              ? Image.memory(
                                                  base64Decode(
                                                    type['thumbnail'].substring(
                                                        type['thumbnail']
                                                                .indexOf(',') +
                                                            1),
                                                  ),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  imageUrl:
                                                      type['thumbnail'] ?? "",
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
                                                          value:
                                                              downloadProgress
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
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                )
                                          : CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              imageUrl: type['thumbnail'] ?? "",
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      value: downloadProgress
                                                          .progress,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      downloadProgress
                                                                  .progress !=
                                                              null
                                                          ? '${(downloadProgress.progress! * 100).toInt()}%'
                                                          : "...",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF757575)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.25),
                                                AppColors.black
                                                    .withOpacity(0.6),
                                                AppColors.black,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12.h,
                                        right: 11.w,
                                        child: IconButtonWidget(
                                          ontap: () {},
                                          height: 37,
                                          width: 37,
                                          containerColor: AppColors.tagCancel
                                              .withOpacity(0.7),
                                          widget: const Icon(Icons.star,
                                              color: Colors.white),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12.h,
                                        right: 11.w,
                                        child: IconButtonWidget(
                                          ontap: () {
                                            deleteVideo(
                                                favoritestate.allVideos[index]
                                                    ['_id'],
                                                favoritestate.allVideos[index]
                                                            ['videoId'] !=
                                                        null
                                                    ? "video"
                                                    : "streamId",
                                                type['_id']);
                                            favoritestate.removeFavorites(
                                                favoritestate.allVideos[index]
                                                    ['_id']);
                                            ;
                                          },
                                          height: 37,
                                          width: 37,
                                          containerColor: AppColors.tagCancel
                                              .withOpacity(0.7),
                                          widget: const Icon(Icons.star,
                                              color: Colors.white),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16.h,
                                        left: 12.w,
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Handle the tap event here
                                                        PersistentNavBarNavigator
                                                            .pushNewScreen(
                                                                context,
                                                                screen:
                                                                    ProfileView(
                                                                  wallet: type[
                                                                              'creator']
                                                                          [
                                                                          'userId']
                                                                      .toString(),
                                                                  token: token,
                                                                ),
                                                                withNavBar:
                                                                    true);
                                                        // Add your custom logic or navigate to a new screen, etc.
                                                      },
                                                      child: CircleAvatar(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child:
                                                              CachedNetworkImage(
                                                            width: 96,
                                                            height: 96,
                                                            fit: BoxFit.cover,
                                                            imageUrl: type[
                                                                        'creator']
                                                                    [
                                                                    'ProfileAvatar'] ??
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
                                                                      height:
                                                                          8),
                                                                  Text(
                                                                    downloadProgress.progress !=
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
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    CustomSizedBoxWidth(
                                                        width: 10.w),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CustomText(
                                                              textStyle: AppStyle
                                                                  .textStyle12regularWhite,
                                                              title: type['creator']
                                                                              [
                                                                              'username']
                                                                          .length >
                                                                      10
                                                                  ? "${type['creator']['username'].substring(0, 10)}..."
                                                                  : type['creator']
                                                                      [
                                                                      'username'],
                                                            ),
                                                            CustomSizedBoxWidth(
                                                                width: 4),
                                                            type['creator']['isVerified'] !=
                                                                        null &&
                                                                    type['creator']
                                                                        [
                                                                        'isVerified']
                                                                ? const Center(
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .solidCircleCheck,
                                                                      color: Color(
                                                                          0xffCEC7C7),
                                                                      size: 12,
                                                                    ),
                                                                  )
                                                                : const SizedBox()
                                                          ],
                                                        ),
                                                        CustomText(
                                                            textStyle: AppStyle
                                                                .textStyle10SemiBoldBlack
                                                                .copyWith(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        217,
                                                                        217,
                                                                        217),
                                                                    fontSize:
                                                                        9.sp),
                                                            title:
                                                                "$formattedFollowers $text"),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width:
                                                      300, // replace with your preferred max width
                                                  child: Text(
                                                    type['title'] ?? "",
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppStyle
                                                        .textStyle12Regular,
                                                  ),
                                                ),
                                                favoritestate.allVideos[index]
                                                            ['streamId'] !=
                                                        null
                                                    ? Row(
                                                        children: [
                                                          CustomText(
                                                              textStyle: AppStyle
                                                                  .textStyle9Regular
                                                                  .copyWith(
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          222,
                                                                          222,
                                                                          222)),
                                                              title:
                                                                  '$formattedViews views'),
                                                          CustomText(
                                                            textStyle: AppStyle
                                                                .textStyle9Regular
                                                                .copyWith(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        222,
                                                                        222,
                                                                        222)),
                                                            title:
                                                                ' • streamed ${timeago.format(DateTime.parse(createdAt), locale: 'en')}',
                                                          ),
                                                        ],
                                                      )
                                                    : CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle10Regular,
                                                        title:
                                                            '$formattedViews views • ${timeago.format(DateTime.parse(createdAt), locale: 'en')}',
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        child: Column(children: [
                          Container(
                            height: 20,
                          ),
                          const Text(
                            "No liked videos yet!",
                            style: TextStyle(color: Colors.white),
                          )
                        ]),
                      )
          ],
        ),
      ),
    ));
  }
}
