import 'dart:convert';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class Connections {
  String server = generalServer;
  String serverLaravel = generalServerApiLaravel;
  Future<bool> login({identifier, password}) async {
    try {
      var request = await http.post(Uri.parse("$serverLaravel/api/login"),
          body: {"email": identifier, "password": password});
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        var m = decodeData['user']['id'];
        return false;
      } else {
        var getUserSpecificRequest = await http.get(
            Uri.parse("$serverLaravel/api/users/${decodeData['user']['id']}"));
        var responseUser = await getUserSpecificRequest.body;
        var decodeDataUser = json.decode(responseUser);
        sharedPrefs!.setString("username", decodeData['user']['username']);
        sharedPrefs!.setString("id", decodeData['user']['id'].toString());
        sharedPrefs!.setString("email", decodeData['user']['email'].toString());
        sharedPrefs!.setString("jwt", decodeData['jwt'].toString());
        var m = decodeDataUser['user']['roles_fronts'];
        sharedPrefs!.setString("role",
            decodeDataUser['user']['roles_fronts'][0]['titulo'].toString());

        sharedPrefs!.setBool("acceptedTermsConditions",
            decodeData['user']['acceptedTermsConditions'] ?? false);

        if (decodeDataUser['user']['roles_fronts'][0]['titulo'].toString() ==
            "VENDEDOR") {
          sharedPrefs!.setString(
            "dateDesdeVendedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaVendedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString("idComercialMasterSeller",
              decodeDataUser['user']['vendedores'][0]['id_master'].toString());
          sharedPrefs!.setString("idComercialMasterSellerPrincipal",
              decodeDataUser['user']['vendedores'][0]['id'].toString());
          sharedPrefs!.setString(
              "NameComercialSeller",
              decodeDataUser['user']['vendedores'][0]['nombre_comercial']
                  .toString());
          decodeDataUser['user']['vendedores'][0]['referer'] != null
              ? sharedPrefs!.setString(
                  "referer", decodeDataUser['user']['vendedores'][0]['referer'])
              : "";
          List temporalPermisos =
              jsonDecode(decodeDataUser['user']['permisos']);
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
        }
        if (decodeDataUser['user']['roles_fronts'][0]['titulo'].toString() ==
            "LOGISTICA") {
          List temporalPermisos =
              jsonDecode(decodeDataUser['user']['permisos']);
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
          sharedPrefs!.setString(
            "dateDesdeTransportHistorial",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaTransportHistorial",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
        }

        if (decodeDataUser['user']['roles_fronts'][0]['titulo'].toString() ==
            "TRANSPORTADOR") {
          sharedPrefs!.setString(
            "dateDesdeTransportadora",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaTransportadora",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString("idTransportadora",
              decodeDataUser['user']['transportadora'][0]['id'].toString());
          sharedPrefs!.setString(
              "CostoT",
              decodeDataUser['user']['transportadora'][0]
                      ['costo_transportadora']
                  .toString());
          List temporalPermisos =
              jsonDecode(decodeDataUser['user']['permisos']);
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
        }
        if (decodeDataUser['user']['roles_fronts'][0]['titulo'].toString() ==
            "OPERADOR") {
          sharedPrefs!.setString(
            "dateDesdeOperador",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaOperador",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );

          sharedPrefs!.setString("numero",
              decodeDataUser['user']['operadores'][0]['telefono'].toString());
          // ! esta es la mia ↓
          sharedPrefs!.setString("idOperadore",
              decodeDataUser['user']['operadores'][0]['id'].toString());
          // !permisos qu ese incluyen
          List temporalPermisos =
              jsonDecode(decodeDataUser['user']['permisos']);
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
        }
        // ! ****************
        sharedPrefs!.setString(
            "fechaAlta", decodeDataUser['user']['fecha_alta'].toString());
        sharedPrefs!.setString(
          "dateOperatorState",
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        );

        if (decodeDataUser['user']['roles_fronts'][0]['titulo'].toString() ==
            "PROVEEDOR") {
          sharedPrefs!.setString(
            "dateDesdeProveedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaProveedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString("idProvider",
              decodeDataUser['user']['providers'][0]['id'].toString());
          sharedPrefs!.setString("idProviderUserMaster",
              decodeDataUser['user']['providers'][0]['id_user'].toString());
          sharedPrefs!.setString("NameProvider",
              decodeDataUser['user']['providers'][0]['name'].toString());
          List temporalPermisos =
              jsonDecode(decodeDataUser['user']['permisos']);
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
        }

        // print(decodeData);
        // print(decodeDataUser);
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  getPersonalInfoAccount() async {
    var getUserSpecificRequest = await http.get(Uri.parse(
        "$server/api/users/${sharedPrefs!.getString("id").toString()}?populate=roles_front&populate=vendedores&populate=transportadora&populate=operadore"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser;
  }

  getPersonalInfoAccountByID(id) async {
    var getUserSpecificRequest = await http.get(Uri.parse(
        "$server/api/users/$id?populate=roles_front&populate=vendedores&populate=transportadora&populate=operadore"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser;
  }

  getTransporterInfoAccountByID(id) async {
    var getUserSpecificRequest = await http
        .get(Uri.parse("$server/api/transportadoras/$id?populate=rutas"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser;
  }

  getPersonalInfoAccountI() async {
    String id = Get.parameters['id'].toString();

    var getUserSpecificRequest =
        await http.get(Uri.parse("$serverLaravel/api/users/$id"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser['user'];
  }
  getPersonalInfoAccountforConfirmOrder(idUser) async {

    var getUserSpecificRequest =
        await http.get(Uri.parse("$serverLaravel/api/users/$idUser"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser['user'];
  }

  // SELLERS
  // FILTER BY USERNAME AND NombreComercial

  Future getSellersFromSellers(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/vendedores?filters[Nombre_Comercial][\$contains]=$search&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;

    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getSellers(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=vendedores&filters[\$or][0][username][\$contains]=$search&filters[\$or][1][vendedores][Nombre_Comercial][\$contains]=$search&filters[\$or][2][email][\$contains]=$search&filters[\$and][3][roles_front][Titulo][\$eq]=VENDEDOR&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getSellersByIdMaster(search) async {
    var request = await http.get(
      Uri.parse(
          "$serverLaravel/api/sellers/${sharedPrefs!.getString("idComercialMasterSeller").toString()}/$search"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    // print(decodeData['users']);
    return decodeData['users'];
  }

  Future getSellersByIdMasterOnly(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users/$id?populate=roles_front&populate=vendedores"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getAllSellers() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=vendedores&filters[roles_front][Titulo][\$eq]=VENDEDOR&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getSellerGeneralByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse("$server/api/users/$id?populate=vendedores"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  getAccessofRolById(id) async {
    try {
      var request = await http.get(
        Uri.parse("$serverLaravel/api/access-ofid/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return [false, ""];
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  getPermissionsSellerPrincipalforNewSeller(id) async {
    try {
      var request = await http.get(
        Uri.parse("$serverLaravel/api/sellerprincipal-for-newseller/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return [false, ""];
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  managePermission(userId, viewName) async {
    try {
      var request =
          await http.post(Uri.parse("$serverLaravel/api/edit-personal-access"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "view_name": viewName,
                "user_id": userId,
              }));
      var response = request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return [false, ""];
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  getAccessofSpecificRol(rol) async {
    try {
      var request = await http.get(
        Uri.parse("$serverLaravel/api/getespc-access/$rol"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return [false, ""];
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  Future createSeller(user, mail, id, code, access) async {
    var request = await http.post(Uri.parse("$server/api/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "roles_front": "2",
          "password": "123456789",
          "FechaAlta":
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          "vendedores": id,
          "role": "1",
          "confirmed": true,
          "CodigoGenerado": code,
          "PERMISOS": access
          // [
          //   "DashBoard",
          //   "Reporte de Ventas",
          //   "Agregar Usuarios Vendedores",
          //   "Ingreso de Pedidos",
          //   "Estado Entregas Pedidos",
          //   "Pedidos No Deseados",
          //   "Billetera",
          //   "Devoluciones",
          //   "Retiros en Efectivo",
          //   "Conoce a tu Transporte"
          // ]
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 201) {
      return [false, ""];
    } else {
      return [true, decodeData['id']];
    }
  }

  Future createInternalSeller(user, mail, permisos) async {
    var request = await http.post(Uri.parse("$serverLaravel/api/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "roles_front": "2",
          "password": "123456789",
          "FechaAlta":
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          "vendedores": sharedPrefs!
              .getString("idComercialMasterSellerPrincipal")
              .toString(),
          "role": "1",
          "confirmed": true,
          "estado": "VALIDADO",
          "PERMISOS": permisos
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 201) {
      return [false, ""];
    } else {
      return [true, decodeData['id']];
    }
  }

  getSellerMaster(id) async {
    var request =
        await http.get(Uri.parse("$serverLaravel/api/users/master/$id"));
    var response = request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return decodeData;
    }
  }

  Future createSellerGeneral(
      comercialName, phone1, phone2, sendCost, returnCost, url) async {
    var request = await http.post(Uri.parse("$server/api/vendedores"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Nombre_Comercial": comercialName,
            "Telefono1": phone1,
            "Telefono2": phone2,
            "CostoEnvio": sendCost,
            "CostoDevolucion": returnCost,
            "FechaAlta":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            "Url_Tienda": url
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future createSellerGeneralLaravel(username, email, password, comercialName,
      phone1, phone2, sendCost, returnCost, url, id) async {
    int res = 0;
    try {
      var request =
          await http.post(Uri.parse("$serverLaravel/api/users/general"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "username": username,
                "email": email,
                "password": password,
                "nombre_comercial": comercialName,
                "telefono1": phone1,
                "telefono2": phone2,
                "costo_envio": 5,
                "costo_devolucion": 5.50,
                "fecha_alta":
                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                "url_tienda": url,
                "referer": id
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future updateSellerGeneral(
      comercialName, phone1, phone2, sendCost, returnCost, url) async {
    String id = Get.parameters['id_Comercial'].toString();
    var request = await http.put(Uri.parse("$server/api/vendedores/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Nombre_Comercial": comercialName,
            "Telefono1": phone1,
            "Telefono2": phone2,
            "CostoEnvio": sendCost,
            "CostoDevolucion": returnCost,
            "Url_Tienda": url
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSellerGeneralInternalAccount(
      comercialName, phone1, phone2, idMaster) async {
    var request = await http.put(Uri.parse("$server/api/vendedores/$idMaster"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Nombre_Comercial": comercialName.toString(),
            "Telefono1": phone1.toString(),
            "Telefono2": phone2.toString(),
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSellerGeneralIdMaster(idMaster, id) async {
    var request = await http.put(Uri.parse("$server/api/vendedores/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Id_Master": idMaster.toString(),
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSeller(user, mail, password) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/users/${sharedPrefs!.getString("id").toString()}"),
        headers: {'Content-Type': 'application/json'},
        body: password.toString().isEmpty
            ? json.encode({
                "username": user,
                "email": mail,
              })
            : json.encode({
                "username": user,
                "email": mail,
                "password": password,
              }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSellerUsername(user) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSellerMail(mail) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": mail,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateSellerI(user, mail, permisos) async {
    String id = Get.parameters['id'].toString();
    var perm = jsonEncode(permisos);
    var request = await http.put(Uri.parse("$serverLaravel/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "permisos": jsonEncode(permisos)
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  verifyUserTerms(userId) async {
    try {
      var requestLaravel = await http
          .get(Uri.parse("$serverLaravel/api/user/verifyterms/$userId"));
      final jsonrequest = requestLaravel.body.toLowerCase();
      // print('res api: $jsonrequest');

      return jsonrequest;
    } catch (e) {
      print(e);
    }
  }

  Future updateUserTCLaravel(userId, acceptedTC) async {
    try {
      var requestLaravel = await http.put(
          Uri.parse("$serverLaravel/api/user/updateterms/$userId"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "accepted_terms_conditions": acceptedTC,
          }));
      var response = await requestLaravel.body;
      var decodeData = json.decode(response);
      if (requestLaravel.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  //LOGISTIC USER
  //  "roles_front": "1", LOGISTIC
  Future createLogisticUser(
      user, person, phone1, phone2, mail, permisos) async {
    var request = await http.post(Uri.parse("$server/api/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "roles_front": "1",
          "Telefono1": phone1,
          "Telefono2": phone2,
          "Persona_Cargo": person,
          "Estado": "VALIDADO",
          "password": "123456789",
          "FechaAlta":
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          "role": "1",
          "confirmed": true,
          "PERMISOS": permisos
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 201) {
      return [false, ""];
    } else {
      return [true, decodeData['id']];
    }
  }

  // FILTER BY USERNAME AND PERSONA_CARGO
  Future getLogisticUsers(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&filters[\$or][0][username][\$contains]=$search&filters[\$or][1][Persona_Cargo][\$contains]=$search&filters[\$and][2][roles_front][Titulo][\$eq]=LOGISTICA&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getLogisticGeneralByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse("$server/api/users/$id"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future updateLogisticUser(
      // user, phone1, phone2, person, mail, password, permisos) async {
      user,
      phone1,
      phone2,
      person,
      mail,
      password) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: password.toString().isEmpty
            ? json.encode({
                "username": user,
                "email": mail,
                "Telefono1": phone1,
                "Telefono2": phone2,
                "Persona_Cargo": person,
                // "PERMISOS": permisos
              })
            : json.encode({
                "username": user,
                "email": mail,
                "Telefono1": phone1,
                "Telefono2": phone2,
                "Persona_Cargo": person,
                "password": password,
                // "PERMISOS": permisos
              }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  //ORDERS
  Future getOrdersSellersAll() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  //DATES ORDERS
  Future getOrdersDateAll() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedido-fechas?populate=pedidos_shopifies&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getUnwantedOrdersSellers(
    code,
    int currentPage,
    int pageSize,
    List arrayPopulate,
    arrayFiltersOrCont,
  ) async {
    String url = "$server/api/pedidos-shopifies?";

    for (var populate in arrayPopulate) {
      url += 'populate=$populate&';
    }
    int numberFilter = 3;

    if (code != "") {
      for (var filter in arrayFiltersOrCont) {
        url +=
            "filters[\$or][$numberFilter][${filter['filter']}][\$contains]=$code&";
        numberFilter++;
      }
    }

    url +=
        "pagination[page]=$currentPage&pagination[pageSize]=$pageSize&sort=id%3Adesc";
    print("url= " + url);
    var request = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }
//  getUnwantedOrdersSellers(code) async {
//     var request = await http.get(
//       Uri.parse(
//           "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][2][Estado_Interno][\$eq]=NO DESEA&pagination[limit]=-1"),
//       headers: {'Content-Type': 'application/json'},
//     );
//     var response = await request.body;
//     var decodeData = json.decode(response);

//     return decodeData['data'];
//   }
// ! PRINCIPAL DE  INGRESO DE PEDIDOS
  Future getPrincipalOrdersSellersFilterLaravel(
      List populate,
      List and,
      List defaultAnd,
      List or,
      currentPage,
      sizePage,
      search,
      sortFiled,
      List not) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/new-pedidos-shopifies"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "or": or,
                "and": filtersAndAll,
                "page_size": sizePage,
                "page_number": currentPage,
                "search": search,
                "sort": sortFiled,
                "not": not
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  Future getOrdersSellersFilter(
      code,
      currentPage,
      pageSize,
      arrayPopulate,
      arrayFiltersOrCont,
      arrayFiltersAnd,
      arrayFiltersDefaultOr,
      arrayFiltersDefaultAnd,
      uniqueFilters) async {
    var url = "$server/api/pedidos-shopifies?";
    int numberFilter = 0;

    for (var populate in arrayPopulate) {
      url += 'populate=$populate&';
    }
    var nestedAnd = "";

    for (var filter in uniqueFilters) {
      url += filter;
    }
    for (var filter in arrayFiltersDefaultOr) {
      int nestedOrCount = 0;

      nestedAnd +=
          "filters[\$and][$numberFilter][${filter['operator']}][$nestedOrCount][${filter['filter']}][${filter['operator_attr']}]=${filter['value']}&";
      nestedOrCount++;
    }

    if (arrayFiltersDefaultOr != []) {
      url += nestedAnd;
      numberFilter++;
    }

    for (var filter in arrayFiltersDefaultAnd) {
      url +=
          "filters[${filter['operator']}][$numberFilter][${filter['filter']}][${filter['operator_attr']}]=${filter['value']}&";
      numberFilter++;
    }

    if (code != "") {
      for (var filter in arrayFiltersOrCont) {
        url +=
            "filters[\$or][$numberFilter][${filter['filter']}][\$contains]=$code&";
        numberFilter++;
      }
    }

    for (var filter in arrayFiltersAnd) {
      // print("filter:" + filter['filter'].toString());
      // print("value:" + filter['value'].toString());

      url +=
          "filters[\$and][$numberFilter][${filter['filter']}][${filter['operator_attr']}]=${filter['value']}&";
      numberFilter++;
    }

    // var configPagination =
    //     "pagination[page]=${currentPage}&pagination[pageSize]=${pageSize}&sort=id%3Adesc";
    url +=
        "pagination[page]=$currentPage&pagination[pageSize]=$pageSize&sort=id%3Adesc";

    print(url);
    var request = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return [
      {'data': decodeData['data'], 'meta': decodeData['meta']}
    ];
  }

  Future getOrdersSellersFilterLaravel(
      arrayFiltersOrCont,
      arrayFiltersDefaultOr,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      sizePage,
      search,
      not,
      sort) async {
    int res = 0;

    List<dynamic> filtersAndAll = [];
    filtersAndAll.addAll(arrayfiltersDefaultAnd);
    filtersAndAll.addAll(arrayFiltersAnd);

    // print(sharedPrefs!.getString("dateDesdeVendedor"));
    // print(sharedPrefs!.getString("dateHastaVendedor"));
    // print("todo and: \n $filtersAndAll");
    //print("sort conn: \n $sort");

    try {
      String urlnew = "$serverLaravel/api/pedidos-shopify/filter/sellers";

      var requestlaravel = await http.post(Uri.parse(urlnew),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "page_size": sizePage,
            "page_number": currentPage,
            "or": arrayFiltersOrCont,
            "ordefault": arrayFiltersDefaultOr,
            "not": not,
            "sort": sort,
            "and": filtersAndAll,
            "search": search
          }));

      var responselaravel = await requestlaravel.body;
      var decodeDataL = json.decode(responselaravel);
      int totalRes = decodeDataL['total'];

      var response = await requestlaravel.body;
      var decodeData = json.decode(response);

      if (requestlaravel.statusCode != 200) {
        res = 1;
        // print("res:" + res.toString());
      } else {
        // print('Total_L: $totalRes');
      }
      // print("res:" + res.toString());
      return decodeData;
    } catch (e) {
      print("Error: $e");
      res = 2;
      // print("res:" + res.toString());
    }
  }

  Future getOrdersSellersByState(code, currentPage, pageSize, String? pedido,
      confirmado, logistico) async {
    print("currentPage=" + currentPage.toString());
    print("pageSize=" + pageSize.toString());
    print("pedido=" + pedido!);
    print("confirmado=" + confirmado!);
    print("logistico=" + logistico!);

    String url = "";
    print("url:" + url);
    var request = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    // print("meta="+decodeData['meta'].toString());
    return [
      {'data': decodeData['data'], 'meta': decodeData['meta']}
    ];
  }

  Future getOrdersSellersSearch(code, currentPage, pageSize, search) async {
    print("code=" + code.toString());
    print("shared=" +
        sharedPrefs!.getString("idComercialMasterSeller").toString());
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[\$and][0][NumeroOrden][\$contains]=&filters[\$and][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][3][Estado_Interno][\$ne]=NO DESEA&sort=id%3Adesc&filters[\$and][4][Status][\$eq]=PEDIDO PROGRAMADO&filters[\$or][0][CiudadShipping][\$contains]=$search&filters[\$or][1][NombreShipping][\$contains]=$search&sort=id%3Adesc&pagination[page]=${currentPage}&pagination[pageSize]=${pageSize}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    print("meta=" + decodeData['meta'].toString());
    //print ("url=$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][3][Estado_Interno][\$ne]=NO DESEA&sort=id%3Adesc&filters[\$and][4][Status][\$eq]=PEDIDO PROGRAMADO&sort=id%3Adesc&pagination[limit]=-1");

    return [
      {'data': decodeData['data'], 'meta': decodeData['meta']}
    ];
  }

  // getUnwantedOrdersSellers(code) async {
  //   var request = await http.get(
  //     Uri.parse(
  //         "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][2][Estado_Interno][\$eq]=NO DESEA&pagination[limit]=-1"),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //   var response = await request.body;
  //   var decodeData = json.decode(response);

  //   return decodeData['data'];
  // }

  // Future getUnwantedOrdersSellers(code, int currentPage, int pageSize,
  //     List arrayFiltersOrCont, List arrayFiltersAndEq) async {
  //   // print("currentPage=" + currentPage.toString());
  //   // print("pageSize=" + pageSize.toString());
  //   // print("pedido=" + pedido!);
  //   // print("confirmado=" + confirmado!);
  //   // print("code=" + code!);

  //   var url =
  //       "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&filters[\$or][0][NumeroOrden][\$contains]=$code&filters[\$and][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][3][Estado_Interno][\$ne]=NO DESEA&sort=id%3Adesc&filters[\$and][4][Status][\$eq]=PEDIDO PROGRAMADO";
  //   int numberFilter = 5;
  //   var filtersOrCont = "";

  //   if (code != "") {
  //     for (var filter in arrayFiltersOrCont) {
  //       filtersOrCont +=
  //           "&filters[\$or][$numberFilter][${filter['filter']}][\$contains]=$code";
  //       numberFilter++;
  //     }
  //   }

  //   var filtersAndEq = "";
  //   for (var filter in arrayFiltersAndEq) {
  //     print("filter:" + filter['filter'].toString());
  //     print("value:" + filter['value'].toString());

  //     filtersAndEq +=
  //         "&filters[\$and][$numberFilter][${filter['filter']}][\$eq]=${filter['value']}";
  //     numberFilter++;
  //   }

  //   var configPagination =
  //       "&sort=id%3Adesc&pagination[page]=${currentPage}&pagination[pageSize]=${pageSize}";
  //   url += filtersOrCont + filtersAndEq + configPagination;

  //   print(url);
  //   var request = await http.get(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //   var response = await request.body;
  //   var decodeData = json.decode(response);
  //   return [
  //     {'data': decodeData['data'], 'meta': decodeData['meta']}
  //   ];
  // }

  getOrdersForPrintGuides(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][Estado_Logistico][\$eq]=PENDIENTE&filters[\$and][2][Estado_Interno][\$eq]=CONFIRMADO&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForPrintedGuides(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][Estado_Logistico][\$eq]=IMPRESO&filters[\$and][2][Estado_Interno][\$eq]=CONFIRMADO&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForPrintGuidesInSendGuides(code, date) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][Estado_Logistico][\$eq]=ENVIADO&filters[\$and][2][Marca_Tiempo_Envio][\$eq]=$date&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForPrintGuidesInSendGuidesOnlyCode(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&filters[Estado_Logistico][\$eq]=ENVIADO&filters[\$or][0][NumeroOrden][\$contains]=$code&filters[\$or][1][NombreShipping][\$contains]=$code&filters[\$or][2][pedido_fecha][Fecha][\$contains]=$code&filters[\$or][3][CiudadShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][Cantidad_Total][\$contains]=$code&filters[\$or][7][ProductoP][\$contains]=$code&filters[\$or][8][ProductoExtra][\$contains]=$code&filters[\$or][9][PrecioTotal][\$contains]=$code&filters[\$or][10][transportadora][Nombre][\$contains]=$code&filters[\$or][11][Status][\$contains]=$code&filters[\$or][12][Estado_Interno][\$contains]=$code&filters[\$or][13][Estado_Logistico][\$contains]=$code&filters[\$or][14][Observacion][\$contains]=$code&filters[\$or][15][Marca_Tiempo_Envio][\$contains]=$code&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForPrintGuidesInSendGuidesAndTransporter(code, date, id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$and][1][Estado_Logistico][\$eq]=ENVIADO&filters[\$and][2][Marca_Tiempo_Envio][\$eq]=$date&filters[\$and][3][transportadora][id][\$eq]=$id&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForHistorialTransportByDates(
      List populate, List and, currentPage, sizePage) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    var request = await http.post(
        Uri.parse("$server/api/history/transport?pagination[limit]=-1"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeLogistica"),
          "end": sharedPrefs!.getString("dateHastaLogistica"),
          "populate": jsonEncode(populate),
          "and": jsonEncode(and),
          "currentPage": currentPage,
          "sizePage": sizePage
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData;
  }

  getOrdersDashboardLogisticLaravel(
      List populate, List and, List defaultAnd, List or) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    List andAll = [];
    andAll.addAll(and);
    andAll.addAll(defaultAnd);

    var request = await http.post(
        Uri.parse(
            "$serverLaravel/api/pedidos-shopify/products/counters/logistic"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeLogistica"),
          "end": sharedPrefs!.getString("dateHastaLogistica"),
          "or": or,
          "and": andAll,
          "not": [],
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersDashboardSellerLaravel(
      List populate, List and, List defaultAnd, List or) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    List andAll = [];
    andAll.addAll(and);
    andAll.addAll(defaultAnd);

    var request = await http.post(
        Uri.parse(
            "$serverLaravel/api/pedidos-shopify/products/counters/logistic"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeLogistica"),
          "end": sharedPrefs!.getString("dateHastaLogistica"),
          "or": or,
          "and": andAll,
          "not": [],
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  Future getOrderByIDHistoryLaravel(id) async {
    var request = await http.get(
      Uri.parse("$serverLaravel/api/pedidos-shopify/$id"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  // ! mia operatoresbytransport
  getOperatoresbyTransport(id) async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/operatoresbytransport/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // ! mia vendedores
  getVendedores() async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/vendedores"),
        headers: {'Content-Type': 'application/json'},
      );
      // var decodeData = json.decode(response);

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // ! mia transportadoras
  getTransportadoras() async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/transportadoras"),
        headers: {'Content-Type': 'application/json'},
      );
      // var decodeData = json.decode(response);
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // ! *******************
  getOrdersForNoveltiesByDatesLaravel(
      List populate,
      List defaultAnd,
      List and,
      List or,
      List not,
      currentPage,
      sizePage,
      search,
      sortField,
      String dateStart,
      String dateEnd) async {
    int res = 0;
    try {
      print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
      print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

      List filtersAndAll = [];
      filtersAndAll.addAll(and);
      filtersAndAll.addAll(defaultAnd);
      var request = await http.post(
          Uri.parse("$serverLaravel/api/logistic/filter/novelties"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": dateStart,
            "end": dateEnd,
            // "start": sharedPrefs!.getString("dateDesdeLogistica"),
            // "end": sharedPrefs!.getString("dateHastaLogistica"),
            "or": or,
            "and": filtersAndAll,
            "not": not,
            "sort": sortField,
            "page_size": sizePage,
            "page_number": currentPage,
            "search": search
          }));
      print(and);
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
      // print(decodeData);
      return decodeData;
    } catch (e) {
      print('Error en la solicitud: $e');
      res = 2;
    }
    return res;
  }

  getOrdersForHistorialTransportByDatesLaravel(List populate, List and, List or,
      currentPage, sizePage, search, sortField) async {
    int res = 0;
    try {
      print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
      print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');
      // ! ↓ esta linea argega que busqueda va hacer
      // or.add("nombre_shipping");
      var request = await http.post(
          Uri.parse("$serverLaravel/api/pedidos-shopify/filter/logistic"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": sharedPrefs!.getString("dateDesdeLogistica"),
            "end": sharedPrefs!.getString("dateHastaLogistica"),
            "or": or,
            "and": and,
            "not": [],
            "sort": sortField,
            "page_size": sizePage,
            "page_number": currentPage,
            "search": search
          }));
      print(and);
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
      // print(decodeData);
      return decodeData;
    } catch (e) {
      print('Error en la solicitud: $e');
      res = 2;
    }
    return res;
  }

  getOrdersDashboard(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeVendedor")}');
    print('end: ${sharedPrefs!.getString("dateHastaVendedor")}');

    var request = await http.post(
        Uri.parse("$server/api/products/dashboard?pagination[limit]=-1"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeVendedor"),
          "end": sharedPrefs!.getString("dateHastaVendedor"),
          "populate": jsonEncode(populate),
          "and": jsonEncode(and)
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersDashboardLogistic(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    var request =
        await http.post(Uri.parse("$server/api/products/dashboard/logistic"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeLogistica"),
              "end": sharedPrefs!.getString("dateHastaLogistica"),
              "populate": jsonEncode(populate),
              "and": jsonEncode(and)
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersDashboardTransportadora(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
    print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');

    var request =
        await http.post(Uri.parse("$server/api/products/dashboard/logistic"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeTransportadora"),
              "end": sharedPrefs!.getString("dateHastaTransportadora"),
              "populate": jsonEncode(populate),
              "and": jsonEncode(and)
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    // print(decodeData['data']);
    return decodeData['data'];
  }

  getOrdersDashboardSellers(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeVendedor")}');
    print('end: ${sharedPrefs!.getString("dateHastaVendedor")}');

    var request =
        await http.post(Uri.parse("$server/api/products/dashboard/logistic"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeVendedor"),
              "end": sharedPrefs!.getString("dateHastaVendedor"),
              "populate": jsonEncode(populate),
              "and": jsonEncode(and)
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersDashboardSellersLaravel(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeVendedor")}');
    print('end: ${sharedPrefs!.getString("dateHastaVendedor")}');

    var request =
        await http.post(Uri.parse("$server/api/products/dashboard/logistic"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeVendedor"),
              "end": sharedPrefs!.getString("dateHastaVendedor"),
              "populate": jsonEncode(populate),
              "and": jsonEncode(and)
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getValuesTrasporter(List populate, List and, List defaultAnd, List or) async {
    print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
    print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');

    List filtersAndAll = [];
    filtersAndAll.addAll(and);

    filtersAndAll.addAll(defaultAnd);

    var request = await http.post(
        Uri.parse(
            "$serverLaravel/api/pedidos-shopify/products/values/transport"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeTransportadora"),
          "end": sharedPrefs!.getString("dateHastaTransportadora"),
          "or": or,
          "and": filtersAndAll,
          "not": []
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getValuesSeller(List populate, List and) async {
    print(
        'startValuesTransport: ${sharedPrefs!.getString("dateDesdeVendedor")}');
    print('endValuesTransport: ${sharedPrefs!.getString("dateHastaVendedor")}');

    var request =
        await http.post(Uri.parse("$server/api/pedidos/values/seller/"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeVendedor"),
              "end": sharedPrefs!.getString("dateHastaVendedor"),
              "populate": jsonEncode(populate),
              "and": jsonEncode(and)
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData;
  }

  getOrdersDashboardLogisticRoutes(List populate, List and) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    var request = await http.post(
        Uri.parse("$server/api/products/city/dashboard/logistic"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeLogistica"),
          "end": sharedPrefs!.getString("dateHastaLogistica"),
          "populate": jsonEncode(populate),
          "and": jsonEncode(and)
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOperatorsByTransport(var id) async {
    var request = await http.post(
      Uri.parse("$server/api/operator/transport/" + id),
      headers: {'Content-Type': 'application/json'},
    );

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForHistorialTransportByCode(code, url) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users&populate=users.vendedores&populate=sub_ruta&populate=operadore&populate=operadore.user&populate=pedido_fecha$url&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  Future createOrderLaravel(
      numero,
      direccion,
      nombre,
      telefono,
      precio,
      observacion,
      ciudad,
      estado,
      productoP,
      productoE,
      cantidadT,
      fecha,
      fechaC,
      dateID) async {
    print(json.encode({
      // "data": {
      "NumeroOrden": numero.toString(),
      "DireccionShipping": direccion.toString(),
      "NombreShipping": nombre.toString(),
      "TelefonoShipping": telefono.toString(),
      "PrecioTotal": precio.toString(),
      "Observacion": observacion.toString(),
      "CiudadShipping": ciudad.toString(),
      "users": sharedPrefs!.getString("idComercialMasterSeller"),
      "Estado_Interno": estado.toString(),
      "IdComercial": sharedPrefs!.getString("idComercialMasterSeller"),
      "ProductoP": productoP.toString(),
      "ProductoExtra": productoE.toString(),
      "Cantidad_Total": cantidadT.toString(),
      "Name_Comercial": sharedPrefs!.getString("NameComercialSeller"),
      "Marca_T_I": fecha.toString(),
      "Fecha_Confirmacion": fechaC.toString(),
      "Tienda_Temporal": sharedPrefs!.getString("NameComercialSeller"),
      // ! este np va xq' ya lo hace en el backend -> "pedido_fecha": dateID
      "pedido_fecha": dateID
      // }
    }));
    var request =
        await http.post(Uri.parse("$serverLaravel/api/pedidos-shopifies"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              // "data": {
              "NumeroOrden": numero.toString(),
              "DireccionShipping": direccion.toString(),
              "NombreShipping": nombre.toString(),
              "TelefonoShipping": telefono.toString(),
              "PrecioTotal": precio.toString(),
              "Observacion": observacion.toString(),
              "CiudadShipping": ciudad.toString(),
              "users": sharedPrefs!.getString("idComercialMasterSeller"),
              "Estado_Interno": estado.toString(),
              "IdComercial": sharedPrefs!.getString("idComercialMasterSeller"),
              "ProductoP": productoP.toString(),
              "ProductoExtra": productoE.toString(),
              "Cantidad_Total": cantidadT.toString(),
              "Name_Comercial": sharedPrefs!.getString("NameComercialSeller"),
              "Marca_T_I": fecha.toString(),
              "Fecha_Confirmacion": fechaC.toString(),
              "Tienda_Temporal": sharedPrefs!.getString("NameComercialSeller"),
              "pedido_fecha": dateID
              // ! este np va xq' ya lo hace en el backend -> "pedido_fecha": dateID
              // }
            }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future createOrder(
      numero,
      direccion,
      nombre,
      telefono,
      precio,
      observacion,
      ciudad,
      estado,
      productoP,
      productoE,
      cantidadT,
      fecha,
      fechaC,
      dateID) async {
    var request = await http.post(Uri.parse("$server/api/pedidos-shopifies"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "NumeroOrden": numero.toString(),
            "DireccionShipping": direccion.toString(),
            "NombreShipping": nombre.toString(),
            "TelefonoShipping": telefono.toString(),
            "PrecioTotal": precio.toString(),
            "Observacion": observacion.toString(),
            "CiudadShipping": ciudad.toString(),
            "users": sharedPrefs!.getString("idComercialMasterSeller"),
            "Estado_Interno": estado.toString(),
            "IdComercial": sharedPrefs!.getString("idComercialMasterSeller"),
            "ProductoP": productoP.toString(),
            "ProductoExtra": productoE.toString(),
            "Cantidad_Total": cantidadT.toString(),
            "Name_Comercial": sharedPrefs!.getString("NameComercialSeller"),
            "Marca_T_I": fecha.toString(),
            "Fecha_Confirmacion": fechaC.toString(),
            "Tienda_Temporal": sharedPrefs!.getString("NameComercialSeller"),
            "pedido_fecha": dateID
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      // return decodeData;
      return [true, decodeData['data']['id']];
    }
  }

  Future createDateOrderLaravel(date) async {
    print(json.encode({
      "fecha": date.toString(),
    }));
    var request =
        await http.post(Uri.parse("$serverLaravel/api/shopify/pedidos"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "fecha": date.toString(),
            }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      print("metodo: $decodeData");
      return decodeData;
      // return [true, decodeData['data']['id']];
    }
  }

  Future createDateOrder(date) async {
    var request = await http.post(Uri.parse("$server/api/shopify/pedidos/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "date": date.toString(),
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  getOrdersForReturns(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&populate=operadore&populate=operadore.user&filters[operadore][user][id][\$eq]=${sharedPrefs!.getString("id")}&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForReturnsTransport(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&populate=operadore&populate=operadore.user&filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora")}&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForReturnsSellers(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&populate=operadore&populate=operadore.user&filters[IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller")}&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForReturnsLogistic(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&populate=operadore&populate=operadore.user&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersByMonth() async {
    String id = Get.parameters['id'].toString();

    var request = await http.post(
      Uri.parse("$server/api/balance/vfdates/$id"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['value'];
    // return decodeData;
  }

  // updOiS/pedidos-shopifies
  Future updateOrderInteralStatusLaravel(text, id) async {
    try {
      var request = await http.post(
          Uri.parse("$serverLaravel/api/updOiS/pedidos-shopifies"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            // "data": {
            "id": id,
            "estado_interno": text,
            "name_comercial":
                sharedPrefs!.getString("NameComercialSeller").toString(),
            "fecha_confirmacion":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
            // }
          }));

      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderInteralStatus(text, id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Interno": text,
                  "Name_Comercial":
                      sharedPrefs!.getString("NameComercialSeller").toString(),
                  "Fecha_Confirmacion":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderInteralStatusHistorial(text, id) async {
    int res = 0;

    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Interno": text,
                  "Fecha_Confirmacion":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future updateOrderInteralStatusLogistic(text, id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Interno": text,
                  "Estado_Logistico": "PENDIENTE"
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderLogisticStatus(text, id) async {
    int res = 0;

    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Logistico": text,
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future updateOrderLogisticStatusPrint(text, id) async {
    int res = 0;
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Logistico": text,
                  "Estado_Interno": "CONFIRMADO",
                  "Fecha_Entrega":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  "Marca_Tiempo_Envio":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future updateOrderInteralStatusInOrderPrinted(text, id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {"Estado_Logistico": text, "Marca_Tiempo_Envio": ""}
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderInfo(city, name, address, phone, quantity, product,
      extraProduct, totalPrice, observation) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "CiudadShipping": city,
            "NombreShipping": name,
            "DireccionShipping": address,
            "TelefonoShipping": phone,
            "Cantidad_Total": quantity,
            "ProductoP": product,
            "ProductoExtra": extraProduct,
            "PrecioTotal": totalPrice,
            "Observacion": observation,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  // ! updateOrderInfoSellerLaravel
  Future updateOrderInfoSellerLaravel(city, name, address, phone, quantity,
      product, extraProduct, totalPrice, observation, id) async {
    var request = await http.post(
        Uri.parse("$serverLaravel/api/updtOrdIS/pedidos-shopifies"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          // "data": {
          "id": id,
          "ciudad_shipping": city,
          "nombre_shipping": name,
          "direccion_shipping": address,
          "telefono_shipping": phone,
          "cantidad_total": quantity,
          "producto_p": product,
          "producto_extra": extraProduct,
          "precio_total": totalPrice,
          "observacion": observation,
          // }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderInfoSeller(city, name, address, phone, quantity, product,
      extraProduct, totalPrice, observation, id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "CiudadShipping": city,
            "NombreShipping": name,
            "DireccionShipping": address,
            "TelefonoShipping": phone,
            "Cantidad_Total": quantity,
            "ProductoP": product,
            "ProductoExtra": extraProduct,
            "PrecioTotal": totalPrice,
            "Observacion": observation,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderInfoNumber(phone) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "TelefonoShipping": phone,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderInfoNumberOperator(phone, id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "TelefonoShipping": phone,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderInfoHistorial(
      cantidad,
      precio,
      producto,
      direccion,
      ciudad,
      comentario,
      tipoDePago,
      nombreCliente,
      productoExtra,
      observacion,
      telefono,
      id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "CiudadShipping": ciudad,
            "NombreShipping": nombreCliente,
            "DireccionShipping": direccion,
            "TelefonoShipping": telefono,
            "Cantidad_Total": cantidad,
            "ProductoP": producto,
            "ProductoExtra": productoExtra,
            "PrecioTotal": precio,
            "Observacion": observacion,
            "TipoPago": tipoDePago,
            "Comentario": comentario,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  postDoc(XFile xFile) async {
    try {
      String url = '$server/api/upload';
      var stream =
          new http.ByteStream(DelegatingStream.typed(xFile.openRead()));

      var uri = Uri.parse(url);
      int length = await xFile.length();
      var request = http.MultipartRequest("POST", uri);
      // request.headers["authorization"] = token;

      var multipartFile = http.MultipartFile('files', stream, length,
          filename: basename(
              "${xFile.name}.${xFile.mimeType.toString().split("/")[1]}"),
          contentType: MediaType(xFile.mimeType.toString(),
              xFile.mimeType.toString().split("/")[1]));

      request.files.add(multipartFile);
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodeData = await json.decode(responseString);
        // print(decodeData[0]['url']);
        return [true, decodeData[0]['url']];
      } else {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodeData = await json.decode(responseString);

        return [false];
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future updateOrderStatusOperatorEntregado(
      status, tipoDePago, comentario, archivo) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "TipoPago": tipoDePago,
            "Archivo": archivo,
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorEntregadoHistorial(
      status, tipoDePago, comentario, archivo, id) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/pedidos-shopifies/$id?populate=users.vendedores&populate=transportadora"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "TipoPago": tipoDePago,
            "Archivo": archivo,
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return decodeData;
    }
  }

  Future updateDateDeliveryAndState(id, fecha_entrega, status) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {"Fecha_Entrega": fecha_entrega, "Status": status}
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorNoEntregado(
      status, comentario, archivo) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": archivo,
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorNoEntregadoHistorial(
      // ?populate=users.vendedores&populate=transportadora
      status,
      comentario,
      archivo,
      id) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/pedidos-shopifies/$id?populate=users.vendedores&populate=transportadora"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": archivo,
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    print("noentregado -> $response");
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorGeneral(status, comentario) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": "",
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorGeneralHistorial(
      // ?populate=users.vendedores&populate=transportadora
      status,
      comentario,
      id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {"Status": status, "Comentario": comentario, "Archivo": ""}
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorGeneralHistorialAndDate(
      status, comentario, id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": "",
            "Fecha_Entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorPedidoProgramado(
      status, comentario, date) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": "",
            "Fecha_Entrega": date
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderFechaEntrega(id, date) async {
    //  String id = Get.parameters['id'].toString();
    print("id de pedido=" + id);
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {"Fecha_Confirmacion": date}
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderStatusOperatorPedidoProgramadoHistorial(
      status, comentario, date, id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Status": status,
            "Comentario": comentario,
            "Archivo": "",
            "Fecha_Entrega": date
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderRouteAndTransport(route, transport, id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {"ruta": route, "transportadora": transport}
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future createRoute(text) async {
    try {
      var request = await http.post(Uri.parse("$server/api/rutas"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "data": {"Titulo": text}
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future createSubRoute(route, text, idTransport) async {
    try {
      var request = await http.post(Uri.parse("$server/api/sub-rutas"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "data": {"Titulo": text, "ruta": route, "ID_Operadora": idTransport}
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderSubRouteAndOperator(subroute, operator, id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {"sub_ruta": subroute, "operadore": operator}
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPayState(id, file) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {"Estado_Pagado": "PAGADO", "Url_Pagado_Foto": file}
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPayStateLogistic(id, file) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Pago_Logistica": "PAGADO",
                  "Url_P_L_Foto": file
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPayStateLogisticUser(id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Pago_Logistica": "RECIBIDO",
                  "ComentarioRechazado": ""
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPendienteStateLogisticUser(id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Pago_Logistica": "PENDIENTE",
                  "ComentarioRechazado": ""
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPayStateLogisticUserRechazado(
      id, comentarioRechazado) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Pago_Logistica": "RECHAZADO",
                  "ComentarioRechazado": comentarioRechazado
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderPayStateLogisticRestart(id) async {
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Pago_Logistica": "PENDIENTE",
                  "Url_P_L_Foto": ""
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getOrdersByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersByIDTransportC(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersByIDOperator(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta&populate=novedades"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersByIDTransport(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta&populate=novedades"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    print(decodeData["data"]);
    return decodeData['data'];
  }

  Future getOrdersByIDSeller(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersByIDLogistic(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersByIDHistorialTransport(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta&populate=novedades"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }
  // ! modificación

  Future getOrdersByIDHistorial(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta&populate=novedades"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrderByID(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrderByIDHistory(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies/$id?populate=users&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=users.vendedores&populate=operadore&populate=operadore.user&populate=pedido_fecha&populate=sub_ruta&populate=novedades"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getWithDrawalByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros/$id?populate=users_permissions_user"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getdtsOrdenRetiro() async {
    String id = Get.parameters['id'].toString();
    try {
      var request = await http.get(
          Uri.parse("$serverLaravel/api/orden_retiro/$id"),
          headers: {'Content-Type': 'application/json'});
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future withdrawalPost(amount) async {
    print(sharedPrefs!.getString("email").toString());
    try {
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/seller/ordenesretiro/withdrawal/${sharedPrefs!.getString("idComercialMasterSeller")}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "monto": amount,
            "fecha":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            "email": sharedPrefs!.getString("email").toString(),
            "id_vendedor":
                "${sharedPrefs!.getString("idComercialMasterSeller")}"
            // "id_vendedor" : "5"
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future withdrawalPut(code) async {
    String id = Get.parameters['id'].toString();

    try {
      var request = await http.put(Uri.parse("$server/api/ordenes-retiros/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "data": {"Codigo": code, "Estado": "APROBADO"}
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  //ROUTES

  Future getRoutes() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/rutas?populate=transportadoras&populate=sub_rutas&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getRoutesForTransporter() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/rutas?populate=transportadoras&populate=sub_rutas&filters[transportadoras][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getSubRoutesSelect() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/operadores?populate=sub_ruta&populate=transportadora&filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getSubRoutesSelectAll() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/operadores?populate=sub_ruta&populate=transportadora&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getSubRoutes() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/sub-rutas?populate=transportadoras&populate=ruta&populate=ruta.transportadoras&populate=ruta.transportadoras.users_permissions_user&filters[ruta][transportadoras][users_permissions_user][id][\$eq]=${sharedPrefs!.getString("id").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  //TRANSPORTS
  Future getAllTransportators() async {
    var request = await http.get(
      Uri.parse("$server/api/transportadoras?pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersSCalendar(id, month) async {
    var request = await http.post(
        Uri.parse("$server/api/pedidos/filter/transporter/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({"mes": month, "year": DateTime.now().year.toString()}));
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  Future getTransportsByRoute(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/transportadoras?populate=rutas&filters[rutas][id][\$eq]=$search&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportPRV(code) async {
    print(
        "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&populate=users&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][1][NumeroOrden][\$contains]=$code&filters[Estado_Logistico][\$eq]=ENVIADO&filters&filters[\$or][2][CiudadShipping][\$contains]=$code&filters[\$or][3][NombreShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][ProductoP][\$contains]=$code&filters[\$or][7][ProductoExtra][\$contains]=$code&filters[\$or][8][PrecioTotal][\$contains]=$code&filters[\$or][9][Status][\$contains]=$code&filters[\$or][10][Estado_Interno][\$contains]=$code&filters[\$or][11][Estado_Logistico][\$contains]=$code&filters[\$or][12][pedido_fecha][Fecha][\$contains]=$code&filters[\$or][13][sub_ruta][Titulo][\$contains]=$code&filters[\$or][14][operadore][user][username][\$contains]=$code&filters[\$or][15][Cantidad_Total][\$contains]=$code&filters[Status][\$eq]=PEDIDO PROGRAMADO&filters[Estado_Interno][\$eq]=CONFIRMADO&pagination[limit]=-1");
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&populate=users.vendedores&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][1][NumeroOrden][\$contains]=$code&filters[Estado_Logistico][\$eq]=ENVIADO&filters&filters[\$or][2][CiudadShipping][\$contains]=$code&filters[\$or][3][NombreShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][ProductoP][\$contains]=$code&filters[\$or][7][ProductoExtra][\$contains]=$code&filters[\$or][8][PrecioTotal][\$contains]=$code&filters[\$or][9][Status][\$contains]=$code&filters[\$or][10][Estado_Interno][\$contains]=$code&filters[\$or][11][Estado_Logistico][\$contains]=$code&filters[\$or][12][pedido_fecha][Fecha][\$contains]=$code&filters[\$or][13][sub_ruta][Titulo][\$contains]=$code&filters[\$or][14][operadore][user][username][\$contains]=$code&filters[\$or][15][Cantidad_Total][\$contains]=$code&filters[Status][\$eq]=PEDIDO PROGRAMADO&filters[Estado_Interno][\$eq]=CONFIRMADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForOperator(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][operadore][user][id][\$eq]=${sharedPrefs!.getString("id").toString()}&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$eq]=PEDIDO PROGRAMADO&filters[\$or][3][Status][\$eq]=REAGENDADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForOperatorState(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&populate=novedades&filters[\$and][0][operadore][user][id][\$eq]=${sharedPrefs!.getString("id").toString()}&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][3][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForOperatorStateByCode(params) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&populate=novedades&filters[operadore][user][id][\$eq]=${sharedPrefs!.getString("id").toString()}&filters[Status][\$ne]=PEDIDO PROGRAMADO$params&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForOperatorStateForCode(params) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[operadore][user][id][\$eq]=${sharedPrefs!.getString("id").toString()}&filters[Status][\$ne]=PEDIDO PROGRAMADO$params&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportOperatorFiltersState(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][operadore][id][\$eq]=$id&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][3][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportFiltersState(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][3][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportState(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][3][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportStateCode(codes) async {
    String code = "";
    if (codes.toString().length > 14) {
      code = codes.toString().substring(15);
    } else {
      code = codes.toString();
    }

    try {
      var request = await http.get(
        Uri.parse(
            "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][0][NumeroOrden][\$contains]=$code&filters[\$or][1][Marca_Tiempo_Envio][\$contains]=$code&filters[\$or][2][Fecha_Entrega][\$contains]=$code&filters[\$or][3][NombreShipping][\$eq]=$code&filters[\$or][4][CiudadShipping][\$contains]=$code&filters[\$or][5][DireccionShipping][\$eq]=$code&filters[\$or][6][TelefonoShipping][\$contains]=$code&filters[\$or][7][Cantidad_Total][\$contains]=$code&filters[\$or][8][ProductoP][\$contains]=$code&filters[\$or][9][ProductoExtra][\$contains]=$code&filters[\$or][10][PrecioTotal][\$contains]=$code&filters[\$or][11][Observacion][\$contains]=$code&filters[\$or][12][Comentario][\$contains]=$code&filters[\$or][13][TipoPago][\$contains]=$code&filters[\$or][14][sub_ruta][Titulo][\$contains]=$code&filters[\$or][15][operadore][user][username][\$contains]=$code&filters[\$or][16][Estado_Pagado][\$contains]=$code&filters[\$or][17][Estado_Devolucion][\$contains]=$code&filters[\$or][18][DO][\$contains]=$code&filters[\$or][19][DL][\$contains]=$code&filters[\$or][20][Marca_T_D][\$contains]=$code&filters[\$or][21][Marca_T_I][\$contains]=$code&filters[\$or][22][Estado_Pagado][\$contains]=$code&filters[Status][\$ne]=PEDIDO PROGRAMADO&pagination[limit]=-1"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);
      return decodeData['data'];
    } catch (e) {
      return [];
    }
  }

  getOperatorsByTransporter() async {
    //http://localhost:1337/api/TRANSPORTADORAS/6?populate=operadores.user
    String url =
        "http://localhost:1337/api/TRANSPORTADORAS/${sharedPrefs!.getString("idTransportadora").toString()}?populate=operadores.user";

    var request = await http
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersCountersTransport(
      List populate, List and, List defaultAnd, List or) async {
    print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
    print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');

    List filtersAndAll = [];
    filtersAndAll.addAll(and);

    filtersAndAll.addAll(defaultAnd);

    var request = await http.post(
        Uri.parse("$serverLaravel/api/pedidos-shopify/products/counters"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeTransportadora"),
          "end": sharedPrefs!.getString("dateHastaTransportadora"),
          "or": or,
          "and": filtersAndAll,
          "not": []
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersCountersSeller(
      List populate, List and, List or, arrayFiltersNotEq) async {
    print('start: ${sharedPrefs!.getString("dateDesdeVendedor")}');
    print('end: ${sharedPrefs!.getString("dateDesdeVendedor")}');

    var request = await http.post(
        Uri.parse("$serverLaravel/api/pedidos-shopify/products/counters"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeVendedor"),
          "end": sharedPrefs!.getString("dateHastaVendedor"),
          "or": or,
          "and": and,
          "not": arrayFiltersNotEq
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForSellerStateSearchForDateSeller(
      code,
      arrayFiltersOrCont,
      arrayFiltersAndEq,
      List arrayFiltersNotEq,
      List arrayDefaultAnd,
      List arrayDefaultOr,
      List populate,
      currentPage,
      sizePage) async {
    String url = "$server/api/shopify/pedidos/filter/seller/dates?";

    List<dynamic> filtersOrCont = [];
    List<dynamic> filtersAndEq = [];
    var bodyParams;

    for (var filter in arrayFiltersAndEq) {
      filtersAndEq.add(filter);
    }

    for (var filter in arrayDefaultOr) {
      filtersOrCont.add({filter['filter']: filter['value']});
    }
    for (var filter in arrayDefaultAnd) {
      filtersAndEq.add({filter['filter']: filter['value']});
    }

    if (code != "") {
      for (var filter in arrayFiltersOrCont) {
        filtersOrCont.add({
          filter['filter']: {'\$contains': code}
        });
      }
    }
    // print(sharedPrefs!.getString("dateDesdeVendedor"));
    // print(sharedPrefs!.getString("dateHastaVendedor"));
    var request = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeVendedor"),
          "end": sharedPrefs!.getString("dateHastaVendedor"),
          "populate": jsonEncode(populate),
          "not": jsonEncode(arrayFiltersNotEq),
          "or": jsonEncode(filtersOrCont),
          "and": jsonEncode(filtersAndEq),
          "currentPage": currentPage,
          "sizePage": sizePage
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData;
  }

  getOrdersForSellerStateSearchForDateSellerLaravel(
      code,
      arrayFiltersOrCont,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      sizePage,
      search,
      not,
      sortField) async {
    int res = 0;

    List<dynamic> filtersAndAll = [];
    filtersAndAll.addAll(arrayfiltersDefaultAnd);
    filtersAndAll.addAll(arrayFiltersAnd);

    // print(sharedPrefs!.getString("dateDesdeVendedor"));
    // print(sharedPrefs!.getString("dateHastaVendedor"));
    // print("todo and: \n $filtersAndAll");

    String urlnew = "$serverLaravel/api/pedidos-shopify/filter";

    try {
      var requestlaravel = await http.post(Uri.parse(urlnew),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": sharedPrefs!.getString("dateDesdeVendedor"),
            "end": sharedPrefs!.getString("dateHastaVendedor"),
            "page_size": sizePage,
            "page_number": currentPage,
            "or": arrayFiltersOrCont,
            "not": not,
            "sort": sortField,
            "and": filtersAndAll,
            "search": search
          }));

      var responselaravel = await requestlaravel.body;
      var decodeDataL = json.decode(responselaravel);
      int totalRes = decodeDataL['total'];

      var response = await requestlaravel.body;
      var decodeData = json.decode(response);

      if (requestlaravel.statusCode != 200) {
        res = 1;
        // print("" + res.toString());
      } else {
        // print(' $totalRes');
      }
      // print("" + res.toString());
      return decodeData;
    } catch (e) {
      print("error!!!: $e");
      res = 2;
      // print("" + res.toString());
    }
  }

  getOrdersDashboardLogisticRoutesLaravel(
      List populate, List and, List defaultAnd, routeId) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');
    List<dynamic> filtersAndAll = [];

    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);

    var request = await http.post(
        Uri.parse("$serverLaravel/api/pedidos-shopify/routes/count"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeLogistica"),
          "end": sharedPrefs!.getString("dateHastaLogistica"),
          "search": "",
          "or": [],
          "and": filtersAndAll,
          "route_id": routeId
        }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForSellerStateSearchForDateTransporter(
      code,
      arrayFiltersOrCont,
      arrayFiltersAndEq,
      List arrayFiltersNotEq,
      List arrayDefaultAnd,
      List arrayDefaultOr,
      List populate,
      currentPage,
      sizePage) async {
    String url = "$server/api/shopify/pedidos/filter/seller/dates?";

    List<dynamic> filtersOrCont = [];
    List<dynamic> filtersAndEq = [];
    var bodyParams;

    for (var filter in arrayFiltersAndEq) {
      filtersAndEq.add(filter);
    }

    for (var filter in arrayDefaultOr) {
      filtersOrCont.add({filter['filter']: filter['value']});
    }
    for (var filter in arrayDefaultAnd) {
      filtersAndEq.add({filter['filter']: filter['value']});
    }

    if (code != "") {
      for (var filter in arrayFiltersOrCont) {
        filtersOrCont.add({
          filter['filter']: {'\$contains': code}
        });
      }
    }
    print(sharedPrefs!.getString("dateDesdeTransportadora"));
    print(sharedPrefs!.getString("dateHastaTransportadora"));
    var request = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "start": sharedPrefs!.getString("dateDesdeTransportadora"),
          "end": sharedPrefs!.getString("dateHastaTransportadora"),
          "populate": jsonEncode(populate),
          "not": jsonEncode(arrayFiltersNotEq),
          "or": jsonEncode(filtersOrCont),
          "and": jsonEncode(filtersAndEq),
          "currentPage": currentPage,
          "sizePage": sizePage
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData;
  }

  //  ! LA MIA --------- ↓↓↓
  Future updateDateDeliveryAndStateLaravel(id, fechaEntrega, status) async {
    print("aqui ->  $id+$fechaEntrega+$status");
    var request =
        await http.post(Uri.parse("$serverLaravel/api/upd/pedidos-shopifies"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "data": [
                {"fecha_Entrega": fechaEntrega},
                {"status": status}
              ],
              "id": id
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  getOrdersByIdLaravel2(int id, List<dynamic> data) {
    // Accede a la lista de pedidos dentro de la propiedad "data"
    for (var pedido in data) {
      if (pedido['id'] == id) {
        // print("se logro");
        return pedido;
      }
    }
    return null;
  }
  // getOrdersByIdLaravel(id)async{
  //   try {
  //     var response = await http.get(Uri.parse("$serverLaravel/api/pedidos-shopifies/$id"),
  //                   headers: {'Content-Type': 'application/json'});

  //   if (response.statusCode == 200) {
  //       var decodeData = json.decode(response.body);
  //       // print(decodeData);
  //       return decodeData;
  //     } else if (response.statusCode == 400) {
  //       print("Error 400: Bad Request");
  //     } else {
  //       print("Error ${response.statusCode}: ${response.reasonPhrase}");
  //     }
  //   } catch (error) {
  //     print("Ocurrió un error durante la solicitud del pedido: $error");
  //   }
  // }

  last30rows() async {
    try {
      var response = await http.get(
          Uri.parse("$serverLaravel/api/transacciones-lst"),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  allTransactions() async {
    try {
      var response = await http.get(
          Uri.parse("$serverLaravel/api/transacciones"),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  postCredit(String idComercial, String monto, String idOrigen, String codigo,
      String origen, String comentario) async {
    try {
      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String? generatedBy = sharedPrefs!.getString("id");
      var response =
          await http.post(Uri.parse("$serverLaravel/api/transacciones/credit"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "act_date": formattedDate,
                "id": idComercial,
                "monto": monto,
                "id_origen": idOrigen,
                "codigo": codigo,
                "origen": origen,
                "comentario": comentario,
                "state": 1,
                "generated_by": generatedBy
              }));
      if (response.statusCode != 200) {
        return 1;
      } else {
        return 0;
      }
    } catch (error) {
      return 2;
    }
  }

  postDebit(String idComercial, String monto, String idOrigen, String codigo,
      String origen, String comentario) async {
    try {
      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String? generatedBy = sharedPrefs!.getString("id");

      var response =
          await http.post(Uri.parse("$serverLaravel/api/transacciones/debit"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "act_date": formattedDate,
                "id": idComercial,
                "monto": monto,
                "id_origen": idOrigen,
                "codigo": codigo,
                "origen": origen,
                "comentario": comentario,
                "state": 1,
                "generated_by": generatedBy
              }));
      if (response.statusCode != 200) {
        return 1;
      } else {
        return 0;
      }
    } catch (error) {
      return 2;
    }
  }

  getOrdersOper(List populate, List and, List defaultAnd, List or, currentPage,
      sizePage, search, List multifilter) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);
    try {
      print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
      print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');
      var response =
          await http.post(Uri.parse("$serverLaravel/api/operator/filter"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                // "start": sharedPrefs!.getString("dateDesdeTransportadora"),
                // "end": sharedPrefs!.getString("dateHastaTransportadora"),
                // "start": "1/1/2023",
                // "end": "1/1/2200",
                "or": or,
                "and": filtersAndAll,
                "page_size": sizePage,
                "page_number": currentPage,
                "search": search,
                // "sort": sortField,
                "not": [],
                "multifilter": multifilter
              }));
      // print(response);
      // print("sort -> $sortField");
      print("and -> $and");
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getOrdersForSellerStateSearchForDateTransporterLaravel(
      List populate,
      List and,
      List defaultAnd,
      List or,
      currentPage,
      sizePage,
      search,
      sortField) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);
    try {
      print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
      print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');
      var response = await http.post(
          Uri.parse("$serverLaravel/api/pedidos-shopify/filter"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": sharedPrefs!.getString("dateDesdeTransportadora"),
            "end": sharedPrefs!.getString("dateHastaTransportadora"),
            "or": or,
            "and": filtersAndAll,
            "page_size": sizePage,
            "page_number": currentPage,
            "search": search,
            "sort": sortField,
            "not": []
          }));
      print("sort -> $sortField");
      print("and -> $and");
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getOrdersLogisticLaravel(List populate, List and, List defaultAnd, List or,
      currentPage, sizePage, search, sortField) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);

    filtersAndAll.addAll(defaultAnd);
    // String startDate = "1/1/2000";
    // String endDate = "1/1/2200";

    // if (search == "") {
    //   startDate = sharedPrefs!.getString("dateOperatorState").toString();
    //   endDate = sharedPrefs!.getString("dateOperatorState").toString();
    // }

    try {
      print('start: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
      print('end: ${sharedPrefs!.getString("dateHastaTransportadora")}');
      var response = await http.post(
          Uri.parse("$serverLaravel/api/pedidos-shopify/filter"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": sharedPrefs!.getString("dateOperatorState").toString(),
            "end": sharedPrefs!.getString("dateOperatorState").toString(),
            "or": or,
            "and": filtersAndAll,
            "page_size": sizePage,
            "page_number": currentPage,
            "search": search,
            "sort": sortField,
            "not": []
          }));
      print("sort -> $sortField");
      print("and -> $and");
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // ! ******************************************************************************
  getWithdrawalSellers(code) async {
    var request = await http.get(
      Uri.parse(
          "$serverLaravel/api/seller/ordenesretiro/retiro/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  getWithdrawalSellersTest(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros?populate=users_permissions_user&filters[\$and][0][users_permissions_user][id][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  getOrdersForSellerState(code) async {
    print("fecha de consulta: " +
        sharedPrefs!.getString("dateOperatorState").toString());
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=users&populate=users.vendedores&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][IdComercial][\$eq]=12/5/2023&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][3][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForSellerStateSearch(
      code, arrayFiltersOrCont, arrayFiltersAndEq, arraysFiltersRanges) async {
    String url =
        "$server/api/pedidos-shopifies?populate=transportadora&populate=users&populate=users.vendedores&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[Status][\$ne]=PEDIDO PROGRAMADO&filters[IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}";

    String filtersOrCont = '';
    int numberFilter = 0;

    if (code != "") {
      for (var filter in arrayFiltersOrCont) {
        filtersOrCont +=
            "&filters[\$or][$numberFilter][${filter['filter']}][\$contains]=$code";
        numberFilter++;
      }
    }

    var filtersAndEq = "";
    for (var filter in arrayFiltersAndEq) {
      print("filter:" + filter['filter'].toString());
      print("value:" + filter['value'].toString());

      filtersAndEq +=
          "&filters[\$and][$numberFilter][${filter['filter']}][\$eq]=${filter['value']}";
      numberFilter++;
    }

    var filterRanges = '';
    for (var filter in arraysFiltersRanges) {
      // print("filter:" + filter['filter'].toString());
      // print("value:" + filter['value'].toString());

      filterRanges +=
          "&filters[\$and][$numberFilter][${filter['filter']}][${filter['operator']}]=${filter['value']}";

      numberFilter++;
    }

    var configPagination = "&pagination[limit]=-1";
    url += filtersOrCont + filtersAndEq + filterRanges + configPagination;
    // "$server/api/pedidos-shopifies?populate=transportadora&populate=users&populate=users.vendedores&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[Status][\$ne]=PEDIDO PROGRAMADO&filters[IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$or][0][NumeroOrden][\$contains]=$code&filters[\$or][1][Fecha_Entrega][\$contains]=$code&filters[\$or][2][CiudadShipping][\$contains]=$code&filters[\$or][3][NombreShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][Cantidad_Total][\$contains]=$code&filters[\$or][7][ProductoP][\$contains]=$code&filters[\$or][8][ProductoExtra][\$contains]=$code&filters[\$or][9][PrecioTotal][\$contains]=$code&filters[\$or][10][Comentario][\$contains]=$code&filters[\$or][11][Status][\$contains]=$code&filters[\$or][12][Estado_Interno][\$contains]=$code&filters[\$or][13][Estado_Logistico][\$contains]=$code&filters[\$or][14][Estado_Devolucion][\$contains]=$code&filters[\$or][15][Marca_T_I][\$contains]=$code&pagination[limit]=-1"
    print('se ha actualizado ' + url);
    var request = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData['data'];
  }

  getOrdersForTransportStateLogistic(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=users&populate=users.vendedores&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][NumeroOrden][\$contains]=$code&filters[\$or][1][Status][\$ne]=PEDIDO PROGRAMADO&filters[\$and][2][Fecha_Entrega][\$eq]=${sharedPrefs!.getString("dateOperatorState")}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportStateLogisticForCode(code, url) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=users&populate=users.vendedores&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[Status][\$ne]=PEDIDO PROGRAMADO$url&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportStateOnlyCode(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForSellerStateOnlyCode(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$and][1][NumeroOrden][\$contains]=$code&filters[\$or][2][Status][\$ne]=PEDIDO PROGRAMADO&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getWithdrawalsSellersListWallet() async {
    //delete
    print(' getWithdrawalsSellersListWallet');

    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros?populate=users_permissions_user&filters[users_permissions_user][id][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getWithdrawalsSellersListWalletById() async {
    String id = Get.parameters['idComercial'].toString();

    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros?populate=users_permissions_user&filters[users_permissions_user][id][\$eq]=${id}&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getWithdrawalsSellersListWalletByCodeAndSearch(code, search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros?populate=users_permissions_user&filters[Estado][\$eq]=${code}&filters[\$or][0][users_permissions_user][username][\$contains]=${search}&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

//
  getWalletValue() async {
    var id =
        "$server/api/balance/${sharedPrefs!.getString("idComercialMasterSeller").toString()}";
    print("id:" + id);
    var request = await http.get(
      Uri.parse(
          "$server/api/balance/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['value'];
  }

  getWalletValueById(id) async {
    var request = await http.get(
      Uri.parse("$server/api/balance/${id}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['value'];
  }

  getWalletValueByIdVF(id) async {
    var request = await http.get(
      Uri.parse("$server/api/balance/vf/${id}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['value'];
  }

  //OPERATOR
  Future getOperatorBySubRoute(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/operadores?populate=sub_ruta&populate=user&filters[sub_ruta][id][\$eq]=$search&filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOperatorByTransport() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/operadores?populate=sub_ruta&populate=user&populate=transportadora&filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    // print(response);

    return decodeData['data'];
  }

  Future createOperatorGeneral(
      phone, costOperator, subruta, idTransport) async {
    var request = await http.post(Uri.parse("$server/api/operadores"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Telefono": phone,
            "Costo_Operador": costOperator,
            "transportadora": idTransport,
            "sub_ruta": subruta,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future createOperator(user, mail, id, code, access) async {
    var request = await http.post(Uri.parse("$server/api/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "roles_front": "4",
          "password": "123456789",
          "FechaAlta":
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          "operadore": id,
          "role": "1",
          "confirmed": true,
          "CodigoGenerado": code,
          "PERMISOS": access
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 201) {
      return [false, ""];
    } else {
      return [true, decodeData['id']];
    }
  }

  Future getOperatorsTransport(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=operadore&populate=operadore.transportadora&populate=operadore.sub_ruta&filters[\$or][0][username][\$contains]=$search&filters[\$and][1][operadore][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$and][2][roles_front][Titulo][\$eq]=OPERADOR&filters[\$or][3][operadore][Costo_Operador][\$contains]=$search&filters[\$or][4][operadore][sub_ruta][Titulo][\$contains]=$search&filters[\$or][5][operadore][transportadora][Nombre][\$contains]=$search&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getAllOperatorsAndByTransport(id) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=operadore&populate=operadore.transportadora&populate=operadore.sub_ruta&filters[\$and][0][operadore][transportadora][id][\$eq]=${id.toString()}&filters[\$and][1][roles_front][Titulo][\$eq]=OPERADOR&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getAllOperators() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=operadore&populate=operadore.transportadora&populate=operadore.sub_ruta&filters[\$and][0][roles_front][Titulo][\$eq]=OPERADOR&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getOperatorsGeneralByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse(
          "$server/api/users/$id?populate=roles_front&populate=operadore&populate=operadore.transportadora&populate=operadore.sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future updateOperatorGeneral(subroute, phone, cost) async {
    String id = Get.parameters['id_Operator'].toString();
    var request = await http.put(Uri.parse("$server/api/operadores/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "sub_ruta": subroute,
            "Telefono": phone,
            "Costo_Operador": cost,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOperator(user, mail) async {
    String id = Get.parameters['id'].toString();
    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future deleteReportSeller(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$serverLaravel/api/generate-reports/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteReportLogistic(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/saldo-ls/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteUser(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);
      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteOperator(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/operadores/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteSellers(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/vendedores/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteTransporter(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/transportadoras/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future deleteWithdrawal(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/ordenes-retiros/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future getReportsSellersByCode() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/generate-reports?filters[Id_Master][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future generateReportSeller(desde, hasta, estado, confirmado) async {
    try {
      var request = await http.post(
          Uri.parse(
              "$server/api/reporte/${sharedPrefs!.getString("idComercialMasterSeller")}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "idMaster": sharedPrefs!.getString("idComercialMasterSeller"),
            "fecha":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            "desde": desde,
            "hasta": hasta,
            "estado": estado,
            "estadoLogistico": confirmado
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future updateWithdrawalRechazado(comentario) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/ordenes-retiros/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Estado": "RECHAZADO",
            "Comentario": comentario,
            "FechaTransferencia":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute} "
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateWithdrawalRealizado(comprobante) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/ordenes-retiros/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Estado": "REALIZADO",
            "Comprobante": comprobante,
            "FechaTransferencia":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute} "
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future createIngresos(date, tipo, persona, motivo, comprobante, monto) async {
    var request = await http.post(Uri.parse("$server/api/ingresos-egresos"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Fecha": "$date ${DateTime.now().hour}:${DateTime.now().minute}",
            "Tipo": tipo,
            "Persona": persona,
            "Motivo": motivo,
            "Comprobante": comprobante,
            "Monto": monto,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future updateIngresos(date, tipo, persona, motivo, comprobante, monto) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/ingresos-egresos/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Fecha": "$date ${DateTime.now().hour}:${DateTime.now().minute}",
            "Tipo": tipo,
            "Persona": persona,
            "Motivo": motivo,
            "Comprobante": comprobante,
            "Monto": monto,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future updateOrdenRetiro(fecha, monto, codigoV, codigoR, fechaT) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/ordenes-retiros/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Fecha": fecha.toString(),
            "Monto": monto.toString(),
            "CodigoGenerado": codigoV.toString(),
            "Codigo": codigoR.toString(),
            "FechaTransferencia": fechaT,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  getIngresosEgresos(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/ingresos-egresos?filters[Persona][\$contains]=$search&sort=id%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getIngresosEgresosByID() async {
    String id = Get.parameters['id'].toString();
    var request = await http.get(
      Uri.parse("$server/api/ingresos-egresos/$id"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getMyBalanceContable() async {
    var request = await http.get(
      Uri.parse("$server/api/contable/saldo"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;

    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  //RETURNS
  Future updateOrderReturnOperator(id) async {
    int res = 0;
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Devolucion": "ENTREGADO EN OFICINA",
                  "DO": "ENTREGADO EN OFICINA",
                  "Marca_T_D":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute} "
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  //RETURNS
  Future updateOrderReturnAll(id) async {
    int res = 0;
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Devolucion": "PENDIENTE",
                  "DO": "PENDIENTE",
                  "DT": "PENDIENTE",
                  "DL": "PENDIENTE",
                  "Marca_T_D": "",
                  "Marca_T_D_T": "",
                  "Marca_T_D_L": ""
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future updateReviewStatus(id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "revisado": true,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderReturnTransport(id, status, mtType) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Estado_Devolucion": status,
            "DT": status,
            mtType:
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute} ",
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderReturnTransportRestart(id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Estado_Devolucion": "PENDIENTE",
            "DO": "PENDIENTE",
            "DT": "PENDIENTE",
            "Marca_T_D": "",
            "Marca_T_D_T": "",
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOrderReturnLogistic(id) async {
    int res = 0;
    try {
      var request =
          await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "data": {
                  "Estado_Devolucion": "EN BODEGA",
                  "DL": "EN BODEGA",
                  "Marca_T_D_L":
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute} "
                }
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
      }
    } catch (e) {
      res = 2;
    }
    return res;
  }

  Future<bool> createNovedad(id_pedido, intento, url_imagen, comment) async {
    var request = await http.post(Uri.parse("$server/api/novedades"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "m_t_novedad":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}",
            "try": intento,
            "url_image": url_imagen,
            "comment": comment,
            "pedidos_shopify": id_pedido
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future getInfoDashboard(
      desde, hasta, tienda, transporte, operator, status) async {
    var request = await http.post(Uri.parse("$server/api/statistic/logistic/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "desde": desde.toString(),
          "hasta": hasta.toString(),
          "tienda": tienda.toString(),
          "transporte": transporte.toString(),
          "operator": operator.toString(),
          "status": status,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getInfoDashboardSellers(
      desde, hasta, transporte, operator, status) async {
    var request = await http.post(Uri.parse("$server/api/statistic/logistic/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "desde": desde.toString(),
          "hasta": hasta.toString(),
          "tienda":
              sharedPrefs!.getString("idComercialMasterSeller").toString(),
          "transporte": transporte.toString(),
          "operator": operator.toString(),
          "status": status,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  //CODE ACOUNT
  Future generateCodeAccount(mail) async {
    var request = await http.post(
      Uri.parse("$server/api/generate-code/$mail"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return decodeData['code'];
    }
  }

  Future updateAccountStatus() async {
    var request = await http.put(
        Uri.parse(
            "$server/api/users/${sharedPrefs!.getString("id").toString()}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"Estado": "VALIDADO"}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateAccountBlock(id) async {
    var request = await http.put(Uri.parse("$serverLaravel/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"blocked": true}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updatenueva(id, datajson) async {
    // {{base_api_laravel}}/api/pedidos-shopify/update/56
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/pedidos-shopify/update/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(datajson));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      return 2;
    }
  }

  Future updateAccountDisBlock(id) async {
    var request = await http.put(Uri.parse("$serverLaravel/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"blocked": false}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future generateLogisticBalance(date) async {
    var request = await http.post(Uri.parse("$server/api/saldo/logis/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dateP": date,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  getLogisticBalance() async {
    var request = await http.get(
      Uri.parse("$server/api/saldo-ls?sort=Fecha%3Adesc&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getLogisticBalanceByDates(start, end) async {
    var request = await http.post(
        Uri.parse(
            "$server/api/saldo/logistic/dates?sort=Fecha%3Adesc&pagination[limit]=-1"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"start": start, "end": end}));
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future createTransporterGeneral(
      nombre, rutas, costo, telefono1, telefono2) async {
    var request = await http.post(Uri.parse("$server/api/transportadoras"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Nombre": nombre.toString(),
            "rutas": rutas,
            "Costo_Transportadora": costo.toString(),
            "Telefono1": telefono1.toString(),
            "Telefono2": telefono2.toString()
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return [false, ""];
    } else {
      return [true, decodeData['data']['id']];
    }
  }

  Future updateTransporterGeneral(
      nombre, rutas, costo, telefono1, telefono2, id) async {
    var request = await http.put(Uri.parse("$server/api/transportadoras/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Nombre": nombre.toString(),
            "rutas": rutas,
            "Costo_Transportadora": costo.toString(),
            "Telefono1": telefono1.toString(),
            "Telefono2": telefono2.toString()
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future createTransporter(user, mail, id, code, access) async {
    var request = await http.post(Uri.parse("$server/api/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
          "roles_front": "3",
          "password": "123456789",
          "FechaAlta":
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          "transportadora": id,
          "role": "1",
          "confirmed": true,
          "CodigoGenerado": code,
          "PERMISOS": access
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 201) {
      return [false, ""];
    } else {
      return [true, decodeData['id']];
    }
  }

  Future updateTransporter(
    user,
    mail,
    id,
  ) async {
    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future getAllTransport(search) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/users?populate=roles_front&populate=transportadora&populate=transportadora.rutas&filters[\$or][0][username][\$contains]=$search&filters[\$or][1][email][\$contains]=$search&filters[\$and][2][roles_front][Titulo][\$eq]=TRANSPORTADOR&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future updateOperatorUser(user, mail) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/users/${sharedPrefs!.getString("id").toString()}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOperatorGeneralUser(user, mail) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/users/${sharedPrefs!.getString("id").toString()}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": user,
          "email": mail,
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updateOperatorGeneralAccount(cost, id) async {
    var request = await http.put(Uri.parse("$server/api/operadores/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            "Costo_Operador": cost,
          }
        }));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  //PASSWORD

  Future updatePassword(password) async {
    var request = await http.put(
        Uri.parse(
            "$server/api/users/${sharedPrefs!.getString("id").toString()}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"password": password}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updatePasswordById(password) async {
    String id = Get.parameters['id'].toString();

    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"password": password}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future updatePasswordByIdGet(password, id) async {
    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"password": password}));
    var response = await request.body;
    var decodeData = json.decode(response);

    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  //--wallet-laravel
  getWithdrawalsSellersListWalletLaravel(
      currentPage, sizePage, sortField) async {
    int res = 0;
    try {
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/seller/ordenesretiro/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "page_size": sizePage,
            "page_number": currentPage,
            "sort": sortField,
          }));

      var responselaravel = await request.body;
      var decodeDataL = json.decode(responselaravel);
      int totalRes = decodeDataL['total'];

      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        res = 1;
        print("res:" + res.toString());
      } else {
        print('Total_L: $totalRes');
      }
      print("res:" + res.toString());
      return decodeData;
    } catch (e) {
      return (e);
    }
  }

  getOrdenesRetiroCount(id) async {
    int res = 0;
    try {
      print("id > $id");
      var request = await http.get(
          Uri.parse("$serverLaravel/api/seller/ordenesretiro/ret-count/$id"),
          headers: {'Content-Type': 'application/json'});

      var responselaravel = await request.body;
      var decodeData = json.decode(responselaravel);

      return decodeData;
    } catch (e) {
      return (e);
    }
  }

  getSaldoPorId(id) async {
    int res = 0;
    try {
      var request =
          await http.post(Uri.parse("$serverLaravel/api/vendedores-sld"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "id_master": id,
              }));

      var responselaravel = await request.body;
      var decodeData = json.decode(responselaravel);

      return decodeData;
    } catch (e) {
      return (e);
    }
  }

  getWalletValueLaravel() async {
    try {
      var request = await http.get(
        Uri.parse(
            "$serverLaravel/api/seller/misaldo/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      // print('saldo Lar: $decodeData');

      return decodeData['value'];
    } catch (e) {
      print(e);
    }
  }

  getValuesSellerLaravel(arrayfiltersDefaultAnd) async {
    try {
      print(json.encode({
        "start": sharedPrefs!.getString("dateDesdeVendedor"),
        "end": sharedPrefs!.getString("dateHastaVendedor"),
        "or": [],
        "and": arrayfiltersDefaultAnd,
        "not": [],
      }));
      int res = 0;
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/pedidos-shopify/products/values/seller"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "start": sharedPrefs!.getString("dateDesdeVendedor"),
            "end": sharedPrefs!.getString("dateHastaVendedor"),
            "or": [],
            "and": arrayfiltersDefaultAnd,
            "not": [],
          }));

      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
        print("res:" + res.toString());
      } else {
        print("res:" + res.toString());
      }
      return decodeData;
    } catch (e) {
      return (e);
    }
  }

// ! para estado de cuente2
  getValuesSellerLaravelc2(arrayfiltersDefaultAnd) async {
    try {
      int res = 0;
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/pedidos-shopify/products/values/seller"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "start": "1/1/2021",
            "end": "1/1/2200",
            "or": [],
            "and": arrayfiltersDefaultAnd,
            "not": [],
          }));

      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        res = 1;
        print("res:" + res.toString());
      } else {
        print("res:" + res.toString());
      }
      return decodeData;
    } catch (e) {
      return (e);
    }
  }

// ** Mi cuenta vendedor
  getPersonalInfoAccountLaravel() async {
    try {
      var getUserSpecificRequest = await http.get(Uri.parse(
          "$serverLaravel/api/users/${sharedPrefs!.getString("id").toString()}"));
      var responseUser = await getUserSpecificRequest.body;
      var decodeDataUser = json.decode(responseUser);
      return decodeDataUser;
    } catch (e) {
      print(e);
    }
  }

  Future updateUserLaravel(user, mail, password) async {
    try {
      var request = await http.put(
          Uri.parse(
              "$serverLaravel/api/users/${sharedPrefs!.getString("id").toString()}"),
          headers: {'Content-Type': 'application/json'},
          body: password.toString().isEmpty
              ? json.encode({
                  "username": user,
                  "email": mail,
                })
              : json.encode({
                  "password": password,
                }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateSellerGeneralInternalAccountLaravel(
      comercialName, phone1, phone2, idMaster) async {
    try {
      var request =
          await http.put(Uri.parse("$serverLaravel/api/vendedores/$idMaster"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "nombre_comercial": comercialName,
                "telefono_1": phone1,
                "telefono_2": phone2,
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateAccountStatusLaravel() async {
    try {
      var request = await http.put(
          Uri.parse(
              "$serverLaravel/api/users/${sharedPrefs!.getString("id").toString()}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"estado": "VALIDADO"}));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderInteralStatusLaravel2(text, id) async {
    //al parecer hay otro
    // print('id: $id, $text');
    try {
      var request =
          await http.put(Uri.parse("$serverLaravel/api/pedidos-shopify/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "estado_interno": text,
                "name_comercial":
                    sharedPrefs!.getString("NameComercialSeller").toString(),
                "fecha_confirmacion":
                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
              }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getRoutesLaravel() async {
    try {
      var request = await http.get(
        Uri.parse("$serverLaravel/api/rutas/"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      return decodeData;
    } catch (e) {
      print(e);
    }
  }

  Future getTransportsByRouteLaravel(search) async {
    try {
      var request = await http.get(
        Uri.parse("$serverLaravel/api/transportadorasbyroute/$search"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      return decodeData;
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderRouteAndTransportLaravel(route, transport, id) async {
    try {
      var request = await http.put(
          Uri.parse(
              "$serverLaravel/api/pedidos-shopify/updateroutetransport/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"ruta": route, "transportadora": transport}));
      var response = await request.body;

      if (request.statusCode != 200) {
        return 1;
      } else {
        var decodeData = json.decode(response);
        return decodeData;
      }
    } catch (e) {
      2;
    }
  }

  //  *
  getAllOrdersByDateRangeLaravel(andDefault, status, internal) async {
    int res = 0;

    print(sharedPrefs!.getString("dateDesdeVendedor"));
    print(sharedPrefs!.getString("dateHastaVendedor"));
    String urlnew = "$serverLaravel/api/pedidos-shopify/filterall";

    try {
      var requestlaravel = await http.post(Uri.parse(urlnew),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": sharedPrefs!.getString("dateDesdeVendedor"),
            "end": sharedPrefs!.getString("dateHastaVendedor"),
            "and": andDefault,
            "status": status,
            "internal": internal,
          }));

      var responselaravel = await requestlaravel.body;
      var decodeDataL = json.decode(responselaravel);

      if (requestlaravel.statusCode != 200) {
        res = 1;
        print("" + res.toString());
      }
      print(res.toString());

      return decodeDataL;
    } catch (e) {
      print("error!!!: $e");
      res = 2;
      print("" + res.toString());
    }
  }

  //--- Logistic: Comprobantes Pago 2
// *
  Future getOrdersSCalendarLaravel(id, month, year) async {
    // print('$id: $month/$year');
    try {
      var request = await http.post(
          Uri.parse("$serverLaravel/api/shippingcost/bytransportadora/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              // {"month": month, "year": DateTime.now().year.toString()}));
              {"month": month, "year": year}));
      var response = await request.body;

      // if (request.statusCode != 200) {
      //   return false;
      // } else {
      //   if (decodeData['data'] == null) {
      //     return [];
      //   } else {
      //     return decodeData['data'];
      //   }
      // }
      if (request.statusCode == 204) {
        return [];
      } else if (request.statusCode == 200) {
        var decodeData = json.decode(response);
        if (decodeData['data'] == null) {
          return [];
        } else {
          return decodeData['data'];
        }
      }
    } catch (e) {
      print("error: $e");
    }
  }

  //  * DEPOSITO REALIZADO and RECIBIDO
  // Future updateOrderPayStateLogisticUserLaravel(status, id) async {
  Future updateTransportadorasShippingCostLaravel(status, id) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/shippingcost/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"status": status, "rejected_reason": ""}));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

//    *
  Future updateGeneralTransportadoraShippingCostLaravel(id, requestjson) async {
    print(json.encode(requestjson));
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/shippingcost/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestjson));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  //  *
  // Future updateOrderPayStateLogisticUserRechazadoLaravel(
  Future updateTransportadorasShippingCostRechazadoLaravel(
      id, comentarioRechazado) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/shippingcost/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              {"status": "RECHAZADO", "rejected_reason": comentarioRechazado}));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderStatusPagoLogisticaLaravel(id, status) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/pedidos-shopify/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              {"estado_pago_logistica": status, "comentario_rechazado": ""}));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderStatusPagoLogisticaRechazadoLaravel(
      id, status, comment) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/pedidos-shopify/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "estado_pago_logistica": status,
            "comentario_rechazado": comment
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

//---
  //  *
  // Future updateOrderStatusOperatorEntregadoHistorialLaravel(
  Future createTransaccionPedidoTransportadora(id, id_transportadora,
      id_operador, status, precio_total, costo_transportadora) async {
    try {
      var request = await http.post(
          Uri.parse("$serverLaravel/api/transaccionespedidotransportadora"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "id_pedido": id,
            "id_transportadora": id_transportadora,
            "id_operador": id_operador,
            "status": status,
            "fecha_entrega":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            "precio_total": precio_total,
            "costo_transportadora": costo_transportadora
          }));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

/**
 * {
    "status": "PENDIENTE",
    "rejected_reason": "",
    "url_proof_payment": ""
}
 */
  Future updateTrasportadoraShippingCost(url_proof_payment, id) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/shippingcost/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"url_proof_payment": url_proof_payment}));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  //  *
  Future getTransaccionesOrdersByTransportadorasDates(
      id_transportadora, dates) async {
    // print(json.encode(
    //     {"id_transportadora": id_transportadora, "fechas_entrega": dates}));
    try {
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/transaccionespedidotransportadora/bydates"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "id_transportadora": id_transportadora,
            "fechas_entrega": dates
          }));
      var response = await request.body;
      // var decodeData = json.decode(response);
      // return decodeData;
      if (request.statusCode == 204) {
        return [];
      } else if (request.statusCode == 200) {
        var decodeData = json.decode(response);
        return decodeData;
      }
    } catch (e) {
      print("error: $e");
    }
  }

  //  *
  // Future getTrasportadoraShippingCostByDate(id_transportadora, fecha) async {
  Future getTrasportadoraShippingCostByDate(id_transportadora, fecha) async {
    try {
      var request = await http.post(
          Uri.parse("$serverLaravel/api/shippingcost/getbydate"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              {"id_transportadora": id_transportadora, "fecha": fecha}));
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        if (decodeData['dailyCosts'] == null) {
          return [];
        } else {
          // print(decodeData['dailyCosts']);
          return decodeData['dailyCosts'];
        }
      }
    } catch (e) {
      print("error!!!: $e");
    }
  }

  //  *
  Future updateTraccionPedidoTransportadora(id, status) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/transaccionespedidotransportadora/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"status": status}));
      var response = await request.body;
      var decodeData = json.decode(response);
      return decodeData['transaccion'];
      // return decodeData;
    } catch (e) {
      print("error: $e");
    }
  }

  Future deleteTraccionPedidoTransportadora(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$serverLaravel/api/transaccionespedidotransportadora/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      var response = await request.body;
      var decodeData = json.decode(response);

      if (decodeData['code'] != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  //  *
  Future getTraccionPedidoTransportadora(
      id_pedido, id_transportadora, fecha_entrega) async {
    try {
      var request = await http.post(
          Uri.parse(
              "$serverLaravel/api/transaccionespedidotransportadora/getByDate"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              // {"month": month, "year": DateTime.now().year.toString()}));
              {
                "id_pedido": id_pedido,
                "id_transportadora": id_transportadora,
                "fecha_entrega": fecha_entrega
              }));
      var response = await request.body;
      var decodeData = json.decode(response);
      return decodeData['transaccion'];
      // return decodeData;
    } catch (e) {
      print("error: $e");
    }
  }

  //    * sellers: Print
  Future getOrdersForPrintGuidesLaravel(List or, List defaultAnd, List and,
      currentPage, sizePage, sortFiled, search) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);
    try {
      var response = await http.post(
          Uri.parse("$serverLaravel/api/pedidos-shopifies-prtgd"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "or": or,
            "and": filtersAndAll,
            "page_size": sizePage,
            "page_number": currentPage,
            "search": search,
            "sort": sortFiled,
            "not": []
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // transportadora- comprobante New
  // http://localhost:8000/api/shippingcost/
  Future createTraspShippingCost(
      id_transp, shipping_total, total_proceeds, total_day, proof) async {
    try {
      var request =
          await http.post(Uri.parse("$serverLaravel/api/shippingcost/"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "id_transportadora": id_transp,
                // "fecha_entrega": fecha_entrega,
                "shipping_total": shipping_total,
                "total_proceeds": total_proceeds,
                "total_day": total_day,
                "proof_payment": proof
              }));
      var response = await request.body;

      if (request.statusCode != 200) {
        return false;
      } else {
        var decodeData = json.decode(response);
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> postDocLaravel(XFile xFile) async {
    try {
      String url = '$serverLaravel/api/upload';
      var stream = http.ByteStream(DelegatingStream.typed(xFile.openRead()));
      var uri = Uri.parse(url);
      int length = await xFile.length();
      var request = http.MultipartRequest("POST", uri);

      var multipartFile = http.MultipartFile('files', stream, length,
          // filename: basename(
          //     "${xFile.name}.${xFile.mimeType.toString().split("/")[1]}"),
          filename: basename(xFile.name),
          contentType: MediaType(xFile.mimeType.toString(),
              xFile.mimeType.toString().split("/")[1]));

      request.files.add(multipartFile);
      var response = await request.send();

      if (response.statusCode == 200) {
        // print("status 200");
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodeData = json.decode(responseString);
        // print("decodeData $decodeData");

        if (decodeData != null) {
          return decodeData;
        } else {
          return [false, 'URL no encontrada en la respuesta del servidor.'];
        }
      } else {
        return [false, 'Error en la solicitud: ${response.statusCode}'];
      }
    } catch (e) {
      print(e);
      return [false, 'Excepción en la solicitud: $e'];
    }
  }

  Future updateOrderWithTime(id, keyvalue, iduser, from, datarequest) async {
    try {
      var request = await http.put(
          Uri.parse("$serverLaravel/api/pedidos-shopify/updatefieldtime/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "keyvalue": keyvalue,
            "iduser": iduser,
            "from": from,
            "datarequest": datarequest
          }));
      var response = await request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      return 2;
    }
  }

//  *
  getProducts(populate, page_size, current_page, or, and, sort, search) async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/products/all"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "populate": populate,
                "page_size": page_size,
                "page_number": current_page,
                "or": or,
                "and": and,
                "sort": sort,
                "search": search
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  //  *
  createProduct(nameProduct, stock, features, price, url_img, warehouse) async {
    print(json.encode({
      "product_name": nameProduct,
      "stock": stock,
      "features": features,
      "price": price,
      "url_img": url_img,
      "warehouse_id": warehouse
    }));
    try {
      var response = await http.post(Uri.parse("$serverLaravel/api/products"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "product_name": nameProduct,
            "stock": stock,
            "features": features,
            "price": price,
            "url_img": url_img,
            "warehouse_id": warehouse
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  //  *
  getProductByID(id, populate) async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/products/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "populate": populate,
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  Future updateProduct(id, datajson) async {
    int res;
    // print(json.encode(datajson));
    try {
      var response = await http.put(
          Uri.parse("$serverLaravel/api/products/$id"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(datajson));

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      res = 3;
      return res;
    }
  }

  //  *
  Future deleteProduct(id) async {
    int res;
    try {
      var response = await http.put(
          Uri.parse("$serverLaravel/api/products/delete/$id"),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      res = 3;
      return res;
    }
  }

  //TEST

  Future getOrdersTest1() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=users.vendedores&populate=pedido_fecha&populate=transportadora&filters[Status][\$eq]=ENTREGADO&filters[Fecha_Entrega][\$eq]=24/5/2023&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersTest2() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=users.vendedores&populate=pedido_fecha&populate=transportadora&filters[Status][\$eq]=NO ENTREGADO&filters[Fecha_Entrega][\$eq]=24/5/2023&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  Future getOrdersTest3() async {
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=users&populate=users.vendedores&populate=pedido_fecha&filters[\$or][0][Estado_Devolucion][\$eq]=DEVOLUCION EN RUTA&filters[\$or][1][Estado_Devolucion][\$eq]=ENTREGADO EN OFICINA&filters[Fecha_Entrega][\$eq]=24/5/2023&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getSaldo() async {
    var request = await http.get(
      Uri.parse(
          "$serverLaravel/api/vendedores/saldo/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['saldo'];
  }

  getTransactionsBySeller() async {
    var request = await http.get(
      Uri.parse(
          "$serverLaravel/api/transacciones/bySeller/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
  }

  Future getOrdersForPrintGuidesInSendGuidesPrincipalLaravel(
      start,
      List populate,
      List and,
      List defaultAnd,
      List or,
      currentPage,
      sizePage,
      search,
      sortFiled,
      List not) async {
    List filtersAndAll = [];
    filtersAndAll.addAll(and);
    filtersAndAll.addAll(defaultAnd);
    try {
      // print("andAll: $filtersAndAll");
      var response =
          await http.post(Uri.parse("$serverLaravel/api/send-guides/printg"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "start": start,
                "populate": populate,
                "or": or,
                "and": filtersAndAll,
                "page_size": sizePage,
                "page_number": currentPage,
                "search": search,
                "sort": sortFiled,
                "not": not
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getUserPedidos(id) async {
    try {
      var response = await http.get(
          Uri.parse("$serverLaravel/api/up-user-pedidos/$id"),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getRolesFront() async {
    try {
      var response = await http.get(
          Uri.parse("$serverLaravel/api/access-total"),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  postNewAccess(lista_data) async {
    try {
      var response = await http.post(Uri.parse("$serverLaravel/api/new-access"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "datos_vista": lista_data,
          }));

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        print("ok");
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  deleteAccessofWindow(lista_data) async {
    try {
      print(json.encode({
        "datos_vista": lista_data,
      }));
      var response =
          await http.post(Uri.parse("$serverLaravel/api/dlt-rolesaccess"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "datos_vista": lista_data,
              }));

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        print("ok");
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  // editAccessofWindow(lista_data) async {
  //   try {
  //     print(json.encode({
  //       "datos_vista": lista_data,
  //     }));
  //     var response =
  //         await http.post(Uri.parse("$serverLaravel/api/upd-rolesaccess"),
  //             headers: {'Content-Type': 'application/json'},
  //             body: json.encode({
  //               "datos_vista": lista_data,
  //             }));

  //     if (response.statusCode == 200) {
  //       var decodeData = json.decode(response.body);
  //       print("ok");
  //       return decodeData;
  //     } else if (response.statusCode == 400) {
  //       print("Error 400: Bad Request");
  //     } else {
  //       print("Error ${response.statusCode}: ${response.reasonPhrase}");
  //     }
  //   } catch (error) {
  //     print("Ocurrió un error durante la solicitud: $error");
  //   }
  // }

  getGeneralDataCron() async {
    try {
      var response = await http.post(Uri.parse("$serverLaravel/api/data-stats"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "date":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        print("ok");
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getGeneralDataCronrt() async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/data-stats-rt"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "date":
                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              }));

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        print("ok");
        return decodeData;
      } else if (response.statusCode == 400) {
        print("Error 400: Bad Request");
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getReferers() async {
    try {
      var response = await http.get(
          Uri.parse(
              "$serverLaravel/api/vendedores/refereds/${sharedPrefs!.getString("idComercialMasterSeller").toString()}"),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  getListToRollback(id) async {
    try {
      var response = await http
          .get(Uri.parse("$serverLaravel/api/transacciones/to-rollback/$id"));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  rollbackTransaction(ids) async {
    String? generatedBy = sharedPrefs!.getString("id");
    try {
      var response = await http.post(
          Uri.parse(
            "$serverLaravel/api/transacciones/rollback",
          ),
          body: json.encode({"ids": ids, "generated_by": generatedBy}));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  getExistTransaction(tipo, id_origen, origen, id_vendedor) async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/transacciones/exist"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "tipo": tipo,
                "id_origen": id_origen,
                "origen": origen,
                "id_vendedor": id_vendedor.toString()
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  getTransactionsByDate(start, end, search, arrayFiltersAnd) async {
    try {
      var response = await http.post(
          Uri.parse("$serverLaravel/api/transacciones/by-date"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "start": start,
            "end": end,
            "search": search,
            "and": arrayFiltersAnd
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData;
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  editAccessofWindow(lista_data) async {
    try {
      print(json.encode({
        "datos_vista": lista_data,
      }));
      var response =
          await http.post(Uri.parse("$serverLaravel/api/upd-rolesaccess"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "datos_vista": lista_data,
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  editStatusandComment(idOrder, status, comment) async {
    try {
      var response = await http.post(
          Uri.parse("$serverLaravel/api/logistic/update-status-comment"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "iddepedido": idOrder,
            "status": status,
            "comentario": comment,
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
      }
    } catch (error) {
      print("Ocurrió un error durante la solicitud: $error");
    }
  }

  getProviders(search) async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/providers/all/$search"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  getSubProviders(search) async {
    try {
      var response = await http.get(
        Uri.parse(
            "$serverLaravel/api/users/subproviders/${sharedPrefs!.getString("id")}/$search"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['users'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  createProvider(ProviderModel provider) async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/users/providers"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "username": provider.user!.username,
                "email": provider.user!.email,
                "provider_name": provider.name,
                "provider_phone": provider.phone,
                "password": '123456789',
                "description": provider.description
                //"username": "Alex Diaz",
                // "email": "radiaza2weww02eec3@hotmail.com",
                // "provider_name": "Nombre proveedor test",
                // "phone": "0992107483",
                // "password": "123456789",
                // "description": "test de proedor"
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }


  // ! warehouses
  getWarehouses() async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/warehouses"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData['warehouses'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }
getWarehousesProvider(int providerId) async {
    try {
      var response = await http.get(
        Uri.parse("$serverLaravel/api/warehouses/provider/$providerId"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        return decodeData['warehouses'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }
  updateProvider(ProviderModel provider) async {
    try {
      var name = provider.user!.id;
      var response = await http.put(
          Uri.parse("$serverLaravel/api/users/providers/${provider.user!.id}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "username": provider.user!.username,
            "email": provider.user!.email,
            "provider_name": provider.name,
            "provider_phone": provider.phone,
            "password": "123456789",
            "description": provider.description
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

      createWarehouse(WarehouseModel warehouse) async {
    try {
      var response =
          await http.post(Uri.parse("$serverLaravel/api/warehouses"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "branch_name": warehouse.branchName,
                "address": warehouse.address,
                "reference": warehouse.reference,
                "description": warehouse.description,
                "provider_id": sharedPrefs!.getString("idProvider")
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }      

  createSubProvider(UserModel user) async {
    try {
      var response = await http.post(
          Uri.parse("$serverLaravel/api/users/subproviders/add"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "username": user.username,
            "email": user.email,
            "fecha_alta": "",
            "password": "123456789",
            "providers": sharedPrefs!.getString("idProvider"),
            "role": 2,
            "roles_front": 5
          }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

        
        
        
        
    updateWarehouse(int id,String nameSucursal,String address,String reference,String description) async {
    try {
      var response =
          await http.put(Uri.parse("$serverLaravel/api/warehouses/$id"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "branch_name": nameSucursal,
                "address": address,
                "reference": reference,
                "description": description,
              }));
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

  updateSubProvider(UserModel provider) async {
    try {
      var response = await http.put(
          Uri.parse(
              "$serverLaravel/api/users/subproviders/update/${provider.id}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "username": provider.username,
            "email": provider.email,
            "blocked": provider.blocked
          }));

      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['providers'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }

deleteWarehouse(int ?warehouseId) async {
    try {
      var response =
          await http.delete(Uri.parse("$serverLaravel/api/warehouses/$warehouseId"),
              headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var decodeData = json.decode(response.body);
        // print(decodeData);
        return decodeData['message'];
      } else {
        return 1;
      }
    } catch (error) {
      return 2;
    }
  }
  cleanTransactionsFailed(id) async {
    try {
      var response = await http.post(
        Uri.parse(
            "$serverLaravel/api/transacciones/cleanTransactionsFailed/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        return 1;
      } else {
        0;
      }
    } catch (error) {
      return 2;
    }
  }

}
