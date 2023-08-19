import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class AddOperatorsTransportControllers {
  TextEditingController searchController = TextEditingController(text: "");

  TextEditingController userController = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController costOperatorController =
      TextEditingController(text: "");

  TextEditingController userEditController = TextEditingController(text: "");
  TextEditingController mailEditController = TextEditingController(text: "");
  TextEditingController phoneEditController = TextEditingController(text: "");
  TextEditingController costOperatorEditController =
      TextEditingController(text: "");

  updateControllersEdit(data) {
    userEditController.text = data['username'].toString();
    mailEditController.text = data['email'].toString();
    phoneEditController.text = data['operadore']["Telefono"].toString();
    costOperatorEditController.text =
        data["operadore"]['Costo_Operador'].toString();
  }

  createUser({success, error, subruta, code}) async {
    var responseCreateGeneral = await Connections().createOperatorGeneral(
        phoneController.text,
        costOperatorController.text,
        subruta,
        sharedPrefs!.getString("idTransportadora").toString());

    var response = await Connections().createOperator(userController.text,
        mailController.text, responseCreateGeneral[1], code);

    if (response[0]) {
      success(response[1]);
    } else {
      error();
    }
  }

  updateOperator({success, error, subRoute}) async {
    var responseGeneralSeller = await Connections().updateOperatorGeneral(
      subRoute,
      phoneEditController.text,
      costOperatorEditController.text,
    );
    var responseSeller = await Connections().updateOperator(
      userEditController.text,
      mailEditController.text,
    );
    if (responseSeller && responseGeneralSeller) {
      success();
    } else {
      error();
    }
  }
}
