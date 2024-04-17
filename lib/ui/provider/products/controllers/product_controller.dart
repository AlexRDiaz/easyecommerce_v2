import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/product_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProductController extends ControllerMVC {
  List<ProductModel> products = [];

// add new product //ok
  addProduct(ProductModel product) async {
    // await Connections().createProduct(product);
    // setState(() {});
    try {
      var response = await Connections().createProduct(product);
      if (response is List && response.length == 2 && response[0] == true) {
        // La respuesta es válida, devuelve el decodeData
        return response[1];
      } else {
        // Si la respuesta no es válida, puedes manejarlo de acuerdo a tus necesidades
        return [];
      }
    } catch (e) {
      // Si hay una excepción, puedes manejarlo de acuerdo a tus necesidades
      return [];
    }
  }

  editProduct(ProductModel product) async {
    await Connections().updateProduct(product);
    setState(() {});
  }

  upate(int productId, json) async {
    await Connections().updateProductRequest(productId, json);
    setState(() {
      // warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);
    });
    // await loadWarehouses(sharedPrefs!.getString("idProvider").toString());
  }

//ok
  disableProduct(int productId) async {
    await Connections().deleteProduct(productId);
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
      pageSize, currentPage, or, and, sort, search, to) async {
    try {
      var response = await Connections().getProductsByProvider(idProvider,
          populate, pageSize, currentPage, or, and, sort, search, to);
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

  Future<Map<String, dynamic>> loadBySubProvider(
      populate, pageSize, currentPage, or, and, sort, search) async {
    try {
      var response = await Connections().getProductsBySubProvider(
          populate, pageSize, currentPage, or, and, sort, search);
      // print(response);
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

  Future<void> loadProductsCatalog(populate, pageSize, currentPage, or, and,
      outFilter, sort, search, filterps) async {
    try {
      var response = await Connections().getProductsCatalog(populate, pageSize,
          currentPage, or, and, outFilter, sort, search, filterps);
      if (response == 1) {
        print('Error: Status Code 1');
      } else if (response == 2) {
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = response['data'];
        // print(jsonData);

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
