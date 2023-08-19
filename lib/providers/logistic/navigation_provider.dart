import 'package:flutter/material.dart';

class NavigationProviderLogistic extends ChangeNotifier {
  int index = 0;
  String nameWindow = "Welcome";
  changeIndex(int newIndex, String newName) {
    index = newIndex;
    nameWindow = newName;
    notifyListeners();
  }
}
