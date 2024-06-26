import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/reserve_model.dart';

class ReportProductos {
  //*
  Future<void> generateExcelReport(products) async {
    print("genReport: $products");
    try {
      String date =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      // var sortedData = sortByCarrierName(dataOrders);
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(0);
      sheet.setColWidth(1, 10);
      sheet.setColAutoFit(3);
      sheet.setColAutoFit(8);
      sheet.setColAutoFit(9);

      var numItem = 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Item';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'ID';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Tipo';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Stock General';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Stock Reservas';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Precio Bodega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Bodega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
          .value = 'Propietario';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0))
          .value = 'Estado Aprobado';

      int totalData = products.length;

      for (int rowIndex = 0; rowIndex < totalData; rowIndex++) {
        final data = products[rowIndex];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = numItem;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: rowIndex + 1))
            .value = data['product_id'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: rowIndex + 1))
            .value = data['product_name'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: rowIndex + 1))
            .value = data['isvariable'] == 1 ? "VARIABLE" : "SIMPLE";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: rowIndex + 1))
            .value = data['stock'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: rowIndex + 1))
            .value = getTotalReserves(data['reserve']); //reservas
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: rowIndex + 1))
            .value = data["price"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: rowIndex + 1))
            .value = getWarehousesNames(data["warehouses"]); //main
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: rowIndex + 1))
            .value = data['seller_owned'] == null ||
                data['seller_owned'].toString() == "0"
            ? ""
            : data['owner']['vendedores'][0]['nombre_comercial'].toString();
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex + 1)).value =
            data['approved'] == 1
                ? 'Aprobado'
                : data['approved'] == 2
                    ? 'Pendiente'
                    : 'Rechazado';
        numItem++;
        //
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
}
