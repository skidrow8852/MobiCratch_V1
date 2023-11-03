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

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class StreamCmntsRow3 extends StatefulWidget {
  final String videoId;

  StreamCmntsRow3({required this.videoId});

  @override
  _StreamCmntsRow3State createState() => _StreamCmntsRow3State();
}

class _StreamCmntsRow3State extends State<StreamCmntsRow3> {
  List<dynamic> allComments = [];
  bool isLoading = true;
  late ScrollController _scrollController =
      ScrollController(); // Initialize the scroll controller

  Future<void> getAllComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      final response = await http.post(
        Uri.parse(
            'https://account.cratch.io/api/video/comments/getComments/$wallet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
        body: json.encode({"videoId": widget.videoId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('comments')) {
          final comments = data['comments'];
          if (comments.isNotEmpty) {
            setState(() {
              allComments = List.from(comments);
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
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
      setState(() {
        isLoading = false;
      });
      print('An error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllComments();
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
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var token = prefs.getString('token') ?? '';

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProfileView(
                                    wallet: allComments[index]['creator']
                                        ['userId'],
                                    token: token,
                                  ),
                                ),
                              );

                              // Na to another page or perform some other action
                            },
                            child: CircleAvatar(
                                child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image(
                                image: NetworkImage(allComments[index]
                                        ['creator']['ProfileAvatar'] ??
                                    ""),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )),
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
                                                FontAwesomeIcons
                                                    .solidCircleCheck,
                                                color: Color(0xffCEC7C7),
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
                                            fontSize: 9.sp),
                                    title:
                                        ' ${timeago.format(DateTime.parse(allComments[index]['createdAt']), locale: 'en')}',
                                  ),
                                ],
                              ),
                              CustomSizedBoxHeight(height: 5.h),
                              FractionallySizedBox(
                                widthFactor: 0.8,
                                child: CustomText(
                                    textStyle:
                                        AppStyle.textStyle11SemiBoldBlack,
                                    title: allComments[index]['content']),
                              ),
                            ],
                          ),
                          CustomSizedBoxHeight(height: 8.h)
                        ],
                      ));
                },
              )
            : Center(
                child: Text(
                  "There are no comments yet.",
                  style: TextStyle(color: Colors.white),
                ),
              );
  }
}
