import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/View/LiveStreamResCreator_View/live_chat.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/AppConstant.dart';
import '../../widgets/custom_icon_button.dart';
import '../Donation/BottomSheet.dart';
import '../Donation/NFT_View/SuccessNft.dart';
import '../Donation/NFT_View/donationDetailScreen.dart';
import '../VideoPage_View/StreamComponents/StreamCmntsRow1.dart';
import '../VideoPage_View/StreamComponents/StreamCmntsRow2.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class LiveStreamViewAndComments extends StatefulWidget {
  final dynamic live;
  final String userWallet;
  final String token;
  const LiveStreamViewAndComments(
      {super.key,
      required this.live,
      required this.userWallet,
      required this.token});

  @override
  State<LiveStreamViewAndComments> createState() =>
      _LiveStreamViewAndCommentsState();
}

class _LiveStreamViewAndCommentsState extends State<LiveStreamViewAndComments>
    with RouteAware {
  var msgtext = TextEditingController();
  var listviewcon = TextEditingController();
  String message = "";
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.live['playbackUrl'] ?? "");
    addview();
  }

  void _initializeVideoPlayer(String path) {
    try {
      _videoPlayerController = VideoPlayerController.network(path);
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
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
  void dispose() {
    _chewieController.pause(); // Pause the video playback
    _videoPlayerController.pause();
    _chewieController.dispose(); // Dispose of the Chewie controller first
    _videoPlayerController
        .dispose(); // Then dispose of the VideoPlayerController

    super.dispose();
  }

  Future<void> addview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      if (widget.live['creator']['userId'] != null) {
        if (widget.live['creator']['userId'] != wallet) {
          await http.put(
              Uri.parse(
                  'https://account.cratch.io/api/live/${widget.live['_id']}/${wallet.toLowerCase()}'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Connection': 'keep-alive'
              },
              body: json.encode(widget.live['views'] != null
                  ? {"views": int.tryParse(widget.live['views'])! + 1}
                  : {}));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isImage = widget.live['playbackUrl'] != null &&
        widget.live['playbackUrl'].endsWith('.png');
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaflodbgcolor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: Stack(
                        alignment: Alignment.topCenter, // or Alignment.center
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
                                            widget.live['playbackUrl']),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.backbutton.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: AppColors.gray75),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
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
                            type: 'live',
                            video: widget.live,
                          ),
                          CustomSizedBoxHeight(height: 26.h),
                          StreamCmntsRow2(
                            walletUser: widget.userWallet,
                            token: widget.token,
                            type: 'live',
                            video: widget.live,
                            ontap: () {
                              showModalBottomSheet(
                                barrierColor: AppColors.gray.withOpacity(0.4),
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
                                    wallet: widget.live['creator']['userId'],
                                    onTapNft: () {
                                      Get.to(showModalBottomSheet(
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
                                          return DonationDetailView(
                                              onTapMint: () {
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
                          CustomText(
                              textStyle: AppStyle.textStyle14whiteSemiBold,
                              title: "Live chat room"),
                          CustomSizedBoxHeight(height: 8.h),
                          Container(
                            height: 300, // Set a specific height
                            child: LiveChatRoom(
                              videoId: widget.live['_id'],
                            ),
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
                      message = value;
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
                                  final mes = message;

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var token = prefs.getString('token') ?? '';
                                  var wallet =
                                      prefs.getString('wallet_address') ?? '';

                                  final response = await http.get(
                                    Uri.parse(
                                        'https://account.cratch.io/api/users/profile/$wallet/$wallet'),
                                    headers: {'Authorization': 'Bearer $token'},
                                  );
                                  final userData = jsonDecode(response.body);

                                  if (response.statusCode == 200) {
                                    if (mes.isNotEmpty) {
                                      msgtext.text = '';
                                      setState(() {
                                        message = "";
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
                                            "userData": userData,
                                            "creator": userData['_id'],
                                            "liveId": widget.live['_id'],
                                            "content": mes
                                          }));
                                    } else {
                                      setState(() {
                                        message = mes;
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
            )
          ],
        ),
      ),
    );
  }
}
