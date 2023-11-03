import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/LiveStreamResCreator_View/liveStreamView.dart';
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

class LiveViewProfile extends StatelessWidget {
  final Map<String, dynamic> video;
  final String userWallet;
  final String token;

  const LiveViewProfile(
      {Key? key,
      required this.video,
      required this.token,
      required this.userWallet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setupIntl();
    String _formatNumber(int number) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    }

    final createdAt = DateTime.parse(video['createdAt']);
    final viewsCount = video['currentlyWatching'];

    String formattedViews;
    if (viewsCount >= 1000000) {
      formattedViews = '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      formattedViews = '${(viewsCount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedViews = '$viewsCount';
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => LiveStreamViewAndComments(
            userWallet: userWallet,
            token: token,
            live: video,
          ),
        );
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
                right: 11.w,
                child: Container(
                  width: 32,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFB5B78), Color(0xFFD61E40)],
                        stops: [0.0, 1.3214]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
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
                                      title: '$formattedViews watching'),
                                  CustomText(
                                    textStyle: AppStyle.textStyle9Regular
                                        .copyWith(
                                            color: const Color.fromARGB(
                                                255, 222, 222, 222)),
                                    title:
                                        ' • started ${timeago.format(createdAt, locale: 'en')}',
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
