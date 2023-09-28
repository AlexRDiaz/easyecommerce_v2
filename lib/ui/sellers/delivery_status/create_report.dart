import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';

class createReport {
  Future<void> generateExcelFile() async {
    final excel = Excel.createExcel();

    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(3);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3)).value =
        'Holaaa';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 4)).value =
        'Esto es una pruba de dowloand excel';

    // excel.save();
    var nombreFile =
        "test-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    // excel.save(fileName: 'test.xlsx');
    excel.save(fileName: '${nombreFile}.xlsx');
  }

//
//
//
  Future<void> generateExcelFileWithData(dataOrders) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(3);

    // Encabezados de columnas
    // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3)).value =
    //     'ID';
    //   Fecha de Ingreso
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'Fecha de Ingreso';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Fecha de Entrega';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Codigo';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Nombre';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Ciudad';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Dirección';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
        'Teléfono';
//Cantidad	Producto	Producto Extra	Precio Total	Comentario	Estado de Confirmacion	Status	Estado de Entrega	Estado Devolucion	Costo Transporte	Costo Devolucion
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
        'Cantidad';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value =
        'Producto';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value =
        'Producto Extra';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0)).value =
        'Precio Total';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0)).value =
        'Comentario';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0)).value =
        'Status';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0)).value =
        'Estado Interno';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0)).value =
        'Estado logistico';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0)).value =
        'Estado Devolucion';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 0)).value =
        'Costo Transporte';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 0)).value =
        'Costo Devolucion';
    // Llenar la hoja de cálculo con los datos del JSON
    for (int rowIndex = 0; rowIndex < dataOrders.length; rowIndex++) {
      final data = dataOrders[rowIndex];

      // sheet
      //     .cell(CellIndex.indexByColumnRow(
      //         columnIndex: 2, rowIndex: rowIndex + 4))
      //     .value = data["id"];

      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 0, rowIndex: rowIndex + 1))
          .value = data["marca_t_i"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 1, rowIndex: rowIndex + 1))
          .value = data["fecha_entrega"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 2, rowIndex: rowIndex + 1))
          .value = data["numero_orden"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 3, rowIndex: rowIndex + 1))
          .value = data["nombre_shipping"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 4, rowIndex: rowIndex + 1))
          .value = data["ciudad_shipping"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 5, rowIndex: rowIndex + 1))
          .value = data["direccion_shipping"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 6, rowIndex: rowIndex + 1))
          .value = data["telefono_shipping"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 7, rowIndex: rowIndex + 1))
          .value = data["cantidad_total"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 8, rowIndex: rowIndex + 1))
          .value = data["producto_p"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 9, rowIndex: rowIndex + 1))
          .value = data["producto_extra"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 10, rowIndex: rowIndex + 1))
          .value = data["precio_total"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 11, rowIndex: rowIndex + 1))
          .value = data["comentario"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 13, rowIndex: rowIndex + 1))
          .value = data["status"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 12, rowIndex: rowIndex + 1))
          .value = data["estado_interno"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 14, rowIndex: rowIndex + 1))
          .value = data["estado_logistico"];
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 15, rowIndex: rowIndex + 1))
          .value = data["estado_devolucion"];

      // faltan if para estos costos
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 16, rowIndex: rowIndex + 1))
          // .value = data["users.vendedores.costo_envio"];
          .value = data["users"][0]["vendedores"][0]["costo_envio"];

      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 17, rowIndex: rowIndex + 1))
          // .value = data["users.vendedores.costo_devolucion"];
          .value = data["users"][0]["vendedores"][0]["costo_devolucion"];
    }

    // Guardar el archivo Excel
    var nombreFile =
        "reporte-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    excel.save(fileName: '${nombreFile}.xlsx');
  }
}
