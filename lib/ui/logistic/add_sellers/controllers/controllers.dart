import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class AddSellersControllers {
  TextEditingController searchController = TextEditingController(text: "");
  TextEditingController comercialNameController =
      TextEditingController(text: "");
  TextEditingController phone1Controller = TextEditingController(text: "");
  TextEditingController phone2Controller = TextEditingController(text: "");
  TextEditingController userController = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  TextEditingController sendCostController = TextEditingController(text: "");
  TextEditingController returnCostController = TextEditingController(text: "");
  TextEditingController urlComercialController =
      TextEditingController(text: "");

  TextEditingController comercialNameEditController =
      TextEditingController(text: "");
  TextEditingController phone1EditController = TextEditingController(text: "");
  TextEditingController phone2EditController = TextEditingController(text: "");
  TextEditingController userEditController = TextEditingController(text: "");
  TextEditingController mailEditController = TextEditingController(text: "");
  TextEditingController passwordEditController =
      TextEditingController(text: "");

  TextEditingController sendCostEditController =
      TextEditingController(text: "");
  TextEditingController returnCostEditController =
      TextEditingController(text: "");
  TextEditingController urlTiendaEditController =
      TextEditingController(text: "");

  createUser({success, error, code}) async {
    var responseCreateGeneral = await Connections().createSellerGeneral(
        comercialNameController.text,
        phone1Controller.text,
        phone2Controller.text,
        sendCostController.text,
        returnCostController.text,
        urlComercialController.text);

    var response = await Connections().createSeller(userController.text,
        mailController.text, responseCreateGeneral[1], code);

    var updateSellerGeneralIdMaster = await Connections()
        .updateSellerGeneralIdMaster(response[1], responseCreateGeneral[1]);

    if (response[0]) {
      success(response[1]);
    } else {
      error();
    }
  }

  updateControllersEdit(data) {
    comercialNameEditController.text =
        data['vendedores'][0]["Nombre_Comercial"].toString();
    phone1EditController.text = data['vendedores'][0]["Telefono1"].toString();
    phone2EditController.text = data['vendedores'][0]["Telefono2"].toString();
    userEditController.text = data["username"].toString();
    mailEditController.text = data["email"].toString();
    sendCostEditController.text =
        data['vendedores'][0]["CostoEnvio"].toString();
    returnCostEditController.text =
        data['vendedores'][0]["CostoDevolucion"].toString();
    urlTiendaEditController.text =
        data['vendedores'][0]["Url_Tienda"].toString();
  }

  updateUser({success, error, username, email}) async {
    var responseSeller = true;
    var responseGeneralSeller = await Connections().updateSellerGeneral(
        comercialNameEditController.text,
        phone1EditController.text,
        phone2EditController.text,
        sendCostEditController.text,
        returnCostEditController.text,
        urlTiendaEditController.text);

    if (username != userEditController.text) {
      responseSeller = await Connections().updateSellerUsername(
        userEditController.text,
      );
    }
    if (email != mailEditController.text) {
      responseSeller = await Connections().updateSellerMail(
        mailEditController.text,
      );
    }

    if (responseSeller && responseGeneralSeller) {
      success();
    } else {
      error();
    }
  }
}
