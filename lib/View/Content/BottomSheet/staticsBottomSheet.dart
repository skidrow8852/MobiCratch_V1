import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/customtext.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class BottomSheetContentStatic extends StatefulWidget {
  final dynamic video;
  final String imageType;
  BottomSheetContentStatic(
      {Key? key, this.onTapNft, required this.video, required this.imageType})
      : super(key: key);

  Function()? onTapNft;

  @override
  State<BottomSheetContentStatic> createState() =>
      _BottomSheetContentStaticState();
}

class _BottomSheetContentStaticState extends State<BottomSheetContentStatic> {
  String formatDateFromString(String dateString) {
    if (dateString.isNotEmpty) {
      var date = DateTime.parse(dateString);
      var formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(date);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600, // Set the desired height here
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Statistic',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          AppColors.indigo,
                          AppColors.mainColor,
                        ],
                      ).createShader(
                        const Rect.fromLTWH(20.0, 0.0, 120.0, 70.0),
                      ),
                  ),
                ),
              ),
            ),
            CustomSizedBoxHeight(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: double.infinity,
                  height: 206,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: widget.video['thumbnail'].length > 100
                      ? Image.memory(
                          base64Decode(
                            widget.video['thumbnail'].substring(
                                widget.video['thumbnail'].indexOf(',') + 1),
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: double.infinity,
                          imageUrl: widget.video['thumbnail'] ?? "",
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  downloadProgress.progress != null
                                      ? '${(downloadProgress.progress! * 100).toInt()}%'
                                      : "...",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                ),
              ),
            ),
            CustomSizedBoxHeight(height: 20),
            CustomSizedBoxHeight(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Title'),
                  CustomSizedBoxHeight(height: 10),
                  Container(
                    width: 300, // replace with your preferred max width
                    child: Text(
                      widget.video['title'] ?? "",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.textStyle11SemiBoldWhite400,
                    ),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Visibility'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                    textStyle: AppStyle.textStyle11SemiBoldWhite400,
                    title: widget.video['visibility'] == 1
                        ? "Public"
                        : widget.video['visibility'] == 0
                            ? "NFT holders"
                            : "Private",
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Date'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                    textStyle: AppStyle.textStyle11SemiBoldWhite400,
                    title: formatDateFromString(widget.video['createdAt']),
                  ),
                  CustomSizedBoxHeight(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 100,
                        width: 88,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFBD64FC),
                                Color(0xFF6644F1),
                              ],
                              stops: [0.118, 0.9035],
                              transform:
                                  GradientRotation(254.96 * 3.1415927 / 180),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                                textStyle: AppStyle.textStyle16Bold600,
                                title: widget.video['views'].toString()),
                            CustomText(
                                textStyle: AppStyle.textStyle12regularWhite,
                                title: 'Views'),
                          ],
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 88,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFBD64FC),
                                Color(0xFF6644F1),
                              ],
                              stops: [0.118, 0.9035],
                              transform:
                                  GradientRotation(254.96 * 3.1415927 / 180),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                                textStyle: AppStyle.textStyle16Bold600,
                                title: widget.imageType == "live"
                                    ? widget.video['numOfmessages'].toString()
                                    : widget.video['comments'].toString()),
                            CustomText(
                                textStyle: AppStyle.textStyle12regularWhite,
                                title: widget.imageType == "live"
                                    ? "Chats"
                                    : "Comments"),
                          ],
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 88,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFBD64FC),
                                Color(0xFF6644F1),
                              ],
                              stops: [0.118, 0.9035],
                              transform:
                                  GradientRotation(254.96 * 3.1415927 / 180),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                                textStyle: AppStyle.textStyle16Bold600,
                                title: widget.video['likes'].toString()),
                            CustomText(
                                textStyle: AppStyle.textStyle12regularWhite,
                                title: 'Likes'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomSizedBoxHeight(height: 60),
          ],
        ),
      ),
    );
  }
}
