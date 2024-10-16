import 'dart:convert';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/user_model.dart';

class ReportProductos {
  //*

  Future<void> generateProductDetails(productsData, filter) async {
    // print("genProductDetails: ${productsData}");
    try {
      //
      List<Map<String, dynamic>> productsJson = [];
      for (var product in productsData) {
        //
        // print(product);
        Map<String, dynamic> dataProduct;

        String id = "";
        String sku = "";
        String name = "";
        int cantidadTotal = 0; //stock gen + reserv
        int tipo = 0;
        int owner = 0;
        String reserves = "";
        Map<String, dynamic> dataFeatures;
        List<dynamic> listVariants;
        String skuGen;
        String skuVariant = "";

        id = product['product_id'].toString();
        name = product['product_name'];
        tipo = product['isvariable'];
        owner = filter == "owner" ? product['seller_owned'] : 0;
        dataFeatures = jsonDecode(product['features']);
        skuGen = dataFeatures["sku"];

        if (tipo == 1) {
          // print("variable");
          listVariants = dataFeatures['variants'];
          // print("$listVariants");
          for (var variant in listVariants) {
            // print(variant);
            sku = "${variant['sku']}C$id";
            cantidadTotal =
                int.parse(variant['inventory_quantity'].toString()) +
                    getTotalStockBySku(product['reserve'], variant['sku']);
            String variantTitle = "";
            variantTitle = buildVariantTitle(variant);
            dataProduct = {
              "sku": sku,
              "warehouse_owner": getWarehouseOwner(product['warehouses']),
              "warehouse_names": getWarehousesNames(product["warehouses"]),
              "owner": owner,
              "name": "$name $variantTitle",
              "cantidadTotal": cantidadTotal,
              "type": "VARIABLE",
              "reserves":
                  getReservesByVariant(product['reserve'], variant['sku']),
            };
            // print(dataProduct);
            productsJson.add(dataProduct);
          }
        } else {
          // print("simple");
          sku = "${skuGen}C$id";
          cantidadTotal = int.parse(product['stock'].toString()) +
              int.parse(getTotalReserves(product['reserve']));
          dataProduct = {
            "sku": sku,
            "warehouse_owner": getWarehouseOwner(product['warehouses']),
            "warehouse_names": getWarehousesNames(product["warehouses"]),
            "owner": owner,
            "name": name,
            "cantidadTotal": cantidadTotal,
            "type": tipo == 0 ? "SIMPLE" : "VARIABLE",
            "reserves": getReserves(product['reserve']),
          };
          // print(dataProduct);
          productsJson.add(dataProduct);
        }
      }
      // print(jsonEncode(productsJson));
      if (filter == "owner") {
        //
        List<Map<String, dynamic>> sortedProducts =
            sortProductsByOwner(productsJson);
        generateExcelReport(sortedProducts);
      } else {
        List<Map<String, dynamic>> sortedProducts =
            sortProductsByWarehouseOwner(productsJson);
        generateExcelReport(sortedProducts);
      }
    } catch (e) {
      print("Error en Details!: $e");
    }
  }

  List<Map<String, dynamic>> sortProductsByOwner(
      List<Map<String, dynamic>> products) {
    products.sort((a, b) {
      int typeA = a['owner'];
      int typeB = b['owner'];
      return typeA.compareTo(typeB);
    });
    return products;
  }

  List<Map<String, dynamic>> sortProductsByWarehouseOwner(
      List<Map<String, dynamic>> products) {
    products.sort((a, b) {
      // Comparar los tipos de productos como enteros
      int typeA = a['warehouse_owner'];
      int typeB = b['warehouse_owner'];
      return typeA.compareTo(typeB);
    });
    return products;
  }

