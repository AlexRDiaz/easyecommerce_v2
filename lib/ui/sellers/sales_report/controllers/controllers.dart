import 'package:flutter/material.dart';

class SalesReportControllers {
  TextEditingController searchController = TextEditingController(
      text:
          "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}");
}

class AddReportControllers {
  late TextEditingController desdeController;
  late TextEditingController hastaController;
  late TextEditingController estadoController;

  AddReportControllers({
    required String desde,
    required String hasta,
    required String estado,
  }) {
    desdeController = TextEditingController(text: desde);
    hastaController = TextEditingController(text: hasta);
    estadoController = TextEditingController(text: estado);
  }
}
