import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:frontend/models/user_model.dart';

class WrehouseController extends ControllerMVC {
  List<WarehouseModel> warehouses = [];

  addProvider(WarehouseModel warehouse) async {
    await Connections().createWarehouse(warehouse);
    setState(() {});
  }


  void deleteProvider(int warehouseId) {
    setState(() {
      warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);
    });
  }

  Future<void> loadWarehouses() async {
    try {
      var data = await Connections().getWarehouses();
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
}
