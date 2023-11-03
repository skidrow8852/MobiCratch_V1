import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import '../../Utils/app_style.dart';
import '../../Utils/color_constant.dart';
import 'NFT_View/NftView.dart';
import 'Token_View/Token_view.dart';
import 'dart:ui';

// ignore: must_be_immutable
class BottomSheetView extends StatelessWidget {
  final String wallet;
  BottomSheetView({Key? key, this.onTapNft, required this.wallet})
      : super(key: key);

  get tabController => null;
  Function()? onTapNft;

  @override
  Widget build(BuildContext context) {
    final screenHeight = window.physicalSize.height / window.devicePixelRatio;
    return Container(
      padding: const EdgeInsets.only(top: 5),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF262848),
              Color(0xFF151624),
            ],
            stops: [0.0, 1.0],
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      height: screenHeight * 0.8,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
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
                    containerColor: const Color.fromRGBO(0, 0, 0, 0.41),
                    widget: const Icon(
                      Icons.clear,
                      color: Color(0xffD699CE),
                      size: 18,
                      weight: 10,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 20,
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
                CustomSizedBoxHeight(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Your support can make a difference',
                    style: AppStyle.textStyle11SemiBoldBlack,
                  ),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: DefaultTabController(
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
                                    AppColors.mainColor,
                                    AppColors.mainColor,
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0.0, 0.0, 150.0, 70.0),
                                ),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            controller: tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.mainColor,
                            ),
                            indicatorPadding: const EdgeInsets.only(
                              left: 30,
                              right: 30,
                              bottom: 10,
                              top: 55,
                            ),
                            tabs: const [
                              Tab(
                                text: 'Token',
                              ),
                              Tab(
                                text: 'NFT',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.6,
                            child: TabBarView(
                              physics: const BouncingScrollPhysics(),
                              controller: tabController,
                              children: [
                                ///Token
                                SelectableContainer(),

                                ///Nft
                                NFTView(
                                  wallet: wallet,
                                  onTapNft: onTapNft!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //////////////////////////////////
              ],
            ),
          ],
        ),
      ),
    );
  }
}
