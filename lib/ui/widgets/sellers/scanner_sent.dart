import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerSent extends StatefulWidget {
  final String from;
  const ScannerSent({super.key, required this.from});

  @override
  State<ScannerSent> createState() => _ScannerStateSent();
}

class _ScannerStateSent extends State<ScannerSent> {
  String? _barcode;
  late bool visible;
  bool edited = false;
  String message = "PEDIDO A REVISAR";
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
                  // barcode = "174836";
                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);

                  var response;

                  if (responseOrder['estado_interno'] == "CONFIRMADO" &&
                      responseOrder['estado_logistico'] == "ENVIADO") {
                    if (widget.from == "seller") {
                      var userIdComercial =
                          sharedPrefs!.getString("idComercialMasterSeller");
                      var idComercialOrder = responseOrder['users'] != null &&
                              responseOrder['users'].isNotEmpty
                          ? responseOrder['users'][0]['vendedores'][0]
                              ['id_master']
                          : "NaN";
                      if (userIdComercial == idComercialOrder) {
                        response = await Connections().updatenueva(
                            barcode.toString(), {'revisado_seller': 1});
                        setState(() {
                          _barcode =
                              "${responseOrder['name_comercial']}-${responseOrder['numero_orden']}";
                        });
                      } else {
                        setState(() {
                          _barcode =
                              "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                          message =
                              "ESTE PEDIDO NO ES DE SU TIENDA, REVISE LA CUENTA CON LA QUE INICIÓ SESION";
                        });
                      }
                    } else if (widget.from == "logistic") {
                      response = await Connections().updatenueva(
                          barcode.toString(), {'revisado_seller': 2});
                      setState(() {
                        _barcode =
                            "${responseOrder['name_comercial']}-${responseOrder['numero_orden']}";
                      });
                    } else {
                      //provider?
                      response = await Connections().updatenueva(
                          barcode.toString(), {'revisado_seller': 1});
                      setState(() {
                        _barcode =
                            "${responseOrder['name_comercial']}-${responseOrder['numero_orden']}";
                      });
                    }
                    if (response == 0) {
                      edited = true;
                      setState(() {
                        message = "SE MARCÓ COMO REVISADO";
                      });
                    }
                  } else {
                    setState(() {
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                      message =
                          "Error, Este pedido se encuentra \nEstado interno: ${responseOrder['estado_interno']}\nEstado Logistico: ${responseOrder['estado_logistico']}\nSe debe encontrar en CONFIRMADO y ENVIADO respectivamente.";
                    });
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Text(message,
                    //     style: TextStyle(fontWeight: FontWeight.bold)),
                    // const SizedBox(
                    //   height: 30,
                    // ),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN: $_barcode\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || edited == false
                                ? Colors.redAccent
                                : Colors.green)),
                    Text(_barcode == null ? '' : 'RESPUESTA:\n $message',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || !edited
                                ? Colors.redAccent
                                : Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CERRAR",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            )
          ],
        ),
      ),
    );
  }
}
