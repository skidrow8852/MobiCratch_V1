import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cratch/Provider/uploadVideo.provider.dart';
import 'package:cratch/config.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/customButton.dart';
import '../../../widgets/customtext.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:path/path.dart' as path;
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class BottomSheetContentEditVideo extends StatefulWidget {
  dynamic video;
  BottomSheetContentEditVideo({Key? key, this.onTapNft, required this.video})
      : super(key: key);

  Function()? onTapNft;

  @override
  State<BottomSheetContentEditVideo> createState() =>
      _BottomSheetContentEditVideoState();
}

class _BottomSheetContentEditVideoState
    extends State<BottomSheetContentEditVideo> {
  get tabController => null;
  File? imageFile;
  int selectedContainer = 1;
  String ipfsImage = "";
  bool isTagsTapped = false;
  String base64Image = "";
  String title = "";
  String description = "";
  bool isTapped = false;
  bool isSaving = false;
  late double _distanceToField;

  bool isTapped1 = false;
  List<String> tags = [];

  late TextfieldTagsController _controller;
  TextEditingController textEditingController = TextEditingController();

  final List<String> dropdownItems = [
    'Crypto',
    'Gaming',
    'Play 2 Earn',
    'Lifestyle',
    'Educational',
    'Sports',
    'Travel & Events',
    'Film & Animation',
    'People & Blogs'
  ];
  String dropdownValue = "Crypto";

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  bool haveSameElements(List<String> array1, List<String> array2) {
    // Convert the arrays to sets
    Set<String> set1 = Set.from(array1);
    Set<String> set2 = Set.from(array2);

    // Compare the sets for equality
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
    textEditingController = TextEditingController();
    try {
      title = widget.video['title'];
      description = widget.video['description'];
      tags = widget.video['tags'].cast<String>();
      dropdownValue = widget.video['category'].isEmpty
          ? "Crypto"
          : widget.video['category'];
      selectedContainer =
          int.tryParse(widget.video['visibility'].toString()) ?? 0;
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  bool isChanging() {
    return title != widget.video['title'] ||
        description != widget.video['description'] ||
        !haveSameElements(tags, widget.video['tags'].cast<String>()) ||
        dropdownValue != widget.video['category'] ||
        selectedContainer !=
            int.tryParse(widget.video['visibility'].toString()) ||
        base64Image.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final videostate = Provider.of<UploadVideoProvider>(context);
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
                  'Edit Video',
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
                  RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: "Title",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  CustomSizedBoxHeight(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TextFormField(
                      initialValue: title,
                      enabled: true,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: InputBorder.none,
                          hintText: title,
                          hintStyle: AppStyle.textStyle12Regular,
                          filled: true,
                          fillColor: isTapped
                              ? AppColors.textFieldActive.withOpacity(0.2)
                              : AppColors.fieldUnActive,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mainColor),
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.redAccsent))),
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
                          title = value;
                        }
                      },
                    ),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: "Description",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  CustomSizedBoxHeight(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TextFormField(
                      initialValue: description,
                      enabled: true,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: InputBorder.none,
                          hintText: description,
                          hintStyle: AppStyle.textStyle12Regular,
                          filled: true,
                          fillColor: isTapped1
                              ? AppColors.textFieldActive.withOpacity(0.2)
                              : AppColors.fieldUnActive,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mainColor),
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.redAccsent))),
                      onTap: () {
                        setState(() {
                          isTapped1 = true;
                        });
                      },
                      onFieldSubmitted: (value) {
                        setState(() {
                          isTapped1 = false;
                        });
                      },
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            isTapped1 = false;
                          });
                        } else {
                          description = value;
                        }
                      },
                    ),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textAlign: TextAlign.start,
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Thumbnail'),
                  CustomSizedBoxHeight(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(6),
                        color: AppColors.offwhite,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          child: GestureDetector(
                            onTap: () {
                              _getFromGallery();
                            },
                            child: Container(
                              height: 77,
                              width: 143,
                              color: AppColors.fieldUnActive,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                        color: AppColors.gray75,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.offwhite)),
                                    child: Center(
                                      child: Icon(Icons.add,
                                          color: AppColors.offwhite),
                                    ),
                                  ),
                                  CustomSizedBoxHeight(height: 8),
                                  CustomText(
                                      textAlign: TextAlign.start,
                                      textStyle:
                                          AppStyle.textStyle9SemiBoldOffWhite,
                                      title: 'Upload thumbnail'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                          height: 77,
                          width: 143,
                          color: Colors.transparent,
                          child: imageFile == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: widget.video['thumbnail'].length > 100
                                      ? Image.memory(
                                          base64Decode(
                                            widget.video['thumbnail'].substring(
                                                widget.video['thumbnail']
                                                        .indexOf(',') +
                                                    1),
                                          ),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              widget.video['thumbnail'] ?? "",
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  value:
                                                      downloadProgress.progress,
                                                  strokeWidth: 2,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  downloadProgress.progress !=
                                                          null
                                                      ? '${(downloadProgress.progress! * 100).toInt()}%'
                                                      : "...",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF757575)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                    ],
                  ),
                  CustomSizedBoxHeight(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                              text: 'Tags',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      CustomSizedBoxHeight(height: 4),
                      TextFieldTags(
                        textfieldTagsController: _controller,
                        initialTags: tags,
                        textSeparators: const [' ', ','],
                        letterCase: LetterCase.normal,
                        validator: (String tag) {
                          if (tag == 'php') {
                            return 'No, please just no';
                          } else if (_controller.getTags!.contains(tag)) {
                            return 'you already entered that';
                          }
                          return null;
                        },
                        inputfieldBuilder:
                            (context, tec, fn, error, onChanged, onSubmitted) {
                          return ((context, sc, tags, onTagDelete) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: TextField(
                                controller: tec,
                                focusNode: fn,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.indigo,
                                      width: 2.0,
                                    ),
                                  ),
                                  hintText: _controller.hasTags ? '' : "tags",
                                  hintStyle:
                                      const TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: isTagsTapped
                                      ? AppColors.mainColor
                                      : AppColors.fieldUnActive,
                                  errorText: error,
                                  suffixIconConstraints: BoxConstraints(
                                      maxWidth: _distanceToField * 0.74),
                                  suffixIcon: tags.isNotEmpty
                                      ? SingleChildScrollView(
                                          controller: sc,
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                              children: tags.map((String tag) {
                                            return Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF6F54E5),
                                                    Color(0xFF373953),
                                                  ],
                                                  stops: [
                                                    0.0608,
                                                    0.9956,
                                                  ],
                                                  transform: GradientRotation(
                                                      92.42 * (3.141592 / 180)),
                                                ),
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0),
                                                    child: InkWell(
                                                      child: Text(
                                                        '#$tag',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  InkWell(
                                                    child: Container(
                                                      height: 23,
                                                      width: 23,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .tagCancel,
                                                          shape:
                                                              BoxShape.circle),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.clear_rounded,
                                                          size: 18.0,
                                                          color: AppColors
                                                              .whiteA700,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      onTagDelete(tag);
                                                      setState(() {
                                                        tags.remove(
                                                            tag); // Remove the tag from the tagss list
                                                      });
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          }).toList()),
                                        )
                                      : null,
                                ),
                                onChanged: onChanged,
                                onSubmitted: (String tag) {
                                  onSubmitted!(
                                      tag); // Call the original onChanged callback
                                  if (tag.isNotEmpty && !tags.contains(tag)) {
                                    setState(() {
                                      tags.add(
                                          tag); // Add the tag to the tagss list
                                    });
                                  }
                                },
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  CustomSizedBoxHeight(height: 5),
                  CustomText(
                      textAlign: TextAlign.start,
                      textStyle: AppStyle.textStyle9SemiBoldWhite,
                      title:
                          'Tags can be useful if content in your stream is commonly misspelled'),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12Regular,
                      title: 'Category'),
                  CustomSizedBoxHeight(height: 5),
                  Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 5.h),
                    decoration: BoxDecoration(
                        color: AppColors.fieldUnActive,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: DropdownButton<String>(
                        dropdownColor: const Color.fromRGBO(52, 53, 65, 1),
                        hint: const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            'Enter here',
                            style: TextStyle(
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        underline: Container(),
                        isExpanded: true,
                        isDense: true,
                        focusColor: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        icon: Icon(Icons.arrow_drop_down_outlined,
                            color: AppColors.whiteA700),
                        value: dropdownValue,
                        items: dropdownItems
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  CustomSizedBoxHeight(height: 5),
                  CustomText(
                      textAlign: TextAlign.start,
                      textStyle: AppStyle.textStyle9SemiBoldWhite,
                      title:
                          'Add a category to your stream, so users could find it more easily'),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textAlign: TextAlign.left,
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Visibility'),
                  CustomSizedBoxHeight(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              selectContainer(1);
                            },
                            child: Container(
                              height: 65,
                              width: 95,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: selectedContainer == 1
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFBD64FC),
                                            Color(0xFF6644F1),
                                          ],
                                          stops: [
                                            0.118,
                                            0.9035,
                                          ],
                                          transform: GradientRotation(
                                              254.96 * 3.14 / 180),
                                        )
                                      : LinearGradient(colors: [
                                          AppColors.fieldUnActive,
                                          AppColors.fieldUnActive,
                                        ])),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                        textStyle: AppStyle
                                            .textStyle11SemiBoldWhite600,
                                        title: 'Public'),
                                    const Spacer(),
                                    CustomText(
                                        textStyle: AppStyle.textStyle8White600,
                                        title: 'Visible to all'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectContainer(2);
                            },
                            child: Container(
                              height: 65,
                              width: 95,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: selectedContainer == 2
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFBD64FC),
                                            Color(0xFF6644F1),
                                          ],
                                          stops: [
                                            0.118,
                                            0.9035,
                                          ],
                                          transform: GradientRotation(
                                              254.96 * 3.14 / 180),
                                        )
                                      : LinearGradient(colors: [
                                          AppColors.fieldUnActive,
                                          AppColors.fieldUnActive,
                                        ])),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                        textStyle: AppStyle
                                            .textStyle11SemiBoldWhite600,
                                        title: 'Private'),
                                    const Spacer(),
                                    CustomText(
                                        textStyle: AppStyle.textStyle8White600,
                                        title: 'Visible only to you'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectContainer(0);
                            },
                            child: Container(
                              height: 65,
                              width: 95,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: selectedContainer == 0
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFBD64FC),
                                            Color(0xFF6644F1),
                                          ],
                                          stops: [0.118, 0.9035],
                                          tileMode: TileMode.repeated,
                                          transform: GradientRotation(
                                              254.96 * 3.14 / 180),
                                        )
                                      : LinearGradient(colors: [
                                          AppColors.fieldUnActive,
                                          AppColors.fieldUnActive,
                                        ])),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                        textStyle: AppStyle
                                            .textStyle11SemiBoldWhite600,
                                        title: 'NFT holders'),
                                    const Spacer(),
                                    CustomText(
                                        textStyle: AppStyle.textStyle8White600,
                                        title: 'Only NFT holders'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                          var wallet = prefs.getString('wallet_address') ?? '';
                          Map<String, dynamic> data = {};
                          int vi = int.tryParse(
                                  widget.video['visibility'].toString()) ??
                              1;
                          if (selectedContainer != vi) {
                            data["visibility"] = selectedContainer;
                          }

                          if (dropdownValue != widget.video['category']) {
                            data["category"] = dropdownValue;
                          }

                          if (base64Image.isNotEmpty) {
                            data["thumbnail"] = base64Image;
                            await uploadImageToWeb3Storage(
                                imageFile!.path, ipfsKey);
                          }
                          if (ipfsImage.length > 2) {
                            data["ipfsThumbnail"] = ipfsImage;
                          }
                          if (title.length > 2 &&
                              title != widget.video['title']) {
                            data["title"] = title;
                          }
                          if (description.length > 2 &&
                              description != widget.video['description']) {
                            data["description"] = description;
                          }
                          if (tags.isNotEmpty &&
                              !haveSameElements(
                                  tags, widget.video['tags'].cast<String>())) {
                            data["tags"] = tags;
                          }

                          if (data.isNotEmpty) {
                            final response = await http.put(
                                Uri.parse(
                                    'https://account.cratch.io/api/video/edit/user/${widget.video['videoId']}/$wallet'),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                  'Connection': 'keep-alive',
                                },
                                body: json.encode(data));

                            if (response.statusCode == 200) {
                              data['thumbnail'] =
                                  jsonDecode(response.body)['thumbnail'] ??
                                      widget.video['thumbnail'];
                              videostate.editUploadVideo(
                                  widget.video['_id'], data);
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

                            setState(() {
                              isSaving = false;
                            });
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              isSaving = false;
                            });
                          }
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
                      AppStyle: isChanging()
                          ? AppStyle.textStyle12regularWhite
                          : AppStyle.textStyle12offWhite,
                      gradient: isChanging()
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
                              colors: [
                                  Color(0xff373953),
                                  Color(0xff373953),
                                ])),
                  CustomSizedBoxHeight(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImageToWeb3Storage(
      String imagePath, String apiKey) async {
    try {
      String imageExtension = path.extension(imagePath).toLowerCase();
      if (imageExtension == "png" ||
          imageExtension == "jpeg" ||
          imageExtension == "jpg") {
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://api.web3.storage/upload'));

        // Load the image file
        var imageFile = await http.MultipartFile.fromPath('file', imagePath);

        // Add the image file to the request
        request.files.add(imageFile);

        // Set the Web3Storage API key in the headers
        request.headers['Authorization'] = 'Bearer $apiKey';

        // Send the request and get the response
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData =
              await response.stream.transform(utf8.decoder).join();
          var jsonResponse = jsonDecode(responseData);

          // Get the CID of the uploaded image
          var cid = jsonResponse['cid'];

          String fileName = path.basename(imagePath);
          if (cid.length > 2) {
            setState(() {
              ipfsImage =
                  'https://$cid.ipfs.dweb.link/$fileName.$imageExtension';
            });
          }
          return cid;
        } else {
          return "";
        }
      } else {
        print('Failed to upload image to Web3Storage');
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  /// Get from gallery
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      String imageExtension = imagePath.split('.').last.toLowerCase();
      if (imageExtension == 'jpg' ||
          imageExtension == 'jpeg' ||
          imageExtension == 'png') {
        setState(() {
          imageFile = File(pickedFile.path);
          List<int> imageBytes = imageFile!.readAsBytesSync();
          base64Image =
              'data:image/$imageExtension;base64,${base64Encode(imageBytes)}';
        });
      }
    }
  }
}
