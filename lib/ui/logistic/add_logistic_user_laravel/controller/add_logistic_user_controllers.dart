import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class AddLogisticsLaravelControllers {
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
    if (phone1Controller.text != "" ||
        phone2Controller.text != "" ||
        personController.text != "" ||
        userController.text != "" ||
        personController.text != "" ||
        mailController.text != "") {
      error();
    }

    Map<String, dynamic> roleParameters = {
      "telefono1": phone1Controller.text,
      "telefono2": phone2Controller.text,
      "persona_cargo": personController.text
    };

    var response = await Connections().createUser(1, userController.text,
        mailController.text, permisos, 1, roleParameters);

    if (response['user_id'] != null) {
      success(response['user_id']);
    } else {
      error();
    }
  }

  updateControllersEdit(data) {
    phone1EditController.text = data[0]['up_user']["telefono_1"].toString();
    phone2EditController.text = data[0]['up_user']["telefono_2"].toString();
    userEditController.text = data[0]['up_user']["username"].toString();
    mailEditController.text = data[0]['up_user']["email"].toString();
    personEditController.text = data[0]['up_user']["persona_cargo"].toString();
  }

  updateUser({success, error, id}) async {
    var response = await Connections().updateLogisticUserLara(
        id,
        userEditController.text,
        mailEditController.text,
        personEditController.text,
        phone1EditController.text,
        phone2EditController.text);
    if (response != 1 && response != 2) {
      success();
    } else {
      error();
    }
  }
}
