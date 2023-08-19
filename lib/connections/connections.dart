import 'dart:convert';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
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
      var request = await http.post(Uri.parse("$server/api/auth/local"), body: {
        "identifier": identifier,
        "password": password,
      });
      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        var getUserSpecificRequest = await http.get(Uri.parse(
            "$server/api/users/${decodeData['user']['id']}?populate=roles_front&populate=vendedores&populate=transportadora&populate=operadore"));
        var responseUser = await getUserSpecificRequest.body;
        var decodeDataUser = json.decode(responseUser);
        sharedPrefs!.setString("username", decodeData['user']['username']);
        sharedPrefs!.setString("id", decodeData['user']['id'].toString());
        sharedPrefs!.setString("email", decodeData['user']['email'].toString());
        sharedPrefs!.setString("jwt", decodeData['jwt'].toString());
        sharedPrefs!.setString(
            "role", decodeDataUser['roles_front']['Titulo'].toString());

        if (decodeDataUser['roles_front']['Titulo'].toString() == "VENDEDOR") {
          sharedPrefs!.setString(
            "dateDesdeVendedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString(
            "dateHastaVendedor",
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
          );
          sharedPrefs!.setString("idComercialMasterSeller",
              decodeDataUser['vendedores'][0]['Id_Master'].toString());
          sharedPrefs!.setString("idComercialMasterSellerPrincipal",
              decodeDataUser['vendedores'][0]['id'].toString());
          sharedPrefs!.setString("NameComercialSeller",
              decodeDataUser['vendedores'][0]['Nombre_Comercial'].toString());
          List temporalPermisos = decodeDataUser['PERMISOS'];
          List<String> finalPermisos = [];
          for (var i = 0; i < temporalPermisos.length; i++) {
            finalPermisos.add(temporalPermisos.toString());
          }
          sharedPrefs!.setStringList("PERMISOS", finalPermisos);
        }
        if (decodeDataUser['roles_front']['Titulo'].toString() == "LOGISTICA") {
          List temporalPermisos = decodeDataUser['PERMISOS'];
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

        if (decodeDataUser['roles_front']['Titulo'].toString() ==
            "TRANSPORTADOR") {
          sharedPrefs!.setString("idTransportadora",
              decodeDataUser['transportadora']['id'].toString());
          sharedPrefs!.setString(
              "CostoT",
              decodeDataUser['transportadora']['Costo_Transportadora']
                  .toString());
        }
        if (decodeDataUser['roles_front']['Titulo'].toString() == "OPERADOR") {
          sharedPrefs!.setString(
              "numero", decodeDataUser['operadore']['Telefono'].toString());
        }
        sharedPrefs!
            .setString("fechaAlta", decodeDataUser['FechaAlta'].toString());
        sharedPrefs!.setString(
          "dateOperatorState",
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        );

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

    var getUserSpecificRequest = await http.get(Uri.parse(
        "$server/api/users/$id?populate=roles_front&populate=vendedores&populate=transportadora&populate=operadore&populate=PERMISOS"));
    var responseUser = await getUserSpecificRequest.body;
    var decodeDataUser = json.decode(responseUser);
    return decodeDataUser;
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
          "$server/api/users?populate=roles_front&populate=vendedores&filters[vendedores][Id_Master][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&filters[\$or][0][username][\$contains]=$search&filters[\$or][1][email][\$contains]=$search&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData;
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

  Future createSeller(user, mail, id, code) async {
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
          "PERMISOS": [
            "DashBoard",
            "Reporte de Ventas",
            "Agregar Usuarios Vendedores",
            "Ingreso de Pedidos",
            "Estado Entregas Pedidos",
            "Pedidos No Deseados",
            "Billetera",
            "Devoluciones",
            "Retiros en Efectivo"
          ]
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
    var request = await http.post(Uri.parse("$server/api/users"),
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
          "Estado": "VALIDADO",
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

    var request = await http.put(Uri.parse("$server/api/users/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({"username": user, "email": mail, "PERMISOS": permisos}));
    var response = await request.body;
    var decodeData = json.decode(response);
    if (request.statusCode != 200) {
      return false;
    } else {
      return true;
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
      user, phone1, phone2, person, mail, password, permisos) async {
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
                "PERMISOS": permisos
              })
            : json.encode({
                "username": user,
                "email": mail,
                "Telefono1": phone1,
                "Telefono2": phone2,
                "Persona_Cargo": person,
                "password": password,
                "PERMISOS": permisos
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

  getOrdersForHistorialTransportByDatesLaravel(
      List populate, List and, List or, currentPage, sizePage, search) async {
    print('start: ${sharedPrefs!.getString("dateDesdeLogistica")}');
    print('end: ${sharedPrefs!.getString("dateHastaLogistica")}');

    var request =
        await http.post(Uri.parse("$serverLaravel/api/pedidos-shopify/filter"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "start": sharedPrefs!.getString("dateDesdeLogistica"),
              "end": sharedPrefs!.getString("dateHastaLogistica"),
              "or": or,
              "and": [],
              "page_size": sizePage,
              "page_number": currentPage,
              "search": search
            }));

    var response = await request.body;
    var decodeData = json.decode(response);
    return decodeData;
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

  getValuesTrasporter(List populate, List and) async {
    print(
        'startValuesTransport: ${sharedPrefs!.getString("dateDesdeTransportadora")}');
    print(
        'endValuesTransport: ${sharedPrefs!.getString("dateHastaTransportadora")}');

    var request =
        await http.post(Uri.parse("$server/api/pedidos/values/transporter/"),
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
    return decodeData;
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
      return [true, decodeData['data']['id']];
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
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
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
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateOrderLogisticStatusPrint(text, id) async {
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
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
    }
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
      status, comentario, archivo, id) async {
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
      status, comentario, id) async {
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
          "$server/api/pedidos-shopifies/$id?populate=users&populate=users.vendedores&populate=producto_shopifies&populate=pedido_fecha&populate=ruta&populate=transportadora&populate=operadore&populate=operadore.user&populate=sub_ruta"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

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

  Future withdrawalPost(amount) async {
    print(sharedPrefs!.getString("email").toString());
    try {
      var request = await http.post(
          Uri.parse(
              "$server/api/ordenes/retiros/withdrawal/${sharedPrefs!.getString("idComercialMasterSeller")}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "monto": amount,
            "fecha":
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            "mail": sharedPrefs!.getString("email").toString()
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
          "$server/api/transportadoras?populate=rutas&filters[rutas][Titulo][\$eq]=$search&pagination[limit]=-1"),
      headers: {'Content-Type': 'application/json'},
    );
    var response = await request.body;
    var decodeData = json.decode(response);

    return decodeData['data'];
  }

  getOrdersForTransportPRV(code) async {
    print(
        "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][1][NumeroOrden][\$contains]=$code&filters[Estado_Logistico][\$eq]=ENVIADO&filters&filters[\$or][2][CiudadShipping][\$contains]=$code&filters[\$or][3][NombreShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][ProductoP][\$contains]=$code&filters[\$or][7][ProductoExtra][\$contains]=$code&filters[\$or][8][PrecioTotal][\$contains]=$code&filters[\$or][9][Status][\$contains]=$code&filters[\$or][10][Estado_Interno][\$contains]=$code&filters[\$or][11][Estado_Logistico][\$contains]=$code&filters[\$or][12][pedido_fecha][Fecha][\$contains]=$code&filters[\$or][13][sub_ruta][Titulo][\$contains]=$code&filters[\$or][14][operadore][user][username][\$contains]=$code&filters[\$or][15][Cantidad_Total][\$contains]=$code&filters[Status][\$eq]=PEDIDO PROGRAMADO&filters[Estado_Interno][\$eq]=CONFIRMADO&pagination[limit]=-1");
    var request = await http.get(
      Uri.parse(
          "$server/api/pedidos-shopifies?populate=transportadora&populate=pedido_fecha&populate=sub_ruta&populate=operadore&populate=operadore.user&filters[\$and][0][transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora").toString()}&filters[\$or][1][NumeroOrden][\$contains]=$code&filters[Estado_Logistico][\$eq]=ENVIADO&filters&filters[\$or][2][CiudadShipping][\$contains]=$code&filters[\$or][3][NombreShipping][\$contains]=$code&filters[\$or][4][DireccionShipping][\$contains]=$code&filters[\$or][5][TelefonoShipping][\$contains]=$code&filters[\$or][6][ProductoP][\$contains]=$code&filters[\$or][7][ProductoExtra][\$contains]=$code&filters[\$or][8][PrecioTotal][\$contains]=$code&filters[\$or][9][Status][\$contains]=$code&filters[\$or][10][Estado_Interno][\$contains]=$code&filters[\$or][11][Estado_Logistico][\$contains]=$code&filters[\$or][12][pedido_fecha][Fecha][\$contains]=$code&filters[\$or][13][sub_ruta][Titulo][\$contains]=$code&filters[\$or][14][operadore][user][username][\$contains]=$code&filters[\$or][15][Cantidad_Total][\$contains]=$code&filters[Status][\$eq]=PEDIDO PROGRAMADO&filters[Estado_Interno][\$eq]=CONFIRMADO&pagination[limit]=-1"),
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
    print(sharedPrefs!.getString("dateDesdeVendedor"));
    print(sharedPrefs!.getString("dateHastaVendedor"));
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

  getWithdrawalSellers(code) async {
    var request = await http.get(
      Uri.parse(
          "$server/api/ordenes-retiros?populate=users_permissions_user&filters[\$and][0][users_permissions_user][id][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&pagination[limit]=-1"),
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
          "$server/api/operadores?populate=sub_ruta&populate=user&filters[sub_ruta][Titulo][\$eq]=$search&pagination[limit]=-1"),
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

  Future createOperator(user, mail, id, code) async {
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
          "CodigoGenerado": code
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

  Future deleteReportSeller(id) async {
    try {
      var request = await http.delete(
        Uri.parse("$server/api/generate-reports/$id"),
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
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
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
      return false;
    } else {
      return true;
    }
  }

  //RETURNS
  Future updateOrderReturnAll(id) async {
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
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
      return false;
    } else {
      return true;
    }
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
    var request = await http.put(Uri.parse("$server/api/pedidos-shopifies/$id"),
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
      return false;
    } else {
      return true;
    }
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
    var request = await http.put(Uri.parse("$server/api/users/$id"),
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

  Future updateAccountDisBlock(id) async {
    var request = await http.put(Uri.parse("$server/api/users/$id"),
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

  Future createTransporter(user, mail, id, code) async {
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
}
