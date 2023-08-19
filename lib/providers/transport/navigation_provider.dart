import 'package:flutter/material.dart';

class NavigationProviderTransport extends ChangeNotifier {
  int index = 0;
  String nameWindow = "Welcome";
  changeIndex(int newIndex, String newName) {
    index = newIndex;
    nameWindow = newName;
    notifyListeners();
  }
}
