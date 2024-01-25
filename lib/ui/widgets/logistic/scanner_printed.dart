import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerPrinted extends StatefulWidget {
  final String from;
  const ScannerPrinted({super.key, required this.from});

  @override
  State<ScannerPrinted> createState() => _ScannerPrintedState();
}

class _ScannerPrintedState extends State<ScannerPrinted> {
  String? _barcode;
  late bool visible;
  bool edited = false;
  var idUser = sharedPrefs!.getString("id");

  String message = "";
  String estado_interno = "";
  String estado_logistico = "";
  String status = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VisibilityDetector(
              onVisibilityChanged: (VisibilityInfo info) {
                visible = info.visibleFraction > 0;
              },
              key: Key('visible-detector-key'),
              child: BarcodeKeyboardListener(
                bufferDuration: Duration(milliseconds: 200),
                onBarcodeScanned: (barcode) async {
                  if (!visible) return;
                  getLoadingModal(context, false);
                  // barcode = "174790";
                  // var responseOrder = await Connections().getOrderByID(barcode);
                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);

                  estado_interno = responseOrder['estado_interno'];
                  estado_logistico = responseOrder['estado_logistico'];
                  status = responseOrder['status'];
                  if (responseOrder['estado_interno'] == "CONFIRMADO" &&
                      responseOrder['estado_logistico'] == "IMPRESO" &&
                      responseOrder['status'] == "PEDIDO PROGRAMADO") {
                    //
                    //hacer upt
                    var responseL;
                    if (widget.from == "seller") {
                      //control de pedido de esa tienda
                      var userIdComercial =
                          sharedPrefs!.getString("idComercialMasterSeller");
                      var idComercialOrder = responseOrder['users'] != null &&
                              responseOrder['users'].isNotEmpty
                          ? responseOrder['users'][0]['vendedores'][0]
                              ['id_master']
                          : "NaN";

                      if (userIdComercial == idComercialOrder) {
                        responseL = await Connections().updateOrderWithTime(
                            barcode.toString(),
                            "estado_logistico:ENVIADO",
                            idUser,
                            "",
                            "");
                      } else {
                        setState(() {
                          _barcode =
                              "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                          message =
                              "ESTE PEDIDO NO ES DE SU TIENDA, REVISE LA CUENTA CON LA QUE INICIÓ SESION";
                        });
                      }
                    } else if (widget.from == "logistic") {
                      responseL = await Connections().updateOrderWithTime(
                          barcode.toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                    } else if (widget.from == "transport_printedguides") {
                      responseL = await Connections().updateOrderWithTime(
                          barcode.toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                      var responsewith = await Connections().updateRetirementStatus(
                          responseOrder['id'].toString());
                          // responseOrder['withdrawan_by'].toString()
                          // "T-${sharedPrefs!.getString("idTransportadora").toString()}");

                    } else if (widget.from == "operator_printedguides") {

                      responseL = await Connections().updateOrderWithTime(
                          barcode.toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                      var responsewith = await Connections().updateRetirementStatus(
                          responseOrder['id'].toString());

                    } else {
                      //provider?
                      responseL = await Connections().updateOrderWithTime(
                          barcode.toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                    }
                    setState(() {
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                    });
                    if (responseL == 0) {
                      edited = true;
                      setState(() {
                        message = "SE MARCÓ COMO ENVIADO";
                      });
                    }
                  } else {
                    setState(() {
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                      message =
                          //'La guia "$_barcode" NO puede ser procesada por los estados actuales\nEstado interno: ${responseOrder['estado_interno']}\nEstado Logistico: ${responseOrder['estado_logistico']}\nStatus: ${responseOrder['status']}\nSe debe encontrar en CONFIRMADO, IMPRESO y PEDIDO PROGRAMADO respectivamente.';
                          // 'Esta guia NO puede ser procesada por los estados actuales\nEstado interno: ${responseOrder['estado_interno']}\nEstado Logistico: ${responseOrder['estado_logistico']}\nStatus: ${responseOrder['status']}\nSe debe encontrar en CONFIRMADO, IMPRESO y PEDIDO PROGRAMADO respectivamente.';
                          'Esta guia NO puede ser procesada por los estados actuales:';
                    });
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        _barcode == null ? 'SCANNER VACIO' : 'ORDEN: $_barcode',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || edited == false
                                ? Colors.redAccent
                                : Colors.green)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_barcode == null ? '' : 'RESPUESTA:'),
                    ),
                    Text(_barcode == null ? '' : '$message\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || !edited
                                ? Colors.redAccent
                                : Colors.green)),
                    Visibility(
                      visible: estado_interno != "" && edited == false,
                      child: Row(
                        children: [
                          Text(
                            'Estado interno: $estado_interno ',
                          ),
                          estado_interno != "CONFIRMADO"
                              ? const Icon(Icons.cancel, color: Colors.red)
                              : const Icon(Icons.check_box,
                                  color: Colors.green),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: estado_logistico != "" && edited == false,
                      child: Row(
                        children: [
                          Text(
                            'Estado Logistico: $estado_logistico ',
                          ),
                          estado_logistico != "IMPRESO"
                              ? const Icon(Icons.cancel, color: Colors.red)
                              : const Icon(Icons.check_box,
                                  color: Colors.green),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: status != "" && edited == false,
                      child: Row(
                        children: [
                          Text(
                            'Status: $status ',
                          ),
                          status != "PEDIDO PROGRAMADO"
                              ? const Icon(Icons.cancel, color: Colors.red)
                              : const Icon(Icons.check_box,
                                  color: Colors.green),
                        ],
                      ),
                    ),
                    Visibility(
                        visible: (estado_interno != "" &&
                                estado_interno != "CONFIRMADO") ||
                            (estado_logistico != "" &&
                                estado_logistico != "IMPRESO") ||
                            (status != "" && status != "PEDIDO PROGRAMADO"),
                        child: const Text(
                            'Se debe encontrar en estados CONFIRMADO, IMPRESO y PEDIDO PROGRAMADO respectivamente.'))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("CERRAR",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            )
          ],
        ),
      ),
    );
  }
}
