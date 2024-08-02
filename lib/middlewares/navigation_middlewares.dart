import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/login/login.dart';
import 'package:get/route_manager.dart';

navigationMiddleware(page) {
  if (sharedPrefs!.getString("jwt") == null) {
    return MaterialPageRoute(builder: (context) => LoginPage());
  } else {
    return page;
  }
}

// navigationMiddleware(page, String roleLocation, String route) {
//   if (sharedPrefs!.getString("jwt") == null) {
//     return MaterialPageRoute(builder: (context) => LoginPage());
//   } else {
//     // Verifica el roleLocation y la ruta
//     if (roleLocation.toLowerCase() == 'logistica' &&
//         route.toLowerCase().contains('logistic')) {
//       return page;
//     } else {
//       return MaterialPageRoute(builder: (context) => LoginPage());
//     }
//   }
// }

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final jwt = sharedPrefs!.getString("jwt");
    final userRole = sharedPrefs!.getString("role");

    if (jwt == null) {
      return RouteSettings(name: '/login');
    } else {
      if (userRole != null) {
        final roleLower = userRole.toLowerCase();
        final routeLower = route?.toLowerCase() ?? '';

        if (roleLower == 'logistica' &&
            routeLower.startsWith('/layout/logistic')) {
          return null;
        }

        if (roleLower == 'proveedor' &&
            routeLower.startsWith('/layout/provider')) {
          return null;
        }

        if (roleLower == 'vendedor' &&
            routeLower.startsWith('/layout/sellers')) {
          return null;
        }

        if (roleLower == 'transportador' &&
            routeLower.startsWith('/layout/transport')) { 
          return null;
        }

        if (roleLower == 'operador' &&
            routeLower.startsWith('/layout/operator')) {
          return null;
        }

        return RouteSettings(name: '/notfound');
      }
    }
    // Redirigir a una página de acceso denegado si el rol no está definido
    return RouteSettings(name: '/notfound');
  }
}
