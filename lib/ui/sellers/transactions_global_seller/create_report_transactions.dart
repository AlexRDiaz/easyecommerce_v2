import 'dart:convert';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';

class CreateReport {
//
//   *
//
// Función para manejar conversiones seguras a double
  double parseDouble(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 0.0;
    }
    try {
      return double.parse(value.toString());
    } catch (e) {
      print('Error al convertir "$value" a double: $e');
      return 0.0; // Valor por defecto en caso de error
    }
  }

// Función para verificar si el estado pertenece a un grupo de estados
  bool isInStatusGroup(String status, List<String> statuses) {
    return statuses.contains(status);
  }

  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(8, 50);
      sheet.setColWidth(12, 20);

      sheet.setColAutoFit(2);
      sheet.setColAutoFit(3);
      sheet.setColAutoFit(6);
      sheet.setColAutoFit(15);

      var nameComercial =
          sharedPrefs!.getString("NameComercialSeller").toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Código';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Fecha de Envío';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Fecha de Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Estado de Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Estado Devocución';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Origen';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Precio Retiro';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Precio Total';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
          .value = 'Costo Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0))
          .value = 'Costo No Entregado';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0))
          .value = 'Costo Devolución';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0))
          .value = 'Costo Proveedor';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0))
          .value = 'Costo Referido';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0))
          .value = 'Total';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0))
          .value = 'Saldo Anterior';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0))
          .value = 'Saldo Actual';

      for (int rowIndex = 0; rowIndex < dataOrders.length; rowIndex++) {
        final data = dataOrders[rowIndex];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = data["code"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: rowIndex + 1))
            .value = data["admission_date"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: rowIndex + 1))
            .value = data["delivery_date"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: rowIndex + 1))
            .value = data["status"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: rowIndex + 1))
            .value = data["return_state"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: rowIndex + 1))
            .value = data["origin"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: rowIndex + 1))
            .value = double.parse(data["withdrawal_price"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: rowIndex + 1))
            .value = double.parse(data["value_order"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: rowIndex + 1))
            .value = double.parse(data["delivery_cost"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 9, rowIndex: rowIndex + 1))
            .value =double.parse( data["notdelivery_cost"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 10, rowIndex: rowIndex + 1))
            .value = double.parse(data["return_cost"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 11, rowIndex: rowIndex + 1))
            .value = double.parse(data["provider_cost"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 12, rowIndex: rowIndex + 1))
            .value = double.parse(data["referer_cost"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 13, rowIndex: rowIndex + 1))
            .value = double.parse(data["total_transaction"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 14, rowIndex: rowIndex + 1))
            .value = double.parse(data["previous_value"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 15, rowIndex: rowIndex + 1))
            .value = double.parse(data["current_value"].toString());
      }

      var nombreFile =
          "$nameComercial-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte! $e");
    }
  }
}
