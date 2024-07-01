import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/Provider/uploadVideo_provider.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/View/VideoPage_View/VideoComponent.dart';
import 'package:cratch/widgets/GradientTextWidget.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/customButton.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../widgets/customtext.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image/image.dart' as img;

class UploadVideoView extends StatefulWidget {
  const UploadVideoView({Key? key}) : super(key: key);

  @override
  State<UploadVideoView> createState() => _UploadVideoViewState();
}

class _UploadVideoViewState extends State<UploadVideoView> {
  File? videoFile;
  String ipfsVideo = "";
  Uint8List? thumbnail;
  bool isTapped = false;
  bool isTapped1 = false;
  String videoDuratio = "";
  String description = "";
  String base64 = "";
  bool isLoading = false;
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

  void selectContainer(int index) {
    setState(() {
      selectedContainer = index;
    });
  }

  List<String>? tagss = ["crypto"];
  late double _distanceToField;
  late TextfieldTagsController _controller;
  TextEditingController textEditingController = TextEditingController();
  bool isTagsTapped = false;
  bool isVideoUploading = false;
  String videoPath = "";
  String title = "";

  Future<void> uploadVideo() async {
    try {
      setState(() {
        isLoading = false; // Set to false initially
      });

      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId') ?? '';
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      var videoId = generateUniqueId();

      if (userId.isNotEmpty &&
          token.isNotEmpty &&
          videoId.isNotEmpty &&
          videoPath.isNotEmpty &&
          title.isNotEmpty && // Make sure title is not empty
          description.isNotEmpty &&
          base64.isNotEmpty &&
          videoDuratio.isNotEmpty &&
          tagss != null &&
          tagss!.isNotEmpty &&
          dropdownValue.isNotEmpty) {
        setState(() {
          isLoading = true; // Set to true only if all conditions are met
        });
        var dt = {
          "title": title.toString(),
          "videoId": videoId.toString(),
          "creator": userId.toString(),
          "videoPath": videoPath.toString(),
          "description": description.toString(),
          "ipfsThumbnail": "",
          "thumbnail": base64.toString(),
          "duration": videoDuratio,
          "tags": tagss,
          "category": dropdownValue,
          "visibility": selectedContainer,
          "ipfsUrl": ''
        };

        final response = await http.post(
          Uri.parse('https://account.cratch.io/api/video/$wallet'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          },
          body: json.encode(dt),
        );

        if (response.statusCode == 200) {
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
                message: "Video Uploaded Successfully",
              ),
            ),
          );

          setState(() {
            isLoading = false;
          });
          try {
            final videostate =
                // ignore: use_build_context_synchronously
                Provider.of<UploadVideoProvider>(context, listen: false);
            videostate.addUploadVideo(jsonDecode(response.body));
            // ignore: empty_catches
          } catch (e) {}
          Future.delayed(const Duration(seconds: 2), () {
            Get.to(() =>
                VideoComponent(videoId: videoId.toString(), creator: true));
          });
        } else {
          setState(() {
            isLoading = false;
          });
          // ignore: avoid_print
          print("Error on the request ${response.statusCode}");
        }
      } else {
        setState(() {
          isLoading = false; // Set to false if any of the conditions fails
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  String generateUniqueId() {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    const idLength = 24; // Specify the desired length of the ID

    // Generate a random alphanumeric ID
    return String.fromCharCodes(
      Iterable.generate(
        idLength,
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
    super.initState();
    _controller = TextfieldTagsController();
    textEditingController = TextEditingController();
  }

  Future<void> uploadVideoFile(File videoFile) async {
    try {
      setState(() {
        isVideoUploading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      var stream = videoFile.openRead();
      var length = await videoFile.length();

      var uri = Uri.parse(
          'https://account.cratch.io/api/video/upload/$wallet'); // Replace with your API route URL

      var request = http.MultipartRequest('POST', uri);
      var multipartFile = http.MultipartFile(
        'file',
        stream.cast(),
        length,
        filename: videoFile.path.split('/').last,
        contentType:
            MediaType.parse('video/mp4'), // Adjust the media type if necessary
      );

      request.files.add(multipartFile);
      request.headers['Connection'] = 'keep-alive';
      request.headers['Authorization'] =
          'Bearer $token'; // Replace with your access token

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseBody);
        setState(() {
          isVideoUploading = false;
          videoPath =
              'https://account.cratch.io/${decodedResponse['filePath']}';
        });
        // Handle the response from the API if needed
      } else {
        setState(() {
          isVideoUploading = false;
        });
        // ignore: avoid_print
        print('Video upload failed');
        // Handle the upload failure if needed
      }
    } catch (error) {
      setState(() {
        isVideoUploading = false;
      });
      // ignore: avoid_print
      print('Error uploading video: $error');
      // Handle any errors that occur during the upload process
    }
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
        child: Scaffold(
          appBar: const TopBar(),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSizedBoxHeight(height: 10),
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
                        text: 'Upload Video',
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
                                  ? AppColors.textFieldActive.withOpacity(0.2)
                                  : AppColors.fieldUnActive,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.mainColor),
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
                                  ? AppColors.textFieldActive.withOpacity(0.2)
                                  : AppColors.fieldUnActive,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.mainColor),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                            color: const Color(0xff9A9A9D),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white60)),
                                        child: const Center(
                                          child: Icon(Icons.add,
                                              color: Colors.white60),
                                        ),
                                      ),
                                      CustomSizedBoxHeight(height: 8),
                                      CustomText(
                                          textAlign: TextAlign.start,
                                          textStyle: AppStyle
                                              .textStyle9SemiBoldOffWhite,
                                          title: 'Upload video'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                                height: 77,
                                width: 147,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6)),
                                child: videoFile != null
                                    ? Center(
                                        child: isVideoUploading
                                            ? const CircularProgressIndicator()
                                            : thumbnail != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.memory(
                                                      thumbnail!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          style: BorderStyle
                                                              .solid),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Add border radius here
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      path.basename(
                                                          videoFile!.path),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                      )
                                    : const Text('')),
                          ),
                        ],
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
                                    style: AppStyle.textStyle12Regular,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.indigo,
                                          width: 2.0,
                                        ),
                                      ),
                                      hintText:
                                          _controller.hasTags ? '' : "tags",
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
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
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
                                                                vertical: 5.0),
                                                        child: InkWell(
                                                          child: Text(
                                                            '#$tag',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.h,
                        ),
                        decoration: BoxDecoration(
                            color: AppColors.fieldUnActive,
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: DropdownButton<String>(
                            dropdownColor: const Color.fromRGBO(52, 53, 65, 1),
                            hint: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                'Enter here',
                                style: AppStyle.textStyle12Regular,
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
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                            textStyle: selectedContainer == 1
                                                ? AppStyle
                                                    .textStyle11SemiBoldWhite600
                                                : AppStyle
                                                    .textStyle11SemiBoldBlack,
                                            title: 'Public'),
                                        CustomSizedBoxHeight(height: 5),
                                        CustomText(
                                            textStyle: selectedContainer == 1
                                                ? AppStyle.textStyle8White600
                                                : AppStyle.textStyle8Black600,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                            textStyle: selectedContainer == 2
                                                ? AppStyle
                                                    .textStyle11SemiBoldWhite600
                                                : AppStyle
                                                    .textStyle11SemiBoldBlack,
                                            title: 'Private'),
                                        CustomSizedBoxHeight(height: 5),
                                        CustomText(
                                            textStyle: selectedContainer == 2
                                                ? AppStyle.textStyle8White600
                                                : AppStyle.textStyle8Black600,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                            textStyle: selectedContainer == 0
                                                ? AppStyle
                                                    .textStyle11SemiBoldWhite600
                                                : AppStyle
                                                    .textStyle11SemiBoldBlack,
                                            title: 'NFT holders'),
                                        CustomSizedBoxHeight(height: 5),
                                        CustomText(
                                            textStyle: selectedContainer == 0
                                                ? AppStyle.textStyle8White600
                                                : AppStyle.textStyle8Black600,
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
                          title: isLoading ? 'Uploading...' : 'Upload',
                          ontap: uploadVideo,
                          AppStyle: (title.isNotEmpty &&
                                  description.length > 2 &&
                                  tagss != null &&
                                  tagss!.isNotEmpty &&
                                  dropdownValue.isNotEmpty &&
                                  videoFile != null &&
                                  thumbnail != null)
                              ? AppStyle.textStyle12regularWhite
                              : AppStyle.textStyle12offWhite,
                          gradient: (title.isNotEmpty &&
                                  description.length > 2 &&
                                  tagss != null &&
                                  tagss!.isNotEmpty &&
                                  dropdownValue.isNotEmpty &&
                                  videoFile != null &&
                                  thumbnail != null)
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

  Future<String> getVideoDuration(String videoPath) async {
    final FlutterFFprobe ffprobe = FlutterFFprobe();
    final MediaInformation info = await ffprobe.getMediaInformation(videoPath);

    final String durationString = info.getMediaProperties()!['duration'];
    final double durationSeconds = double.tryParse(durationString) ?? 0;

    final int minutes = (durationSeconds / 60).floor();
    final int seconds = (durationSeconds % 60).floor();

    final String formattedDuration =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return formattedDuration;
  }

  /// Get from gallery

  Future<String?> generateThumbnailBase64(String videoPath) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 500,
      maxWidth: 500,
      quality: 100,
    );

    if (uint8list != null) {
      setState(() {
        thumbnail = uint8list;
      });
      final image = img.decodeImage(uint8list);
      final thumbnails = img.copyResize(image!, width: 500, height: 500);

      final List<int> pngBytes = img.encodeJpg(thumbnails);
      final base64String = base64Encode(pngBytes);
      setState(() {
        base64 = 'data:image/jpeg;base64,$base64String';
      });
      return 'data:image/jpeg;base64,$base64String';
    }

    return null;
  }

  Future<String> uploadVideoToWeb3Storage(
      String videoPath, String apiKey) async {
    String imageExtension = path.extension(videoPath).toLowerCase();

    if (imageExtension == "mp4" || imageExtension == "mov") {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.web3.storage/upload'));

      // Load the video file
      var videoFile = await http.MultipartFile.fromPath('file', videoPath);

      // Add the video file to the request
      request.files.add(videoFile);

      // Set the Web3Storage API key in the headers
      request.headers['Authorization'] = 'Bearer $apiKey';

      // Send the request and get the response
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.transform(utf8.decoder).join();
        var jsonResponse = jsonDecode(responseData);

        // Get the CID of the uploaded video
        var cid = jsonResponse['cid'];

        String fileName = path.basename(videoPath);
        if (cid.length > 2) {
          setState(() {
            ipfsVideo = 'https://$cid.ipfs.dweb.link/$fileName.$imageExtension';
          });
        }

        return cid;
      } else {
        return "";
      }
    } else {
      throw Exception('Failed to upload video to Web3Storage');
    }
  }

  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );
    try {
      if (pickedFile != null) {
        setState(() {
          videoFile = File(pickedFile.path);
        });

        String duration = await getVideoDuration(pickedFile.path);
        await generateThumbnailBase64(pickedFile.path);
        setState(() {
          videoDuratio = duration;
        });
        await uploadVideoFile(videoFile ?? File(""));
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
