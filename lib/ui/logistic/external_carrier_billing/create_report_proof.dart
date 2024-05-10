import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';

class CreateReportProof {
//
//   *
//
  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);
      var orders = dataOrders['data'];
      var total = dataOrders['total'];

      var name_transportadora = "";
      //Fecha de Entrega	Codigo	Producto	Cantidad	Precio Total	Status	Transportadora	Costo Envio

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Fecha de Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Codigo';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Cantidad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Precio Total';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Status';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Transportadora';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Costo Envio';

      for (int rowIndex = 0; rowIndex < orders.length; rowIndex++) {
        final data = orders[rowIndex];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = data["fecha_entrega"];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex + 1))
                .value =
            "${data["pedidos_shopify"]["name_comercial"]}-${data["pedidos_shopify"]["numero_orden"]}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: rowIndex + 1))
            .value = data["pedidos_shopify"]["producto_p"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: rowIndex + 1))
            .value = data["pedidos_shopify"]["cantidad_total"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: rowIndex + 1))
            .value = data["pedidos_shopify"]["precio_total"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: rowIndex + 1))
            .value = data["status"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: rowIndex + 1))
            .value = data["transportadora"]["nombre"];
        name_transportadora = data["transportadora"]["nombre"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: rowIndex + 1))
            .value = data["costo_transportadora"];

        //
      }

      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 6, rowIndex: (orders.length) + 1))
          .value = "Total Costo Transportadora";
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 7, rowIndex: (orders.length) + 1))
          .value = total;

      var nombreFile =
          "$name_transportadora-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print(e);
      print("Error en Generar el reporte!");
    }
  }
}
