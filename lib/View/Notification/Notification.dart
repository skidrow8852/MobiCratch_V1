import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/widgets/GradientTextWidget.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Utils/color_constant.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_icon_button.dart';

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  void clearNotifications() {
    setState(() {
      notifications = [];
    });
  }

  void handleNotifBell() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var address = prefs.getString('wallet_address') ?? '';
      var token = prefs.getString('token') ?? '';
      final response = await http.delete(
        Uri.parse(
            'https://account.cratch.io/api/notifications/${address.toLowerCase()}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
      );
      if (response.statusCode == 200) {
        clearNotifications();
      }
    } catch (e) {
      print(e);
    }
  }

  void handleNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var address = prefs.getString('wallet_address') ?? '';
      var token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/notifications/${address.toLowerCase()}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data != null && response.statusCode == 200 && data is List) {
        setState(() {
          notifications = data;
          isLoading = false; // Data fetching complete
        });

        try {
          await http.put(
            Uri.parse(
                'https://account.cratch.io/api/notifications/${address.toLowerCase()}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
          );
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false; // Error occurred during data fetching
      });
    }
  }

  @override
  void initState() {
    super.initState();
    handleNotifications();
  }

  @override
  Widget build(BuildContext context) {
    setupIntl();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF191B32),
            Color(0xFF191B32),
            Color(0xFF030304),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF191B32),
          shadowColor: Colors.transparent,
          actions: [
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
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientTextWidget(
                      size: 17.h,
                      text: 'Notifications',
                    ),
                    CustomSizedBoxHeight(height: 20),
                    isLoading // Display loader while data is fetching
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : notifications.isEmpty
                            ? SizedBox(
                                height: 50,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: [
                                    Text(
                                      "You don’t have any new notifications yet!",
                                      style: AppStyle.textStyle12Regular,
                                    ),
                                  ],
                                ))
                            : SizedBox(
                                height: 500,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: [
                                    for (var notification in notifications)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: Image.network(
                                                        notification[
                                                                'avatar'] ??
                                                            "https://bafybeifgsujzqhmwznuytnynypwg2iaotji3d3whty5ymjbi6gghwcmgk4.ipfs.dweb.link/profile-avatar.png")
                                                    .image,
                                              ),
                                              CustomSizedBoxWidth(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (notification['type'] ==
                                                        'message')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} sent you a message',
                                                      ),
                                                    if (notification['type'] ==
                                                        'nft creation')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} created a new NFT Collection',
                                                      ),
                                                    if (notification['type'] ==
                                                        'follow')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} started following you',
                                                      ),
                                                    if (notification['type'] ==
                                                        'donate')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} made a donation',
                                                      ),
                                                    if (notification['type'] ==
                                                        'nft purchase')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} purchased your NFT',
                                                      ),
                                                    if (notification['type'] ==
                                                        'videoPublish')
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle12Regular,
                                                        title:
                                                            '${notification['username'].length > 12 ? notification['username'].substring(0, 12) : notification['username']} published a new video',
                                                      ),
                                                    CustomText(
                                                      title:
                                                          '${timeago.format(DateTime.parse(notification['createdAt']), locale: 'en')}',
                                                      textStyle: AppStyle
                                                          .textStyle11SemiBoldBlack,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          CustomSizedBoxHeight(height: 20),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                  ],
                ),
              )),
              CustomButton(
                width: double.infinity,
                title: 'Clear All',
                ontap: handleNotifBell,
                AppStyle: AppStyle.textStyle12regularWhite,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8408FF),
                    Color(0xFFCB5BFF),
                    Color(0xFFCB5BFF),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
