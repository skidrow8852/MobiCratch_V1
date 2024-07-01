import 'dart:convert';
import 'dart:io';
import 'package:cratch/Provider/Avatar_provider.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/CustomLabel.dart';
import '../../widgets/customButton.dart';
import 'package:http/http.dart' as http;

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  File? imageAvatar;
  File? imageCover;
  String address = "";
  String token = "";
  Map<String, dynamic> alluserData = {};
  String username = '';
  String about = '';
  String cover = '';
  String avatar = '';
  bool isLoading = true;
  bool isUsernameEdit = false;
  bool isAboutEdit = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    getWalletAddress();
  }

  Future<void> pickImageAvatar(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageAvatar = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageCover(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageCover = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    try {
      if (imageAvatar != null) {
        final url = Uri.parse(
            'https://account.cratch.io/api/video/upload/image/${address.toLowerCase()}');
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';
        final image = imageAvatar != null
            ? await http.MultipartFile.fromPath('file', imageAvatar!.path)
            : null;
        request.files.add(image!);
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseJson = json.decode(responseBody);
          setState(() {
            avatar =
                "https://account.cratch.io/uploads/images/${responseJson["fileName"].toString()}";
          });
        }
      }

      if (imageCover != null) {
        final url = Uri.parse(
            'https://account.cratch.io/api/video/upload/image/${address.toLowerCase()}');
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';
        final image = imageCover != null
            ? await http.MultipartFile.fromPath('file', imageCover!.path)
            : null;
        request.files.add(image!);
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseJson = json.decode(responseBody);
          setState(() {
            cover =
                "https://account.cratch.io/uploads/images/${responseJson["fileName"].toString()}";
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getWalletAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? walletAddress = prefs.getString('wallet_address');
    String? tokenAdress = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
          'https://account.cratch.io/api/users/${walletAddress?.toLowerCase()}'),
      headers: {'Authorization': 'Bearer $tokenAdress'},
    );
    final userData = jsonDecode(response.body);

    if (walletAddress != null && response.statusCode == 200) {
      setState(() {
        address = walletAddress.toLowerCase();
        token = tokenAdress ?? "";
        alluserData = userData;
        username = userData['username'];
        about = userData['about'];
        cover = userData['ProfileCover'];
        avatar = userData['ProfileAvatar'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onUsernameChanged(String text) {
    String previous = alluserData['username'];
    if (text != previous) {
      setState(() {
        isUsernameEdit = true;
        username = text;
      });
    } else {
      setState(() {
        isUsernameEdit = false;
      });
    }
  }

  void onAboutChange(String text) {
    String previous = alluserData['about'];
    if (text != previous) {
      setState(() {
        isAboutEdit = true;
        about = text;
      });
    } else {
      setState(() {
        isAboutEdit = false;
      });
    }
  }

  Future<void> onSave() async {
    try {
      setState(() {
        saving = true;
      });
      await uploadImage();
      Map<String, dynamic> data = {};

      if (username != alluserData['username']) {
        data['username'] = username;
      }

      if (about != alluserData['about']) {
        data['about'] = about;
      }
      if (cover != alluserData['ProfileCover']) {
        data['ProfileCover'] = cover;
      }
      if (avatar != alluserData['ProfileAvatar']) {
        data['ProfileAvatar'] = avatar;
      }

      if (data.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token') ?? '';
        var wallet = prefs.getString('wallet_address') ?? '';

        final response = await http.put(
            Uri.parse(
                'https://account.cratch.io/api/users/${wallet.toLowerCase()}/edit'),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data));

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
                message: "Settings Saved Successfully",
              ),
            ),
          );

          if (avatar.isNotEmpty) {
            final avatarstate =
                Provider.of<AvatarProvider>(context, listen: false);
            avatarstate.setAvatar(avatar);
            prefs.setString('avatar', avatar);
          }
          setState(() {
            alluserData['username'] = username;
            alluserData['about'] = about;
            isAboutEdit = false;
            isUsernameEdit = false;
            imageAvatar = null;
            imageCover = null;
          });
        } else {
          showTopSnackBar(
              padding: const EdgeInsets.symmetric(horizontal: 50),
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
      }

      setState(() {
        saving = false;
      });
    } catch (e) {
      setState(() {
        saving = false;
      });

      showTopSnackBar(
          padding: const EdgeInsets.symmetric(horizontal: 50),
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
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWithNavBar(
      screen: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgGradient2,
                AppColors.bgGradient2,
                AppColors.bgGradient1,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const TopBar(),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          CustomSizedBoxHeight(height: 30.h),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Settings",
                              style: TextStyle(
                                fontSize: 17.h,
                                fontWeight: FontWeight.w700,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: <Color>[
                                      AppColors.txtGradient1,
                                      AppColors.txtGradient2,
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(
                                      0.0,
                                      0.0,
                                      200.0,
                                      100.0,
                                    ),
                                  ),
                              ),
                            ),
                          ),
                          CustomSizedBoxHeight(height: 30.h),

                          /// Avatar Secion

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                      textStyle:
                                          AppStyle.textStyle14whiteSemiBold,
                                      title: "Avatar"),
                                  SizedBox(height: 10.h),
                                  Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                          radius: 40.r,
                                          backgroundColor:
                                              const Color(0xFFFFFFFF),
                                          child: ClipOval(
                                            child: imageAvatar != null
                                                ? Image.file(
                                                    imageAvatar!,
                                                    fit: BoxFit.cover,
                                                    width: 200.w,
                                                    height: 130.h,
                                                  )
                                                : Image.network(
                                                    avatar,
                                                    fit: BoxFit.cover,
                                                    width: 200.w,
                                                    height: 130.h,
                                                  ),
                                          )),
                                      Positioned(
                                        left: 60.w,
                                        top: 2.h,
                                        child: GestureDetector(
                                          onTap: (() {
                                            pickImageAvatar(
                                                ImageSource.gallery);
                                          }),
                                          child: Container(
                                            width: 26.w,
                                            height: 26.h,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButtonWidget(
                                                ontap: () {},
                                                height: 50.h,
                                                width: 50.w,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFC366FC),
                                                    Color(0xFF553EEE)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.mainColor,
                                                    blurRadius:
                                                        20.0, // soften the shadow
                                                    spreadRadius:
                                                        -4, //extend the shadow
                                                    offset: const Offset(
                                                      0.0, // Move to right 10  horizontally
                                                      4.0, // Move to bottom 10 Vertically
                                                    ),
                                                  )
                                                ],
                                                widget: InkWell(
                                                  onTap: () {
                                                    pickImageAvatar(
                                                        ImageSource.gallery);
                                                  },
                                                  child: Icon(Icons.edit,
                                                      color:
                                                          AppColors.whiteA700,
                                                      size: 18.w),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: 160.w,
                                height: 107.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                        color: AppColors.mainColor, width: 1)),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(height: 10.h),
                                      CustomText(
                                          textStyle:
                                              AppStyle.textStyle12Regular,
                                          title: "Balance"),
                                      SizedBox(height: 15.h),
                                      //SvgPicture.asset(AppImages.logo),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.logopng,
                                            height: 25,
                                            width: 25,
                                          ),
                                          SizedBox(width: 10.w),
                                          CustomText(
                                              textStyle:
                                                  AppStyle.textStyle12Regular,
                                              title: alluserData['rewards']
                                                  .toString()),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      Container(
                                        height: 36.h,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xff7449EF),
                                              Color(0xffB260FB),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: CustomText(
                                            textStyle: AppStyle
                                                .textStyle12regularWhite,
                                            title: 'Withdraw',
                                          ),
                                        ),
                                      )
                                    ]),
                              )
                            ],
                          ),

                          ////// End of Avatar section

                          CustomSizedBoxHeight(height: 15.h),
                          CustomLabel(title: "Profile Cover"),
                          CustomSizedBoxHeight(height: 7.h),

                          /// Profile Cover

                          Container(
                            height: 108.h,
                            width: 310,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                image: imageCover != null
                                    ? FileImage(
                                        imageCover!,
                                      ) as ImageProvider<Object>
                                    : NetworkImage(cover),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButtonWidget(
                                    ontap: () {},
                                    height: 35.h,
                                    width: 35.w,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFC366FC),
                                        Color(0xFF553EEE)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.mainColor,
                                        blurRadius: 20.0, // soften the shadow
                                        spreadRadius: -4, //extend the shadow
                                        offset: const Offset(
                                          0.0, // Move to right 10  horizontally
                                          4.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                    widget: InkWell(
                                      onTap: () {
                                        pickImageCover(ImageSource.gallery);
                                      },
                                      child: Icon(Icons.edit,
                                          color: AppColors.whiteA700,
                                          size: 24.w),
                                    )),
                              ),
                            ),
                          ),

                          ////// End of profile cover Section
                          ///
                          ///
                          CustomSizedBoxHeight(height: 15.h),
                          CustomSizedBoxHeight(height: 5.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomLabel(title: "Username"),
                              CustomSizedBoxHeight(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: TextFormField(
                                  maxLines: 1,
                                  enabled: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                      border: InputBorder.none,
                                      hintText: username,
                                      hintStyle: AppStyle.textStyle12Regular,
                                      filled: true,
                                      fillColor: AppColors.fieldUnActive,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.mainColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.redAccsent))),
                                  onChanged: onUsernameChanged,
                                  initialValue: username,
                                ),
                              ),
                            ],
                          ),
                          CustomSizedBoxHeight(height: 15.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomLabel(title: "About"),
                              CustomSizedBoxHeight(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: TextFormField(
                                  maxLines: 1,
                                  enabled: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                      border: InputBorder.none,
                                      hintText: about,
                                      hintStyle: AppStyle.textStyle12Regular,
                                      filled: true,
                                      fillColor: AppColors.fieldUnActive,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.mainColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.redAccsent))),
                                  onChanged: onAboutChange,
                                  initialValue: about,
                                ),
                              ),
                            ],
                          ),
                          CustomSizedBoxHeight(height: 15.h),
                          CustomButton(
                              color: AppColors.fieldUnActive,
                              gradient: isUsernameEdit ||
                                      isAboutEdit ||
                                      imageAvatar != null ||
                                      imageCover != null
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                          Color(0xFF7356EC),
                                          Color(0xFFF6587A),
                                        ])
                                  : null,
                              AppStyle: isUsernameEdit ||
                                      isAboutEdit ||
                                      imageAvatar != null ||
                                      imageCover != null
                                  ? AppStyle.textStyle12regularWhite
                                  : AppStyle.textStyle12offWhite,
                              title: saving ? 'Saving ...' : 'Save change',
                              ontap: () {
                                if (isUsernameEdit ||
                                    isAboutEdit ||
                                    imageAvatar != null ||
                                    imageCover != null) {
                                  onSave();
                                }
                              }),
                          CustomSizedBoxHeight(height: 80.h),
                        ],
                      )),
          ),
        ),
      ),
    );
  }
}
