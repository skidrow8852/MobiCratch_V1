import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/Messages/ChatView.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/AppConstant.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/customtext.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

// ignore: must_be_immutable
class AddMessagesView extends StatefulWidget {
  dynamic data;

  AddMessagesView({Key? key, required this.data}) : super(key: key);

  @override
  State<AddMessagesView> createState() => _AddMessagesViewState();
}

class _AddMessagesViewState extends State<AddMessagesView> {
  List<dynamic> allUserData = [];
  List<dynamic> copyData = [];
  bool isChanging = false;

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
      print(e);
    }
  }

  Future<void> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var tokena = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      var apiCall = await http.get(
          Uri.parse('https://account.cratch.io/api/users/all/$wallet'),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          });

      var response = json.decode(apiCall.body);

      if (apiCall.statusCode == 200 && response != null && response is List) {
        setState(() {
          allUserData = response;
          copyData = response;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _onSearchTextChanged(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        copyData = allUserData;
        isChanging = false;
      });
      return;
    }
    allUserData.forEach((user) {
      if (searchText.isNotEmpty) {
        setState(() {
          isChanging = true;
          copyData = allUserData
              .where((user) => user['username']
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
              .toList();
        });
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    setupIntl();
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
          // extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: const TopBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFFE2A3C9),
                    )),
                CustomSizedBoxHeight(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TextFormField(
                    // autocorrect: true,
                    // enableSuggestions: true,
                    onChanged: _onSearchTextChanged,
                    maxLines: 5,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: AppColors.whiteA700, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      filled: true,
                      fillColor: AppColors.fieldUnActive,
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.search,
                        color: AppColors.gray75,
                      ),
                      contentPadding: const EdgeInsets.only(left: 10),
                      hintStyle: TextStyle(
                          color: const Color(0xff7C7C7C),
                          fontWeight: FontWeight.w300,
                          fontFamily: AppConstant.interMedium,
                          fontSize: 15.sp),
                    ),
                  ),
                ),
                widget.data.length > 0
                    ? Expanded(
                        child: isChanging
                            ? ListView.builder(
                                padding: const EdgeInsets.only(
                                    bottom: 60.0, top: 10),
                                physics: const BouncingScrollPhysics(),
                                itemCount: copyData.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.loose,
                                    clipBehavior: Clip.none,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          PersistentNavBarNavigator
                                              .pushNewScreen(
                                            context,
                                            screen: ChatView(
                                                userData: copyData[index]),
                                            withNavBar: false,
                                          );
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  '${copyData[index]['ProfileAvatar']}'),
                                              radius: 25),
                                          title: CustomText(
                                            title:
                                                '${copyData[index]['username']}',
                                            textStyle: AppStyle
                                                .textStyle12regularWhite,
                                          ),
                                          subtitle: CustomText(
                                            title: "Hi There! let's chat 👋",
                                            textStyle: AppStyle
                                                .textStyle9SemiBoldWhite,
                                          ),
                                        ),
                                      ),
                                      copyData[index]['isOnline']
                                          ? Positioned(
                                              top: 52,
                                              left: 50,
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : Positioned(
                                              top: 52,
                                              left: 50,
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                    ],
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                    bottom: 60.0, top: 10),
                                physics: const BouncingScrollPhysics(),
                                itemCount: widget.data.length,
                                itemBuilder: (context, index) {
                                  if (widget.data[index]['last_time_message']
                                          .toString() ==
                                      "👋") {
                                    return Container();
                                  } else {
                                    return Stack(
                                      fit: StackFit.loose,
                                      clipBehavior: Clip.none,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            PersistentNavBarNavigator
                                                .pushNewScreen(
                                              context,
                                              screen: ChatView(
                                                  userData: widget.data[index]),
                                              withNavBar: false,
                                            );
                                          },
                                          child: ListTile(
                                            leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '${widget.data[index]['ProfileAvatar']}'),
                                                radius: 25),
                                            title: CustomText(
                                              title:
                                                  '${widget.data[index]['username']}',
                                              textStyle: AppStyle
                                                  .textStyle12regularWhite,
                                            ),
                                            subtitle: CustomText(
                                              textStyle: TextStyle(
                                                color: const Color.fromARGB(
                                                    255, 186, 186, 186),
                                                fontSize: 9.sp,
                                                fontFamily:
                                                    AppConstant.interMedium,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              title:
                                                  '${timeago.format(DateTime.parse(widget.data[index]['last_time_message'].toString()), locale: 'en')}',
                                            ),
                                          ),
                                        ),
                                        widget.data[index]['from_status']
                                            ? Positioned(
                                                top: 52,
                                                left: 50,
                                                child: Container(
                                                  height: 10,
                                                  width: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                            : Positioned(
                                                top: 52,
                                                left: 50,
                                                child: Container(
                                                  height: 10,
                                                  width: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    );
                                  }
                                },
                              ),
                      )
                    : const Center()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
