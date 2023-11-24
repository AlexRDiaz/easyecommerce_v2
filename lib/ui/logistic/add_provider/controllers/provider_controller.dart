import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:frontend/models/user_model.dart';

class ProviderController extends ControllerMVC {
  List<ProviderModel> providers = [];

  // Método para agregar un nuevo proveedor
  addProvider(ProviderModel provider) async {
    await Connections().createProvider(provider);
    setState(() {});
  }

  editProvider(ProviderModel provider) async {
    await Connections().updateProvider(provider);
    setState(() {});
  }

  // Método para actualizar un proveedor existente

  // Método para eliminar un proveedor
  void deleteProvider(int providerId) {
    setState(() {
      providers.removeWhere((provider) => provider.id == providerId);
    });
  }

  Future<void> loadProviders() async {
    try {
      var data = await Connections().getProviders();
      if (data == 1) {
        // Maneja el caso de error 1
        print('Error: Status Code 1');
      } else if (data == 2) {
        // Maneja el caso de error 2
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = data;
        providers =
            jsonData.map((data) => ProviderModel.fromJson(data)).toList();
        print(providers);
        setState(() {});
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar proveedores: $e');
    }
  }
}
