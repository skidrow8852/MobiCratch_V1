import 'package:flutter/foundation.dart';

class FollowingProvider with ChangeNotifier {
  List<dynamic> followings = [];

  void setFollowings(List<dynamic> value) {
    followings = value;
    notifyListeners();
  }

  void addFollowings(String value) {
    followings.add(value);
    notifyListeners();
  }

  void removeFollowings(String id) {
    followings.removeWhere((value) => value == id);
    notifyListeners();
  }
}
