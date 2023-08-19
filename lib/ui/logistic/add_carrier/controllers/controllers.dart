import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class AddCarriersControllers {
  TextEditingController searchController = TextEditingController(text: "");
  TextEditingController comercialNameController =
      TextEditingController(text: "");
  TextEditingController typeProductController = TextEditingController(text: "");
  TextEditingController userController = TextEditingController(text: "");
  TextEditingController phone1Controller = TextEditingController(text: "");
  TextEditingController phone2Controller = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  // createUserCarrier({success, error}) async {
  //   var response = await Connections().createSeller(
  //       comercialNameController.text,
  //       phone1Controller.text,
  //       phone2Controller.text,
  //       userController.text,
  //       mailController.text,
  //       sendCostController.text,
  //       returnCostController.text);
  //   if (response[0]) {
  //     success(response[1]);
  //   } else {
  //     error();
  //   }
  // }
}

class AddCarrierController {
  late TextEditingController usuarioController;
  late TextEditingController tipoUsuarioController;
  late TextEditingController correoController;
  late TextEditingController costoController;
  late TextEditingController rutaController;
  late TextEditingController telefonoController;
  late TextEditingController telefonoDosController;

  AddCarrierController({
    required String usuario,
    required String tipoUsuario,
    required String correo,
    required String costo,
    required String ruta,
    required String telefono,
    required String telefonoDos,
  }) {
    usuarioController = TextEditingController(text: usuario);
    tipoUsuarioController = TextEditingController(text: tipoUsuario);
    correoController = TextEditingController(text: correo);
    costoController = TextEditingController(text: costo);
    rutaController = TextEditingController(text: ruta);
    telefonoController = TextEditingController(text: telefono);
    telefonoDosController = TextEditingController(text: telefonoDos);
  }
}
