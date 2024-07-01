import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/widgets/GradientTextWidget.dart';
import 'package:flutter/material.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:cratch/View/DashBoard/Components/CarouselSlider_container.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../Utils/color_constant.dart';
import '../LiveStreamResCreator_View/liveStreamView.dart';
import '../VideoPage_View/VideoComponent.dart';
import '../ViewAllVideo&Stream/viewAllLiveStream_view.dart';
import '../ViewAllVideo&Stream/viewAllVideo_View.dart';
import 'Components/topStreams_widget.dart';
import 'package:http/http.dart' as http;
import 'Components/topVideos_widget.dart';
import 'dart:convert';
import '../TopBar/TopBar.dart';

class DashBoardView extends StatefulWidget {
  final String? wallet = "";

  DashBoardView();

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  bool isLoading = true;
  bool isLivesLoading = true;
  bool isVideosLoading = true;

  int _currentPage = 0;

  final List<Map<String, dynamic>> carouselDetails = [
    {
      'title': 'WATCH P2E TOURNAMENTS\n ANYWHERE ANYTHIME',
      'description': 'Watch your favorite streamers\n & players only on Cratch',
      'image': AppImages.splinter,
      'grad': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(123, 91, 251, 0.91),
            Color.fromRGBO(37, 190, 207, 1),
          ]),
      'paddin': 0.0
    },
    {
      'grad': LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.whiteA700,
            AppColors.whiteA700,
            AppColors.black,
            AppColors.black,
            AppColors.black,
          ]),
      'paddin': 0.0,
      'title': 'WATCH PUBG GLOBAL\nCHAMPIONSHIP',
      'description': 'Enjoy watching the biggest PUBG\n event of thes year',
      'image': AppImages.pubg,
      // ignore: equal_keys_in_map
      'grad': const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(36, 59, 75, 1),
          Color.fromRGBO(255, 255, 219, 1)
        ],
      ),
      // ignore: equal_keys_in_map
      'paddin': 0.0
    },
    {
      'title': 'WATCH AXIE INFINITY:\n BATTLE OF THE GUILDS',
      'description':
          'Watch Axie Infinity tournaments only on\n Cratch, and win valuable prizes',
      'image': AppImages.axie,
      'grad': const RadialGradient(
        center: Alignment.topCenter,
        radius: 1,
        colors: [
          Color.fromRGBO(0, 208, 170, 1),
          Color.fromRGBO(129, 191, 127, 1),
        ],
      ),
      'paddin': 0.0
    },
    {
      'title': 'WATCH THE SANDBOX\n ALPHA SEASON 3',
      'description':
          'Watch events live on MetaCratch, and join\n the Metaverse community',
      'image': AppImages.mobox,
      'grad': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF233C89), Color(0xFF7A2261)],
        stops: [0, 1],
      ),
      'paddin': 0.0
    },
  ];

  List<dynamic> topVerifiedUsers = [];
  List<dynamic> allLives = [];
  List<dynamic> allVideos = [];
  late String address = '';

  late String token = "";

  Future<Map<String, String>> _getWalletAddressAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    var addressa = prefs.getString('wallet_address') ?? '';
    var tokena = prefs.getString('token') ?? '';
    setState(() {
      address = addressa.toLowerCase();
      token = tokena;
    });
    return {'address': addressa, 'token': tokena};
  }

  @override
  void initState() {
    super.initState();

    try {
      _getWalletAddressAndToken();
      getTopVerifiedUsers().then((users) {
        setState(() {
          topVerifiedUsers = users;
          isLoading = false;
        });
      });

      fetchLives().then((li) {
        setState(() {
          allLives = li;
          isLivesLoading = false;
        });
      });

      fetchVideos().then((vi) {
        setState(() {
          allVideos = vi;
          isVideosLoading = false;
        });
      });
    } catch (e) {
      isLoading = false;
      isLivesLoading = false;
      isVideosLoading = false;
      // ignore: avoid_print
      print(e);
    }
  }

  Future<List<dynamic>> fetchLives() async {
    final prefs = await SharedPreferences.getInstance();
    var tokena = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('https://account.cratch.io/api/live/home/lives/8'),
      headers: {'Authorization': 'Bearer $tokena'},
    );

    if (response.statusCode == 200) {
      final lives = jsonDecode(response.body);
      allLives = lives;
      setState(() {
        isLivesLoading = false;
      });
      return lives;
    } else {
      setState(() {
        isLivesLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchVideos() async {
    final prefs = await SharedPreferences.getInstance();
    var tokena = prefs.getString('token') ?? '';
    var address = prefs.getString('wallet_address') ?? '';
    final response = await http.get(
      Uri.parse('https://account.cratch.io/api/video/home/videos/8/$address'),
      headers: {'Authorization': 'Bearer $tokena'},
    );

    if (response.statusCode == 200) {
      final vid = jsonDecode(response.body);
      allVideos = vid;
      setState(() {
        isVideosLoading = false;
      });
      return vid;
    } else {
      setState(() {
        isVideosLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> getTopVerifiedUsers() async {
    try {
      address = '';

      final data = await _getWalletAddressAndToken();
      var response = await http.get(
        Uri.parse("https://account.cratch.io/api/users/verified/all/$address"),
        headers: {'Authorization': 'Bearer ${data['token']}'},
      );
      if (response.statusCode == 200) {
        var verifiedUsers = json.decode(response.body);

        address = data['address'] ?? "";
        token = data["token"] ?? "";

        setState(() {
          address = data['address'] ?? "";
          token = data["token"] ?? "";
        });
        verifiedUsers = verifiedUsers.sublist(0, 10);
        return verifiedUsers;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            const TopBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 5),
                  children: [
                    SizedBox(
                      height: 167,
                      child: CarouselSlider.builder(
                        itemCount: carouselDetails.length,
                        options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 10),
                          height: 167,
                          aspectRatio: 340 / 167,
                          viewportFraction: 1.0,
                          onPageChanged:
                              (int page, CarouselPageChangedReason reason) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          return CarouselSliderContainer(
                            title: carouselDetails[index]['title'],
                            description: carouselDetails[index]['description'],
                            myImage: carouselDetails[index]['image'],
                            grad: carouselDetails[index]['grad'],
                            paddin: carouselDetails[index]['paddin'],
                          );
                        },
                      ),
                    ),
                    CustomSizedBoxHeight(height: 10),
                    _buildIndicator(),
                    CustomSizedBoxHeight(height: 30),

                    /// Top Streamers and Like Stories
                    Text(
                      "Top Streamers",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              Color(0xFFFB5876),
                              Color(0xff6750D3),
                              Color(0xff6750D3),
                            ],
                          ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                          ),
                      ),
                    ),
                    CustomSizedBoxHeight(height: 20),
                    isLoading
                        ?
                        // Center(child: CircularProgressIndicator())

                        SizedBox(
                            height: 75,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 6,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  width: 65,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                          border: Border.all(
                                            color: Colors.yellow,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Shimmer.fromColors(
                                          baseColor: const Color(0xFF373953),
                                          highlightColor:
                                              const Color(0xFF16172B),
                                          child: const CircleAvatar(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : SizedBox(
                            height: 75,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: topVerifiedUsers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to new page and pass wallet parameter
                                    if (topVerifiedUsers[index]['userId'] !=
                                            null &&
                                        token.isNotEmpty) {
                                      PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: ProfileView(
                                            wallet: topVerifiedUsers[index]
                                                    ['userId'] ??
                                                '',
                                            token: token,
                                          ),
                                          withNavBar: true);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: SizedBox(
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.yellow,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      topVerifiedUsers[index][
                                                              "ProfileAvatar"] ??
                                                          ""),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: topVerifiedUsers[
                                                                    index]
                                                                ["isOnline"] ==
                                                            true
                                                        ? Colors.green
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomText(
                                                  textStyle: AppStyle
                                                      .textStyle10Regular,
                                                  title: topVerifiedUsers[index]
                                                                  ["username"]
                                                              .length >
                                                          7
                                                      ? topVerifiedUsers[index]
                                                              ["username"]
                                                          .substring(0, 7)
                                                      : topVerifiedUsers[index]
                                                          ["username"]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    CustomSizedBoxHeight(height: 13),

                    /// Top Streams with listVertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientTextWidget(
                          text: 'Top Streams',
                          size: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Get.to(()=> AllLivesView());
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const AllLivesView(), withNavBar: true);
                          },
                          child: CustomText(
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(117, 117, 117, 1),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold, // Add font weight here
                            ),
                            title: 'View all',
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: isLivesLoading ? 4 : allLives.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: LiveStreamViewAndComments(
                                    userWallet: address,
                                    token: token,
                                    live: allLives[index]),
                                withNavBar: false,
                              );
                            },
                            child: isLivesLoading
                                ? SizedBox(
                                    width: 264,
                                    height: 140,
                                    child: Shimmer.fromColors(
                                      baseColor: const Color(0xFF373953),
                                      highlightColor: const Color(0xFF16172B),
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF373953),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  )
                                : TopStreamsListView(
                                    live: allLives[index],
                                    token: token,
                                  ),
                          );
                        },
                      ),
                    ),

                    CustomSizedBoxHeight(height: 13),

                    /// Top Videos with listVertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Top Videos",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFF9C77CE),
                                  Color(0xff1B50D9),
                                  Color(0xff1B50D9),
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                              ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Get.to(()=> AllVideoView());
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const AllVideoView(), withNavBar: true);
                          },
                          child: CustomText(
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(117, 117, 117, 1),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold, // Add font weight here
                            ),
                            title: 'View all',
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: isVideosLoading ? 4 : allVideos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Get.to(() => VideoComponent(
                                      videoId: allVideos[index]['videoId'],
                                    ));
                              },
                              child: isVideosLoading
                                  ? SizedBox(
                                      width: 264,
                                      height: 140,
                                      child: Shimmer.fromColors(
                                        baseColor: const Color(0xFF373953),
                                        highlightColor: const Color(0xFF16172B),
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF373953),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    )
                                  : TopVideosWidgets(
                                      video: allVideos[index],
                                      token: token,
                                    ));
                        },
                      ),
                    ),
                    CustomSizedBoxHeight(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(carouselDetails.length, (int index) {
        return Container(
          width: _currentPage == index ? 30 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: _currentPage == index
                ? Colors.white
                : Colors.grey, // Replace with your desired indicator colors
          ),
        );
      }),
    );
  }
}
