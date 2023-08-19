import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class PasswordSellersControllers {
  TextEditingController password = TextEditingController(text: "");
  updatePassword({success, error}) async {
    var response = await Connections().updatePassword(password.text);
    if (response) {
      success();
    } else {
      error();
    }
  }
}
