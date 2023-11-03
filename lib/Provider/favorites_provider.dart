import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  List<dynamic> allVideos = [];

  void setFavorites(List<dynamic> value) {
    allVideos = value;
    notifyListeners();
  }

  void addFavorites(Map<String, dynamic> value) {
    allVideos.add(value);
    notifyListeners();
  }

  void removeFavorites(String id) {
    allVideos.removeWhere((value) => value['_id'] == id);
    notifyListeners();
  }
}
