import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class Navigators {
  pushNamedAndRemoveUntil(context, path) {
    Get.offNamed(path);
  }

  pushNamed(context, path) {
    Get.toNamed(path);
  }
}
