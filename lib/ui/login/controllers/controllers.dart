import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class LoginControllers {
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  login(
      {required Function() success,
      required Function(String error) error}) async {
    var response = await Connections().login(
        identifier: controllerMail.text, password: controllerPassword.text);
    if (response == true) {
      success();
    } else {
      error('${response['error']}');
    }
  }
}
