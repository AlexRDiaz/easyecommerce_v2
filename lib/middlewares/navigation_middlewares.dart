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

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (sharedPrefs!.getString("jwt") == null)
      return RouteSettings(name: '/login');
    return null;
  }
}
