import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/integrations_model.dart';
import 'package:frontend/models/product_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class MyIntegrationsController extends ControllerMVC {
  List<IntegrationsModel> integrations = [];

  Future<void> loadIntegrations() async {
    try {
      var response = await Connections().getIntegrations();
      if (response == 1) {
        print('Error: Status Code 1');
      } else if (response == 2) {
        print('Error: Status Code 2');
      } else {
        // print(jsonData)
        for (var obj in response) {
          var m = IntegrationsModel.fromJson(obj);
          integrations.add(m);
        }
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar productos: $e');
    }
  }
}