  Future<void> generateExcelReport(products) async {
    // print("genReport: $products");
    try {
      String date =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];

      // Ajustar ancho de las columnas
      sheet!.setColWidth(4, 50);
      sheet.setColAutoFit(0);
      sheet.setColAutoFit(1);
      sheet.setColAutoFit(2);
      sheet.setColWidth(3, 20);
      sheet.setColAutoFit(7);

      // Encabezados de la hoja de cálculo
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Fecha';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Bodega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Item';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'SKU Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Cantidad total';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Tipo';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Reservas';

      // Llenar la hoja de cálculo con datos
      int rowIndex = 1;
      for (var product in products) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = date;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = product['warehouse_names'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = rowIndex;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = product['sku'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = product['name'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = product['cantidadTotal'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = product['type'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = product['reserves'];

        rowIndex++;
      }

      var nombreFile =
          "Productos-${sharedPrefs!.getString("NameProvider").toString()}-EasyEcommerce-$date";

      excel.save(fileName: '$nombreFile.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!: $e");
    }
  }

  String getWarehousesNames(dynamic warehouses) {
    String names = "";
    if (warehouses != null) {
      for (var warehouse in warehouses) {
        if (warehouse['branch_name'] != null) {
          names += "${warehouse['branch_name']}/ ";
        }
      }
      if (names.isNotEmpty) {
        names = names.substring(0, names.length - 2);
      }
    }
    return names;
  }

  String getTotalReserves(dynamic reserves) {
    int reserveStock = 0;

    // List<ReserveModel>? reservesList = reserves;
    List<ReserveModel> reservesList = (reserves as List)
        .map(
            (reserve) => ReserveModel.fromJson(reserve as Map<String, dynamic>))
        .toList();
    for (int i = 0; i < reservesList.length; i++) {
      ReserveModel reserve = reservesList[i];

      reserveStock += int.parse(reserve.stock.toString());
    }
    return reserveStock.toString();
  }

  String getReserves(dynamic reserves) {
    String reservesText = "";
    /*
    List<ReserveModel> reservesList = (reserves as List)
        .map(
            (reserve) => ReserveModel.fromJson(reserve as Map<String, dynamic>))
        .toList();
    for (int i = 0; i < reservesList.length; i++) {
      ReserveModel reserve = reservesList[i];
      UserModel? userSeller = reserve.user;
      reservesText += "${userSeller?.username}: ${reserve.stock}, \n";
    }
    */
    for (var reserva in reserves) {
      reservesText +=
          "${reserva["seller"]['vendor']['nombre_comercial'].toString()}: ${reserva["stock"]}, \n";
      //          "${reserva["seller"]['vendedores'][0]['nombre_comercial'].toString()}: ${reserva["stock"]}, \n";
    }
    // reservesText = reservesText.substring(0, reservesText.length - 2);

    return reservesText;
  }

  int getTotalStockBySku(List<dynamic> reserves, String sku) {
    int totalStock = 0;

    for (var reserve in reserves) {
      if (reserve['sku'] == sku) {
        totalStock += int.parse(reserve['stock'].toString());
      }
    }

    return totalStock;
  }

  String getReservesByVariant(List<dynamic> reserves, String sku) {
    Map<String, int> reservesByUser = {};

    List<Map<String, dynamic>> reservesList =
        reserves.cast<Map<String, dynamic>>();

    for (var reserve in reservesList) {
      if (reserve['sku'] == sku) {
        // String seller = reserve['seller']['username'];
        String seller =
            reserve["seller"]['vendor']['nombre_comercial'].toString();
        // reserve["seller"]['vendedores'][0]['nombre_comercial'].toString();
        int stock = reserve['stock'];

        if (reservesByUser.containsKey(seller)) {
          reservesByUser[seller] = reservesByUser[seller]! + stock;
        } else {
          reservesByUser[seller] = stock;
        }
      }
    }

    String reservesText = "";
    reservesByUser.forEach((username, stock) {
      reservesText += "  $username: $stock\n";
    });

    return reservesText;
  }

  int getWarehouseOwner(dynamic warehouses) {
    int idWOwner = 0;
    if (warehouses != null && warehouses.isNotEmpty) {
      idWOwner = warehouses[0]['warehouse_id'];
    }
    return idWOwner;
  }

  String buildVariantTitle(Map<String, dynamic> element) {
    List<String> excludeKeys = ['id', 'sku', 'inventory_quantity', 'price'];
    List<String> elementDetails = [];

    element.forEach((key, value) {
      if (!excludeKeys.contains(key)) {
        elementDetails.add("$value");
      }
    });

    return elementDetails.join("/");
  }
}
