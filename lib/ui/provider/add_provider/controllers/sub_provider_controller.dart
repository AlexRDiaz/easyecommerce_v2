import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/user_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SubProviderController extends ControllerMVC {
  List<UserModel> users = [];
  TextEditingController searchController = TextEditingController();

  // Método para agregar un nuevo proveedor
  addSubProvider(UserModel user) async {
    await Connections().createSubProvider(user);
    setState(() {});
  }

  editSubProvider(UserModel user) async {
    await Connections().updateSubProvider(user);
    setState(() {});
  }

  // Método para actualizar un proveedor existente

  // Método para eliminar un proveedor
  void deleteSubuser(int userId) {
    setState(() {
      users.removeWhere((user) => user.id == userId);
    });
  }

  Future<void> loadSubProviders() async {
    try {
      var data = await Connections().getSubProviders(searchController.text);
      if (data == 1) {
        // Maneja el caso de error 1
        print('Error: Status Code 1');
      } else if (data == 2) {
        // Maneja el caso de error 2
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = data;
        users = jsonData.map((data) => UserModel.fromJson(data)).toList();
        setState(() {});
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar proveedores: $e');
    }
  }
}
