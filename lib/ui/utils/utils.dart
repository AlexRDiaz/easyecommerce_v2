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

  // * Product
  static List<String> categories() {
    return [
      "Casa",
      "Mascota",
      "Ropa",
      "Electrónica",
      "Cocina",
      "Belleza",
      "Salud",
      "Juguetes"
    ];
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
}
