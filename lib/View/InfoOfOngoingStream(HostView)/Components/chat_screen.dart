import 'dart:convert';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../../Utils/AppConstant.dart';
import '../../../widgets/GradientTextWidget.dart';
import '../../../widgets/custom_icon_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:socket_io_client/socket_io_client.dart' as IO;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class ChatScreen extends StatefulWidget {
  final dynamic liveId;
  const ChatScreen({Key? key, required this.liveId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var msgtext = TextEditingController();
  var listviewcon = TextEditingController();
  var msg = "";
  final ScrollController _scrollController = ScrollController();
  List<dynamic> allComments = [];
  Map<String, dynamic> alluserData = {};
  String walleta = "";
  String tokena = "";
  bool isLoading = true;
  IO.Socket? socket;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getAllComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      setState(() {
        walleta = wallet;
        tokena = token;
      });
      final response = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/live/chat/${widget.liveId}/${wallet.toLowerCase()}'),
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

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    var wallet = prefs.getString('wallet_address') ?? '';
    setState(() {
      walleta = wallet;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/users/profile/${wallet.toLowerCase()}/${wallet.toLowerCase()}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final userData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          alluserData = userData.containsKey('status') ? {} : userData;
        });
      }
    } catch (e) {
      print(e);
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

    socket?.on('live-chat-sent', (data) {
      if (data['liveId'] == widget.liveId) {
        if (mounted) {
          setState(() {
            allComments.add(data);
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllComments();
    getUserData();
    initializeSocket("https://account.cratch.io/");
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    setupIntl();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: allComments.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return allComments.isNotEmpty
                        ? Column(
                            children: [
                              allComments[index]['creator']['userId']
                                          ?.toLowerCase() ==
                                      walleta.toLowerCase()
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 45,
                                          ),
                                          child: GradientTextWidget(
                                              text: 'You', size: 12),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 40,
                                                  top: 5.h,
                                                  bottom: 5.h),
                                              padding: const EdgeInsets.all(12),
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFF2587C),
                                                    Color(0xFF7B51C7),
                                                  ],
                                                  stops: [0.0448, 1.0316],
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        147, 83, 185, 0.33),
                                                    offset: Offset(0, 4),
                                                    blurRadius: 13,
                                                  ),
                                                ],
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth:
                                                        300, // set the maximum width to 200 pixels
                                                  ),
                                                  child: Text(
                                                    allComments[index]
                                                            ['content'] ??
                                                        "",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.whiteA700,
                                                      fontSize: 12.sp,
                                                      fontFamily: AppConstant
                                                          .interSemiBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    // Set the maximum number of lines to 2
                                                    maxLines: 1000,
                                                    overflow: TextOverflow
                                                        .ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 45, bottom: 10),
                                          child: GradientTextWidget(
                                              text:
                                                  '${timeago.format(DateTime.parse(allComments[index]['createdAt']), locale: 'en')}',
                                              size: 10),
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                ProfileView(
                                                  wallet: allComments[index]
                                                      ['creator']['userId'],
                                                  token: tokena,
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 25.0,
                                              backgroundImage: NetworkImage(
                                                allComments[index]['creator']
                                                        ['ProfileAvatar'] ??
                                                    "",
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 20),
                                                child: Row(
                                                  children: [
                                                    GradientTextWidget(
                                                        text: allComments[index]
                                                                    ['creator']
                                                                ['username'] ??
                                                            "",
                                                        size: 12),
                                                    CustomSizedBoxWidth(
                                                        width: 4),
                                                    allComments[index]['creator']
                                                                    [
                                                                    'isVerified'] !=
                                                                null &&
                                                            allComments[index]
                                                                ['isVerified']
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
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    // width: 250.w,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5,
                                                          right: 25.w,
                                                          bottom: 5.h),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          begin: Alignment(
                                                              -1.0, -1.0),
                                                          end: Alignment(
                                                              1.0, 1.0),
                                                          colors: [
                                                            Color(0xFFB360FA),
                                                            Color(0xFF5F41F0),
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          transform:
                                                              GradientRotation(
                                                                  94.0 *
                                                                      3.146 /
                                                                      180),
                                                        ),
                                                        color: Theme.of(context)
                                                            .toggleableActiveColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color:
                                                                Color.fromRGBO(
                                                                    101,
                                                                    68,
                                                                    241,
                                                                    0.33),
                                                            offset:
                                                                Offset(0, 4),
                                                            blurRadius: 13,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                          maxWidth:
                                                              300, // set the maximum width to 200 pixels
                                                        ),
                                                        child: Text(
                                                          allComments[index]
                                                                  ['content'] ??
                                                              "",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .whiteA700,
                                                            fontSize: 12.sp,
                                                            fontFamily: AppConstant
                                                                .interSemiBold,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          maxLines:
                                                              1000, // Set the maximum number of lines to 2
                                                          overflow: TextOverflow
                                                              .ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, bottom: 10),
                                                child: GradientTextWidget(
                                                    text:
                                                        '${timeago.format(DateTime.parse(allComments[index]['createdAt']), locale: 'en')}',
                                                    size: 10),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                            ],
                          )
                        : const Center();
                  }),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                // elevation: 2,
                // margin: EdgeInsets.all(7),
                color: AppColors.fieldUnActive,
                child: TextFormField(
                  // autocorrect: true,
                  // enableSuggestions: true,
                  maxLines: 3,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    setState(() {
                      msg = value;
                    });
                  },
                  controller: msgtext,
                  style: TextStyle(color: AppColors.whiteA700, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    suffixIcon: msgtext.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButtonWidget(
                              ontap: () async {
                                try {
                                  if (msg.isNotEmpty &&
                                      alluserData.isNotEmpty) {
                                    var txt = msg;
                                    msgtext.text = '';
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    var token = prefs.getString('token') ?? '';

                                    setState(() {
                                      msg = "";
                                    });

                                    await http.post(
                                        Uri.parse(
                                            'https://account.cratch.io/api/live/chat'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Connection': 'keep-alive',
                                          'Authorization': 'Bearer $token',
                                        },
                                        body: json.encode({
                                          "userData": alluserData,
                                          "creator": alluserData['_id'],
                                          "liveId": widget.liveId,
                                          "content": txt
                                        }));
                                  }
                                } catch (e) {
                                  print(e);
                                }
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
                                Icons.send,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            null,
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
            ),
          ),
        )
      ],
    );
  }
}
