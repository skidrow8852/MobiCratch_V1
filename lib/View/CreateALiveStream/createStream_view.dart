import 'dart:convert';
import 'dart:math';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/View/CreateALiveStream/success_view.dart';
import 'package:cratch/View/InfoOfOngoingStream(HostView)/infoOngoingStream_view.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/customButton.dart';
import 'package:http/http.dart' as http;

class CreateStream extends StatefulWidget {
  const CreateStream({Key? key}) : super(key: key);

  @override
  State<CreateStream> createState() => _CreateStreamState();
}

class _CreateStreamState extends State<CreateStream> {
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
  bool isLoading = true;

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  Future<void> getStream() async {
    try {
      setState(() {});
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var userId = prefs.getString('userId') ?? '';
      final response = await http.get(
        Uri.parse('https://account.cratch.io/api/live/user/$userId'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (!responseData.containsKey('status')) {
          setState(() {
            isLoading = false;
          });
          // ignore: use_build_context_synchronously
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: InfoOngoingStreamView(
                details: responseData,
              ),
              withNavBar: false);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("error ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  List<String>? tagss = ["crypto"];
  late double _distanceToField;
  late TextfieldTagsController _controller;
  TextEditingController textEditingController = TextEditingController();
  bool isTagsTapped = false;
  bool isVideoUploading = false;
  String title = "";
  Map<String, dynamic> streamDetails = {};

  Future<void> startStream() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId') ?? '';
      var token = prefs.getString('token') ?? '';
      var streamKey = generateUniqueId(8) +
          "-" +
          generateUniqueId(4) +
          "-" +
          generateUniqueId(4) +
          "-" +
          generateUniqueId(4) +
          "-" +
          generateUniqueId(12);
      var streamId = generateUniqueId(5) +
          generateUniqueId(4) +
          generateUniqueId(5) +
          generateUniqueId(10);

      if (userId.isNotEmpty &&
          token.isNotEmpty &&
          streamKey.isNotEmpty &&
          title.isNotEmpty && // Make sure title is not empty
          description.isNotEmpty &&
          tagss != null &&
          tagss!.isNotEmpty &&
          dropdownValue.isNotEmpty &&
          streamId.isNotEmpty) {
        setState(() {
          isVideoUploading = true;
        });
        final response = await http.post(
          Uri.parse('https://account.cratch.io/api/live/new'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          },
          body: json.encode({
            "creator": userId,
            "title": title.toString(),
            "isActive": false,
            "description": description,
            "tags": tagss,
            "category": dropdownValue,
            "visibility": selectedContainer,
            "streamUrl": streamId,
            "streamKey": streamKey,
            "playbackUrl": 'https://live.cratch.io/live/$streamKey/index.m3u8'
          }),
        );

        final videoData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            streamDetails = videoData;
            isVideoUploading = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SuccessView(
                video: streamDetails,
              ),
            ),
          );
        } else {
          setState(() {
            isVideoUploading = false;
          });
          print("Error on the request ${response.statusCode}");
        }
      } else {
        setState(() {
          isVideoUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        isVideoUploading = false;
      });
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  String generateUniqueId(int number) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    // Generate a random alphanumeric ID
    return String.fromCharCodes(
      Iterable.generate(
        number,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    getStream();
    super.initState();

    _controller = TextfieldTagsController();
    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWithNavBar(
      screen: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              AppColors.bgGradient2,
              AppColors.bgGradient2,
              AppColors.bgGradient1,
            ])),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const TopBar(),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSizedBoxHeight(height: 40),
                        Row(
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.mainColor,
                                )),
                            GradientTextWidget(
                              text: 'Create Stream',
                              size: 17.h,
                            )
                          ],
                        ),
                        CustomSizedBoxHeight(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSizedBoxHeight(height: 15),
                            RichText(
                              text: TextSpan(
                                style: AppStyle.textStyle12Regular,
                                children: const [
                                  TextSpan(
                                    text: "Title",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            CustomSizedBoxHeight(height: 5),
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
                                    hintText: "Title",
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
                                    title = value;
                                  }
                                },
                              ),
                            ),
                            CustomSizedBoxHeight(height: 15),
                            RichText(
                              text: TextSpan(
                                style: AppStyle.textStyle12Regular,
                                children: const [
                                  TextSpan(
                                    text: "Description",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            CustomSizedBoxHeight(height: 5),
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
                                    hintText: "Description",
                                    hintStyle: AppStyle.textStyle12Regular,
                                    filled: true,
                                    fillColor: isTapped1
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
                                  text: TextSpan(
                                    style: AppStyle.textStyle12Regular,
                                    children: const [
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
                                    } else if (_controller.getTags!
                                        .contains(tag)) {
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
                                          style: AppStyle.textStyle12Regular,
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
                                                : "tags",
                                            hintStyle: const TextStyle(
                                                color: Colors.white),
                                            filled: true,
                                            fillColor: isTagsTapped
                                                ? AppColors.mainColor
                                                : AppColors.fieldUnActive,
                                            errorText: error,
                                            suffixIconConstraints:
                                                BoxConstraints(
                                                    maxWidth: _distanceToField *
                                                        0.74),
                                            suffixIcon: tags.isNotEmpty
                                                ? SingleChildScrollView(
                                                    controller: sc,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                        children: tags
                                                            .map((String tag) {
                                                      return Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                20.0),
                                                          ),
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
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
                                                                onTagDelete(
                                                                    tag);
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
                                    padding: EdgeInsets.only(left: 5.0),
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
                            CustomSizedBoxHeight(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        selectContainer(1);
                                      },
                                      child: Container(
                                        height: 65,
                                        width: 95,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
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
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          1
                                                      ? AppStyle
                                                          .textStyle11SemiBoldWhite600
                                                      : AppStyle
                                                          .textStyle11SemiBoldBlack,
                                                  title: 'Public'),
                                              CustomSizedBoxHeight(height: 5),
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          1
                                                      ? AppStyle
                                                          .textStyle8White600
                                                      : AppStyle
                                                          .textStyle8Black600,
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
                                            borderRadius:
                                                BorderRadius.circular(3),
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
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          2
                                                      ? AppStyle
                                                          .textStyle11SemiBoldWhite600
                                                      : AppStyle
                                                          .textStyle11SemiBoldBlack,
                                                  title: 'Private'),
                                              CustomSizedBoxHeight(height: 5),
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          2
                                                      ? AppStyle
                                                          .textStyle8White600
                                                      : AppStyle
                                                          .textStyle8Black600,
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
                                            borderRadius:
                                                BorderRadius.circular(3),
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
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          0
                                                      ? AppStyle
                                                          .textStyle11SemiBoldWhite600
                                                      : AppStyle
                                                          .textStyle11SemiBoldBlack,
                                                  title: 'NFT holders'),
                                              CustomSizedBoxHeight(height: 5),
                                              CustomText(
                                                  textStyle: selectedContainer ==
                                                          0
                                                      ? AppStyle
                                                          .textStyle8White600
                                                      : AppStyle
                                                          .textStyle8Black600,
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
                                title: isVideoUploading
                                    ? 'Starting...'
                                    : 'Start Stream',
                                ontap: startStream,
                                AppStyle: (title.isNotEmpty &&
                                        description.length > 2 &&
                                        tagss != null &&
                                        tagss!.isNotEmpty &&
                                        dropdownValue.isNotEmpty)
                                    ? AppStyle.textStyle12regularWhite
                                    : AppStyle.textStyle12offWhite,
                                gradient: (title.isNotEmpty &&
                                        description.length > 2 &&
                                        tagss != null &&
                                        tagss!.isNotEmpty &&
                                        dropdownValue.isNotEmpty)
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
                            CustomSizedBoxHeight(height: 60),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
