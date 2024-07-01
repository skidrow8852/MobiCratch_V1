import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/app_style.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/customtext.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:socket_io_client/socket_io_client.dart' as IO;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class LiveChatRoom extends StatefulWidget {
  final String videoId;

  const LiveChatRoom({super.key, required this.videoId});

  @override
  _StreamCmntsRow3State createState() => _StreamCmntsRow3State();
}

class _StreamCmntsRow3State extends State<LiveChatRoom> {
  List<dynamic> allComments = [];
  bool isLoading = true;
  IO.Socket? socket;
  final ScrollController _scrollController =
      ScrollController(); // Initialize the scroll controller

  Future<void> getAllComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      final response = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/live/chat/${widget.videoId}/$wallet'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            allComments = responseData;
            isLoading = false;
          });
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('status')) {
          setState(() {
            allComments = [];
            isLoading = false;
          });
        } else {
          setState(() {
            allComments = [];
            isLoading = false;
          });
          // Handle other cases or provide a default behavior
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('An error occurred: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initializeSocket(String serverHost) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';

    socket = IO.io(
      serverHost,
      IO.OptionBuilder().setTransports(['websocket', 'polling']).setQuery(
          {'token': token}).build(),
    );

    socket?.on('live-chat-sent', (data) {
      if (data['liveId'] == widget.videoId) {
        setState(() {
          allComments.add(data);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllComments();
    initializeSocket("https://account.cratch.io/");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    if (allComments.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    setupIntl();
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : allComments.isNotEmpty
            ? ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: allComments.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CustomSizedBoxHeight(height: 8.h),
                        GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            var token = prefs.getString('token') ?? '';

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProfileView(
                                        wallet: allComments[index]['creator']
                                            ['userId'],
                                        token: token,
                                      )),
                            );

                            // Navigate to another page or perform some other action
                          },
                          child: CircleAvatar(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image(
                                image: NetworkImage(
                                  allComments[index]['creator']
                                          ['ProfileAvatar'] ??
                                      "",
                                ),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        CustomSizedBoxWidth(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    CustomText(
                                      textStyle:
                                          AppStyle.textStyle12regularWhite,
                                      title: allComments[index]['creator']
                                                      ['username']
                                                  .length >
                                              10
                                          ? "${allComments[index]['creator']['username'].substring(0, 10)}..."
                                          : allComments[index]['creator']
                                              ['username'],
                                    ),
                                    CustomSizedBoxWidth(width: 4),
                                    allComments[index]['creator']
                                                    ['isVerified'] !=
                                                null &&
                                            allComments[index]['creator']
                                                ['isVerified']
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
                                CustomSizedBoxWidth(width: 3.w),
                                CustomText(
                                  textStyle: AppStyle.textStyle10SemiBoldBlack
                                      .copyWith(
                                    color: const Color(0xffA1A1A1),
                                    fontSize: 9.sp,
                                  ),
                                  title:
                                      ' ${timeago.format(DateTime.parse(allComments[index]['createdAt']), locale: 'en')}',
                                ),
                              ],
                            ),
                            CustomSizedBoxHeight(height: 5.h),
                            CustomText(
                              textStyle: AppStyle.textStyle11SemiBoldBlack,
                              title: allComments[index]['content'],
                            ),
                          ],
                        ),
                        CustomSizedBoxHeight(height: 8.h),
                      ],
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  "",
                  style: TextStyle(color: Colors.white),
                ),
              );
  }
}
