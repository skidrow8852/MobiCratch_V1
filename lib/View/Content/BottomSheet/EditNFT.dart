import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/Provider/EditNfts_provider.dart';
import 'package:flutter/material.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/customButton.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class BottomSheetContentEditNFt extends StatefulWidget {
  dynamic nft;
  BottomSheetContentEditNFt({Key? key, this.onTapNft, required this.nft})
      : super(key: key);

  get tabController => null;
  Function()? onTapNft;

  @override
  // ignore: library_private_types_in_public_api
  _BottomSheetContentEditNFtState createState() =>
      _BottomSheetContentEditNFtState();
}

class _BottomSheetContentEditNFtState extends State<BottomSheetContentEditNFt> {
  bool isTapped = false;
  int price = 1;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    price = int.tryParse(widget.nft['price'].toString()) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final nftstate = Provider.of<EditNftsProvider>(context);
    return Container(
      height: 600, // Set the desired height here
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Column(
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
                  'Edit NFT',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSizedBoxHeight(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: double.infinity,
                      height: 206,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: widget.nft['ipfsThumbnail'].length > 2
                          ? Image(
                              image: NetworkImage(widget.nft['ipfsThumbnail']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : widget.nft['videoId']['thumbnail'].length > 100
                              ? Image.memory(
                                  base64Decode(
                                    widget.nft['videoId']['thumbnail']
                                        .substring(widget.nft['videoId']
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
                                  imageUrl:
                                      widget.nft['videoId']['thumbnail'] ?? "",
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey,
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
                  CustomSizedBoxHeight(height: 15),
                  CustomTextFormField(
                    title: 'Name',
                    star: '',
                    hintText: widget.nft['name'],
                    isEdit: false,
                  ),
                  CustomSizedBoxHeight(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: 144,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  children: [
                                    TextSpan(
                                      text: "Price",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              CustomSizedBoxHeight(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: TextFormField(
                                  initialValue: widget.nft['price'].toString(),
                                  enabled: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                      border: InputBorder.none,
                                      hintText: widget.nft['price'].toString(),
                                      hintStyle: AppStyle.textStyle12Regular,
                                      filled: true,
                                      fillColor: isTapped
                                          ? AppColors.textFieldActive
                                              .withOpacity(0.2)
                                          : AppColors.fieldUnActive,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.mainColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.redAccsent))),
                                  onTap: () {
                                    setState(() {
                                      isTapped = true;
                                    });
                                  },
                                  onFieldSubmitted: (value) {
                                    setState(() {
                                      isTapped = false;
                                    });
                                  },
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        isTapped = false;
                                      });
                                    } else {
                                      if (int.tryParse(value.toString())! > 0) {
                                        setState(() {
                                          price =
                                              int.tryParse(value.toString()) ??
                                                  1;
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        width: 144,
                        child: CustomTextFormField(
                          title: 'Quantity',
                          star: '',
                          hintText: widget.nft['quantity'].toString(),
                          isEdit: false,
                        ),
                      ),
                    ],
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomButton(
                      width: double.infinity,
                      title: isSaving ? "Saving..." : 'Save',
                      ontap: () async {
                        setState(() {
                          isSaving = true;
                        });
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          var token = prefs.getString('token') ?? '';
                          Map<String, dynamic> data = {};

                          if (int.tryParse(price.toString()) != null &&
                              price !=
                                  int.tryParse(
                                      widget.nft['price'].toString())) {
                            data["price"] = price;
                          }

                          if (data.isNotEmpty) {
                            final response = await http.put(
                                Uri.parse(
                                    'https://account.cratch.io/api/nft/edit/${widget.nft['contract']}'),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                  'Connection': 'keep-alive',
                                },
                                body: json.encode(data));

                            if (response.statusCode == 200) {
                              nftstate.editNfts(widget.nft['_id'], price);
                              showTopSnackBar(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                Overlay.of(context),
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.8, // Set width to 80% of the screen width
                                  child: CustomSnackBar.error(
                                    backgroundColor: const Color(0xFF165E54),
                                    borderRadius: BorderRadius.circular(5),
                                    iconPositionLeft: 12,
                                    iconRotationAngle: 0,
                                    icon: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Color(0xff36A697),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                        weight: 100,
                                      ),
                                    ),
                                    message: "Change Saved Successfully",
                                  ),
                                ),
                              );
                            }
                            Navigator.pop(context);
                          }
                          setState(() {
                            isSaving = false;
                          });
                        } catch (e) {
                          setState(() {
                            isSaving = false;
                          });
                          showTopSnackBar(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              Overlay.of(context),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Set width to 80% of the screen width
                                child: CustomSnackBar.error(
                                  backgroundColor: const Color(0xFF532B48),
                                  borderRadius: BorderRadius.circular(5),
                                  iconPositionLeft: 12,
                                  iconRotationAngle: 0,
                                  icon: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xFFFF1818),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                      weight: 100,
                                    ),
                                  ),
                                  message: "Ooops, There was an Error",
                                ),
                              ));
                        }
                      },
                      AppStyle:
                          price != int.tryParse(widget.nft['price'].toString())
                              ? AppStyle.textStyle12regularWhite
                              : AppStyle.textStyle12offWhite,
                      gradient: price !=
                              int.tryParse(widget.nft['price'].toString())
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                  Color(0xFF7356EC),
                                  Color(0xFFF6587A),
                                ])
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff373953), Color(0xff373953)])),
                  CustomSizedBoxHeight(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
