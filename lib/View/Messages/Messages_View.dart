import 'dart:convert';
import 'package:cratch/Utils/AppConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/customtext.dart';
import 'AddMessage_View.dart';
import 'ChatView.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class MessagesView extends StatefulWidget {
  const MessagesView({Key? key}) : super(key: key);

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  String address = "";
  String token = "";
  bool isChatLoading = true;
  List<dynamic> chatUsers = [];
  IO.Socket? socket;

  void onMessageReceived(Map<String, dynamic> data, String address) {
    if (data['to']?.toLowerCase() == address.toLowerCase() ||
        data['from']?.toLowerCase() == address.toLowerCase()) {
      String userId = data['from']?.toLowerCase() == address.toLowerCase()
          ? data['to'].toString().toLowerCase()
          : data['from'].toString().toLowerCase();

      // Check if user already exists in chatUsers list
      int userIndex = chatUsers.indexWhere(
          (user) => user['userId']?.toLowerCase() == userId.toLowerCase());

      if (userIndex != -1) {
        // User already exists, update details
        if (data['from']?.toLowerCase() == address.toLowerCase()) {
          // You sent the latest message, set to_count to 0

          chatUsers[userIndex]['to_count'] = 0;
          chatUsers[userIndex]['message'] = data['last_message'];
          chatUsers[userIndex]['last_time_message'] = data['last_time_message'];
        } else {
          chatUsers[userIndex]['to_count'] = data['to_count'] as int;
          chatUsers[userIndex]['message'] = data['last_message'];
          chatUsers[userIndex]['last_time_message'] = data['last_time_message'];
        }
      } else if (data['from']?.toLowerCase() == address.toLowerCase() &&
          userIndex == -1) {
        String username = data['to_name']?.length >= 15
            ? "${data['to_name'].substring(0, 15)}..."
            : data['to_name'].toString();
        String profileAvatar = data['to_avatar'].toString();
        String createdAt = data['last_time_message'];
        bool isOnline = data['to_status'];
        String fromName = data['to_name']?.length >= 15
            ? "${data['to_name'].substring(0, 15)}..."
            : data['to_name'].toString();
        String fromAvatar = data['to_avatar'].toString();
        String to = data['from'].toString();
        String message = data['last_message'];
        bool fromStatus = data['from_status'];
        int toCount = 0;

        chatUsers.add({
          "username": username,
          "ProfileAvatar": profileAvatar,
          "userId": userId,
          "createdAt": createdAt,
          "isOnline": isOnline,
          "from_name": fromName,
          "from_avatar": fromAvatar,
          "to": to,
          "message": message,
          "last_time_message": createdAt,
          "from_status": fromStatus,
          "to_count": toCount,
        });
      } else {
        // User does not exist, add to list
        String username = data['from_name']?.length >= 15
            ? "${data['from_name'].substring(0, 15)}..."
            : data['from_name'].toString();
        String profileAvatar = data['from_avatar'].toString();
        String createdAt = data['last_time_message'];
        bool isOnline = data['from_status'];
        String fromName = data['from_name']?.length >= 15
            ? "${data['from_name'].substring(0, 15)}..."
            : data['from_name'].toString();
        String fromAvatar = data['from_avatar'].toString();
        String to = data['to'].toString();
        String message = data['last_message'];
        bool fromStatus = data['from_status'];
        int toCount = data['to_count'] as int;

        if (data['from']?.toLowerCase() == address.toLowerCase()) {
          // You sent the latest message, set to_count to 0
          toCount = 0;
        }

        chatUsers.add({
          "username": username,
          "ProfileAvatar": profileAvatar,
          "userId": userId,
          "createdAt": createdAt,
          "isOnline": isOnline,
          "from_name": fromName,
          "from_avatar": fromAvatar,
          "to": to,
          "message": message,
          "last_time_message": data['last_time_message'],
          "from_status": fromStatus,
          "to_count": toCount,
        });
      }

      List<Map<String, dynamic>> usersWithTimestamp = [];
      List<Map<String, dynamic>> usersWithGreeting = [];

      for (var user in chatUsers) {
        if (user['last_time_message'] == "👋") {
          usersWithGreeting.add(user);
        } else {
          usersWithTimestamp.add(user);
        }
      }

      usersWithTimestamp.sort(
          (a, b) => b['last_time_message'].compareTo(a['last_time_message']));

      List<Map<String, dynamic>> sortedChatUsers = [];
      sortedChatUsers.addAll(usersWithTimestamp);
      sortedChatUsers.addAll(usersWithGreeting);

      if (mounted) {
        setState(() {
          chatUsers = sortedChatUsers;
        });
      }
    }
  }

  void initializeSocket(String serverHost) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';

    socket = IO.io(
      serverHost,
      IO.OptionBuilder().setTransports(['websocket', 'polling']).setQuery(
          {'token': token}).build(),
    );

    socket?.on('last-chat', (data) {
      try {
        if (mounted) {
          onMessageReceived(data, address);
        }
      } catch (e) {
        print(e);
      }
    });

    socket?.on('clear-conversation', (data) {
      try {
        String? from = data['from']?.toString().toLowerCase();
        int userIndex = chatUsers.indexWhere(
            (user) => user['userId']?.toString().toLowerCase() == from);

        if (userIndex != -1 && mounted) {
          setState(() {
            chatUsers[userIndex]['to_count'] = 0;
          });
        } else {
          print('User not found in chatUsers list');
        }
      } catch (e) {
        print('Error: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getMessages();
    initializeSocket("https://account.cratch.io/");
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
      var uniqueUsers = Set<String>(); // Store unique userIds

      if (response.statusCode == 200 && data is List && data.isNotEmpty) {
        for (var d in data) {
          if (d['from'].toString() == wallet.toLowerCase() &&
              uniqueUsers.add(d['to'].toString())) {
            chatUsers.add({
              "username": d['to_name']?.length >= 15
                  ? "${d['to_name'].substring(0, 15)}..."
                  : d['to_name'].toString(),
              "ProfileAvatar": d['to_avatar'].toString(),
              "userId": d['to'].toString(),
              "createdAt": d['createdAt'],
              "isOnline": d['to_status'],
              "from_name": d['to_name']?.length >= 15
                  ? "${d['to_name'].substring(0, 15)}..."
                  : d['to_name'].toString(),
              "from_avatar": d['to_avatar'].toString(),
              "to": d['from'].toString(),
              "message": d['last_message'],
              "last_time_message": d['last_time_message'],
              "from_status": d['from_status'],
              "to_count": 0
            });
          } else {
            uniqueUsers.add(d['from'].toString());
            chatUsers.add({
              "username": d['from_name']?.length >= 15
                  ? "${d['from_name'].substring(0, 15)}..."
                  : d['from_name'].toString(),
              "ProfileAvatar": d['from_avatar'].toString(),
              "userId": d['from'].toString(),
              "createdAt": d['createdAt'],
              "isOnline": d['from_status'],
              "from_name": d['from_name']?.length >= 15
                  ? "${d['from_name'].substring(0, 15)}..."
                  : d['from_name'].toString(),
              "from_avatar": d['from_avatar'].toString(),
              "to": d['to'].toString(),
              "message": d['last_message'],
              "last_time_message": d['last_time_message'],
              "from_status": d['from_status'],
              "to_count": d['to_count'] as int
            });
          }
        }
      }

      var response2 = await http.get(
          Uri.parse('https://account.cratch.io/api/users/limited/all/$wallet'),
          headers: {
            'Authorization': 'Bearer $tokena',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          });

      if (response2.statusCode == 200) {
        var dt = json.decode(response2.body);
        var usersAdded = 0; // Track the number of users added

        for (var dats in dt) {
          if (usersAdded >= 5) {
            break; // Limit to 5 users
          }

          var lastMessageTime = "👋";
          var message = "Hi there! let's chat"; // Default message

          var conv = data is! Map
              ? data.firstWhere((obj) => obj['to'] == dats['userId'],
                  orElse: () => null)
              : null;
          if (conv != null && conv['from'] == wallet.toLowerCase()) {
            message = conv['last_message'];
            lastMessageTime = conv['last_time_message'];
          }

          if (uniqueUsers.add(dats['userId'].toString())) {
            chatUsers.add({
              "username": dats['username']?.length >= 15
                  ? "${dats['username'].substring(0, 15)}..."
                  : dats['username'].toString(),
              "ProfileAvatar": dats['ProfileAvatar'].toString(),
              "userId": dats['userId'].toString(),
              "createdAt": dats['createdAt'],
              "isOnline": dats['isOnline'],
              "from_name": dats['username']?.length >= 15
                  ? "${dats['username'].substring(0, 15)}..."
                  : dats['username'].toString(),
              "from_avatar": dats['ProfileAvatar'].toString(),
              "to": dats['userId'].toString(),
              "message": conv != null ? message : "Hi there! let's chat",
              "last_time_message": conv != null ? lastMessageTime : "👋",
              "to_count": 0,
              "from_status": dats['isOnline']
            });

            usersAdded++;
          }
        }
      }
      List<Map<String, dynamic>> usersWithTimestamp = [];
      List<Map<String, dynamic>> usersWithGreeting = [];

      for (var user in chatUsers) {
        if (user['last_time_message'] == "👋") {
          usersWithGreeting.add(user);
        } else {
          usersWithTimestamp.add(user);
        }
      }

      usersWithTimestamp.sort(
          (a, b) => b['last_time_message'].compareTo(a['last_time_message']));

      List<Map<String, dynamic>> sortedChatUsers = [];
      sortedChatUsers.addAll(usersWithTimestamp);
      sortedChatUsers.addAll(usersWithGreeting);
      if (mounted) {
        setState(() {
          chatUsers = sortedChatUsers;
          isChatLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isChatLoading = false;
      });
      print(e);
    }
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
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const TopBar(),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF373953),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 20),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 10.0, top: 20),
                            child: Text(
                              'Messages',
                              style: TextStyle(
                                fontSize: 17.h,
                                fontWeight: FontWeight.w700,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: [
                                      AppColors.mainColor,
                                      AppColors.indigo,
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                                  ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0, left: 5),
                            child: IconButtonWidget(
                              ontap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddMessagesView(data: chatUsers),
                                  ),
                                );
                              },
                              height: 35,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.mainColor,
                                  AppColors.indigoAccent,
                                ],
                              ),
                              width: 35,
                              widget: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: isChatLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                // top: 10.h,
                                bottom: 60.h,
                                left: 23.w,
                                right: 23.w),
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: 10.h),
                              physics: const BouncingScrollPhysics(),
                              itemCount: chatUsers.length,
                              itemBuilder: (context, index) {
                                String message = chatUsers[index]['message'];
                                RegExp regExp = RegExp(
                                  r"https?:\/\/[^\s]+\.(?:jpg|jpeg|gif|png)",
                                  caseSensitive: false,
                                  multiLine: true,
                                );
                                Match? match = regExp.firstMatch(message);
                                return Stack(
                                  fit: StackFit.loose,
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: ChatView(
                                              userData: chatUsers[index]),
                                          withNavBar: false,
                                        );
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            '${chatUsers[index]['from_avatar']}',
                                          ),
                                          radius: 25,
                                        ),
                                        title: CustomText(
                                          title: chatUsers[index]['from_name'],
                                          textStyle:
                                              AppStyle.textStyle12regularWhite,
                                        ),
                                        subtitle: CustomText(
                                          title: match != null
                                              ? message.replaceAll(
                                                  match.group(0)!, ' 📷')
                                              : chatUsers[index]['message'],
                                          textStyle: AppStyle
                                              .textStyle11SemiBoldWhite400,
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            chatUsers[index]["to_count"] > 0
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      CustomText(
                                                        textStyle: TextStyle(
                                                          color: const Color(
                                                              0xFFAC81EE),
                                                          fontSize: 9.sp,
                                                          fontFamily:
                                                              AppConstant
                                                                  .interMedium,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        title:
                                                            '${timeago.format(DateTime.parse(chatUsers[index]["last_time_message"].toString()), locale: 'en')}',
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Container(
                                                        width: 23,
                                                        height: 23,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .mainColor,
                                                              AppColors.indigo,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            chatUsers[index][
                                                                        "to_count"] >
                                                                    9
                                                                ? "9+"
                                                                : "${chatUsers[index]["to_count"]}",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : CustomText(
                                                    textStyle: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              186,
                                                              186,
                                                              186),
                                                      fontSize: 9.sp,
                                                      fontFamily: AppConstant
                                                          .interMedium,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    title: chatUsers[index][
                                                                    'last_time_message']
                                                                .toString() ==
                                                            "👋"
                                                        ? "👋"
                                                        : '${timeago.format(DateTime.parse(chatUsers[index]["last_time_message"].toString()), locale: 'en')}',
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    chatUsers[index]['from_status']
                                        ? Positioned(
                                            top: 41.h,
                                            left: 50.w,
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
                                            top: 41.h,
                                            left: 50.w,
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
                            ),
                          ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
