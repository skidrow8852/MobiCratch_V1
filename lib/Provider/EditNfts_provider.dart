import 'package:flutter/foundation.dart';

class EditNftsProvider with ChangeNotifier {
  List<dynamic> allVideos = [];

  void setEditNfts(List<dynamic> value) {
    allVideos = value;
    notifyListeners();
  }

  void addEditNfts(Map<String, dynamic> value) {
    allVideos.add(value);
    notifyListeners();
  }

  void editNfts(String id, int data) {
    int index = allVideos.indexWhere((value) => value['_id'] == id);
    allVideos[index]['price'] = data;
    notifyListeners();
  }
}
