import 'package:cratch/Provider/EditNfts_provider.dart';
import 'package:cratch/Provider/favorites_provider.dart';
import 'package:cratch/Provider/uploadVideo.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'BottomNavBar.dart';
import 'Provider/notifications_provider.dart';
import 'View/Login/login_View.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    wallet: prefs.getString('wallet_address') ?? "",
    token: prefs.getString('token') ?? "",
  ));
}

class MyApp extends StatefulWidget {
  final String wallet;
  final String token;

  const MyApp({
    Key? key,
    required this.token,
    required this.wallet,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    String yourToken = widget.token;

    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(375, 713),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UploadVideoProvider()),
            ChangeNotifierProvider(create: (_) => EditNftsProvider()),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MobiCratch',
            theme: ThemeData(
              // Override the button theme colors
              primarySwatch: Colors.blue,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            home: (widget.wallet == "" ||
                    widget.token == "" ||
                    JwtDecoder.isExpired(yourToken))
                ? const LoginView()
                : const DashBoardScreen(),
          ),
        );
      },
    );
  }
}
