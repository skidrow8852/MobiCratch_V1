import 'package:flutter/material.dart';

import '../../../Utils/app_style.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/customtext.dart';

class ProfileDetails extends StatelessWidget {
  final String? username;
  final int? followers;
  final String? description;
  const ProfileDetails(
      {Key? key, this.username, this.followers, this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedFollowers =
        followers != null ? _formatNumber(followers!) : "";
    String text = followers! > 1 ? "Followers" : 'Follower';
    return Column(
      children: [
        CustomSizedBoxHeight(height: 50),
        CustomText(
            textStyle: AppStyle.textStyle17Bold,
            title: (username != null && username!.length > 20)
                ? '${username!.substring(0, 20)}...'
                : username!),
        CustomSizedBoxHeight(height: 10),
        CustomText(
            textStyle: AppStyle.textStyle9SemiBoldWhite,
            title: '$formattedFollowers $text'),
        CustomSizedBoxHeight(height: 10),
        Container(
          width: 300, // replace with your preferred max width
          child: Text(
            textAlign: TextAlign.center,
            description ?? "",
            softWrap: true,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            style: AppStyle.textStyle11SemiBoldBlack,
          ),
        ),
        CustomSizedBoxHeight(height: 30),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
