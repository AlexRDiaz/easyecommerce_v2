import 'package:flutter/material.dart';

class NavigationProviderOperator extends ChangeNotifier {
  int index = 0;
  String nameWindow = "Welcome";
  changeIndex(int newIndex, String newName) {
    index = newIndex;
    nameWindow = newName;
    notifyListeners();
  }
}
