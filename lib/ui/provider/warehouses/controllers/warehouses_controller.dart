import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:frontend/models/user_model.dart';

class WrehouseController extends ControllerMVC {
  List<WarehouseModel> warehouses = [];

  addWarehouse(WarehouseModel warehouse) async {
    print("controlador> $warehouse");
    await Connections().createWarehouse(warehouse);
    setState(() {});
  }

  updateWarehouse(
      int warehouseId,
      String nameSucursal,
      String address,
      String customerphoneNumber,
      String reference,
      String description,
      String url_image,
      String city,
      var collection) async {
    await Connections().updateWarehouse(
        warehouseId,
        nameSucursal,
        address,
        customerphoneNumber,
        reference,
        description,
        url_image,
        city,
        collection);
    setState(() {});
  }

  deleteWarehouse(int warehouseId) async {
    await Connections().deleteWarehouse(warehouseId);
    setState(() {
      // warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);
    });
    await loadWarehouses(sharedPrefs!.getString("idProvider").toString());
  }

  activateWarehouse(int warehouseId) async {
    await Connections().activateWarehouse(warehouseId);
    setState(() {
      // warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);
    });
    await loadWarehouses(sharedPrefs!.getString("idProvider").toString());
  }

  Future<void> loadWarehouses(idProvider) async {
    try {
      var data =
          await Connections().getWarehousesProvider(int.parse(idProvider));
      if (data == 1) {
        // Maneja el caso de error 1
        print('Error: Status Code 1');
      } else if (data == 2) {
        // Maneja el caso de error 2
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = data;
        warehouses =
            jsonData.map((data) => WarehouseModel.fromJson(data)).toList();
        setState(() {});
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar bodegass: $e');
    }
  }

  Future<void> loadWarehousesAll() async {
    try {
      var data = await Connections().getWarehouses();
      if (data == 1) {
        print('Error: Status Code 1');
      } else if (data == 2) {
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = data;
        warehouses =
            jsonData.map((data) => WarehouseModel.fromJson(data)).toList();
        setState(() {});
      }
    } catch (e) {
      print('Error al cargar bodegass: $e');
    }
  }
}
