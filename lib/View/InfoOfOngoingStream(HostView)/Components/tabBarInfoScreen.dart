import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/InfoOfOngoingStream(HostView)/Components/videoContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../Utils/app_style.dart';
import '../../../Utils/color_constant.dart';
import '../../../widgets/Sizebox/sizedboxheight.dart';
import '../../../widgets/customButton.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/customtext.dart';
import 'package:http/http.dart' as http;

class TabBarInfoScreen extends StatefulWidget {
  final dynamic details;
  const TabBarInfoScreen({Key? key, required this.details}) : super(key: key);

  @override
  State<TabBarInfoScreen> createState() => _TabBarInfoScreenState();
}

class _TabBarInfoScreenState extends State<TabBarInfoScreen> {
  bool isVisible2 = false;
  List<String>? tagss = ["crypto"];
  late double _distanceToField;
  late TextfieldTagsController _controller;
  TextEditingController textEditingController = TextEditingController();
  bool isTagsTapped = false;
  String title = "";
  bool isTapped = false;
  bool isTapped1 = false;
  String description = "";

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
  int selectedContainer = 1;
  bool isLoading = false;

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  bool areArraysSimilar(List<String> array1, List<String> array2) {
    // Check if the arrays have different lengths
    if (array1.length != array2.length) {
      return false;
    }

    // Check if all corresponding elements are equal
    for (int i = 0; i < array1.length; i++) {
      if (array1[i] != array2[i]) {
        return false;
      }
    }

    // If all elements are equal and the lengths are the same, arrays are similar
    return true;
  }

  @override
  void initState() {
    super.initState();
    selectContainer(int.tryParse(widget.details['visibility'].toString()) ?? 1);
    setState(() {
      dropdownValue = widget.details['category'] ?? "Crypto";
      tagss = widget.details['tags'].cast<String>().toList();
    });
    _controller = TextfieldTagsController();
    textEditingController = TextEditingController();
  }

