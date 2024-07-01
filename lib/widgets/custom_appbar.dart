import 'dart:convert';
import 'package:cratch/Provider/Avatar_provider.dart';
import 'package:cratch/Provider/notifications_provider.dart';
import 'package:cratch/View/Search/Search_View.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cratch/Utils/image_constant.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import '../View/Notification/Notification.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget {
  Function() searchOntap;
  Function()? notificationOntap;
  Function()? settingOntap;
  Function()? profileOntap;
  Map<String, dynamic> alluserData = {};
  CustomAppBar(
      {Key? key,
      this.notificationOntap,
      this.profileOntap,
      required this.searchOntap,
      this.settingOntap})
      : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void dispose() {
    super.dispose();
  }

  IO.Socket? socket;
  String alluserData = "";
  bool isNotification = false;
  int unreadCount = 0;

  void initializeSocket(String serverHost, String wallet) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';

    socket = IO.io(
      serverHost,
      IO.OptionBuilder().setTransports(['websocket', 'polling']).setQuery(
          {'token': token}).build(),
    );

    socket?.on('notif', (data) {
      if (data['to'].toLowerCase() == wallet.toLowerCase()) {
        setState(() {
          unreadCount++;
          isNotification = true;
        });

        final notificationState =
            Provider.of<NotificationProvider>(context, listen: false);
        notificationState.unreadCount = unreadCount;
        notificationState.setNotification(true);
        notificationState.setUnreadCount(unreadCount);
      }
    });
  }

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? address = prefs.getString('wallet_address');
      String? token = prefs.getString('token');
      String? avatar = prefs.getString('avatar');
      String? userId = prefs.getString('userId');

      if (avatar == null || userId == null) {
        final response = await http.get(
          Uri.parse(
              'https://account.cratch.io/api/users/profile/${address?.toLowerCase()}/${address?.toLowerCase()}'),
          headers: {'Authorization': 'Bearer $token'},
        );

        final userData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          await prefs.setString('avatar', userData['ProfileAvatar']);
          await prefs.setString('userId', userData['_id']);
          final avatarstate =
              Provider.of<AvatarProvider>(context, listen: false);
          avatarstate.setAvatar(userData['ProfileAvatar'] ?? "");
          getNotif(address ?? "", token ?? "");
        }
      } else {
        final avatarstate = Provider.of<AvatarProvider>(context, listen: false);
        avatarstate.setAvatar(prefs.getString('avatar') ?? "");

        getNotif(address ?? "", token ?? "");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getNotif(String wallet, String tok) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://account.cratch.io/api/notifications/${wallet.toLowerCase()}'),
        headers: {'Authorization': 'Bearer $tok'},
      );
      final data = jsonDecode(response.body);
      if (data != null && response.statusCode == 200) {
        for (var notif in data) {
          if (!notif['isRead']) {
            setState(() {
              unreadCount++;
              isNotification = true; // Data fetching complete
            });
            final notificationState =
                Provider.of<NotificationProvider>(context, listen: false);
            notificationState.unreadCount = unreadCount;
            notificationState.setNotification(true);
            notificationState.setUnreadCount(unreadCount);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    SharedPreferences.getInstance().then((prefs) {
      String? address = prefs.getString('wallet_address');
      initializeSocket("https://account.cratch.io/", address ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = Provider.of<NotificationProvider>(context);
    final avatarstate = Provider.of<AvatarProvider>(context);
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 18),
          child: IconButtonWidget(
            ontap: () {
              ZoomDrawer.of(context)!.open();
            },
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(251, 91, 120, 1),
                Color.fromRGBO(255, 65, 99, 0.53),
              ],
              stops: [0.0462, 0.8846],
              transform: GradientRotation(16.7 * 3.1415927 / 180),
            ),
            height: 35,
            width: 35,
            widget: const Icon(
              Icons.menu,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: IconButtonWidget(
              ontap: () {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: const Search(), withNavBar: false);
              },
              height: 35,
              width: 35,
              widget: SvgPicture.asset(AppImages.searchSvg)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 9, right: 8),
          child: Stack(
            children: [
              IconButtonWidget(
                ontap: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: const NotificationView(), withNavBar: false);
                  if (unreadCount > 0) {
                    setState(() {
                      unreadCount = 0;
                      isNotification = false; // Reset unread count
                    });
                    notificationState.setNotification(false);
                    notificationState.setUnreadCount(0);
                  }
                },
                height: 35,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(122, 91, 253, 0.15),
                    Color.fromRGBO(122, 91, 253, 1),
                  ],
                  stops: [0.1083, 1.0199],
                  transform: GradientRotation(21.5 * 3.1415927 / 180),
                ),
                width: 35,
                widget: const Icon(
                  Icons.notifications,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              if (isNotification && notificationState.isNotification == true)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(251, 91, 120, 1),
                          Color.fromRGBO(255, 65, 99, 0.53),
                        ],
                        stops: [0.0462, 0.8846],
                        transform: GradientRotation(16.7 * 3.1415927 / 180),
                      ),
                    ),
                    child: Text(
                      notificationState.unreadCount > 9
                          ? '9+'
                          : notificationState.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // ...

        Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 9, right: 11),
          child: IconButtonWidget(
            ontap: widget.settingOntap!,
            height: 35,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(249, 206, 53, 1),
                Color.fromRGBO(233, 141, 2, 0.72),
              ],
              stops: [0.1022, 0.9375],
              transform: GradientRotation(27.32 * 3.1415927 / 180),
            ),
            width: 35,
            widget: const Icon(
              Icons.settings,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: IconButtonWidget(
            ontap: widget.profileOntap!,
            height: 36,
            width: 40,
            widget: Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(
                    avatarstate.avatar,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
