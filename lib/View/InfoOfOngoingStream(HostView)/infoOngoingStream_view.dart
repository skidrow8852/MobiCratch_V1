import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/View/TopBar/TopBar.dart';
import 'package:get/get.dart';
import '../../Utils/color_constant.dart';
import '../../widgets/GradientTextWidget.dart';
import 'Components/chat_screen.dart';
import 'Components/tabBarInfoScreen.dart';

class InfoOngoingStreamView extends StatefulWidget {
  final dynamic details;
  const InfoOngoingStreamView({Key? key, required this.details})
      : super(key: key);

  @override
  State<InfoOngoingStreamView> createState() => _InfoOngoingStreamViewState();
}

class _InfoOngoingStreamViewState extends State<InfoOngoingStreamView> {
  get tabController => null;
  bool loading = false;
  bool isVisible2 = false;

  @override
  Widget build(BuildContext context) {
    return DrawerWithNavBar(
      screen: Scaffold(
        // extendBodyBehindAppBar: true,
        backgroundColor: AppColors.bgGradient2,
        appBar: const TopBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Row(
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.to(() => const DashBoardScreen());
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.mainColor,
                        )),
                    GradientTextWidget(
                      text: 'Stream Details',
                      size: 17.h,
                    )
                  ],
                ),
              ),
              DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TabBar(
                      labelColor: Colors.white,
                      // unselectedLabelColor: Colors.black,
                      unselectedLabelStyle: TextStyle(
                        color: AppColors.whiteA700,
                      ),
                      labelPadding: const EdgeInsets.all(10),
                      labelStyle: TextStyle(
                          foreground: Paint()
                            ..shader = LinearGradient(
                              tileMode: TileMode.repeated,
                              colors: [
                                AppColors.redAccsent,
                                AppColors.mainColor,
                                AppColors.mainColor,
                                AppColors.txtGradient4,
                                AppColors.txtGradient4,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                            ),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700),
                      controller: tabController,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.redAccsent,
                              AppColors.mainColor,
                              AppColors.bgGradient3,
                            ],
                          )),
                      indicatorPadding: const EdgeInsets.only(
                          left: 65, right: 65, bottom: 20, top: 44),
                      tabs: const [
                        Tab(
                          text: 'Information',
                        ),
                        Tab(text: 'Stream chat'),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.78,
                      child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: tabController,
                        children: [
                          ///Information
                          TabBarInfoScreen(details: widget.details),

                          ///Stream Chat

                          ChatScreen(liveId: widget.details['_id'])
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
