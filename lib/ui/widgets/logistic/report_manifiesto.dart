import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';

class ReportManifiesto {
//
//   *
//
  Future<void> generateExcelReport(optionsCheckBox) async {
    // print("generateExcelReportManifiesto");
    try {
      String date =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      // var sortedData = sortByCarrierName(dataOrders);
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(5, 50);
      sheet.setColAutoFit(0);
      sheet.setColAutoFit(2);
      sheet.setColAutoFit(4);
      sheet.setColAutoFit(6);
      sheet.setColAutoFit(7);

      var numItem = 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Item';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Fecha de Impresión';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Codigo de pedido';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Ciudad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Cantidad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Producto y Producto Extra';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Proveedor';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Transportadora';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
          .value = 'Precio Total';

      int totalData = optionsCheckBox.length;

      for (int rowIndex = 0; rowIndex < totalData; rowIndex++) {
        final data = optionsCheckBox[rowIndex];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = numItem;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: rowIndex + 1))
            // .value = data['date'];
            .value = date;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: rowIndex + 1))
            .value = data['numPedido'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: rowIndex + 1))
            .value = data['city'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: rowIndex + 1))
            .value = data['quantity'];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 5, rowIndex: rowIndex + 1))
                .value =
            "${data['product']} ${data['extraProduct'] != "" ? "/${data['extraProduct']}" : ""}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: rowIndex + 1))
            .value = data["provider"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: rowIndex + 1))
            .value = data["transport"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: rowIndex + 1))
            .value = data["price"];

        numItem++;
        //
      }

      var nombreFile =
          // "Guias_Enviadas_$name_comercial-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
          "Guias_Impresas-Manifiesto-EasyEcommerce-$date";

      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!: $e");
    }
  }
}
