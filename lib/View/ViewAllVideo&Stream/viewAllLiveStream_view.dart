import 'dart:convert';
import 'package:cratch/View/Live_View/Live_View.dart';
import 'package:flutter/material.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/Sizebox/sizedboxheight.dart';
import 'package:http/http.dart' as http;

class AllLivesView extends StatefulWidget {
  const AllLivesView({
    Key? key,
  }) : super(key: key);

  @override
  _AllLivesViewState createState() => _AllLivesViewState();
}

class _AllLivesViewState extends State<AllLivesView> {
  late TabController tabController;
  bool loading = false;
  bool isVisible2 = false;
  List<dynamic> userVideos = [];
  var skip = 0;
  var limit = 6;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  Future<List<dynamic>> fetchLives() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('https://account.cratch.io/api/live/all/$skip/$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final lives = jsonDecode(response.body);
      userVideos.addAll(lives);

      return lives;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchMoreLives() async {
    if (isLoadingMore || !hasMoreData) return; // Avoid multiple requests

    setState(() {
      isLoadingMore = true;
    });

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('https://account.cratch.io/api/live/all/$skip/$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final lives = jsonDecode(response.body);
      setState(() {
        userVideos.addAll(lives);
        isLoadingMore = false;
        skip += 1; // Increment skip by the number of fetched lives
        hasMoreData = (lives.length == limit);
      });
    } else {
      setState(() {
        isLoadingMore = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();

    fetchLives().then((li) {
      if (mounted) {
        setState(() {
          userVideos = li;
          isLoading = false;
          skip += 1;
          hasMoreData = (li.length == limit);
        });
      }
    });
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
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              CustomSizedBoxHeight(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GradientTextWidget(
                        size: 17.h,
                        text: 'All Lives',
                      ),
                    ),
                  ],
                ),
              ),
              isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: LivesListView(
                        userVideos: userVideos,
                        fetchMoreLives: fetchMoreLives,
                        isLoadingMore: isLoadingMore,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class LivesListView extends StatefulWidget {
  final List<dynamic> userVideos;
  final VoidCallback fetchMoreLives;
  final bool isLoadingMore;

  LivesListView({
    required this.userVideos,
    required this.fetchMoreLives,
    required this.isLoadingMore,
  });

  @override
  _LivesListViewState createState() => _LivesListViewState();
}

class _LivesListViewState extends State<LivesListView> {
  final ScrollController _scrollController = ScrollController();
  String address = "";
  String token = "";

  Future<Map<String, String>> _getWalletAddressAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    var addressa = prefs.getString('wallet_address') ?? '';
    var tokena = prefs.getString('token') ?? '';
    setState(() {
      address = addressa.toLowerCase();
      token = tokena;
    });
    return {'address': addressa};
  }

  @override
  void initState() {
    super.initState();
    _getWalletAddressAndToken();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.position.outOfRange &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.7 &&
        !widget.isLoadingMore) {
      widget.fetchMoreLives(); // Fetch more lives when reaching 80% of the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 50),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.userVideos.length +
          (widget.isLoadingMore ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        if (index < widget.userVideos.length) {
          return LiveView(
            video: widget.userVideos[index] ?? [],
            userWallet: address,
            token: token,
          );
        } else if (index == widget.userVideos.length) {
          return widget.isLoadingMore
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ) // Display loading indicator
              : const SizedBox(); // Empty SizedBox when not loading more
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
