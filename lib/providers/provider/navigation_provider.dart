import 'package:flutter/material.dart';

class NavigationProviderProvider extends ChangeNotifier {
  int index = 0;
  String nameWindow = "Bienvenido";
  changeIndex(int newIndex, String newName) {
    index = newIndex;
    nameWindow = newName;
    notifyListeners();
  }
}
