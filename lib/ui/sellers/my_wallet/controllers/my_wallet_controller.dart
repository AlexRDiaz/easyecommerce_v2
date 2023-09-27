import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class MyWalletController {
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  getSaldo({success, error}) async {
    var response = await Connections().getSaldo();

    if (response) {
      return response;
    } else {
      error();
    }
  }
}
