import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';
import '../../../widgets/customButton.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/customtext.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// ignore: must_be_immutable
class BottomSheetContentCreateNFt extends StatefulWidget {
  List<dynamic> nfts;

  BottomSheetContentCreateNFt({Key? key, this.onTapNft, required this.nfts})
      : super(key: key);

  Function()? onTapNft;

  @override
  // ignore: library_private_types_in_public_api
  _BottomSheetContentCreateNFtState createState() =>
      _BottomSheetContentCreateNFtState();
}

class _BottomSheetContentCreateNFtState
    extends State<BottomSheetContentCreateNFt> {
  dynamic selectedCategory;
  String thumbnail = "";

  @override
  Widget build(BuildContext context) {
    thumbnail = widget.nfts.isNotEmpty ? widget.nfts[0]['thumbnail'] : "";
    return Container(
      height: 700, // Set the desired height here
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
                  'Create NFT',
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
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle12Regular, title: 'Title'),
                  CustomSizedBoxHeight(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: widget.nfts.isNotEmpty
                        ? DropdownButton(
                            style: const TextStyle(
                              color: Color.fromARGB(255, 125, 123, 135),
                            ),
                            value: selectedCategory == null &&
                                    widget.nfts.isNotEmpty
                                ? widget.nfts[0]['title']
                                : selectedCategory,
                            items: widget.nfts.map((v) {
                              return DropdownMenuItem(
                                value: v['title'].toString(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                    v['title'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;

                                thumbnail = widget.nfts.firstWhere((element) =>
                                    element['title'] ==
                                    selectedCategory)['thumbnail'];
                              });
                            },
                            isExpanded: true, // set isExpanded to true
                          )
                        : const DropDown(
                            category: ["Crypto"],
                          ),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                        width: double.infinity,
                        height: 206,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: widget.nfts.isNotEmpty &&
                                widget.nfts[0]['thumbnail'].isNotEmpty
                            ? widget.nfts[0]['thumbnail'].length > 100
                                ? Image.memory(
                                    base64Decode(
                                      widget.nfts[0]['thumbnail'].substring(
                                          widget.nfts[0]['thumbnail']
                                                  .indexOf(',') +
                                              1),
                                    ),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    imageUrl: thumbnail,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  )
                            : Image.asset(
                                AppImages.fortnite,
                                fit: BoxFit.fill,
                                width: double.infinity,
                              )),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomTextFormField(
                    title: 'Name',
                    star: '',
                    hintText:
                        selectedCategory != null ? "$selectedCategory" : "",
                    isEdit: true,
                  ),
                  CustomSizedBoxHeight(height: 15),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 144,
                        child: CustomTextFormField(
                          title: 'Price',
                          star: '',
                          hintText: '1',
                          isEdit: true,
                        ),
                      ),
                      SizedBox(
                        width: 144,
                        child: CustomTextFormField(
                          title: 'Quantity',
                          star: '',
                          hintText: '15',
                          isEdit: true,
                        ),
                      ),
                    ],
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomButton(
                    title: 'Create',
                    ontap: () {
                      showTopSnackBar(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          Overlay.of(context),
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.8, // Set width to 80% of the screen width
                            child: CustomSnackBar.error(
                              backgroundColor:
                                  const Color.fromRGBO(65, 93, 134, 1),
                              borderRadius: BorderRadius.circular(5),
                              iconPositionLeft: 15,
                              iconRotationAngle: 0,
                              icon: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Color(0xFF1875FF),
                                child: FaIcon(
                                  FontAwesomeIcons.info,
                                  size: 15,
                                ),
                              ),
                              message: "Coming Soon! Stay Tuned!",
                            ),
                          ));
                    },
                    AppStyle: AppStyle.textStyle12regularWhite,
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7356EC),
                          Color(0xFFF6587A),
                        ]),
                  ),
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

class DropDown extends StatefulWidget {
  final List<String> category;
  final Function(String)? onSelectionChanged;

  const DropDown({Key? key, required this.category, this.onSelectionChanged})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: const Text('Select Title'),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray75),
        ),
        contentPadding:
            const EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      ),
      value: _selectedCategory,
      items: widget.category.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(value!);
        }
      },
    );
  }
}
