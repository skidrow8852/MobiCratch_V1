import 'package:flutter/foundation.dart';

class AvatarProvider with ChangeNotifier {
  String avatar = "";

  void setAvatar(String value) {
    avatar = value;
    notifyListeners();
  }
}
