import 'package:flutter/material.dart';

class MySellerAccountControllers {
  late TextEditingController nombreComercialController;
  late TextEditingController numeroTelefonoController;
  late TextEditingController telefonoDosController;
  late TextEditingController usuarioController;
  late TextEditingController fechaAltaController;
  late TextEditingController correoController;

  MySellerAccountControllers({
    required String nombreComercial,
    required String numeroTelefono,
    required String telefonoDos,
    required String usuario,
    required String fechaAlta,
    required String correo,
  }) {
    nombreComercialController = TextEditingController(text: nombreComercial);
    numeroTelefonoController = TextEditingController(text: numeroTelefono);
    telefonoDosController = TextEditingController(text: telefonoDos);
    usuarioController = TextEditingController(text: usuario);
    fechaAltaController = TextEditingController(text: fechaAlta);
    correoController = TextEditingController(text: correo);
  }
}
