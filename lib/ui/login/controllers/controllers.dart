import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class LoginControllers {
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  login({success, error}) async {
    var response = await Connections().login(
        identifier: controllerMail.text, password: controllerPassword.text);
    if (response) {
      success();
    } else {
      error();
    }
  }
}
