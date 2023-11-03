import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/AppConstant.dart';
import '../../widgets/custom_icon_button.dart';
import '../Donation/BottomSheet.dart';
import '../Donation/NFT_View/SuccessNft.dart';
import '../Donation/NFT_View/donationDetailScreen.dart';
import 'StreamComponents/StreamCmntsRow1.dart';
import 'StreamComponents/StreamCmntsRow2.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class VideoComponent extends StatefulWidget {
  final String videoId;
  final bool? creator;

  const VideoComponent({super.key, required this.videoId, this.creator});

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  var msgtext = TextEditingController();
  var listviewcon = TextEditingController();
  bool isVisible2 = false;
  bool isLoading = true;
  List<dynamic> allComments = [];
  String msg = "";
  bool isCommentsLoading = true;

  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  Map<String, dynamic> allVideoData = {};

  Future<void> getAllComments(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? wallet = prefs.getString('wallet_address');
      String? token = prefs.getString('token');
      final response = await http.post(
          Uri.parse(
              'https://account.cratch.io/api/video/comments/getComments/$wallet'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          },
          body: json.encode({"videoId": id}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('comments')) {
          final comments = data['comments'];
          if (comments.isNotEmpty) {
            setState(() {
              allComments = List.from(
                  comments); // Initialize allComments as an empty list
              isCommentsLoading = false;
            });
          } else {
            setState(() {
              isCommentsLoading = false;
            });
          }
        } else {
          setState(() {
            isCommentsLoading = false;
          });
        }
      } else {
        setState(() {
          isCommentsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isCommentsLoading = false;
      });
      print('An error occurred: $e');
    }
  }

  String address = "";
  String token = "";

  Future<Map<String, String>> _getWalletAddressAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    var addressa = prefs.getString('wallet_address') ?? '';
    var tokena = prefs.getString('token') ?? '';
    setState(() {
      address = addressa.toLowerCase();
      token = tokena;
    });
    return {'address': addressa};
  }

  @override
  void initState() {
    super.initState();
    _getWalletAddressAndToken().then(((value) {
      getVideo();
    }));
  }

  @override
  void dispose() {
    _chewieController.pause(); // Pause the video playback
    _videoPlayerController.pause();
    _chewieController.dispose(); // Dispose of the Chewie controller first
    _videoPlayerController
        .dispose(); // Then dispose of the VideoPlayerController

    super.dispose();
  }

  Future<void> getVideo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var address = prefs.getString('wallet_address') ?? '';
      var token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(widget.creator != null
            ? 'https://account.cratch.io/api/video/${widget.videoId}/owner/${address.toLowerCase()}'
            : 'https://account.cratch.io/api/video/${widget.videoId}/user/${address.toLowerCase()}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive'
        },
      );
      final videoData = jsonDecode(response.body);
      print(videoData);
      if (response.statusCode == 200 &&
          videoData['status'] == null &&
          videoData['error'] == null) {
        setState(() {
          isLoading = false;
          allVideoData = videoData;
        });

        _initializeVideoPlayer(videoData['videoPath']);
        getAllComments(videoData['_id']);
        await http.put(
            Uri.parse(widget.creator != null
                ? ''
                : 'https://account.cratch.io/api/video/edit/${widget.videoId}/${address.toLowerCase()}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive'
            },
            body: json.encode(videoData['views'] != null
                ? {"views": int.tryParse(videoData['views'])! + 1}
                : {}));
      } else {
        _initializeVideoPlayer("");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeVideoPlayer(String path) {
    try {
      final videoPlayerController = VideoPlayerController.network(path);
      _chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: 16 / 9
          // other customization options
          );
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing ChewieController: $e');
      // Handle the error gracefully, e.g., show an error message or fallback UI
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    setupIntl();

    bool isImage = allVideoData['videoPath'] != null &&
        allVideoData['videoPath'].endsWith('.png');
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaflodbgcolor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: isLoading
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            child: Stack(
                              alignment:
                                  Alignment.topCenter, // or Alignment.center
                              children: [
                                Container(
                                  width: double
                                      .infinity, // Set the width to take up the full available space
                                  child: isImage
                                      ? Container(
                                          height: 220.h,
                                          decoration: BoxDecoration(
                                            // Use videoData['videoPath'] as the background image
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  allVideoData['videoPath']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : AspectRatio(
                                          aspectRatio: 16 /
                                              9, // Replace with the correct aspect ratio of the video
                                          child: Chewie(
                                            controller: _chewieController,
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.w, vertical: 15.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.back();
                                        },
                                        child: Container(
                                          height: 40.h,
                                          width: 40.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.backbutton
                                                .withOpacity(0.5),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.gray75),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              color: AppColors.iconcolor,
                                              size: 20.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                StreamCmntsRow1(
                                  video: allVideoData,
                                  type: 'video',
                                ),
                                CustomSizedBoxHeight(height: 26.h),
                                StreamCmntsRow2(
                                  walletUser: address,
                                  token: token,
                                  type: 'video',
                                  video: allVideoData,
                                  ontap: () {
                                    showModalBottomSheet(
                                      barrierColor:
                                          AppColors.gray.withOpacity(0.4),
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
                                        return BottomSheetView(
                                          wallet: allVideoData['creator']
                                              ['userId'],
                                          onTapNft: () {
                                            Get.to(showModalBottomSheet(
                                              barrierColor: AppColors.gray
                                                  .withOpacity(0.4),
                                              backgroundColor:
                                                  AppColors.bgGradient2A,
                                              isDismissible: true,
                                              useSafeArea: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(25.r),
                                                  topRight:
                                                      Radius.circular(25.r),
                                                ),
                                              ),
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return DonationDetailView(
                                                    onTapMint: () {
                                                  Get.to(showModalBottomSheet(
                                                    barrierColor: AppColors.gray
                                                        .withOpacity(0.4),
                                                    backgroundColor:
                                                        AppColors.bgGradient2A,
                                                    isDismissible: true,
                                                    useSafeArea: true,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                25.r),
                                                        topRight:
                                                            Radius.circular(
                                                                25.r),
                                                      ),
                                                    ),
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return const NftSuccessBottomSheet();
                                                    },
                                                  ));
                                                });
                                              },
                                            ));
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                CustomSizedBoxHeight(height: 26.h),
                                Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                            textStyle: AppStyle
                                                .textStyle14whiteSemiBold,
                                            title: "Comments"),
                                        CustomSizedBoxHeight(height: 8.h),
                                        Container(
                                            height:
                                                300, // Set a specific height
                                            child:
                                                // StreamCmntsRow3(
                                                //     videoId: allVideoData['_id']),
                                                isCommentsLoading
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )
                                                    : allComments.isNotEmpty
                                                        ? ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                allComments
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      CustomSizedBoxHeight(
                                                                          height:
                                                                              8.h),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          final prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          var token =
                                                                              prefs.getString('token') ?? '';
                                                                          // Navigate to another page or perform some other action
                                                                          Navigator.pop(
                                                                              context);
                                                                          PersistentNavBarNavigator.pushNewScreen(
                                                                              context,
                                                                              screen: ProfileView(
                                                                                wallet: allComments[index]['creator']['userId'],
                                                                                token: token,
                                                                              ),
                                                                              withNavBar: true);
                                                                        },
                                                                        child: CircleAvatar(
                                                                            child: ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(100),
                                                                          child:
                                                                              Image(
                                                                            image:
                                                                                NetworkImage(allComments[index]['creator']['ProfileAvatar'] ?? ""),
                                                                            width:
                                                                                96,
                                                                            height:
                                                                                96,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        )),
                                                                      ),
                                                                      CustomSizedBoxWidth(
                                                                          width:
                                                                              10.w),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  CustomText(
                                                                                    textStyle: AppStyle.textStyle12regularWhite,
                                                                                    title: allComments[index]['creator']['username'].length > 10 ? "${allComments[index]['creator']['username'].substring(0, 10)}..." : allComments[index]['creator']['username'],
                                                                                  ),
                                                                                  CustomSizedBoxWidth(width: 4),
                                                                                  allComments[index]['creator']['isVerified'] != null && allComments[index]['creator']['isVerified']
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
                                                                                textStyle: AppStyle.textStyle10SemiBoldBlack.copyWith(color: const Color(0xffA1A1A1), fontSize: 9.sp),
                                                                                title: ' ${timeago.format(DateTime.parse(allComments[index]['createdAt']), locale: 'en')}',
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          CustomSizedBoxHeight(
                                                                              height: 5.h),
                                                                          Container(
                                                                            width:
                                                                                300, // replace with your preferred max width
                                                                            child:
                                                                                Text(
                                                                              allComments[index]['content'] ?? "",
                                                                              softWrap: true,
                                                                              maxLines: 15,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: AppStyle.textStyle11SemiBoldBlack,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      CustomSizedBoxHeight(
                                                                          height:
                                                                              8.h)
                                                                    ],
                                                                  ));
                                                            },
                                                          )
                                                        : const SizedBox(
                                                            child: Text(
                                                              "There are no comments yet.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ))
                                      ],
                                    ),

                                    /// Replies View
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ),
            SizedBox(
              // height: MediaQuery.of(context).size.height*0.044,
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
                  maxLines: 5,
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
                    hintText: 'Type a comment...',
                    border: InputBorder.none,
                    suffixIcon: msgtext.text.length != 0
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButtonWidget(
                              ontap: () async {
                                try {
                                  final mes = msg;

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var token = prefs.getString('token') ?? '';
                                  var wallet =
                                      prefs.getString('wallet_address') ?? '';

                                  final response = await http.get(
                                    Uri.parse(
                                        'https://account.cratch.io/api/users/profile/${wallet.toLowerCase()}/$wallet'),
                                    headers: {'Authorization': 'Bearer $token'},
                                  );
                                  final userData = jsonDecode(response.body);

                                  if (response.statusCode == 200) {
                                    if (mes.length >= 2) {
                                      msgtext.text = '';
                                      setState(() {
                                        msg = "";
                                        allComments.add({
                                          "creator": userData,
                                          "content": mes,
                                          "createdAt": DateTime.now().toString()
                                        });
                                      });
                                      await http.post(
                                          Uri.parse(
                                              'https://account.cratch.io/api/video/comments/saveComment'),
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'Connection': 'keep-alive',
                                            'Authorization': 'Bearer $token',
                                          },
                                          body: json.encode({
                                            "id": userData['_id'],
                                            "creator": wallet,
                                            "videoId": allVideoData['_id'],
                                            "value": mes
                                          }));
                                    } else {
                                      setState(() {
                                        msg = mes;
                                        msgtext.text = mes;
                                      });
                                    }
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
                            Icons.emoji_emotions_outlined,
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
            )
          ],
        ),
      ),
    );
  }
}
