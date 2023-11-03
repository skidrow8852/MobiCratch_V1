import 'dart:convert';
import 'dart:math';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/Sizebox/sizedboxheight.dart';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int selected = 0;
  int tab = 0;
  List<double> views0 = [0, 0, 0, 0, 0, 0, 0];
  List<double> views1 = [0, 0, 0, 0, 0];
  List<double> views2 = [0, 0, 0, 0, 0];
  List<double> views3 = [0, 0, 0, 0, 0];
  Map latestVideo = {};

  List<double> watchtime0 = [0, 0, 0, 0, 0, 0, 0];
  List<double> watchtime1 = [0, 0, 0, 0, 0];
  List<double> watchtime2 = [0, 0, 0, 0, 0];
  List<double> watchtime3 = [0, 0, 0, 0, 0];

  List<String> alltime = [
    "Jan 2023",
    "June 2023",
    "Dec 2023",
    "Jan 2024",
    "June 2024"
  ];

  int tokens = 0;
  int views = 0;
  int viewssec = 0;
  int viewsthird = 0;
  int viewsfourth = 0;
  int followers = 0;
  double watchtime = 0;
  double watchtimesec = 0;
  double watchtimethird = 0;
  double watchtimefourth = 0;

  List<double> followersData = [
    0,
    0,
    0,
    0,
  ];

  late TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();
    getAnalytics();
    getUser();
    _tabController = TabController(vsync: this, length: 4, initialIndex: tab);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      selected = 0;
    });
  }

  Future<void> getAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var userId = prefs.getString('userId') ?? '';
      var response = await http.get(
          Uri.parse('https://account.cratch.io/api/analytics/week/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });
      var data = jsonDecode(response.body);

      var response1 = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/analytics/twentyeight/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });
      var data1 = jsonDecode(response1.body);

      var response2 = await http.get(
          Uri.parse('https://account.cratch.io/api/analytics/year/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });
      var data2 = jsonDecode(response2.body);

      var response3 = await http.get(
          Uri.parse('https://account.cratch.io/api/analytics/all/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });

      var data3 = jsonDecode(response3.body);
      DateTime now = DateTime.now();
      if (response.statusCode == 200 &&
          response1.statusCode == 200 &&
          response2.statusCode == 200 &&
          response3.statusCode == 200 &&
          data is List &&
          (data.isNotEmpty ||
              data1.isNotEmpty ||
              data2.isNotEmpty ||
              data3.isNotEmpty)) {
        for (int j = 0; j < data.length; j++) {
          watchtime +=
              (double.tryParse(data[j]['watchtime'].toString()) ?? 0) / 3600;
        }

        List<double> documentCounts = [];
        List<double> documentCounts1 = [];
        List<double> documentCounts2 = [];
        List<double> documentCounts3 = [];

        for (int i = 0; i < 7; i++) {
          DateTime currentDate = now.subtract(Duration(days: i));
          String currentDateString =
              DateFormat('yyyy-MM-dd').format(currentDate);
          int count = data
              .where((element) =>
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(element['createdAt'])) ==
                  currentDateString)
              .length;
          documentCounts.add(count.toDouble());
        }

        // Fill in missing days with 0 count
        for (int i = 0; i < 7; i++) {
          if (i >= documentCounts.length) {
            documentCounts.add(0.0);
          }
        }

        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        final daysInMonth =
            DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
        final dates = List.generate((daysInMonth / 5).ceil(), (index) {
          final previousDay = lastMonth.subtract(Duration(days: index * 5));
          return DateFormat('dd-MMM').format(previousDay);
        });

        for (int i = 0; i < dates.length; i++) {
          int count = data1.where((element) {
            DateTime createdAt = DateTime.parse(element['createdAt']);
            DateTime previousDay = lastMonth.subtract(Duration(days: i * 5));
            DateTime currentDay = previousDay.subtract(const Duration(days: 5));

            return createdAt.isAfter(currentDay) &&
                createdAt.isBefore(previousDay);
          }).length;

          documentCounts1.add(count.toDouble());
        }

        // Fill in missing days with 0 count
        for (int i = 0; i < 7; i++) {
          if (i >= documentCounts.length) {
            documentCounts1.add(0.0);
          }
        }

        for (int j = 0; j < data1.length; j++) {
          watchtimesec +=
              (double.tryParse(data1[j]['watchtime'].toString()) ?? 0) / 3600;
        }

        final lastYear = DateTime(now.year - 1, now.month, now.day);
        const monthsInYear = 12;
        final months = List.generate((monthsInYear / 2).ceil(), (index) {
          return DateTime(
              lastYear.year, lastYear.month + (index * 2), lastYear.day);
        });

        for (int i = 0; i < months.length; i++) {
          int count = data2.where((element) {
            DateTime createdAt = DateTime.parse(element['createdAt']);
            DateTime previousMonth =
                DateTime(lastYear.year, lastYear.month + (i * 2), lastYear.day);
            DateTime currentMonth = DateTime(
                previousMonth.year, previousMonth.month - 2, previousMonth.day);

            return createdAt.isAfter(currentMonth) &&
                createdAt.isBefore(previousMonth);
          }).length;

          documentCounts2.add(count.toDouble());
        }

        // Fill in missing months with 0 count
        for (int i = 0; i < 6; i++) {
          if (i >= documentCounts2.length) {
            documentCounts2.add(0.0);
          }
        }

        for (int j = 0; j < data2.length; j++) {
          watchtimethird +=
              (double.tryParse(data2[j]['watchtime'].toString()) ?? 0) / 3600;
        }

        List<String> formattedDates = [];

        for (int i = 0; i < dates.length; i++) {
          DateTime previousMonth =
              DateTime(lastYear.year, lastYear.month + (i * 6), lastYear.day);
          DateTime currentMonth = DateTime(
              previousMonth.year, previousMonth.month - 6, previousMonth.day);
          double watchTimeSum = 0.0;

          for (int j = 0; j < data3.length; j++) {
            DateTime createdAt = DateTime.parse(data3[j]['createdAt']);
            if (createdAt.isAfter(currentMonth) &&
                createdAt.isBefore(previousMonth)) {
              watchTimeSum += 1.0;
            }
          }

          documentCounts3.add(watchTimeSum);
          String formattedDate = DateFormat('MMM yyyy').format(currentMonth);
          formattedDates.add(formattedDate);
        }
        for (int j = 0; j < data3.length; j++) {
          watchtimefourth +=
              (double.tryParse(data3[j]['watchtime'].toString()) ?? 0) / 3600;
        }
        for (int i = 0; i < dates.length; i++) {
          if (i >= documentCounts3.length) {
            documentCounts3.add(0.0);
          }
        }

        List<double> watchTimeSums1 = [];

        for (int i = 0; i < 7; i++) {
          DateTime currentDate = now.subtract(Duration(days: i));
          String currentDateString =
              DateFormat('yyyy-MM-dd').format(currentDate);
          double watchTimeSum = 0.0;

          for (int j = 0; j < data.length; j++) {
            String createdAtString = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(data[j]['createdAt']));

            if (createdAtString == currentDateString) {
              var number = (double.tryParse(data[j]['watchtime']) ?? 0) / 3600;
              watchTimeSum += double.parse(number.toStringAsFixed(2));
            }
          }

          watchTimeSums1.add(watchTimeSum);
        }

        for (int i = 0; i < 7; i++) {
          if (i >= watchTimeSums1.length) {
            watchTimeSums1.add(0.0);
          }
        }

        List<double> watchTimeSums2 = [];

        for (int i = 0; i < dates.length; i++) {
          DateTime previousDay = lastMonth.subtract(Duration(days: i * 5));
          DateTime currentDay = previousDay.subtract(const Duration(days: 5));
          double watchTimeSum = 0.0;

          for (int j = 0; j < data1.length; j++) {
            DateTime createdAt = DateTime.parse(data1[j]['createdAt']);

            if (createdAt.isAfter(currentDay) &&
                createdAt.isBefore(previousDay)) {
              var number = (double.tryParse(data1[j]['watchtime']) ?? 0) / 3600;
              watchTimeSum += double.parse(number.toStringAsFixed(2));
            }
          }

          watchTimeSums2.add(watchTimeSum);
        }
        for (int i = 0; i < dates.length; i++) {
          if (i >= watchTimeSums2.length) {
            watchTimeSums2.add(0.0);
          }
        }

        List<double> watchTimeSums3 = [];

        for (int i = 0; i < dates.length; i++) {
          DateTime previousMonth =
              DateTime(lastYear.year, lastYear.month + (i * 2), lastYear.day);
          DateTime currentMonth = DateTime(
              previousMonth.year, previousMonth.month - 2, previousMonth.day);
          double watchTimeSum = 0.0;

          for (int j = 0; j < data2.length; j++) {
            DateTime createdAt = DateTime.parse(data2[j]['createdAt']);

            if (createdAt.isAfter(currentMonth) &&
                createdAt.isBefore(previousMonth)) {
              var number = (double.tryParse(data2[j]['watchtime']) ?? 0) / 3600;
              watchTimeSum += double.parse(number.toStringAsFixed(2));
            }
          }

          watchTimeSums3.add(watchTimeSum);
        }
        for (int i = 0; i < dates.length; i++) {
          if (i >= watchTimeSums3.length) {
            watchTimeSums3.add(0.0);
          }
        }

        List<double> watchTimeSums4 = [];

        for (int i = 0; i < dates.length; i++) {
          DateTime previousMonth =
              DateTime(lastYear.year, lastYear.month + (i * 6), lastYear.day);
          DateTime currentMonth = DateTime(
              previousMonth.year, previousMonth.month - 6, previousMonth.day);
          double watchTimeSum = 0.0;

          for (int j = 0; j < data3.length; j++) {
            DateTime createdAt = DateTime.parse(data3[j]['createdAt']);

            if (createdAt.isAfter(currentMonth) &&
                createdAt.isBefore(previousMonth)) {
              watchTimeSum +=
                  (double.tryParse(data3[j]['watchtime']) ?? 0) / 3600;
            }
          }

          watchTimeSums4.add(double.parse(watchTimeSum.toStringAsFixed(2)));
        }
        for (int i = 0; i < dates.length; i++) {
          if (i >= watchTimeSums4.length) {
            watchTimeSums4.add(0.0);
          }
        }

        setState(() {
          views = data.length;
          viewssec = data1.length;
          viewsthird = data2.length;
          viewsfourth = data3.length;
          views0 = documentCounts.isNotEmpty ? documentCounts : views0;
          views1 = documentCounts1.isNotEmpty ? documentCounts1 : views1;
          views2 = documentCounts2.isNotEmpty ? documentCounts2 : views2;
          views3 = documentCounts3.isNotEmpty ? documentCounts3 : views3;
          alltime = formattedDates.isNotEmpty ? formattedDates : alltime;

          watchtime0 = watchTimeSums1.isNotEmpty ? watchTimeSums1 : watchtime0;
          watchtime1 = watchTimeSums2.isNotEmpty ? watchTimeSums2 : watchtime1;
          watchtime2 = watchTimeSums3.isNotEmpty ? watchTimeSums3 : watchtime2;
          watchtime3 = watchTimeSums4.isNotEmpty ? watchTimeSums4 : watchtime3;
        });
      }
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var wallet = prefs.getString('wallet_address') ?? '';
      var userId = prefs.getString('userId') ?? '';
      var response4 = await http.get(
          Uri.parse('https://account.cratch.io/api/users/$wallet'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });
      var data4 = jsonDecode(response4.body);
      if (data4 is Map && !data4.containsKey('status')) {
        setState(() {
          tokens = data4['rewards'].toInt() ?? 0;
          followers = data4['followers'].length;
          followersData = [
            0,
            0,
            0,
            double.tryParse(data4['followers'].length.toString()) ?? 0,
            0,
            0
          ];
        });
      }

      var response5 = await http.get(
          Uri.parse('https://account.cratch.io/api/video/user/$userId/$wallet'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          });
      var data5 = jsonDecode(response5.body);
      if (data5 is List && data5.isNotEmpty) {
        setState(() {
          latestVideo = data5[0];
        });
      }
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastSevenDays = List.generate(7, (index) {
      final previousDay = now.subtract(Duration(days: index));
      return DateFormat('dd MMM').format(previousDay);
    });

    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    final daysInMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
    final dates = List.generate((daysInMonth / 5).ceil(), (index) {
      final previousDay = lastMonth.subtract(Duration(days: index * 5));
      return DateFormat('dd MMM').format(previousDay);
    });

    List<String> monthNames = [];

    for (int i = 1; i <= 12; i += 2) {
      DateTime monthDate = DateTime(now.year, i);
      String monthName = DateFormat('MMMM').format(monthDate);
      monthNames.add(monthName);
    }
    return DrawerWithNavBar(
      screen: DefaultTabController(
        length: 4,
        initialIndex: tab,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.scaflodbgcolor,
                AppColors.scaflodbgcolor,
                AppColors.scaflodbgcolor,
              ],
            ),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: const TopBar(),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // CustomSizedBoxHeight(height: 30.h),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.scaflodbgcolor,
                          AppColors.scaflodbgcolor,
                          const Color(0xff27283C),
                          const Color(0xff27283C),
                          const Color(0xff27283C)
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      )),
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 21.w, right: 18.w, top: 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Channel analytics",
                          style: TextStyle(
                            fontSize: 17.h,
                            fontWeight: FontWeight.w700,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: <Color>[
                                  AppColors.txtGradient1,
                                  AppColors.txtGradient2
                                  //add more color here.
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
                        CustomSizedBoxHeight(height: 30.h),
                        Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.fieldUnActive,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.offwhite,
                              indicatorColor: Colors.white,
                              indicator: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(60, 21, 122, 0.58),
                                    offset: Offset(3.0, 1.0),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  transform:
                                      GradientRotation(105.38 * 3.14 / 180),
                                  colors: [
                                    Color(0xFF49149D),
                                    Color(0xFFA57AE9),
                                  ],
                                  stops: [0.0713, 1.0],
                                ),
                              ),
                              tabs: [
                                GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(0);
                                    },
                                    child: const Center(child: Text('Week'))),
                                GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(1);
                                    },
                                    child: const Center(child: Text('Month'))),
                                GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(2);
                                    },
                                    child: const Center(child: Text('Year'))),
                                GestureDetector(
                                  onTap: () {
                                    _tabController.animateTo(3);
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Lifetime',
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        SizedBox(
                          height: 410,
                          child: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 23.h,
                                    ),
                                    Row(
                                      children: [
                                        selected == 0
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                            AppImages.logopng,
                                                            height: 25,
                                                            width: 25,
                                                          )),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: '0'),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Channel views'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 0;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          views.toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Channel views',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 1
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: watchtime
                                                              .toStringAsFixed(
                                                                  2)),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Watch time(hours)'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 1;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          watchtime
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Watch time(hours)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 2
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: '+$followers'),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title: 'Followers'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 2;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '+$followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Sparkline(
                                      fallbackWidth: 453.w,
                                      data: selected == 0
                                          ? views0
                                          : selected == 1
                                              ? watchtime0
                                              : followersData,
                                      // backgroundColor: Colors.red,
                                      lineColor: Colors.indigoAccent,
                                      fillMode: FillMode.below,
                                      fillColor: Colors.green.withOpacity(.3),
                                      pointsMode: PointsMode.all,
                                      pointSize: 12.0,
                                      pointColor: Colors.indigo,
                                      useCubicSmoothing: true,
                                      lineWidth: 1.5,
                                      gridLinelabelPrefix: '\$',
                                      gridLineLabelPrecision: 3,
                                      enableGridLines: false,
                                      averageLine: false,
                                      averageLabel: false,
                                      kLine: const [
                                        'max',
                                        'min',
                                        'first',
                                        'last'
                                      ],
                                      // max: 50.5,
                                      // min: 10.0,
                                      enableThreshold: true,
                                      thresholdSize: 0.5,
                                      lineGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.mainColor,
                                          AppColors.indigoAccent,
                                        ],
                                      ),
                                      fillGradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xff373953),
                                          Color(0xff373953)
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (final day
                                            in lastSevenDays.reversed)
                                          Text(
                                            day.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: const Color(0xff848484)),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 23.h,
                                    ),
                                    Row(
                                      children: [
                                        selected == 0
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: viewssec
                                                              .toString()),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Channel views'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 0;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          viewssec.toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Channel views',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 3
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: watchtimesec
                                                              .toStringAsFixed(
                                                                  2)),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Watch time(hours)'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 3;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          watchtimesec
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Watch time(hours)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 4
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle16Bold600,
                                                        title: '+$followers',
                                                      ),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title: 'Followers'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 4;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '+$followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Sparkline(
                                      fallbackWidth: 453.w,
                                      data: selected == 0
                                          ? views1
                                          : selected == 3
                                              ? watchtime1
                                              : followersData,
                                      // backgroundColor: Colors.red,
                                      lineColor: Colors.indigoAccent,
                                      fillMode: FillMode.below,
                                      fillColor: Colors.green.withOpacity(.3),
                                      pointsMode: PointsMode.all,
                                      pointSize: 12.0,
                                      pointColor: Colors.indigo,
                                      useCubicSmoothing: true,
                                      lineWidth: 1.5,
                                      gridLinelabelPrefix: '\$',
                                      gridLineLabelPrecision: 3,
                                      enableGridLines: false,
                                      averageLine: false,
                                      averageLabel: false,
                                      kLine: const [
                                        'max',
                                        'min',
                                        'first',
                                        'last'
                                      ],
                                      // max: 50.5,
                                      // min: 10.0,
                                      enableThreshold: true,
                                      thresholdSize: 0.5,
                                      lineGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.mainColor,
                                          AppColors.indigoAccent,
                                        ],
                                      ),
                                      fillGradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xff373953),
                                          Color(0xff373953)
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (final date in dates.reversed)
                                          Text(
                                            date.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: const Color(0xff848484)),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 23.h,
                                    ),
                                    Row(
                                      children: [
                                        selected == 0
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: viewsthird
                                                              .toString()),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Channel views'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 0;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          viewsthird.toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Channel views',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 5
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: watchtimethird
                                                              .toStringAsFixed(
                                                                  2)),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Watch time(hours)'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 5;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          watchtimethird
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Watch time(hours)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 6
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle16Bold600,
                                                        title: '+$followers',
                                                      ),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title: 'Followers'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 6;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '+$followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Sparkline(
                                      fallbackWidth: 453.w,
                                      data: selected == 0
                                          ? views2
                                          : selected == 5
                                              ? watchtime2
                                              : followersData,
                                      // backgroundColor: Colors.red,
                                      lineColor: Colors.indigoAccent,
                                      fillMode: FillMode.below,
                                      fillColor: Colors.green.withOpacity(.3),
                                      pointsMode: PointsMode.all,
                                      pointSize: 12.0,
                                      pointColor: Colors.indigo,
                                      useCubicSmoothing: true,
                                      lineWidth: 1.5,
                                      gridLinelabelPrefix: '\$',
                                      gridLineLabelPrecision: 3,
                                      enableGridLines: false,
                                      averageLine: false,
                                      averageLabel: false,
                                      kLine: const [
                                        'max',
                                        'min',
                                        'first',
                                        'last'
                                      ],
                                      // max: 50.5,
                                      // min: 10.0,
                                      enableThreshold: true,
                                      thresholdSize: 0.5,
                                      lineGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.mainColor,
                                          AppColors.indigoAccent,
                                        ],
                                      ),
                                      fillGradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xff373953),
                                          Color(0xff373953)
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (final date in monthNames)
                                          Text(
                                            date.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: const Color(0xff848484)),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 23.h,
                                    ),
                                    Row(
                                      children: [
                                        selected == 0
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: viewsfourth
                                                              .toString()),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Channel views'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 0;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          viewsfourth
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Channel views',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 7
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle16Bold600,
                                                          title: watchtimefourth
                                                              .toStringAsFixed(
                                                                  2)),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title:
                                                              'Watch time(hours)'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 7;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          watchtimefourth
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          'Watch time(hours)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: 11.w,
                                        ),
                                        selected == 8
                                            ? Container(
                                                height: 128.h,
                                                width: 103.w,
                                                decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            165, 81, 191, 0.37),
                                                        offset:
                                                            Offset(0.0, 4.0),
                                                        blurRadius: 12.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            AppImages.shape),
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Image.asset(
                                                              AppImages.logopng,
                                                              height: 25,
                                                              width: 25)),
                                                      CustomSizedBoxHeight(
                                                          height: 30),
                                                      CustomText(
                                                        textStyle: AppStyle
                                                            .textStyle16Bold600,
                                                        title: '+$followers',
                                                      ),
                                                      CustomText(
                                                          textStyle: AppStyle
                                                              .textStyle8White600,
                                                          title: 'Followers'),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            const BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.58),
                                                                      Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.33),
                                                                    ],
                                                                    stops: [
                                                                      0.1281,
                                                                      0.8983
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    transform:
                                                                        GradientRotation(262 *
                                                                            (pi /
                                                                                180))),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                        child: Text(
                                                          tokens > 0
                                                              ? "+$tokens CRTC"
                                                              : "$tokens CRTC",
                                                          style: AppStyle
                                                              .textStyle8White600
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xFFE2DFDF)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 8;
                                                  });
                                                },
                                                child: Container(
                                                  height: 128.h,
                                                  width: 103.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff373953),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '+$followers',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                        Text(
                                                          "Followers",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: const Color(
                                                                  0xff848484)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Sparkline(
                                      fallbackWidth: 453.w,
                                      data: selected == 0
                                          ? views3
                                          : selected == 7
                                              ? watchtime3
                                              : followersData,
                                      // backgroundColor: Colors.red,
                                      lineColor: Colors.indigoAccent,
                                      fillMode: FillMode.below,
                                      fillColor: Colors.green.withOpacity(.3),
                                      pointsMode: PointsMode.all,

                                      pointSize: 12.0,
                                      pointColor: Colors.indigo,
                                      useCubicSmoothing: true,
                                      lineWidth: 1.5,
                                      gridLinelabelPrefix: '\$',
                                      gridLineLabelPrecision: 3,
                                      enableGridLines: false,
                                      averageLine: false,
                                      averageLabel: false,
                                      kLine: const [
                                        'max',
                                        'min',
                                        'first',
                                        'last'
                                      ],
                                      // max: 50.5,
                                      // min: 10.0,
                                      enableThreshold: true,
                                      thresholdSize: 0.5,
                                      lineGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.mainColor,
                                          AppColors.indigoAccent,
                                        ],
                                      ),

                                      fillGradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xff373953),
                                          Color(0xff373953)
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (final day in alltime)
                                          Text(
                                            day.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: const Color(0xff848484)),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.h,
                ),
                Container(
                  width: 372.w,
                  height: 265.h,
                  margin: const EdgeInsets.only(bottom: 50),
                  decoration: const BoxDecoration(
                      color: Color(0xff27283C),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 5),
                          child: Text(
                            'Latest video',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: const Color(0xff848484)),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        latestVideo.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: latestVideo['thumbnail'].length >
                                              100
                                          ? Image.memory(base64Decode(
                                              latestVideo['thumbnail']
                                                  .substring(
                                                      latestVideo['thumbnail']
                                                              .indexOf(',') +
                                                          1),
                                            ))
                                          : Image.network(
                                              latestVideo['thumbnail'])),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      latestVideo['title'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Color.fromARGB(
                                              255, 223, 223, 223),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(AppImages.gamingImage3)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
