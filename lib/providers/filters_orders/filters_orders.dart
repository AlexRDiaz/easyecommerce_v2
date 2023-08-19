import 'package:flutter/material.dart';

class FiltersOrdersProviders extends ChangeNotifier {
  bool todos = true;

  bool codigoFilter = false;
  bool rangoFilter = false;
  bool nameFilter = false;
  bool cityFilter = false;
  int indexActive = 0;
  changeValue(newValue, index) {
    switch (index) {
      case 0:
        todos = true;
        if (newValue) {
          codigoFilter = false;
          rangoFilter = false;
          nameFilter = false;
          cityFilter = false;
        }
        indexActive = 1;

        notifyListeners();
        break;
      case 1:
        codigoFilter = true;
        if (newValue) {
          todos = false;

          rangoFilter = false;
          nameFilter = false;
          cityFilter = false;
        }
        indexActive = 1;

        notifyListeners();
        break;
      case 2:
        rangoFilter = true;
        if (newValue) {
          todos = false;

          codigoFilter = false;
          nameFilter = false;
          cityFilter = false;
        }
        indexActive = 2;

        notifyListeners();
        break;
      case 3:
        nameFilter = true;
        if (newValue) {
          todos = false;

          codigoFilter = false;
          rangoFilter = false;
          cityFilter = false;
        }
        indexActive = 3;

        notifyListeners();
        break;
      case 4:
        cityFilter = true;
        if (newValue) {
          todos = false;

          codigoFilter = false;
          rangoFilter = false;
          nameFilter = false;
        }
        indexActive = 4;

        notifyListeners();
        break;
      default:
    }
  }
}
