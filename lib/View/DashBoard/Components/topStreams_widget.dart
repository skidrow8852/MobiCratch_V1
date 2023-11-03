import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/widgets/Sizebox/sizedboxwidth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/customtext.dart';

class TopStreamsListView extends StatelessWidget {
  String _getFormattedWatchingCount(int watchingCount) {
    if (watchingCount >= 1000000) {
      return '${(watchingCount / 1000000).toStringAsFixed(1)}M watching';
    } else if (watchingCount >= 1000) {
      return '${(watchingCount / 1000).toStringAsFixed(1)}K watching';
    } else {
      return '$watchingCount watching';
    }
  }

  final dynamic live;
  final String token;
  const TopStreamsListView({Key? key, required this.live, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
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
              height: double.infinity,
              imageUrl: live['thumbnail'] ?? "",
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
                width: 35,
                height: 16,
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

                      Color.fromRGBO(0, 0, 0, 0.6),
                      Color.fromRGBO(0, 0, 0, 0.5),

                      // Transparent black at the top
                      Colors.black, // Solid black at the bottom
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileView(
                              wallet: live['creator']['userId'],
                              token: token,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.whiteA700,
                            width: 1.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                                live['creator']['ProfileAvatar'] ?? ""),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              textStyle: AppStyle.textStyle10Regular,
                              title: live['creator']['username'].length > 10
                                  ? "${live['creator']['username'].substring(0, 10)}..."
                                  : live['creator']['username'],
                            ),
                            CustomSizedBoxWidth(width: 4),
                            live['creator']['isVerified'] != null &&
                                    live['creator']['isVerified']
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
                        Container(
                          width: 200, // replace with your preferred max width
                          child: Text(
                            live['title'] ?? "",
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.textStyle12Regular,
                          ),
                        ),
                        CustomText(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 228, 227, 227),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          title: _getFormattedWatchingCount(
                              live['currentlyWatching']),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
