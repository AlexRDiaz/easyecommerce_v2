import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

class NavigationProviderSellers extends ChangeNotifier {
  int index = sharedPrefs!.getInt("index") ?? 0;
  String nameWindow = sharedPrefs!.getString("nameWindow") ?? "Welcome";
  changeIndex(int newIndex, String newName) {
    index = newIndex;
    nameWindow = newName;

    notifyListeners();
    sharedPrefs!.setInt("index", index);
    sharedPrefs!.setString("nameWindow", nameWindow);
  }
}
