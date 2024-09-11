import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // * Product
  static List<String> categories() {
    return ["Hogar", "Mascota", "Moda", "Tecnología", "Cocina", "Belleza"];
  }

  static List<String> typesProduct() {
    return ["SIMPLE", "VARIABLE"];
  }

  static List<String> typesVariables() {
    return ["Tallas", "Colores", "Tamaños"];
  }

  static List<Map<String, List<String>>> variablesToSelect() {
    return [
      {
        "sizes": ["S", "M", "L", "XL", "2XL", "3XL"]
      },
      {
        "colors": ["Blanco", "Negro", "Amarillo", "Azul", "Rojo"],
      },
      {
        "dimensions": ["Grande", "Mediano", "Pequeño"]
      }
    ];
  }

  static String formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }

  static Future<void> updateLogisticaDates() async {
    final prefs = await SharedPreferences.getInstance();
    String date =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    await prefs.setString('dateDesdeLogistica', date);
    await prefs.setString('dateHastaLogistica', date);
  }

  static Color? getColorState(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF66BB6A;
        break;
      case "NOVEDAD":
        color = 0xFFf2b600;
        // color = 0xFFD6DC27;
        break;
      case "NOVEDAD RESUELTA":
        color = 0xFFFF5722;
        break;
      case "NO ENTREGADO":
        color = 0xFFF32121;
        break;
      case "REAGENDADO":
        color = 0xFFE320F1;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;
      case "PEDIDO PROGRAMADO":
        color = 0xFF7E84F2;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
  }

  static Color getColorStateArea(String areaState) {
    final String area = areaState.split(":")[0];
    final String state = areaState.split(":")[1];

    if (area == "status") {
      switch (state) {
        case "ENTREGADO":
          return const Color.fromARGB(128, 102, 187, 106);
        // return const Color.fromARGB(255, 102, 187, 106);
        case "NOVEDAD":
          return const Color.fromARGB(128, 214, 220, 39);
        // return const Color.fromARGB(255, 244, 225, 57);
        case "NOVEDAD RESUELTA":
          return const Color.fromARGB(128, 244, 132, 57);
        case "NO ENTREGADO":
          return const Color.fromARGB(128, 230, 44, 51);
        // return const Color.fromARGB(255, 243, 33, 33);
        case "REAGENDADO":
          return const Color.fromARGB(128, 227, 32, 241);
        // return const Color.fromARGB(255, 227, 32, 241);
        case "EN RUTA":
          return const Color.fromARGB(128, 51, 170, 255);
        // return const Color.fromARGB(255, 33, 150, 243);
        case "EN OFICINA":
          return const Color(0xFF4B4C4B);
        // return const Color(0xFF4B4C4B);
        case "PEDIDO PROGRAMADO":
          return const Color(0xFF7E84F2);
        // return const Color(0xFF7E84F2);
        default:
          return const Color.fromARGB(255, 108, 108, 109);
      }
    } else if (area == "estado_devolucion") {
      return const Color.fromARGB(128, 8, 61, 153);
      // return const Color.fromARGB(128, 2, 87, 247);
    } else {
      return const Color.fromARGB(128, 196, 198, 198);
    }
  }
}
