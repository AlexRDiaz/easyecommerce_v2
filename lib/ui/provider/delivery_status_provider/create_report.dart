import 'dart:convert';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class CreateReportProvider {
//   *
  List listProducts = [];
  List provTransactions = [];

  Future<int> generateOrdersDetails(ordersData) async {
    // print(ordersData[0]);
    int res = 0;
    try {
      //
      List<Map<String, dynamic>> productsJson = [];
      for (var data in ordersData) {
        //
        // print(product);
        Map<String, dynamic> dataOrder;

        String sentDate = data['marca_tiempo_envio'] == null
            ? ""
            : data["marca_tiempo_envio"];
        String deliveryDate =
            data['fecha_entrega'] == null ? "" : data["fecha_entrega"];
        String id = data["id"].toString();
        String code =
            "${data['vendor']['nombre_comercial']}-${data['numero_orden']}";
        String sku = "";
        String producto = "";
        int cantidad = 0; //stock gen + reserv
        String seller = data['vendor']['nombre_comercial'];
        double unitPrice = 0;
        double totalPrice = 0;
        String status = data['status_history'].toString() == "null" ||
                data['status_history'].toString() == "[]"
            ? (data['status'].toString() == "NOVEDAD" ||
                        data['status'].toString() == "NO ENTREGADO") &&
                    data['estado_devolucion'].toString() != "PENDIENTE"
                ? data['estado_devolucion'].toString()
                : data['status'].toString()
            : getLastStatusFromJson(
                data['status_history'].toString(),
              ).toString().split(":")[1];

        List variantDetails = jsonDecode(data['variant_details']);
        // print(variantDetails);

        // List<int> idProdUniques =
        //     await extractUniqueIds(jsonDecode(data['variant_details']));

        // Set<int> currentIds = idProdUniques.toSet();
        /*
      if (data['products'] != [] && data['products'].isNotEmpty) {
        print("or_ped_lk");
        listProducts = transformProducts(data['products']);
      } else {
        print("getProdByIds");
        var responseProducts =
            await Connections().getProductsByIds(idProdUniques, []);
        listProducts = responseProducts;
      }
      */

        if (data['prov_transactions'] != [] &&
            data['prov_transactions'].isNotEmpty) {
          provTransactions = (data['prov_transactions']);
        } else {
          // print("$id no tiene prov_transactions");
        }

        // print(provTransactions);

        for (var variant in variantDetails) {
          RegExp pattern = RegExp(r'^(.*[^C])C\d+$');
          // int idProd = 0;
          sku = variant['sku'].toString();
          if (sku != "null" && sku != "" && pattern.hasMatch(sku)) {
            // int indexOfC = sku.lastIndexOf('C');
            // if (indexOfC != -1 && indexOfC + 1 < sku.length) {
            //   String digits = sku.substring(indexOfC + 1);
            //   idProd = (int.parse(digits));
            // }

            producto = "${variant['title']} "
                "${variant['variant_title'] != null ? variant['variant_title'] : ""}";

            cantidad = int.parse(variant['quantity'].toString());

            if (status == "ENTREGADO") {
              // unitPrice = getPriceByProductId(idProd);

              // totalPrice = cantidad * unitPrice;
              if (provTransactions.isNotEmpty) {
                totalPrice = getPriceBySku(sku);
                unitPrice = totalPrice / cantidad;
              }
            }
            dataOrder = {
              "sentDate": sentDate,
              "deliveryDate": deliveryDate,
              "id": id,
              "code": code,
              "sku": sku,
              "producto": producto,
              "cantidad": cantidad,
              "seller": seller,
              "unitPrice": unitPrice,
              "totalPrice": totalPrice,
              "status": status,
            };
            // print(dataProduct);
            productsJson.add(dataOrder);
          } else {
            //
          }
        }

        provTransactions.clear();
      }
      // print(jsonEncode(productsJson));
      generateExcelFileWithDataProvider(productsJson);
      return res;
    } catch (e) {
      print("Error en Details!: $e");
      return 1;
    }
  }

  List<int> extractUniqueIds(List variantDetails) {
    Set<String> uniqueSkus = {};
    // RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');
    RegExp pattern = RegExp(r'^(.*[^C])C\d+$');

    for (var item in variantDetails) {
      String? sku = item['sku'];

      if (sku != null && sku != "" && pattern.hasMatch(sku)) {
        uniqueSkus.add(item['sku']);
      } else {}
    }

    List<int> digitsList = [];

    for (var sku in uniqueSkus) {
      int indexOfC = sku.lastIndexOf('C');
      if (indexOfC != -1 && indexOfC + 1 < sku.length) {
        String digits = sku.substring(indexOfC + 1);
        digitsList.add(int.parse(digits));
      }
    }

    return digitsList;
  }

  List<dynamic> transformProducts(List<dynamic> listOrderProducts) {
    List<Map<String, dynamic>> result = [];

    try {
      for (var item in listOrderProducts) {
        var product = item['product_simple'];
        listProducts.add(product);
      }
    } catch (e) {
      // print("transformProducts $e");
    }

    return listProducts;
  }

  double getPriceByProductId(int idProduct) {
    for (var product in listProducts) {
      if (product['product_id'] == idProduct) {
        return double.parse(product['price'].toString());
      }
    }
    return 0.0;
  }

  double getPriceBySku(String sku) {
    for (var transaction in provTransactions) {
      if (transaction['sku_product_reference'] == sku) {
        return double.parse(transaction['amount'].toString());
      }
    }
    return 0.0;
  }

  Future<void> generateExcelFileWithDataProvider(
      List<Map<String, dynamic>> dataOrders) async {
    try {
      var providerName = sharedPrefs?.getString("NameProvider") ?? "Proveedor";
      final excel = Excel.createExcel();
      final String? defaultSheetName = excel.getDefaultSheet();
      if (defaultSheetName == null) {
        throw Exception("No se pudo obtener la hoja predeterminada.");
      }

      final sheet = excel.sheets[defaultSheetName];
      if (sheet == null) {
        throw Exception("No se pudo crear o acceder a la hoja de Excel.");
      }

      const List<String> headers = [
        'Fecha Envío',
        'Fecha de Entrega',
        'Código',
        'ID',
        'SKU',
        'Producto',
        'Cantidad',
        'Tienda Vendedora',
        'Valor Unitario',
        'Valor Total',
        'Estado de Transporte'
      ];

      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
            .value = headers[colIndex];

        if (colIndex == 5) {
          sheet.setColWidth(colIndex, 50);
        } else {
          sheet.setColAutoFit(colIndex);
        }
      }

      int rowIndex = 1;

      for (var order in dataOrders) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = order['sentDate'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = order['deliveryDate'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = order['code'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = order['id'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = order['sku'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = order['producto'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = order['cantidad'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = order['seller'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = order['unitPrice'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = order['totalPrice'];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = order['status'];

        rowIndex++;
      }

      String nombreFile =
          "$providerName-EasyEcommerce-${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}";
      excel.save(fileName: '$nombreFile.xlsx');

      // print("Archivo Excel generado exitosamente: $nombreFile.xlsx");
    } catch (e) {
      print("Error en Generar el reporte: $e");
    }
  }

  List<Map<String, dynamic>> extractProductIdsAndPrices(List<dynamic> data) {
    List<Map<String, dynamic>> productIdsAndPrices = [];

    for (var entry in data) {
      if (entry['products'] != null) {
        for (var product in entry['products']) {
          if (product['product_simple'] != null) {
            productIdsAndPrices.add({
              'product_id': product['product_simple']['product_id'],
              'price': product['product_simple']['price']
            });
          }
        }
      }
    }

    return productIdsAndPrices;
  }

  String formatProductIdsAndPrices(List<Map<String, dynamic>> products) {
    return products.map((product) {
      return 'ID: ${product['product_id']} - Price: ${product['price']}';
    }).join('\n');
  }

  String? getLastStatusFromJson(String statusHistoryJson) {
    try {
      List<dynamic> statusHistory = jsonDecode(statusHistoryJson);

      statusHistory = statusHistory.reversed.toList();

      var lastEntry = statusHistory.first;
      String? status = lastEntry['status'] as String?;
      String? area = lastEntry['area'] as String?;

      return '$area:$status';
    } catch (e) {
      print('Error al procesar el JSON: $e');
      return null;
    }
  }
}
