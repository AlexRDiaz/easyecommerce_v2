import 'package:flutter/material.dart';
import 'package:frontend/ui/utils/utils.dart';

class NavigationProviderLogistic extends ChangeNotifier {
  int index = 0;
  String nameWindow = "Welcome";
  changeIndex(int newIndex, String newName) async {
     await UIUtils.updateLogisticaDates();
    index = newIndex;
    nameWindow = newName;
    notifyListeners();
  }
}
