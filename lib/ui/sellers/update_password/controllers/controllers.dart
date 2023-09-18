import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class PasswordSellersControllers {
  TextEditingController password = TextEditingController(text: "");
  var username = "";
  var email = "";

  updatePassword({success, error}) async {
    var response =
        await Connections().updateUserLaravel(username, email, password.text);
    if (response) {
      success();
    } else {
      error();
    }
  }
}
