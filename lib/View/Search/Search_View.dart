import 'dart:convert';
import 'package:cratch/Utils/AppConstant.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/View/SavedSession/SavedSession.dart';
import 'package:cratch/View/ViewAllVideo&Stream/viewAllVideos.dart';
import 'package:cratch/widgets/GradientTextWidget.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isSearching = false;
  String searchText = '';
  List<dynamic> result = [];
  bool showSuggestions = true;
  String wallet = '';
  bool isTyping = false;
  String token = '';
  bool finishSearch = false;
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _onSearchTextChanged(String text) {
    if (text.isNotEmpty && text.length > 1) {
      setState(() {
        searchText = text;
        showSuggestions = false;
        isTyping = true;
      });
    } else {
      setState(() {
        showSuggestions = true;
        result = [];
        finishSearch = false;
        isSearching = false;
        isTyping = false;
      });
    }
  }

  static List<String> suggestions = [
    "Gaming in Crypto",
    "Splinterlands online battles",
    "What is Axie Infinity"
  ];

  Future<void> searchVideos(String query) async {
    try {
      _searchFocusNode.unfocus();
      setState(() {
        textEditingController.text = query;
        showSuggestions = false;
        isSearching = true;
        isTyping = false;
      });
      final prefs = await SharedPreferences.getInstance();
      var address = prefs.getString('wallet_address') ?? '';
      var token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/video/search/${address.toLowerCase()}/query?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data is List) {
        setState(() {
          result = data;
          isSearching = false;
          finishSearch = true;
        });
      } else {
        setState(() {
          showSuggestions = true;
          isSearching = false;
          finishSearch = true;
        });
      }
    } catch (e) {
      setState(() {
        showSuggestions = true;
        isSearching = false;
        finishSearch = true;
      });
    }
  }

  Future<Map<String, String>> _getWalletAddressAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    var addressa = prefs.getString('wallet_address') ?? '';
    var tokena = prefs.getString('token') ?? '';
    setState(() {
      wallet = addressa.toLowerCase();
      token = tokena;
    });
    return {'address': addressa, 'token': tokena};
  }

  @override
  void initState() {
    _getWalletAddressAndToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.bgGradient2,
              shadowColor: Colors.transparent,
              actions: [
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
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GradientTextWidget(
                          size: 17.h,
                          text: 'Search',
                        ),
                      ),
                      CustomSizedBoxHeight(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TextFormField(
                          focusNode: _searchFocusNode, // Assign the focus node
                          controller:
                              textEditingController, // Set the TextEditingController
                          onChanged: _onSearchTextChanged,
                          maxLines: 5,
                          minLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction
                              .search, // Specify the textInputAction
                          onEditingComplete: () async {
                            await searchVideos(searchText);
                          },
                          style: TextStyle(
                              color: AppColors.whiteA700, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            filled: true,
                            fillColor: AppColors.fieldUnActive,
                            border: InputBorder.none,
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                if (finishSearch && !isTyping) {
                                  setState(() {
                                    textEditingController.text = '';
                                    showSuggestions = true;
                                    isSearching = false;
                                    finishSearch = false;
                                    searchText = '';
                                    result = [];
                                  });
                                } else {
                                  await searchVideos(searchText);
                                }
                              },
                              child: Icon(
                                finishSearch && !isTyping
                                    ? Icons.close
                                    : Icons.search,
                                color: AppColors.gray75,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(left: 10),
                            hintStyle: TextStyle(
                              color: const Color(0xff7C7C7C),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppConstant.interMedium,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSizedBoxHeight(height: 20),
                              SizedBox(
                                  height: 700,
                                  child: showSuggestions
                                      ? ListView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          children: [
                                              for (var suggestion
                                                  in suggestions)
                                                GestureDetector(
                                                  onTap: () async {
                                                    await searchVideos(
                                                        suggestion);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8,
                                                                  bottom: 8),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .fieldUnActive,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            5))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      15.0),
                                                              child: Text(
                                                                suggestion,
                                                                style: const TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            238,
                                                                            238,
                                                                            238),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                )
                                            ])
                                      : isSearching
                                          ? const SizedBox(
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : result.isEmpty
                                              ? Row(
                                                  children: [
                                                    CustomSizedBoxHeight(
                                                        height: 20),
                                                    SizedBox(
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: finishSearch
                                                                ? const Text(
                                                                    "No result found",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xff7C7C7C),
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : const SizedBox()))
                                                  ],
                                                )
                                              : ListView.builder(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 50),
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount: result
                                                      .length, // Add 1 for loading indicator
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (result[index]
                                                            ['videoId'] !=
                                                        null) {
                                                      return ViewAllVideos(
                                                          video:
                                                              result[index] ??
                                                                  []);
                                                    } else {
                                                      return SavedSession(
                                                        video: result[index],
                                                        userWallet: wallet,
                                                        token: token,
                                                      );
                                                    }
                                                  },
                                                ))
                            ]),
                      ))
                    ]))));
  }
}
