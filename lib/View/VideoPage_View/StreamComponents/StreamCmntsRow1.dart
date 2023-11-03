import 'dart:convert';

import 'package:cratch/Provider/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/Sizebox/sizedboxwidth.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class StreamCmntsRow1 extends StatefulWidget {
  Map<String, dynamic> video;
  String type;
  StreamCmntsRow1({super.key, required this.video, required this.type});
  @override
  State<StreamCmntsRow1> createState() => _StreamCmntsRow1State();
}

class _StreamCmntsRow1State extends State<StreamCmntsRow1> {
  int likes = 0;
  bool isLiked = false;
  String likeId = "";
  String user = "";

  Future<void> onLike() async {
    try {
      try {
        if (widget.type != "live") {
          final favoritestate =
              Provider.of<FavoritesProvider>(context, listen: false);
          String type = widget.type == "video" ? "videoId" : "streamId";
          favoritestate.addFavorites({
            type: widget.video,
            "userId": user,
            "_id": likeId.isEmpty ? widget.video['_id'] : likeId
          });
        }
      } catch (e) {
        print(e);
      }
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId') ?? '';
      var token = prefs.getString('token') ?? '';
      var address = prefs.getString('wallet_address') ?? '';
      String videoType = widget.type == "video"
          ? "videoId"
          : widget.type == "live"
              ? "liveId"
              : "streamId";
      final response = await http.post(
          Uri.parse('https://account.cratch.io/api/video/likes/upLike'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line
          },
          body:
              json.encode({"userId": userId, videoType: widget.video['_id']}));

      if (response.statusCode == 200) {
        String url = widget.type == "video"
            ? 'https://account.cratch.io/api/video/edit/${widget.video['videoId']}/$address'
            : widget.type == "live"
                ? 'https://account.cratch.io/api/live/${widget.video['_id']}/$address'
                : "https://account.cratch.io/api/live/saved/${widget.video['streamId']['streamId']}/$address";
        await http.put(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive', // Add this line
            },
            body: json.encode({"likes": likes}));
      }
    } catch (e) {}
  }

  Future<void> unLike() async {
    try {
      try {
        if (widget.type != "live") {
          final favoritestate =
              Provider.of<FavoritesProvider>(context, listen: false);
          favoritestate
              .removeFavorites(likeId.isEmpty ? widget.video['_id'] : likeId);
        }
      } catch (e) {
        print(e);
      }

      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId') ?? '';
      var token = prefs.getString('token') ?? '';
      var address = prefs.getString('wallet_address') ?? '';
      String videoType = widget.type == "video"
          ? "videoId"
          : widget.type == "live"
              ? "liveId"
              : "streamId";

      final response = await http.post(
          Uri.parse('https://account.cratch.io/api/video/likes/unLike'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line
          },
          body:
              json.encode({"userId": userId, videoType: widget.video['_id']}));

      if (response.statusCode == 200) {
        String url = widget.type == "video"
            ? 'https://account.cratch.io/api/video/edit/${widget.video['videoId']}/$address'
            : widget.type == "live"
                ? 'https://account.cratch.io/api/live/${widget.video['_id']}/$address'
                : "https://account.cratch.io/api/live/saved/${widget.video['streamId']}/$address";

        await http.put(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive', // Add this line
            },
            body: json.encode({"likes": likes}));
      }
    } catch (e) {}
  }

  void likeOrUnlike() async {
    try {
      if (isLiked == false) {
        likes += 1;
        setState(() {
          isLiked = true;
        });
        await onLike();
      } else {
        likes = likes >= 0 ? likes - 1 : 0;
        setState(() {
          isLiked = false;
        });
        await unLike();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var userId = prefs.getString('userId') ?? '';
      setState(() {
        likes = widget.video['likes'];
        user = userId;
      });

      String videoType = widget.type == "video"
          ? "videoId"
          : widget.type == "live"
              ? "liveId"
              : "streamId";

      final response = await http.post(
          Uri.parse("https://account.cratch.io/api/video/likes/getLikes"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive', // Add this line
          },
          body: json.encode({videoType: widget.video['_id']}));
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data.containsKey("success") &&
          data['success'] == true) {
        if (data['likes'].isNotEmpty) {
          data['likes']?.forEach((like) {
            if (like['userId'] == userId &&
                like[videoType] == widget.video['_id']) {
              setState(() {
                isLiked = true;
                likeId = like['_id'];
              });
            }
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getLikes();
  }

  @override
  Widget build(BuildContext context) {
    final viewsCount = widget.type == 'video'
        ? widget.video['views']
        : widget.type == 'live'
            ? widget.video['currentlyWatching']
            : widget.video['views'];
    final text = widget.type == 'live' ? "watching" : "views";
    String formattedViews;
    if (viewsCount >= 1000000) {
      formattedViews = '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      formattedViews = '${(viewsCount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedViews = '$viewsCount';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 250, // replace with your preferred max width
              child: Text(
                widget.video['title'] ?? "",
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyle.textStyle12Regular,
              ),
            ),
            CustomSizedBoxHeight(height: 5.h),
            CustomText(
                textStyle: AppStyle.textStyle12offWhite,
                title: "$formattedViews $text")
          ],
        ),
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButtonWidget(
                  ontap: likeOrUnlike,
                  height: 50.h,
                  width: 50.w,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0853, 0.9147],
                    colors: [
                      isLiked
                          ? const Color(0xffC76CFF)
                          : const Color(0xff373953),
                      isLiked
                          ? const Color(0xff4D30FF)
                          : const Color(0xff535573),
                    ],
                    transform: const GradientRotation(204.23 * 3.14 / 180),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLiked ? AppColors.mainColor : Colors.transparent,
                      blurRadius: 20.0, // soften the shadow
                      spreadRadius: -4, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        4.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                  widget: InkWell(
                    onTap: likeOrUnlike,
                    child: Icon(Icons.favorite,
                        color:
                            isLiked ? AppColors.whiteA700 : Color(0xFF979797),
                        size: 22.w),
                  )),
            ),
            CustomSizedBoxWidth(width: 10.w),
            CustomText(textStyle: AppStyle.textStyle12offWhite, title: "$likes")
          ],
        ),
      ],
    );
  }
}
