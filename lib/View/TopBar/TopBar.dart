import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cratch/View/Profile/profile_view.dart';
import 'package:cratch/View/Settings/settings_view.dart';
import 'package:cratch/widgets/custom_appbar.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
  });
  @override
  Size get preferredSize => const Size.fromHeight(56.0);
  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: double.infinity,
      leading: CustomAppBar(
        searchOntap: () {},
        settingOntap: () {
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: const SettingsView(), withNavBar: true);
        },
        profileOntap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? address = prefs.getString('wallet_address');
          String? token = prefs.getString('token');
          // ignore: use_build_context_synchronously
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: ProfileView(
                wallet: address?.toLowerCase() ?? '',
                token: token ?? '',
              ),
              withNavBar: true);
        },
        notificationOntap: () {},
      ),
    );
  }
}
