import 'package:flutter/material.dart';

class AddStockToVendorsControllers {
  TextEditingController searchController = TextEditingController(text: "");
}

class AddStockToVendorController {
  late TextEditingController fechaController;
  late TextEditingController idController;
  late TextEditingController idProductoController;
  late TextEditingController cantidadController;

  AddStockToVendorController({
    required String fecha,
    required String id,
    required String idProducto,
    required String cantidad,
  }) {
    fechaController = TextEditingController(text: fecha);
    idController = TextEditingController(text: id);
    idProductoController = TextEditingController(text: idProducto);
    cantidadController = TextEditingController(text: cantidad);
  }
}
