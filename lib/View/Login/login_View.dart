import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cratch/BottomNavBar.dart';
import 'package:cratch/Provider/Contract_factory_provider.dart';
import 'package:cratch/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cratch/Utils/app_style.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:cratch/widgets/Sizebox/sizedboxheight.dart';
import 'package:cratch/widgets/customtext.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/GradientTextWidget.dart';
import '../../widgets/customButton.dart';
import 'package:cratch/widgets/LoginView/modal.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isModalVisible = false;
  bool _isLoading = false;
  // ignore: prefer_typing_uninitialized_variables
  var _Appuri, _session, signClient, response;

  Future<void> _storeWalletAddress(String? address, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_address', "$address");
    await prefs.setString('token', "$token");
  }

  String currentVersion = ""; // Variable to store the current app version
  String latestVersion = ""; // Variable to store the latest app version

  void checkForUpdate() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
        latestVersion = await fetchLatestVersion();
        if (latestVersion.isNotEmpty && currentVersion != latestVersion) {
          showUpdateDialog(); // Display a dialog or custom screen
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> fetchLatestVersion() async {
    try {
      final response = await http.get(
          Uri.parse('https://account.cratch.io/api/users/version'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          });
      String value = json.decode(response.body)['version'];
      return value;
    } catch (e) {
      return "1.2.0";
    }
  }

  void showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF0F0B1F), // Set background color to transparent
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius
          ),
          content: Container(
            width: 400,
            height: 180,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/update.png'), // Replace with your own image path
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 25.0, bottom: 16.0),
                  child: Text(
                    'Update Available',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Inter, sans-serif",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 8, 16, 16),
                  child: Text(
                    'A new version of the app is available. Please update to the latest version.',
                    style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        height: 1.3,
                        fontFamily: "Inter, sans-serif",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 25.0), // Adjust the padding as needed
                    child: TextButton(
                      onPressed: () {
                        launchAppStore(); // Open the Google Play Store or App Store
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF337FFF),
                            fontFamily: "Inter, sans-serif"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void launchAppStore() async {
    const url =
        "https://play.google.com/store/apps/details?id=io.cratch.myapp"; // Provide the URL of your app in the Google Play Store or App Store
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  Future<void> handleUser(String? wallet, String? token) async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/users/${wallet?.toLowerCase()}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          });

      if ((jsonDecode(response.body) as Map<String, dynamic>)
          .containsKey('status')) {
        var values = {
          "userId": "${wallet?.toLowerCase()}",
          "username": "${wallet?.toLowerCase()}",
          "isOnline": true
        };
        var response = await http.post(
            Uri.parse('https://account.cratch.io/api/users/add'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Connection': 'keep-alive'
            },
            body: json.encode(values));
        var data = json.decode(response.body);
        if (response.statusCode == 200 && data.length > 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data?['_id'].toString() ?? "");

          /// the code logic, redirect to home page
          Get.to(() => const DashBoardScreen());
          return;
        }
      } else {
        Get.to(() => const DashBoardScreen());
        return;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> getToken(String wallet, String? publicKey, String? topic) async {
    setState(() {
      _isLoading = true;
    });
    const url =
        'https://account.cratch.io/api'; // Replace with your actual API URL

    try {
      final response = await http.post(Uri.parse('$url/users/login/mbldata'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive'
          },
          body: json.encode(
              {"wallet": wallet, "publicKey": publicKey, "topic": topic}));
      final result = json.decode(response.body);

      if ((jsonDecode(response.body) as Map<String, dynamic>)
          .containsKey('token')) {
        await _storeWalletAddress(wallet.toLowerCase(), result['token'] ?? "");
        await handleUser(wallet.toLowerCase(), result['token'] ?? "");
        setState(() {
          _isLoading = false;
        });
      } else {
        /// the code logic, redirect to home page
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
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
    }
  }

  void _toggleModalVisibility() {
    setState(() {
      _isModalVisible = !_isModalVisible;
    });
  }

  void _handleTap() {
    if (_isModalVisible) {
      setState(() {
        _isModalVisible = false;
      });
    }
  }

  SignInstanceCreate() async {
    signClient = await SignClient.createInstance(
      projectId: walletConnectId,
      metadata: const PairingMetadata(
        name: 'Cratch',
        description: 'Sign in using your Wallet',
        url: 'https://cratch.io',
        icons: ['https://cratch.io/logo.png'],
      ),
    );
  }

  getUri() async {
    response = await signClient.connect(requiredNamespaces: {
      'eip155': const RequiredNamespace(
          chains: ['eip155:361'], //
          methods: ['personal_sign'], //
          events: []),
    });

    Uri? uri = response.uri;
    _Appuri = uri.toString();
  }

  void handleException(BuildContext context, dynamic e) {
    if (e is PlatformException && e.code == 'ACTIVITY_NOT_FOUND') {
      // Handle the specific exception
      showMetaMaskWarning(context);
    } else {
      // Handle other exceptions
      print(e);
      // Handle other exceptions as needed, e.g., show a generic error message
    }
  }

  launchWithMetamask(BuildContext context) async {
    try {
      await getUri();
      await launchUrlString(_Appuri, mode: LaunchMode.externalApplication);

      _session = await response.session.future;
      final sess = Provider.of<ContractFactory>(context, listen: false);
      sess.setSession(_session);

      signClient.onSessionConnect.subscribe((SessionConnect? session) {
        if (session != null) {
          String consoleOutput = session.toString();
          RegExp publicKeyRegex = RegExp(r'publicKey: ([a-fA-F0-9]+)');
          RegExp topicRegex = RegExp(r'topic: ([a-fA-F0-9]+)');

          // Extract publicKey
          String? publicKey =
              publicKeyRegex.firstMatch(consoleOutput)?.group(1);

          // Extract topic
          String? topic = topicRegex.firstMatch(consoleOutput)?.group(1);

          String accountsSection =
              consoleOutput.split("accounts: [")[1].split("]")[0];
          List<String> accounts = accountsSection.split(", ");

          String firstAccountAddress =
              accounts[0].split(":")[2].replaceAll("'", "");

          if (firstAccountAddress.length > 2) {
            getToken(firstAccountAddress, publicKey, topic);
          }
        }
      });
    } catch (e) {
      handleException(context, e);
    }
  }

  launchWithWalletConnect(BuildContext context) async {
    await getUri();
    _toggleModalVisibility();

    _session = await response.session.future;

    if (_session != null) _toggleModalVisibility();
    final sess = Provider.of<ContractFactory>(context, listen: false);
    sess.setSession(_session);

    signClient.onSessionConnect.subscribe((SessionConnect? session) {
      if (session != null) {
        String consoleOutput = session.toString();
        // String controllerValue =
        //     consoleOutput.split("controller: ")[1].split(",")[0];
        RegExp publicKeyRegex = RegExp(r'publicKey: ([a-fA-F0-9]+)');
        RegExp topicRegex = RegExp(r'topic: ([a-fA-F0-9]+)');

// Extract publicKey
        String? publicKey = publicKeyRegex.firstMatch(consoleOutput)?.group(1);

// Extract topic
        String? topic = topicRegex.firstMatch(consoleOutput)?.group(1);
        String accountsSection =
            consoleOutput.split("accounts: [")[1].split("]")[0];
        List<String> accounts = accountsSection.split(", ");

        String firstAccountAddress =
            accounts[0].split(":")[2].replaceAll("'", "");

        // print(controllerValue);
        if (firstAccountAddress.length > 2) {
          getToken(firstAccountAddress, publicKey, topic);
        }
      }
    });
  }

  void showMetaMaskWarning(BuildContext context) async {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        backgroundColor: const Color(0xFF532B48),
        borderRadius: BorderRadius.circular(5),
        iconPositionLeft: 12,
        iconRotationAngle: 0,
        message:
            "MetaMask is not installed. Please download MetaMask from the Google Play Store.",
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SignInstanceCreate();
      setState(() {});
    });
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(AppImages.newbg),
                fit: BoxFit.fill,
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Image.asset(
                        AppImages.logoname,
                        width: 150,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          GradientTextWidget(
                            size: 25,
                            text: 'Login',
                          ),
                          CustomSizedBoxHeight(height: 20.h),
                          CustomText(
                            textStyle: AppStyle.textStyle13Regular,
                            title:
                                'This party’s just getting started! Sign in to\n join the fun. ',
                            textAlign: TextAlign.center,
                            maxline: 2,
                          ),
                          CustomSizedBoxHeight(height: 20),
                          CustomButton(
                              width: double.infinity,
                              ontap: () => {launchWithMetamask(context)},
                              image: AppImages.metamask,
                              title: 'MetaMask',
                              AppStyle: AppStyle.textStyle14whiteSemiBold,
                              // color: AppColors.mainColor,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.mainColor.withOpacity(0.4),
                                  AppColors.indigo.withOpacity(0.4),
                                  AppColors.indigo.withOpacity(0.4),
                                ],
                              )),
                          CustomSizedBoxHeight(height: 20.h),
                          CustomButton(
                              width: double.infinity,
                              ontap: () => {launchWithWalletConnect(context)},
                              AppStyle: AppStyle.textStyle14whiteSemiBold,
                              image: AppImages.walletconnectpng,
                              title: 'WalletConnect',
                              // color: AppColors.mainColor,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.mainColor.withOpacity(0.4),
                                  AppColors.indigo.withOpacity(0.4),
                                  AppColors.indigo.withOpacity(0.4),
                                ],
                              )),
                          CustomSizedBoxHeight(height: 20.h),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isModalVisible)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: WalletConnectModal(
                    uri: _Appuri,
                  ),
                ),
              ),
            if (_isLoading) // Conditionally show the loading indicator
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black
                        .withOpacity(0.5), // Semi-transparent black background
                  ),
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue), // Blue color for the loader
                    ),
                  ),
                  // Your existing content
                  // ...
                ],
              ),
          ],
        ),
      ),
    );
  }
}
