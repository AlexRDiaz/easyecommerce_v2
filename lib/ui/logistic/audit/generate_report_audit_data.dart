import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';

class CreateReportAudit {
//
//   *
//
  var tittleStyle = CellStyle(bold: true, backgroundColorHex: "#D3D3D3");
  var headerStyle = CellStyle(
      bold: true, backgroundColorHex: "#D3D3D3", fontColorHex: "#1976D2");
  Future<void> generateExcelFileWithDataAudit(dataOrders) async {

    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);

      var titleCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = 'EASY ECOMMERCE - REPORTE AUDITORIA';
      titleCell.cellStyle = tittleStyle;
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 0),
          customValue: 'EASY ECOMMERCE - REPORTE AUDITORIA');

      for (var col = 0; col <= 17; col++) {
        var cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }

      List<String> headers = [
        'Tienda',
        'Fecha Ingreso Pedido',
        'Fecha de Confirmación',
        'Fecha Entrega',
        'Marca Tiempo Envio',
        'Código',
        'Nombre Cliente',
        'Ciudad',
        // 'Usuario de Confirmación',
        'Status',
        'Transportadora',
        'Ruta',
        'SubRuta',
        'Operador',
        'Observación',
        'Comentario',
        'Estado Interno',
        'Estado Logístico',
        'Estado Devolución',
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
            .value = data['users'][0]['vendedores'][0]['nombre_comercial'].toString()!=""?
            data['users'][0]['vendedores'][0]['nombre_comercial'].toString(): "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: excelRowIndex))
                .value =
            extractDateFromBrackets(safeValue(data['marca_t_i'].toString())) != "" ? 
            extractDateFromBrackets(safeValue(data['marca_t_i'].toString())) :"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: excelRowIndex))
            .value = data['fecha_confirmacion'].toString()!="" ?
                    data['fecha_confirmacion'].toString() :"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: excelRowIndex))
            .value = data['fecha_entrega'].toString()!=""?
            data['fecha_entrega'].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: excelRowIndex))
            .value = data['marca_tiempo_envio'].toString()!=""?
            data['marca_tiempo_envio'].toString():"";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 5, rowIndex: excelRowIndex))
                .value =
            "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'].toString() : data['tienda_temporal']}-${data['numero_orden'].toString()}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: excelRowIndex))
            .value = data["nombre_shipping"].toString()!=""?
            data["nombre_shipping"].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: excelRowIndex))
            .value = data['ciudad_shipping'].toString()!=""?
            data['ciudad_shipping'].toString() :"";

        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 8, rowIndex: excelRowIndex))
        //     .value =data['confirmed_by'] != null ? data['confirmed_by']['username'].toString() : 'Desconocido';
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: excelRowIndex))
            .value = data["status"].toString()!= " "
            ?data["status"].toString() : "";

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 9, rowIndex: excelRowIndex))
            .value = data['transportadora'] != null &&
                data['transportadora'].toString() != "[]"
            ? data['transportadora'][0]['nombre'].toString()
            : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 10, rowIndex: excelRowIndex))
                .value =
            data['ruta'] != null && data['ruta'].toString() != "[]"
                ? data['ruta'][0]['titulo'].toString()
                : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 11, rowIndex: excelRowIndex))
                .value =
            data['sub_ruta'] != null && data['sub_ruta'].toString() != "[]"
                ? data['sub_ruta'][0]['titulo'].toString()
                : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 12, rowIndex: excelRowIndex))
                .value =
            data['operadore'] != null && data['operadore'].toString() != "[]"
                ? data['operadore'][0]['up_users'][0]['username'].toString()
                : "";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 13, rowIndex: excelRowIndex))
            .value = data["observacion"].toString()!=""?
            data["observacion"].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 14, rowIndex: excelRowIndex))
            .value = data["comentario"].toString()!=""?
            data["comentario"].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 15, rowIndex: excelRowIndex))
            .value = data["estado_interno"].toString()!=""?
            data["estado_interno"].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 16, rowIndex: excelRowIndex))
            .value = data["estado_logistico"].toString()!=""?
            data["estado_logistico"].toString():"";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 17, rowIndex: excelRowIndex))
            .value = data["estado_devolucion"].toString()!=""?
            data["estado_devolucion"].toString():"";

        //
      }

      var nombreFile =
          "Auditoria-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '$nombreFile.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!");
    }
  }

  getLengthArrayMap(List data) {
    var arraylength = data.length;
    return arraylength.toString();
  }



  String safeValue(dynamic value, [String defaultValue = '']) {
    return (value ?? defaultValue).toString();
  }

  String extractDateFromBrackets(String input) {
    int startIndex = input.indexOf('[');
    int endIndex = input.indexOf(']');

    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      return input.substring(startIndex + 1, endIndex);
    }

    return input; // Retorna la entrada original si no hay corchetes o el formato es incorrecto
  }
}
