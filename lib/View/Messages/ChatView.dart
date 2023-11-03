import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/AppConstant.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/customtext.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ignore: must_be_immutable
class ChatView extends StatefulWidget {
  dynamic userData;
  ChatView({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  String _currentDate = '';
  bool _isFirstTimeChatsLoad = true;

  void _scrollToBottom(List _list) {
    RegExp regExp = RegExp(
      r"https?:\/\/[^\s]+\.(?:jpg|jpeg|gif|png)",
      caseSensitive: false,
      multiLine: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        int totalHeight = 1;

        for (int i = 0; i < _list.length; i++) {
          String message = _list[i]['message'];
          Match? match = regExp.firstMatch(message);
          if (match != null) {
            totalHeight += 1;
          }
        }

        // Scroll to the bottom taking into account the total height of items

        _scrollController.jumpTo(totalHeight +
            _scrollController.position.maxScrollExtent +
            (110 * totalHeight * 2));
      }
    });
  }

  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 100);
      });
    }
  }

  bool shouldDisplayDate(int index) {
    if (index == 0) {
      return true; // Display the date for the first chat message
    } else {
      DateTime currentDate =
          DateTime.parse(chats[index]['createdAt']); // Current chat's date
      DateTime previousDate =
          DateTime.parse(chats[index - 1]['createdAt']); // Previous chat's date

      // Check if the year is the same for both dates
      bool isSameYear = currentDate.year == previousDate.year;

      return currentDate.day != previousDate.day ||
          currentDate.month != previousDate.month ||
          !isSameYear; // Display the date if it's different from the previous chat or if it's a different year
    }
  }

  String formatDateWithYear(int index) {
    DateTime date = DateTime.parse(chats[index]['createdAt']);

    String formattedDate = DateFormat('MMM d').format(date);

    // Check if the year is different from the current year
    if (date.year != DateTime.now().year) {
      formattedDate += ' ${date.year}'; // Append the year to the formatted date
    }

    return formattedDate;
  }

  void _scrollListener() {
    if (chats.isNotEmpty) {
      setState(() {
        _currentDate = DateFormat('MMM d')
            .format(DateTime.parse(chats[chats.length - 1]['createdAt']));
      });
      double scrollOffset = _scrollController.offset;
      double totalHeight = _scrollController.position.maxScrollExtent -
          _scrollController.position.minScrollExtent;
      double availableHeight =
          totalHeight - _scrollController.position.viewportDimension;

      double averageItemHeight = availableHeight / chats.length;
      int currentChatIndex = (scrollOffset / averageItemHeight).round();

      if (currentChatIndex >= 0 && currentChatIndex < chats.length) {
        DateTime chatDate =
            DateTime.parse(chats[currentChatIndex]['createdAt']);
        DateTime currentDate = DateTime.now();
        setState(() {
          String dayMonth = DateFormat('MMM d').format(chatDate);
          if (chatDate.year != currentDate.year) {
            _currentDate = "$dayMonth ${chatDate.year}";
          } else {
            _currentDate = dayMonth;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  var msgtext = TextEditingController();
  var listviewcon = TextEditingController();
  List<dynamic> chats = [];
  IO.Socket? socket;
  var mesg = "";
  bool isLoading = true;

  String token = "";
  String walleta = "";
  Future<void> getChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var tokena = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      walleta = wallet;
      token = tokena;
      setState(() {
        walleta = wallet;
        token = tokena;
      });
      var response = await http.post(
        Uri.parse('https://account.cratch.io/api/messages/get'),
        headers: {
          'Authorization': 'Bearer $tokena',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive', // Add this line// Add this line
        },
        body: json.encode(
            {"from": wallet.toLowerCase(), "to": widget.userData?['userId']}),
      );
      var data = json.decode(response.body);
      if (data.length > 0) {
        walleta = wallet;
        token = tokena;
        setState(() {
          walleta = wallet;
          chats = data;
          isLoading = false;
        });
        if (_isFirstTimeChatsLoad) {
          _scrollToBottom(data);
          _isFirstTimeChatsLoad = false;

          try {
            await http.put(
              Uri.parse('https://account.cratch.io/api/messages/conversations'),
              headers: {
                'Authorization': 'Bearer $tokena',
                'Content-Type': 'application/json',
                'Connection': 'keep-alive', // Add this line// Add this line
              },
              body: json.encode({
                "to": wallet.toLowerCase(),
                "from": widget.userData?['userId']?.toLowerCase()
              }),
            );
          } catch (e) {
            print(e);
          }
        }
      } else {
        walleta = wallet;
        token = tokena;
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

  void initializeSocket(String serverHost) async {
    socket = IO.io(serverHost, <String, dynamic>{
      'transports': ['websocket', 'polling'],
    });

    socket?.on('last-chat', (data) {
      if (!mounted) return;
      if (data['to']?.toLowerCase() == walleta.toLowerCase() &&
          data['from']?.toLowerCase() ==
              widget.userData['userId'].toLowerCase()) {
        setState(() {
          chats.add({
            "username": widget.userData['username'] ?? "",
            "ProfileAvatar": widget.userData['ProfileAvatar'],
            "userId": widget.userData['userId'],
            "message": data['last_message'],
            "createdAt": data['last_time_message'],
            "isOnline": data['from_status'],
            "fromSelf": false
          });
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });
  }

  String imageUrl = "";

  Future<void> uploadImage(File imageFile, String accessToken) async {
    try {
      if (_image != null) {
        final url = Uri.parse(
            'https://account.cratch.io/api/video/upload/image/${walleta.toLowerCase()}');
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $accessToken';
        final image = _image != null
            ? await http.MultipartFile.fromPath('file', _image!.path)
            : null;
        request.files.add(image!);
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseJson = json.decode(responseBody);
          setState(() {
            imageUrl =
                "https://account.cratch.io/uploads/images/${responseJson["fileName"].toString()}";
          });
        } else {
          imageUrl = "";
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getChats();
    _scrollController.addListener(_scrollListener);
    initializeSocket("https://account.cratch.io");
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
        resizeToAvoidBottomInset: true,

        // extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: const TopBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF373953),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          try {
                            Get.back();
                            await http.put(
                              Uri.parse(
                                  'https://account.cratch.io/api/messages/conversations'),
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                                'Connection':
                                    'keep-alive', // Add this line// Add this line
                              },
                              body: json.encode({
                                "to": walleta.toLowerCase(),
                                "from":
                                    widget.userData?['userId']?.toLowerCase()
                              }),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFE2A3C9),
                        )),
                    SizedBox(
                        width: 250,
                        child: ListTile(
                          tileColor: Colors.transparent,
                          leading: GestureDetector(
                              onTap: () {
                                // Perform the redirection here
                                // For example, you can use Navigator.push() to navigate to another page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileView(
                                      wallet: widget.userData['userId'],
                                      token: token,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width:
                                    51, // Set the desired width of the container
                                height:
                                    51, // Set the desired height of the container
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFA26CE2),
                                    width: 3.0,
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFD598CE),
                                      Color(0xFFA26CE2),
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color:
                                          Color.fromRGBO(163, 109, 226, 0.26),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),

                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          widget.userData['ProfileAvatar'] ??
                                              "",
                                        ),
                                      ),
                                    ),
                                    widget.userData['isOnline']
                                        ? Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green,
                                              ),
                                            ),
                                          )
                                        : Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                              )),
                          title: CustomText(
                            title: widget.userData['username'] ?? "",
                            textStyle: AppStyle.textStyle12regularWhite,
                          ),
                          subtitle: CustomText(
                            title: widget.userData['isOnline']
                                ? "Online"
                                : 'Offline',
                            textStyle: TextStyle(
                                color: const Color(0xFFD2D2D2),
                                fontSize: 9.sp,
                                fontFamily: AppConstant.interMedium,
                                fontWeight: FontWeight.w500),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            isLoading
                ? const Expanded(
                    child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ))
                : chats.isNotEmpty
                    ? Expanded(
                        child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _DateHeaderDelegate(
                              date: _currentDate,
                            ),
                          ),
                          SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              String message = chats[index]['message'];
                              RegExp regExp = RegExp(
                                r"https?:\/\/[^\s]+\.(?:jpg|jpeg|gif|png)",
                                caseSensitive: false,
                                multiLine: true,
                              );
                              Match? match = regExp.firstMatch(message);
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    shouldDisplayDate(index)
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Text(
                                              formatDateWithYear(index),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    chats[index]['fromSelf']
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 45,
                                                ),
                                                child: GradientTextWidget(
                                                    text: 'You', size: 12),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 40,
                                                        top: 5.h,
                                                        bottom: 5.h),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration:
                                                        const BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xFFF2587C),
                                                          Color(0xFF7B51C7),
                                                        ],
                                                        stops: [0.0448, 1.0316],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color.fromRGBO(
                                                              147,
                                                              83,
                                                              185,
                                                              0.33),
                                                          offset: Offset(0, 4),
                                                          blurRadius: 13,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                          maxWidth:
                                                              300, // set the maximum width to 200 pixels
                                                        ),
                                                        child: (match != null)
                                                            ? Column(
                                                                children: [
                                                                  Hero(
                                                                    tag: match
                                                                        .group(
                                                                            0)!,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          PageRouteBuilder(
                                                                            opaque:
                                                                                false,
                                                                            pageBuilder: (BuildContext context,
                                                                                _,
                                                                                __) {
                                                                              return GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Container(
                                                                                  decoration: const BoxDecoration(color: Colors.black),
                                                                                  child: Center(
                                                                                    child: FractionallySizedBox(
                                                                                      widthFactor: 1,
                                                                                      heightFactor: 1,
                                                                                      child: CachedNetworkImage(
                                                                                        fit: BoxFit.contain,
                                                                                        imageUrl: match.group(0)!,
                                                                                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              CircularProgressIndicator(
                                                                                                value: downloadProgress.progress,
                                                                                              ),
                                                                                              const SizedBox(height: 8),
                                                                                              Text(
                                                                                                downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        constraints:
                                                                            const BoxConstraints(maxHeight: 200),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          imageUrl:
                                                                              match.group(0)!,
                                                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                                              Center(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                CircularProgressIndicator(
                                                                                  value: downloadProgress.progress,
                                                                                ),
                                                                                const SizedBox(height: 8),
                                                                                Text(
                                                                                  downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              const Icon(Icons.error),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10.0),
                                                                    child: Text(
                                                                      message.replaceAll(
                                                                          match.group(
                                                                              0)!,
                                                                          ''),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        color: AppColors
                                                                            .whiteA700,
                                                                        fontSize:
                                                                            12.sp,
                                                                        fontFamily:
                                                                            AppConstant.interSemiBold,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      maxLines:
                                                                          1000, // Set the maximum number of lines to 2
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                chats[index][
                                                                        'message'] ??
                                                                    "",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  color: AppColors
                                                                      .whiteA700,
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontFamily:
                                                                      AppConstant
                                                                          .interSemiBold,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                // Set the maximum number of lines to 2
                                                                maxLines: 1000,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 45, bottom: 10),
                                                child: GradientTextWidget(
                                                    text:
                                                        '${DateFormat('hh:mm a').format(DateTime.parse(chats[index]["createdAt"]))}',
                                                    size: 10),
                                              ),
                                            ],
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(left: 40),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: GradientTextWidget(
                                                      text: widget.userData[
                                                              'username'] ??
                                                          "",
                                                      size: 12),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      // width: 250.w,
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 25.w,
                                                            top: 5.h,
                                                            bottom: 5.h),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment(
                                                                -1.0, -1.0),
                                                            end: Alignment(
                                                                1.0, 1.0),
                                                            colors: [
                                                              Color(0xFFB360FA),
                                                              Color(0xFF5F41F0),
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            transform:
                                                                GradientRotation(
                                                                    94.0 *
                                                                        3.146 /
                                                                        180),
                                                          ),
                                                          color: Theme.of(
                                                                  context)
                                                              .toggleableActiveColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      101,
                                                                      68,
                                                                      241,
                                                                      0.33),
                                                              offset:
                                                                  Offset(0, 4),
                                                              blurRadius: 13,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                            maxWidth:
                                                                300, // set the maximum width to 200 pixels
                                                          ),
                                                          child: (match != null)
                                                              ? Column(
                                                                  children: [
                                                                    Hero(
                                                                      tag: match
                                                                          .group(
                                                                              0)!,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .push(
                                                                            PageRouteBuilder(
                                                                              opaque: false,
                                                                              pageBuilder: (BuildContext context, _, __) {
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(color: Colors.black),
                                                                                    child: Center(
                                                                                      child: FractionallySizedBox(
                                                                                        widthFactor: 1,
                                                                                        heightFactor: 1,
                                                                                        child: CachedNetworkImage(
                                                                                          fit: BoxFit.contain,
                                                                                          imageUrl: match.group(0)!,
                                                                                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                CircularProgressIndicator(
                                                                                                  value: downloadProgress.progress,
                                                                                                ),
                                                                                                const SizedBox(height: 8),
                                                                                                Text(
                                                                                                  downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          constraints:
                                                                              const BoxConstraints(maxHeight: 200),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            imageUrl:
                                                                                match.group(0)!,
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
                                                                                    downloadProgress.progress != null ? '${(downloadProgress.progress! * 100).toInt()}%' : "...",
                                                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.error),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10.0),
                                                                      child:
                                                                          Text(
                                                                        message.replaceAll(
                                                                            match.group(0)!,
                                                                            ''),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AppColors.whiteA700,
                                                                          fontSize:
                                                                              12.sp,
                                                                          fontFamily:
                                                                              AppConstant.interSemiBold,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        maxLines:
                                                                            1000, // Set the maximum number of lines to 2
                                                                        overflow:
                                                                            TextOverflow.ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Text(
                                                                  chats[index][
                                                                          'message'] ??
                                                                      "",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColors
                                                                        .whiteA700,
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontFamily:
                                                                        AppConstant
                                                                            .interSemiBold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  maxLines:
                                                                      1000, // Set the maximum number of lines to 2
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // Use ellipsis to indicate that the text has been truncated
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, bottom: 10),
                                                  child: GradientTextWidget(
                                                      text:
                                                          '${DateFormat('hh:mm a').format(DateTime.parse(chats[index]["createdAt"]))}',
                                                      size: 10),
                                                ),
                                              ],
                                            ),
                                          )
                                  ],
                                ),
                              );
                            }, childCount: chats.length),
                          )
                        ],
                      ))
                    : Expanded(
                        child: Container(),
                      ),
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: AppColors.fieldUnActive,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_image != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              image: DecorationImage(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                    });

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _scrollController.jumpTo(_scrollController
                                          .position.maxScrollExtent);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      width: 20,
                                      height: 20,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      TextFormField(
                        maxLines: 5,
                        minLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) {
                          setState(() {
                            mesg = value;
                          });
                        },
                        controller: msgtext,
                        style:
                            TextStyle(color: AppColors.whiteA700, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: GestureDetector(
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                            },
                            child: const Icon(
                              Icons.filter,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          suffixIcon: msgtext.text.isNotEmpty || _image != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButtonWidget(
                                    ontap: () async {
                                      try {
                                        var dt = mesg;

                                        if (dt.isNotEmpty || _image != null) {
                                          if (_image != null) {
                                            await uploadImage(_image!, token);
                                          }
                                          var finalMessage = imageUrl.length > 2
                                              ? ' $imageUrl'
                                              : imageUrl;
                                          setState(() {
                                            chats.add({
                                              "username":
                                                  widget.userData['username'] ??
                                                      "",
                                              "ProfileAvatar": widget
                                                  .userData['ProfileAvatar'],
                                              "userId":
                                                  widget.userData['userId'],
                                              "message": dt + finalMessage,
                                              "createdAt":
                                                  DateTime.now().toString(),
                                              "isOnline": true,
                                              "fromSelf": true
                                            });
                                            _image = null;
                                          });
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            _scrollController.jumpTo(
                                                _scrollController
                                                    .position.maxScrollExtent);
                                          });
                                          msgtext.text = '';
                                          await http.post(
                                            Uri.parse(
                                                'https://account.cratch.io/api/messages/'),
                                            headers: {
                                              'Authorization': 'Bearer $token',
                                              'Content-Type':
                                                  'application/json',
                                              'Connection':
                                                  'keep-alive', // Add this line// Add this line
                                            },
                                            body: json.encode({
                                              "from": walleta.toLowerCase(),
                                              "to": widget.userData?['userId'],
                                              "message": dt + finalMessage
                                            }),
                                          );
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    height: 35,
                                    boxShadow: const [
                                      BoxShadow(
                                        color:
                                            Color.fromRGBO(151, 49, 254, 0.27),
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(
                                            0xFFC76CFF), // The first color from the given gradient
                                        Color(
                                            0xFF4D30FF), // The second color from the given gradient
                                      ],
                                    ),
                                    width: 35,
                                    widget: const Icon(
                                      Icons.send,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  null,
                                  color: AppColors.gray75,
                                ),
                          contentPadding: const EdgeInsets.only(
                              left: 10, top: 10, bottom: 10),
                          hintStyle: TextStyle(
                              color: const Color(0xff7C7C7C),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppConstant.interMedium,
                              fontSize: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;

  _DateHeaderDelegate({required this.date});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    bool isToday = (DateTime.now().day.toString() == date);
    return date.isNotEmpty
        ? Container(
            color: Colors.transparent,
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FractionallySizedBox(
                          alignment: Alignment.center,
                          widthFactor:
                              null, // Set to a value less than 1.0 to allow the width to be adjusted based on the text length
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(150, 21, 22, 49),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 20, right: 20),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  isToday ? 'Today' : date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                )))
        : const Center();
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
