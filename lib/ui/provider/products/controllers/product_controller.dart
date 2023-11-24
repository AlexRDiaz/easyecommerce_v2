import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/product_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProductController extends ControllerMVC {
  List<ProductModel> products = [];

// Método para agregar un nuevo proveedor
  addProduct(ProductModel product) async {
    await Connections().createProduct(product);
    setState(() {});
  }

  editProduct(ProductModel product) async {
    await Connections().updateProduct(product);
    setState(() {});
  }

  //
  // Upt active to 0 to delete a product
  void deleteProduct(int productId) {
    setState(() {
      products.removeWhere((product) => product.productId == productId);
    });
  }

  Future<void> loadProductsByProvider(idProvider, populate, pageSize,
      currentPage, or, and, sort, search) async {
    try {
      var data = await Connections().getProductsByProvider(
          idProvider, populate, pageSize, currentPage, or, and, sort, search);
      if (data == 1) {
        // Maneja el caso de error 1
        print('Error: Status Code 1');
      } else if (data == 2) {
        // Maneja el caso de error 2
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = data['data'];
        products = jsonData.map((data) => ProductModel.fromJson(data)).toList();
        setState(() {});
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar productos: $e');
    }
  }
}