  Future<void> saveChanges() async {
    try {
      var data = {};
      setState(() {
        isLoading = true;
      });
      if (title != widget.details["title"] && title.length > 2) {
        data["title"] = title;
      } else if (description != widget.details["description"] &&
          description.length > 2) {
        data["description"] = description;
      } else if (selectedContainer !=
          int.tryParse(widget.details["visibility"].toString())) {
        data["visibility"] = selectedContainer;
      } else if (dropdownValue != widget.details["category"] &&
          dropdownValue.isNotEmpty) {
        data["category"] = dropdownValue;
      } else if (areArraysSimilar(tagss!, widget.details["tags"])) {
        data["tags"] = tagss;
      } else {
        setState(() {
          isLoading = false;
        });
      }

      if (data.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token') ?? '';
        final response = await http.put(
            Uri.parse(
                'https://account.cratch.io/api/live/edit/userlive/${widget.details['_id']}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: json.encode(data));

        if (response.statusCode == 200) {
          setState(() {
            isVisible2 = false;
            isLoading = true;
          });
          showTopSnackBar(
            padding: const EdgeInsets.symmetric(horizontal: 50),
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
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///Edit Button

        /// Visibility off
        Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 10, left: 23, right: 23),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButtonWidget(
                    ontap: () {
                      setState(() {
                        isVisible2 = !isVisible2;
                      });
                    },
                    width: 31,
                    height: 31,
                    widget: Icon(isVisible2 ? Icons.clear_rounded : Icons.edit,
                        color: AppColors.whiteA700),
                    gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      begin: Alignment.topLeft,
                      colors: [
                        AppColors.mainColor,
                        AppColors.indigoAccent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.mainColor,
                          blurRadius: 10,
                          spreadRadius: isVisible2 ? -10 : -7,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  CustomSizedBoxHeight(height: 10),
                  VideoContainer(liveUrl: widget.details['playbackUrl']),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Title'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle11SemiBoldWhite400,
                      title: widget.details['title'] ?? ""),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Description'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle11SemiBoldWhite400,
                      title: widget.details['description'] ?? ""),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Tags'),
                  CustomSizedBoxHeight(height: 8),
                  SizedBox(
                    height: 24,
                    child: ListView.builder(
                      itemCount: widget.details['tags'].length ?? 0,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  end: Alignment.bottomRight,
                                  begin: Alignment.topLeft,
                                  colors: [
                                    AppColors.mainColor,
                                    AppColors.indigoAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: CustomText(
                                textStyle: AppStyle.textStyle10Regular,
                                title:
                                    widget.details['tags'][index] ?? "Crypto"),
                          ),
                        );
                      },
                    ),
                  ),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Category'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle11SemiBoldWhite400,
                      title: widget.details['category'] ?? "Crypto"),
                  CustomSizedBoxHeight(height: 15),
                  CustomText(
                      textStyle: AppStyle.textStyle12regularWhite,
                      title: 'Visibility'),
                  CustomSizedBoxHeight(height: 10),
                  CustomText(
                      textStyle: AppStyle.textStyle11SemiBoldWhite400,
                      title: int.tryParse(
                                  widget.details['visibility'].toString()) ==
                              1
                          ? 'Public'
                          : widget.details['visibility'] == 2
                              ? "Private"
                              : "NFT Holders"),
                  CustomSizedBoxHeight(height: 25),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Server URL',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: TextFormField(
                                        initialValue:
                                            "rtmp://live.cratch.io:2000/live",
                                        readOnly: true,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.lock_open,
                                              color: Colors.white),
                                          hintText: 'Stream URL',
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const CopyTextButton(
                                    textValue:
                                        'rtmp://live.cratch.io:2000/live',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Stream key',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: TextFormField(
                                        initialValue: '********************',
                                        readOnly: true,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.lock_open,
                                              color: Colors.white),
                                          hintText: 'Key',
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CopyTextButton(
                                    textValue:
                                        widget.details['streamKey'] ?? '',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Live URL',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: TextFormField(
                                        initialValue:
                                            'https://account.cratch.io/live/${widget.details['streamUrl']}',
                                        readOnly: true,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.web_stories,
                                              color: Colors.white),
                                          hintText: 'Playback URL',
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  CopyTextButton(
                                    textValue:
                                        'https://account.cratch.io/live/${widget.details['streamUrl']}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),

        /// Visibility on
        Padding(
          padding: const EdgeInsets.only(top: 35),
          child: Visibility(
            visible: isVisible2,
            maintainAnimation: true,
            maintainSize: true,
            maintainState: true,
            child: Container(
              color: AppColors.bgGradient2,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSizedBoxHeight(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSizedBoxHeight(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TextFormField(
                            enabled: true,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                border: InputBorder.none,
                                hintText: widget.details['title'],
                                hintStyle: AppStyle.textStyle12Regular,
                                filled: true,
                                fillColor: isTapped
                                    ? AppColors.textFieldActive.withOpacity(0.2)
                                    : AppColors.fieldUnActive,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.mainColor),
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
                                title = value;
                              }
                            },
                          ),
                        ),
                        CustomSizedBoxHeight(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TextFormField(
                            enabled: true,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                border: InputBorder.none,
                                hintText: widget.details['description'],
                                hintStyle: AppStyle.textStyle12Regular,
                                filled: true,
                                fillColor: isTapped1
                                    ? AppColors.textFieldActive.withOpacity(0.2)
                                    : AppColors.fieldUnActive,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.mainColor),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.redAccsent))),
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
                              initialTags: tagss,
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
                              inputfieldBuilder: (context, tec, fn, error,
                                  onChanged, onSubmitted) {
                                return ((context, sc, tags, onTagDelete) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: TextField(
                                      controller: tec,
                                      focusNode: fn,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.indigo,
                                            width: 2.0,
                                          ),
                                        ),
                                        hintText: _controller.hasTags
                                            ? ''
                                            : "Some tags",
                                        hintStyle: const TextStyle(
                                            color: Colors.white),
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
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                    children:
                                                        tags.map((String tag) {
                                                  return Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xFF6F54E5),
                                                          Color(0xFF373953),
                                                        ],
                                                        stops: [
                                                          0.0608,
                                                          0.9956,
                                                        ],
                                                        transform:
                                                            GradientRotation(
                                                                92.42 *
                                                                    (3.141592 /
                                                                        180)),
                                                      ),
                                                    ),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                          child: InkWell(
                                                            child: Text(
                                                              '#$tag',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            onTap: () {
                                                              print(
                                                                  "$tag selected");
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        InkWell(
                                                          child: Container(
                                                            height: 23,
                                                            width: 23,
                                                            decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .tagCancel,
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .clear_rounded,
                                                                size: 18.0,
                                                                color: AppColors
                                                                    .whiteA700,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            onTagDelete(tag);
                                                            setState(() {
                                                              tagss!.remove(
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
                                        if (tag.isNotEmpty &&
                                            !tags.contains(tag)) {
                                          setState(() {
                                            tagss!.add(
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
                        CustomSizedBoxHeight(height: 3),
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
                              dropdownColor:
                                  const Color.fromRGBO(52, 53, 65, 1),
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
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
                        CustomSizedBoxHeight(height: 3),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomText(
                                              textStyle: AppStyle
                                                  .textStyle11SemiBoldWhite600,
                                              title: 'Public'),
                                          const Spacer(),
                                          CustomText(
                                              textStyle:
                                                  AppStyle.textStyle8White600,
                                              title: 'Everyone can see'),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomText(
                                              textStyle: AppStyle
                                                  .textStyle11SemiBoldWhite600,
                                              title: 'Private'),
                                          const Spacer(),
                                          CustomText(
                                              textStyle:
                                                  AppStyle.textStyle8White600,
                                              title: 'No one can see'),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomText(
                                              textStyle: AppStyle
                                                  .textStyle11SemiBoldWhite600,
                                              title: 'NFT holders'),
                                          const Spacer(),
                                          CustomText(
                                              textStyle:
                                                  AppStyle.textStyle8White600,
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
                        CustomSizedBoxHeight(height: 30),
                        CustomButton(
                          width: double.infinity,
                          title: isLoading ? 'Saving...' : 'Save Changes',
                          ontap: saveChanges,
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
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class CopyTextButton extends StatelessWidget {
  final String textValue;

  const CopyTextButton({super.key, required this.textValue});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: textValue));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              alignment: Alignment.center,
              child: const Text(
                'Copied to clipboard',
                textAlign: TextAlign.center,
              ),
            ),

            backgroundColor: const Color.fromARGB(
                255, 96, 94, 94), // Set your desired color here
            behavior: SnackBarBehavior.floating,
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 4, left: 8),
        child: Icon(Icons.copy, color: Colors.white),
      ),
    );
  }
}
