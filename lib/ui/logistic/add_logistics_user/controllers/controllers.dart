import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class AddLogisticsControllers {
  TextEditingController searchController = TextEditingController(text: "");
  TextEditingController userController = TextEditingController(text: "");
  TextEditingController personController = TextEditingController(text: "");
  TextEditingController phone1Controller = TextEditingController(text: "");
  TextEditingController phone2Controller = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");

  TextEditingController userEditController = TextEditingController(text: "");
  TextEditingController personEditController = TextEditingController(text: "");
  TextEditingController phone1EditController = TextEditingController(text: "");
  TextEditingController phone2EditController = TextEditingController(text: "");
  TextEditingController mailEditController = TextEditingController(text: "");
  TextEditingController passwordEditController =
      TextEditingController(text: "");

  createLogisticUser({success, error, permisos}) async {
    var response = await Connections().createLogisticUser(
        userController.text,
        personController.text,
        phone1Controller.text,
        phone2Controller.text,
        mailController.text,
        permisos);
    if (response[0]) {
      success(response[1]);
    } else {
      error();
    }
  }

  updateControllersEdit(data) {
    phone1EditController.text = data["Telefono1"].toString();
    phone2EditController.text = data["Telefono2"].toString();
    userEditController.text = data["username"].toString();
    mailEditController.text = data["email"].toString();
    personEditController.text = data["Persona_Cargo"].toString();
  }

  updateUser({success, error, permisos}) async {
    var response = await Connections().updateLogisticUser(
        userEditController.text,
        phone1EditController.text,
        phone2EditController.text,
        personEditController.text,
        mailEditController.text,
        passwordEditController.text,
        permisos);
    if (response) {
      success();
    } else {
      error();
    }
  }
}
