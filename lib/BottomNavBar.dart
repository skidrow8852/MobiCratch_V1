import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:freestyle_speed_dial/freestyle_speed_dial.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'View/Analytics/analytics_view.dart';
import 'View/CreateALiveStream/createStream_view.dart';
import 'View/DashBoard/dashBoard_view.dart';
import 'View/Favorites/favorites_View.dart';
import 'View/Followers/followers.dart';
import 'View/Login/login_View.dart';
import 'View/Messages/Messages_View.dart';
import 'View/UploadVideoS/UploadVideo_View.dart';
import 'View/Content/content_View.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final PersistentTabController tabController =
    PersistentTabController(initialIndex: 0);

// ignore: must_be_immutable
class DrawerWithNavBar extends StatefulWidget {
  Widget screen;
  DrawerWithNavBar({Key? key, required this.screen}) : super(key: key);

  @override
  State<DrawerWithNavBar> createState() => _DrawerWithNavBarState();
}

class _DrawerWithNavBarState extends State<DrawerWithNavBar> {
  Future<void> offline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';

      await http.put(
          Uri.parse(
              'https://account.cratch.io/api/users/${wallet.toLowerCase()}/edit'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"isOnline": false}));
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the drawer before navigating back
        ZoomDrawer.of(context)!.close();
        return true; // Allow the navigation to proceed
      },
      child: ZoomDrawer(
        menuBackgroundColor: const Color(0xFF17062F),
        drawerShadowsBackgroundColor: const Color(0xFF17062F),

        borderRadius: 24,
        clipMainScreen: true,
        mainScreenTapClose: true,
        // closeCurve: Curves.bounceInOut,
        style: DrawerStyle.defaultStyle,
        menuScreenWidth: double.infinity,
        showShadow: true,
        openCurve: Curves.easeInOutCubic,
        slideWidth: MediaQuery.of(context).size.width * 0.6,
        duration: const Duration(milliseconds: 300),
        angle: 0.0,
        shadowLayer2Color: const Color(0xff191639),
        shadowLayer1Color: const Color(0xff100E29),
        mainScreen: widget.screen,
        menuScreen: Theme(
          data: ThemeData.dark(),
          child: Scaffold(
            backgroundColor: AppColors.mainColor,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(AppImages.backgroundDra),
                fit: BoxFit.cover,
              )),
              child: Padding(
                padding: EdgeInsets.only(left: 26.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSizedBoxHeight(height: 140),
                    SizedBox(
                      width: 120,
                      child: IconButton(
                          onPressed: () {
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const DashBoardScreen(),
                                withNavBar: false);
                            tabController.jumpToTab(0);
                          },
                          icon: Row(
                            children: [
                              const Icon(Icons.window_rounded),
                              const SizedBox(width: 5),
                              CustomText(
                                  textStyle: AppStyle.textStyle14whiteSemiBold,
                                  title: 'Home')
                            ],
                          )),
                    ),
                    CustomSizedBoxHeight(height: 15),
                    SizedBox(
                      width: 120,
                      child: IconButton(
                          onPressed: () {
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const Followers());
                          },
                          icon: Row(
                            children: [
                              const Icon(Icons.person_add_alt_rounded),
                              const SizedBox(width: 5),
                              CustomText(
                                  textStyle: AppStyle.textStyle14whiteSemiBold,
                                  title: 'Followers')
                            ],
                          )),
                    ),
                    CustomSizedBoxHeight(height: 15),
                    SizedBox(
                      width: 120,
                      child: IconButton(
                          onPressed: () {
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const AnalyticsScreen());
                          },
                          icon: Row(
                            children: [
                              SvgPicture.asset(
                                AppImages.Vectorsvg,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              CustomText(
                                  textStyle: AppStyle.textStyle14whiteSemiBold,
                                  title: 'Analytics')
                            ],
                          )),
                    ),
                    CustomSizedBoxHeight(height: 70),
                    SizedBox(
                      width: 120,
                      child: IconButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.remove('token');
                            prefs.remove('wallet_address');
                            prefs.remove('userId');
                            offline();
                            Get.to(() => const LoginView());
                          },
                          icon: Row(
                            children: [
                              const Icon(Icons.logout),
                              const SizedBox(width: 5),
                              CustomText(
                                  textStyle: AppStyle.textStyle14whiteSemiBold,
                                  title: 'Logout')
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  String currentVersion = ""; // Variable to store the current app version
  String latestVersion = ""; // Variable to store the latest app version
  int messages = 0;
  var chatUsers = <String>{};
  IO.Socket? socket;
  String address = "";

  void onMessageReceived(Map<String, dynamic> data, String address) {
    if (data['to']?.toLowerCase() == address.toLowerCase()) {
      chatUsers.add(data['from']!.toLowerCase());
      if (mounted) {
        setState(() {
          messages = chatUsers.length;
        });
      }
    }
  }

  Future<void> getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var tokena = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      setState(() {
        address = wallet;
      });

      var response = await http.post(
          Uri.parse('https://account.cratch.io/api/messages/conversations'),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line
          },
          body: json.encode({"wallet": wallet.toLowerCase()}));

      var data = json.decode(response.body);

      if (response.statusCode == 200 && data is List && data.isNotEmpty) {
        for (var d in data) {
          if (d['from'].toString() != wallet.toLowerCase() &&
              d['to_count'] as int > 0) {
            chatUsers.add(d['from']);
          }
        }
      }
      if (mounted) {
        setState(() {
          messages = chatUsers.length;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void initializeSocket(String serverHost) async {
    socket = IO.io(serverHost, <String, dynamic>{
      'transports': ['websocket', 'polling'],
    });

    socket?.on('last-chat', (data) {
      try {
        if (mounted) {
          onMessageReceived(data, address);
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    });

    socket?.on('clear-conversation', (data) {
      try {
        String? from = data['from']?.toString().toLowerCase();

        if (chatUsers.contains(from)) {
          if (mounted) {
            chatUsers.remove(from);
            setState(() {
              messages = chatUsers.length;
            });
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    getMessages();
    initializeSocket("https://account.cratch.io");
  }

  void checkForUpdate() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
        latestVersion = await fetchLatestVersion();
        if (latestVersion.isNotEmpty &&
            currentVersion != latestVersion &&
            latestVersion != "error") {
          showUpdateDialog(); // Display a dialog or custom screen
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<String> fetchLatestVersion() async {
    try {
      final response = await http.get(
          Uri.parse('https://account.cratch.io/api/users/version'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          });
      String value = json.decode(response.body)['version'];
      return value;
    } catch (e) {
      return "error";
    }
  }

  void showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF0F0B1F), // Set background color to transparent
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius
          ),
          content: Container(
            width: 400,
            height: 180,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/update.png'), // Replace with your own image path
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 25.0, bottom: 16.0),
                  child: Text(
                    'Update Available',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Inter, sans-serif",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 8, 16, 16),
                  child: Text(
                    'A new version of the app is available. Please update to the latest version.',
                    style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        height: 1.3,
                        fontFamily: "Inter, sans-serif",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 25.0), // Adjust the padding as needed
                    child: TextButton(
                      onPressed: () {
                        launchAppStore(); // Open the Google Play Store or App Store
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF337FFF),
                            fontFamily: "Inter, sans-serif"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void launchAppStore() async {
    const url =
        "https://play.google.com/store/apps/details?id=io.cratch.myapp"; // Provide the URL of your app in the Google Play Store or App Store
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  List<Widget> _screens() {
    return [
      DashBoardView(),
      ContentView(),
      const CreateStream(),
      const MessagesView(),
      const FavoritesView(),
      // AllUserScreen(),
      // ProfileScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navbarItem(int? number) {
    return [
      PersistentBottomNavBarItem(
        opacity: 0.00000001,
        icon: Container(
          height: 40,
          width: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff9761ED),
                Color(0xff7525F3),
              ],
              stops: [
                0.0599,
                0.8036,
              ],
              transform: GradientRotation(
                  213 * (pi / 180)), // Set the rotation of the gradient
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigoAccent.withOpacity(0.6),
                blurRadius: 20.0,
                spreadRadius: 0.0,
                offset: const Offset(
                  0.0,
                  8.0,
                ),
              )
            ],
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Center(
            child: Icon(
              Icons.window_rounded,
            ),
          ),
        ),
        activeColorPrimary: Colors.white,
        inactiveIcon: Container(
          height: 40,
          width: 45,
          color: Colors.transparent,
          child: const Center(
            child: Icon(
              Icons.window_rounded,
            ),
          ),
        ),
        activeColorSecondary: const Color.fromRGBO(151, 97, 237, 1),
        title: 'Home',
        textStyle: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      PersistentBottomNavBarItem(
        opacity: 0.00000001,
        icon: Container(
          height: 40,
          width: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff9761ED),
                Color(0xff7525F3),
              ],
              stops: [
                0.0599,
                0.8036,
              ],
              transform: GradientRotation(
                  213 * (pi / 180)), // Set the rotation of the gradient
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigoAccent.withOpacity(0.6),
                blurRadius: 20.0,
                spreadRadius: 0.0,
                offset: const Offset(
                  0.0,
                  8.0,
                ),
              )
            ],
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 31,
            ),
          ),
        ),
        activeColorPrimary: Colors.white,
        inactiveIcon: Container(
          height: 40,
          width: 45,
          color: Colors.transparent,
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 31,
            ),
          ),
        ),
        activeColorSecondary: const Color.fromRGBO(151, 97, 237, 1),
        title: 'Content',
        textStyle: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      PersistentBottomNavBarItem(
          opacity: 0.00000001,
          icon: Container(
              height: 40,
              width: 45,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffC098FF),
                      Color(0xff5300D5),
                    ],
                    stops: [0.0, 1.0],
                    transform: GradientRotation(225 * 3.14 / 180),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xff220C49),
                      blurRadius: 10,
                      spreadRadius: 2.0, //extend the shadow
                      offset: Offset(
                        0.0, // Move to right 10  horizontally
                        6.0, // Move to bottom 10 Vertically
                      ),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 97, 10, 238),
                      offset: Offset(0.0, 9.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(100)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  AppImages.imgVideocam,
                ),
              )),
          activeColorPrimary: Colors.white,
          inactiveIcon: Container(
              height: 40,
              width: 45,
              decoration: BoxDecoration(
                  // gradient: const LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  //   colors: [
                  //     Color(0xffC098FF),
                  //     Color(0xff5300D5),
                  //   ],
                  //   stops: [
                  //     0.0,
                  //     1.0,
                  //   ],
                  // ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xff220C49),
                      blurRadius: 10,
                      spreadRadius: 2.0, //extend the shadow
                      offset: Offset(
                        0.0, // Move to right 10  horizontally
                        6.0, // Move to bottom 10 Vertically
                      ),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 97, 10, 238),
                      offset: Offset(0.0, 9.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(100)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  AppImages.imgVideocam,
                ),
              )),
          activeColorSecondary: Colors.white),
      PersistentBottomNavBarItem(
        opacity: 0.00000001,
        icon: Stack(
          children: [
            Container(
              height: 40,
              width: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff9761ED),
                    Color(0xff7525F3),
                  ],
                  stops: [
                    0.0599,
                    0.8036,
                  ],
                  transform: GradientRotation(
                      213 * (pi / 180)), // Set the rotation of the gradient
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigoAccent.withOpacity(0.6),
                    blurRadius: 20.0,
                    spreadRadius: 0.0,
                    offset: const Offset(
                      0.0,
                      8.0,
                    ),
                  )
                ],
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidComment,
                      size: 20,
                    ),
                  )),
            ),
            if (number! > 0)
              Positioned(
                right: 7,
                bottom: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(251, 91, 120, 1),
                        Color.fromRGBO(255, 65, 99, 0.53),
                      ],
                      stops: [0.0462, 0.8846],
                      transform: GradientRotation(16.7 * 3.1415927 / 180),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number > 9 ? "9+" : number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: number > 9 ? 8 : 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        activeColorPrimary: Colors.white,
        inactiveIcon: Stack(
          children: [
            Container(
              height: 40,
              width: 45,
              color: Colors.transparent,
              child: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidComment,
                      size: 20,
                    ),
                  )),
            ),
            if (number > 0)
              Positioned(
                right: 7,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(251, 91, 120, 1),
                        Color.fromRGBO(255, 65, 99, 0.53),
                      ],
                      stops: [0.0462, 0.8846],
                      transform: GradientRotation(16.7 * 3.1415927 / 180),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number > 9 ? "9+" : number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: number > 9 ? 9.5 : 10,
                        fontWeight:
                            number > 9 ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        activeColorSecondary: const Color.fromRGBO(151, 97, 237, 1),
        title: 'Messenger',
        textStyle: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      PersistentBottomNavBarItem(
        opacity: 0.00000001,
        icon: Container(
          height: 40,
          width: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff9761ED),
                Color(0xff7525F3),
              ],
              stops: [
                0.0599,
                0.8036,
              ],
              transform: GradientRotation(
                  213 * (pi / 180)), // Set the rotation of the gradient
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigoAccent.withOpacity(0.6),
                blurRadius: 20.0,
                spreadRadius: 0.0,
                offset: const Offset(
                  0.0,
                  8.0,
                ),
              )
            ],
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.star_rate_rounded,
            size: 28,
          ),
        ),
        activeColorPrimary: Colors.white,
        inactiveIcon: Container(
          height: 40,
          width: 45,
          color: Colors.transparent,
          child: const Icon(
            Icons.star_rate_rounded,
            size: 28,
          ),
        ),
        activeColorSecondary: const Color.fromRGBO(151, 97, 237, 1),
        title: 'Favorites',
        textStyle: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWithNavBar(
      screen: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffc098ff),
                Color(0xff5300d5),
              ],
              stops: [
                0.0,
                1.0,
              ],
            ),
          ),
          child: SpeedDialBuilder(
            buttonAnchor: Alignment.center,
            itemAnchor: Alignment.center,
            reverse: true,
            buttonBuilder: (context, isActive, toggle) => FloatingActionButton(
              onPressed: toggle,
              backgroundColor: Colors.transparent,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubicEmphasized,
                turns: isActive ? 1 : 0,
                child: SvgPicture.asset(AppImages.imgVideocam),
              ),
            ),
            itemBuilder: (context, Widget item, i, animation) {
              // radius in relative units to each item
              const radius = 1.7;
              // angle in radians
              final angle = i * (1 / 0.7) + 4;

              final targetOffset = Offset(
                radius * cos(angle),
                radius * sin(angle),
              );

              final offsetAnimation = Tween<Offset>(
                begin: Offset.zero,
                end: targetOffset,
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: item,
                ),
              );
            },
            items: [
              FloatingActionButton.small(
                backgroundColor: AppColors.indigoAccent2,
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: const CreateStream(), withNavBar: true);
                },
                child: Image.asset(AppImages.streamIcon),
              ),
              FloatingActionButton.small(
                backgroundColor: AppColors.indigoAccent2,
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: const UploadVideoView(), withNavBar: true);
                },
                child: SvgPicture.asset(AppImages.uploadsvg),
              ),
            ],
          ),
        ),
        body: PersistentTabView(
          controller: tabController,
          navBarHeight: 60,
          context,
          screens: _screens(),
          items: _navbarItem(messages),
          backgroundColor: AppColors.bgGradient1,
          navBarStyle: NavBarStyle.style8,
          decoration: NavBarDecoration(borderRadius: BorderRadius.circular(1)),
          stateManagement: true,
        ),
      ),
    );
  }
}
