import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';

class CreateReport {
//
//   *
//
  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);
      var nameComercial =
          sharedPrefs!.getString("NameComercialSeller").toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Fecha de Ingreso';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Fecha de Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Codigo';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Nombre';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Ciudad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Dirección';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Teléfono';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Cantidad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
          .value = 'Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0))
          .value = 'Producto Extra';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0))
          .value = 'Precio Total';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0))
          .value = 'Comentario';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0))
          .value = 'Status';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0))
          .value = 'Estado Interno';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0))
          .value = 'Estado logistico';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0))
          .value = 'Estado Devolucion';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 0))
          .value = 'Costo Envio';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 0))
          .value = 'Costo Devolucion';
      for (int rowIndex = 0; rowIndex < dataOrders.length; rowIndex++) {
        final data = dataOrders[rowIndex];

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
                .value =
            "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data["numero_orden"]}";
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
                columnIndex: 12, rowIndex: rowIndex + 1))
            .value = data["status"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 13, rowIndex: rowIndex + 1))
            .value = data["estado_interno"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 14, rowIndex: rowIndex + 1))
            .value = data["estado_logistico"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 15, rowIndex: rowIndex + 1))
            .value = data["estado_devolucion"];

        if (data['users'] != null) {
          if (data['status'] == "ENTREGADO" ||
              data['status'] == "NO ENTREGADO") {
            var costo_envio =
                data['users'][0]['vendedores'][0]['costo_envio'].toString();
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 16, rowIndex: rowIndex + 1))
                .value = costo_envio;
          } else {
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 16, rowIndex: rowIndex + 1))
                .value = "";
          }
        } else {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 16, rowIndex: rowIndex + 1))
              .value = "";
        }

        if (data['users'] != null) {
          if (data['status'] == "NOVEDAD") {
            if (data['estado_devolucion'] == "ENTREGADO EN OFICINA" ||
                data['status'] == "EN RUTA" ||
                data['estado_devolucion'] == "EN BODEGA" ||
                data['estado_devolucion'] == "DEVOLUCION EN RUTA") {
              var costo_devolucion = data['users'][0]['vendedores'][0]
                      ['costo_devolucion']
                  .toString();
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 17, rowIndex: rowIndex + 1))
                  .value = costo_devolucion;
            }
          } else {
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 17, rowIndex: rowIndex + 1))
                .value = "";
          }
        } else {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 17, rowIndex: rowIndex + 1))
              .value = "";
        }

        //
      }

      var nombreFile =
          "$nameComercial-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!");
    }
  }
}
