import 'package:flutter/foundation.dart';

class UploadVideoProvider with ChangeNotifier {
  List<dynamic> allVideos = [];

  void setUploadVideo(List<dynamic> value) {
    allVideos = value;
    notifyListeners();
  }

  void addUploadVideo(Map<String, dynamic> value) {
    allVideos.add(value);
    notifyListeners();
  }

  void editUploadVideo(String id, Map<String, dynamic> data) {
    int index = allVideos.indexWhere((value) => value['_id'] == id);
    Map<String, dynamic> existingData = allVideos[index];

    // Update existingData with the new values from data
    data.forEach((key, value) {
      existingData[key] = value;
    });

    allVideos[index] = existingData;
    notifyListeners();
  }
}
