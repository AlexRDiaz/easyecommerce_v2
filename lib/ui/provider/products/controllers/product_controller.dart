import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/product_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProductController extends ControllerMVC {
  List<ProductModel> products = [];

// add new product //ok
  addProduct(ProductModel product) async {
    await Connections().createProduct(product);
    setState(() {});
  }

  editProduct(ProductModel product) async {
    await Connections().updateProduct(product);
    setState(() {});
  }

//ok
  disableProduct(int warehouseId) async {
    await Connections().deleteProduct(warehouseId);
    setState(() {});
  }

  // Future<void> loadProductsByProvider(idProvider, populate, pageSize,
  //     currentPage, or, and, sort, search) async {
  //   try {
  //     var response = await Connections().getProductsByProvider(
  //         idProvider, populate, pageSize, currentPage, or, and, sort, search);
  //     if (response == 1) {
  //       print('Error: Status Code 1');
  //     } else if (response == 2) {
  //       print('Error: Status Code 2');
  //     } else {
  //       List<dynamic> jsonData = response['data'];

  //       var total = response['total'];
  //       var lastPage = response['last_page'];
  //       print('Total: $total');
  //       print('Last Page: $lastPage');

  //       products = jsonData.map((data) => ProductModel.fromJson(data)).toList();
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     // Maneja otros errores
  //     print('Error al cargar productos: $e');
  //   }
  // }

  Future<Map<String, dynamic>> loadProductsByProvider(idProvider, populate,
      pageSize, currentPage, or, and, sort, search) async {
    try {
      var response = await Connections().getProductsByProvider(
          idProvider, populate, pageSize, currentPage, or, and, sort, search);
      if (response == 1) {
        print('Error: Status Code 1');
      } else if (response == 2) {
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = response['data'];

        var total = response['total'];
        var lastPage = response['last_page'];

        products = jsonData.map((data) => ProductModel.fromJson(data)).toList();
        setState(() {});
        // Construir el objeto de respuesta
        Map<String, dynamic> result = {
          'data': products.map((product) => product.toJson()).toList(),
          'total': total,
          'last_page': lastPage,
        };
        return result;
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar productos: $e');
    }
    return {
      'data': [],
      'total': 0,
      'last_page': 0,
    };
  }

  Future<void> loadProductsCatalog(
      populate, pageSize, currentPage, or, and, sort, search) async {
    try {
      var response = await Connections().getProductsCatalog(
          populate, pageSize, currentPage, or, and, sort, search);
      if (response == 1) {
        print('Error: Status Code 1');
      } else if (response == 2) {
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = response['data'];

        var total = response['total'];
        var lastPage = response['last_page'];
        // print('Total: $total');
        // print('Last Page: $lastPage');

        products = jsonData.map((data) => ProductModel.fromJson(data)).toList();
        setState(() {});
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar productos: $e');
    }
  }
}
