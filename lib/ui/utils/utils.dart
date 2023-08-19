import 'package:flutter/material.dart';

class UIUtils {
  /// return a color based on the status
  static Color getColor(String status) {
    status = status.toUpperCase();
    switch (status) {
      case 'ENTREGADO':
        {
          return const Color(0XFF62bc5d);
        }
      case 'NO ENTREGADO':
        {
          return const Color(0XFF9f3e4a);
        }
      case 'NOVEDAD':
        {
          return const Color(0XFFb5b749);
        }
      case 'REAGENDADO':
        {
          return const Color(0XFFa12d6c);
        }
      case 'EN RUTA':
        {
          return const Color(0XFF6d9dcb);
        }
      case 'EN OFICINA':
        {
          return const Color(0XFF6d9dcb);
        }
      default:
        {
          return Colors.black;
        }
    }
  }
}
