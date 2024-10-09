import 'dart:convert';
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
      sheet!.setColWidth(8, 50);
      sheet.setColWidth(12, 20);

      sheet.setColAutoFit(2);
      sheet.setColAutoFit(3);
      sheet.setColAutoFit(6);
      sheet.setColAutoFit(15);

      var nameComercial =
          sharedPrefs!.getString("NameComercialSeller").toString();
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      //     .value = 'Fecha de Ingreso';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Fecha Envio';
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
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0))
      //     .value = 'Estado Interno';
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0))
      //     .value = 'Estado logistico';
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0))
      //     .value = 'Estado Devolucion';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0))
          .value = 'Costo Envio';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0))
          .value = 'Costo Devolucion';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 0))
          .value = 'Costo Proveedor';
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 0))
      //     .value = 'Transportadora';

      for (int rowIndex = 0; rowIndex < dataOrders.length; rowIndex++) {
        final data = dataOrders[rowIndex];

        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 0, rowIndex: rowIndex + 1))
        //     .value = data["marca_t_i"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = data["marca_tiempo_envio"];
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
            .value = data["precio_total"].toString() == "" ||
                data["precio_total"].toString() == "null"
            ? ""
            : double.parse(data["precio_total"].toString());
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 11, rowIndex: rowIndex + 1))
            .value = data["comentario"];
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 12, rowIndex: rowIndex + 1))
        //     .value = data["status"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 12, rowIndex: rowIndex + 1))
            .value = data['status_history'].toString() == "null" ||
                data['status_history'].toString() == "[]"
            ? (data['status'].toString() == "NOVEDAD" ||
                        data['status'].toString() == "NO ENTREGADO") &&
                    data['estado_devolucion'].toString() != "PENDIENTE"
                ? data['estado_devolucion'].toString()
                : data['status'].toString()
            : getLastStatusFromJson(
                data['status_history'].toString(),
              ).toString().split(":")[1];
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 13, rowIndex: rowIndex + 1))
        //     .value = data["estado_interno"];
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 14, rowIndex: rowIndex + 1))
        //     .value = data["estado_logistico"];
        // sheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: 15, rowIndex: rowIndex + 1))
        //     .value = data["estado_devolucion"];

        var costoEnvio = "";

        if (data['pedido_carrier'].isNotEmpty) {
          costoEnvio = data['costo_envio'] == null ||
                  data['costo_envio'].toString() == "null" ||
                  data['costo_envio'].toString() == ""
              ? ""
              : data['costo_envio'].toString();
        } else if (data['pedido_carrier'].isEmpty && data['users'] != null) {
          if (data['status'].toString() == "ENTREGADO" ||
              data['status'].toString() == "NO ENTREGADO") {
            if (data['costo_envio'] == null ||
                data['costo_envio'].toString() == "null" ||
                data['costo_envio'].toString() == "") {
              costoEnvio =
                  data['users'][0]['vendedores'][0]['costo_envio'].toString();
            } else {
              costoEnvio = data['costo_envio'].toString();
            }
          }
        }

        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 13, rowIndex: rowIndex + 1))
                .value =
            costoEnvio.toString() == "" || costoEnvio.toString() == "null"
                ? ""
                : double.parse(costoEnvio.toString());

        var costoDevolucion = "";

        if (data['pedido_carrier'].isNotEmpty) {
          costoDevolucion = data['costo_devolucion'] == null ||
                  data['costo_devolucion'].toString() == "null" ||
                  data['costo_devolucion'].toString() == ""
              ? ""
              : data['costo_devolucion'].toString();
        } else if (data['pedido_carrier'].isEmpty && data['users'] != null) {
          if (data['status'].toString() == "NOVEDAD") {
            if (data['estado_devolucion'] != "PENDIENTE") {
              if (data['costo_devolucion'] == null ||
                  data['costo_devolucion'].toString() == "null" ||
                  data['costo_devolucion'].toString() == "") {
                costoDevolucion = data['users'][0]['vendedores'][0]
                        ['costo_devolucion']
                    .toString();
              } else {
                costoDevolucion = data['costo_devolucion'].toString();
              }
            }
          }
        }

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 14, rowIndex: rowIndex + 1))
            .value = costoDevolucion.toString() == "" ||
                costoDevolucion.toString() == "null"
            ? ""
            : double.parse(costoDevolucion.toString());

        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 15, rowIndex: rowIndex + 1))
                .value =
            data['value_product_warehouse'] != null
                ? double.parse(data['value_product_warehouse'].toString())
                : " ";
        /*
        if (data["transportadora"].isEmpty) {
          if (data['pedido_carrier'].isNotEmpty) {
            sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 16, rowIndex: rowIndex + 1))
                    .value =
                data['pedido_carrier'][0]['carrier']['name'].toString();
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
              .value = data["transportadora"][0]["nombre"];
        }
        */
        //
      }

      var nombreFile =
          "$nameComercial-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte! $e");
    }
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
