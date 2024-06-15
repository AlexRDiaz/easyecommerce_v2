import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/main.dart';

class CreateReportStatusOrdersOperator {
//
//   *
//
  var tittleStyle = CellStyle(bold: true, backgroundColorHex: "#D3D3D3");
  var headerStyle = CellStyle(
      bold: true, backgroundColorHex: "#D3D3D3", fontColorHex: "#1976D2");
  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);

      var titleCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = 'EASY ECOMMERCE - REPORTE ESTADO DE ENTREGA OPERADOR';
      titleCell.cellStyle = tittleStyle;
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: 0),
          customValue: 'EASY ECOMMERCE - REPORTE ESTADO DE ENTREGA OPERADOR');

      for (var col = 0; col <= 23; col++) {
        var cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }

      List<String> headers = [
        'Fecha de Envio',
        'Fecha de Entrega',
        'Código',
        'Nombre Cliente',
        // 'Ciudad',
        // 'Dirección',
        'Teléfono Cliente',
        'Cantidad',
        'Producto',
        'Producto Extra',
        'Precio Total',
        'Observación',
        'Comentario',
        'Status'
        // 'Tipo de Pago',
        // 'Sub Ruta',
        // 'Operador',
        // 'Estado Devolución',
        // 'MDT. OF.',
        // 'MDT. BOD.',
        // 'MDT. RUTA',
        // 'MDT. INP',
        // 'Estado de Pago',
        // 'Número Intentos'
      ];

      for (var i = 0; i < headers.length; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
        cell.value = headers[i];
        cell.cellStyle = tittleStyle;
      }

      for (int rowIndex = 0; rowIndex < dataOrders.length; rowIndex++) {
        final data = dataOrders[rowIndex];
        final int excelRowIndex = rowIndex + 3;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: excelRowIndex))
            .value = data['marca_tiempo_envio'].toString().split(" ")[0];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: excelRowIndex))
            .value = data['fecha_entrega'].toString();
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 2, rowIndex: excelRowIndex))
                .value =
            "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal']}-${data['numero_orden']}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: excelRowIndex))
            .value = data["nombre_shipping"].toString();
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 4, rowIndex: excelRowIndex))
        //     .value = data['ciudad_shipping'].toString();
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 5, rowIndex: excelRowIndex))
        //     .value = data["direccion_shipping"].toString();
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: excelRowIndex))
            .value = data["telefono_shipping"].toString();

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: excelRowIndex))
            .value = data["cantidad_total"].toString();
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: excelRowIndex))
            .value = data["producto_p"].toString();
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 7, rowIndex: excelRowIndex))
                .value =
            data["producto_extra"] != null
                ? data["producto_extra"].toString()
                : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 8, rowIndex: excelRowIndex))
                .value =
            data["precio_total"] != null ? data["precio_total"].toString() : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 9, rowIndex: excelRowIndex))
                .value =
            data["observacion"] != null ? data["observacion"].toString() : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 10, rowIndex: excelRowIndex))
                .value =
            data["comentario"] != null ? data["comentario"].toString() : "";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 11, rowIndex: excelRowIndex))
            .value = data["status"];
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 14, rowIndex: excelRowIndex))
        //         .value =
        //     data["tipo_pago"] != null ? data["tipo_pago"].toString() : "";
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 15, rowIndex: excelRowIndex))
        //         .value =
        //     data['sub_ruta'] != null && data['sub_ruta'].isNotEmpty
        //         ? data['sub_ruta'][0]['titulo'].toString()
        //         : "";
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 16, rowIndex: excelRowIndex))
        //         .value =
        //     data['operadore'] != null && data['operadore'].toString() != "[]"
        //         ? data['operadore'][0]['up_users'][0]['username'].toString()
        //         : "";
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 17, rowIndex: excelRowIndex))
        //     .value = data["estado_devolucion"].toString();
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 18, rowIndex: excelRowIndex))
        //         .value =
        //     data["marca_t_d"] != null ? data["marca_t_d"].toString() : "";
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 19, rowIndex: excelRowIndex))
        //         .value =
        //     data["marca_t_d_l"] != null ? data["marca_t_d_l"].toString() : "";
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 20, rowIndex: excelRowIndex))
        //         .value =
        //     data["marca_t_d_t"] != null ? data["marca_t_d_t"].toString() : "";
        // sheet
        //         .cell(CellIndex.indexByColumnRow(
        //             columnIndex: 21, rowIndex: excelRowIndex))
        //         .value =
        //     data["marca_t_i"] != null ? data["marca_t_i"].toString() : "";
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 22, rowIndex: excelRowIndex))
        //     .value = data['estado_pagado'].toString();
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 23, rowIndex: excelRowIndex))
        //     .value = getLengthArrayMap(data['novedades']);

        //
      }

      var nombreFile =
          "EstadoEntregaTransporte-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '$nombreFile.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!: $e");
    }
  }

  getLengthArrayMap(List data) {
    var arraylength = data.length;
    return arraylength.toString();
  }
}
