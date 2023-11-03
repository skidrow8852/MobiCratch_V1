import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/View/Profile/Components/SavedComments.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../Utils/app_style.dart';
import '../../../widgets/customtext.dart';

void setupIntl() {
  Intl.defaultLocale = 'en_US';
  initializeDateFormatting();
}

class SavedSession extends StatelessWidget {
  final dynamic video;
  final String token;
  final String userWallet;
  const SavedSession(
      {Key? key,
      required this.video,
      required this.userWallet,
      required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setupIntl();
    final createdAt = DateTime.parse(video['createdAt']);
    final viewsCount = video['views'];
    String formatNumber(int number) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    }

    String text =
        video['creator']['followers']?.length > 1 ? "followers" : 'follower';

    String formattedViews;
    if (viewsCount >= 1000000) {
      formattedViews = '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      formattedViews = '${(viewsCount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedViews = '$viewsCount';
    }

    String formattedFollowers = video['creator']['followers'] != null
        ? formatNumber(video['creator']['followers']!.length)
        : "";

    return GestureDetector(
      onTap: () {
        Get.to(
          () => SavedComments(
            token: token,
            userWallet: userWallet,
            streamId: video['streamId'],
          ),
        );
        // Perform the redirection here
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 220,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              CachedNetworkImage(
                fit: BoxFit.cover,
                width: double.infinity,
                imageUrl: video['thumbnail'] ?? "",
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
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
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    video['duration'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.h,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.0),
                        Color.fromRGBO(0, 0, 0, 0.2),
                        Color.fromRGBO(0, 0, 0, 0.5),

                        // Transparent black at the top
                        Colors.black, // Solid black at the bottom
                      ],
                    ), // add opacity to text background
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileView(
                                                  wallet: video['creator']
                                                      ['userId'],
                                                  token: token,
                                                )));
                                  },
                                  child: CircleAvatar(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image(
                                      image: NetworkImage(video['creator']
                                              ['ProfileAvatar'] ??
                                          ""),
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                                ),
                                CustomSizedBoxWidth(width: 5.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CustomText(
                                          textStyle:
                                              AppStyle.textStyle12regularWhite,
                                          title: video['creator']['username']
                                                      .length >
                                                  10
                                              ? "${video['creator']['username'].substring(0, 10)}..."
                                              : video['creator']['username'],
                                        ),
                                        CustomSizedBoxWidth(width: 4),
                                        video['creator']['isVerified'] !=
                                                    null &&
                                                video['creator']['isVerified']
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
                                    CustomSizedBoxHeight(height: 5.h),
                                    CustomText(
                                        textStyle: AppStyle
                                            .textStyle10SemiBoldBlack
                                            .copyWith(
                                                color: const Color.fromARGB(
                                                    255, 217, 217, 217),
                                                fontSize: 9.sp),
                                        title: "$formattedFollowers $text"),
                                  ],
                                ),
                              ],
                            ),
                            CustomSizedBoxHeight(height: 2.h),
                            Container(
                              width: MediaQuery.of(context).size.width -
                                  35, // replace with your preferred max width
                              child: Text(
                                video['title'] ?? "",
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyle.textStyle12Regular,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 5.0, top: 2),
                              child: Row(
                                children: [
                                  CustomText(
                                      textStyle: AppStyle.textStyle9Regular
                                          .copyWith(
                                              color: const Color.fromARGB(
                                                  255, 222, 222, 222)),
                                      title: '$formattedViews views'),
                                  CustomText(
                                    textStyle: AppStyle.textStyle9Regular
                                        .copyWith(
                                            color: const Color.fromARGB(
                                                255, 222, 222, 222)),
                                    title:
                                        ' • streamed ${timeago.format(createdAt, locale: 'en')}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
