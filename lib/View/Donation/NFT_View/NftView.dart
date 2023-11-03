import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/widgets/customButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class NFTView extends StatefulWidget {
  final String wallet;
  NFTView({Key? key, required this.onTapNft, required this.wallet})
      : super(key: key);

  Function()? onTapNft;

  @override
  _NFTViewState createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
  List<dynamic> nfts = [];
  bool isLoading = true;

  Future<void> fetchNfts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var address = prefs.getString('wallet_address') ?? '';

      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/nft/user/${widget.wallet.toLowerCase()}/$address'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && json.decode(response.body) is List) {
        setState(() {
          nfts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        isLoading = false;
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch NFTs');
      }
    } catch (e) {
      isLoading = false;
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNfts();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading // show loader while data is being fetched
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : nfts.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: nfts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 340,
                            height: 206,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(
                                children: [
                                  nfts[index]['ipfsThumbnail'].length > 2
                                      ? Image(
                                          image: NetworkImage(
                                              nfts[index]['ipfsThumbnail']),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : nfts[index]['videoId']['thumbnail']
                                                  .length >
                                              100
                                          ? Image.memory(
                                              base64Decode(
                                                nfts[index]['videoId']
                                                        ['thumbnail']
                                                    .substring(nfts[index]
                                                                    ['videoId']
                                                                ['thumbnail']
                                                            .indexOf(',') +
                                                        1),
                                              ),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              imageUrl: nfts[index]['videoId']
                                                      ['thumbnail'] ??
                                                  "",
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      value: downloadProgress
                                                          .progress,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      downloadProgress
                                                                  .progress !=
                                                              null
                                                          ? '${(downloadProgress.progress! * 100).toInt()}%'
                                                          : "...",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF757575)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.25),
                                            AppColors.black.withOpacity(0.6),
                                            AppColors.black,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12.h,
                                    left: 11.w,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      height: 33,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(AppImages.logopng,
                                              height: 25, width: 25),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            nfts[index]['price'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16.h,
                                    left: 20.w,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                                color: Colors.black.withOpacity(
                                                    0.1), // set opacity here
                                              ),
                                              width:
                                                  300, // replace with your preferred max width
                                              child: Text(
                                                nfts[index]['name'] ?? "",
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppStyle.textStyle12Regular,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            CustomButton(
                                              width: 98,
                                              height: 29,
                                              title: 'Mint',
                                              icon: Icons.arrow_forward_ios,
                                              ontap: () {
                                                showTopSnackBar(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 50),
                                                    Overlay.of(context),
                                                    Container(
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.8, // Set width to 80% of the screen width
                                                      child:
                                                          CustomSnackBar.error(
                                                        backgroundColor:
                                                            const Color
                                                                .fromRGBO(
                                                                65, 93, 134, 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        iconPositionLeft: 15,
                                                        iconRotationAngle: 0,
                                                        icon:
                                                            const CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor:
                                                              Color(0xFF1875FF),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .info,
                                                            size: 15,
                                                          ),
                                                        ),
                                                        message:
                                                            "Coming Soon! Stay Tuned!",
                                                      ),
                                                    ));
                                              },
                                              boxshadow: const [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                      123, 76, 244, 0.63),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 11,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                              gradient: const LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  Color(0xFFBD64FC),
                                                  Color(0xFF6644F1),
                                                ],
                                                stops: [
                                                  0.118,
                                                  0.9035,
                                                ],
                                                transform: GradientRotation(
                                                    254.96 * (3.1415926 / 180)),
                                              ),
                                              AppStyle:
                                                  AppStyle.textStyle13SemiBold,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppImages.noNft),
                    const Text(
                      "Video creator did not create an NFT collection yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
  }
}
