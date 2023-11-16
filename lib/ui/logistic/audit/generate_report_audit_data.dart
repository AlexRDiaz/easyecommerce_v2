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
  Future<void> generateExcelFileWithData(dataOrders) async {
    List<Future<String>> usernameFutures =
        dataOrders.map<Future<String>>((order) {
      return userNametotoConfirmOrder(order['confirmed_by'] ?? 0);
    }).toList();

    // Esperar a que todos los Future se completen
    List<String> usernames = await Future.wait(usernameFutures);

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
          CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: 0),
          customValue: 'EASY ECOMMERCE - REPORTE AUDITORIA');

      for (var col = 0; col <= 18; col++) {
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
        'Usuario de Confirmación',
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
            .value = data['users'][0]['vendedores'][0]['nombre_comercial'];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: excelRowIndex))
                .value =
            extractDateFromBrackets(safeValue(data['marca_t_i'].toString()));
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: excelRowIndex))
            .value = data['fecha_confirmacion'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: excelRowIndex))
            .value = data['fecha_entrega'];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: excelRowIndex))
            .value = data['marca_tiempo_envio'];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 5, rowIndex: excelRowIndex))
                .value =
            "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal']}-${data['numero_orden']}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: excelRowIndex))
            .value = data["nombre_shipping"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: excelRowIndex))
            .value = data['ciudad_shipping'];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: excelRowIndex))
            .value = usernames[rowIndex];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 9, rowIndex: excelRowIndex))
            .value = data["status"];

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 10, rowIndex: excelRowIndex))
            .value = data['transportadora'] != null &&
                data['transportadora'].toString() != "[]"
            ? data['transportadora'][0]['nombre'].toString()
            : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 11, rowIndex: excelRowIndex))
                .value =
            data['ruta'] != null && data['ruta'].toString() != "[]"
                ? data['ruta'][0]['titulo'].toString()
                : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 12, rowIndex: excelRowIndex))
                .value =
            data['sub_ruta'] != null && data['sub_ruta'].toString() != "[]"
                ? data['sub_ruta'][0]['titulo'].toString()
                : "";
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 13, rowIndex: excelRowIndex))
                .value =
            data['operadore'] != null && data['operadore'].toString() != "[]"
                ? data['operadore'][0]['up_users'][0]['username'].toString()
                : "";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 14, rowIndex: excelRowIndex))
            .value = data["observacion"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 15, rowIndex: excelRowIndex))
            .value = data["comentario"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 16, rowIndex: excelRowIndex))
            .value = data["estado_interno"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 17, rowIndex: excelRowIndex))
            .value = data["estado_logistico"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 18, rowIndex: excelRowIndex))
            .value = data["estado_devolucion"];

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

  Future<String> userNametotoConfirmOrder(userId) async {
    if (userId == 0) {
      return 'Desconocido';
    } else {
      var user =
          await Connections().getPersonalInfoAccountforConfirmOrder(userId);
      // Verifica si user es nulo
      if (user != null && user.containsKey('username')) {
        return user['username'].toString();
      } else {
        // Maneja el caso de usuario nulo o sin 'username'
        return 'Desconocido';
      }
    }
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
