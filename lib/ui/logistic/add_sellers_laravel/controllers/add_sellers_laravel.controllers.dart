import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class AddSellersLaravelControllers {
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

  createUser({success, error}) async {
    var accesofRol = await Connections().getAccessofSpecificRol("VENDEDOR");

    Map<String, dynamic> roleParameters = {
      "nombre_comercial": comercialNameController.text,
      "telefono1": phone1Controller.text,
      "telefono2": phone2Controller.text,
      "costo_envio": sendCostController.text,
      "costo_devolucion": returnCostController.text,
      "url_tienda": urlComercialController.text
    };

    var response = await Connections().createUser(2, userController.text,
        mailController.text, accesofRol, 2, roleParameters);

    if (response['user_id'] != null) {
      success(response['user_id']);
    } else {
      error();
    }
  }

  updateControllersEdit(data) {
    comercialNameEditController.text =
        data[0]["up_user"]['vendedores'][0]['nombre_comercial'].toString();
    phone1EditController.text =
        data[0]["up_user"]['vendedores'][0]['telefono_1'].toString();
    phone2EditController.text =
        data[0]["up_user"]['vendedores'][0]['telefono_2'].toString();
    userEditController.text =
        data[0]["up_user"] != null && data[0]["up_user"].isNotEmpty
            ? data[0]["up_user"]['username'] != null
                ? data[0]["up_user"]['username'].toString()
                : ""
            : "";
    mailEditController.text =
        data[0]["up_user"] != null && data[0]["up_user"].isNotEmpty
            ? data[0]["up_user"]['email'] != null
                ? data[0]["up_user"]['email'].toString()
                : ""
            : "";
    sendCostEditController.text =
        data[0]["up_user"]['vendedores'][0]['costo_envio'].toString();
    returnCostEditController.text =
        data[0]["up_user"]['vendedores'][0]['costo_devolucion'].toString();
    urlTiendaEditController.text =
        data[0]["up_user"]['vendedores'][0]['url_tienda'] != null &&
                data[0]["up_user"]['vendedores'][0]['url_tienda'].isNotEmpty
            ? data[0]["up_user"]['vendedores'][0]['url_tienda'].toString()
            : "";
  }

  updateUser({success, error, idUser}) async {
    var responseSeller = true;
    var responseGeneralSeller = await Connections().updateSellerLara(
        idUser,
        userEditController.text,
        mailEditController.text,
        comercialNameEditController.text,
        phone1EditController.text,
        phone2EditController.text,
        sendCostEditController.text,
        returnCostEditController.text,
        urlTiendaEditController.text);

    print(responseGeneralSeller);
    // if (username != userEditController.text) {
    //   responseSeller = await Connections().updateSellerUsername(
    //     userEditController.text,
    //   );
    // }
    // if (email != mailEditController.text) {
    //   responseSeller = await Connections().updateSellerMail(
    //     mailEditController.text,
    //   );
    // }

    // if (responseSeller && responseGeneralSeller['message'] == "Usuario actualizado con éxito") {
    if (responseGeneralSeller != 1 && responseGeneralSeller != 2) {
      success();
    } else {
      error();
    }
  }

  // verifyUserTC(userId) async {
  //   return await Connections().verifyUserTerms(userId);
  // }

  // updateUserTC(userId, acceptedTermsConditions) async {
  //   await Connections().updateUserTCLaravel(userId, acceptedTermsConditions);
  // }
}
