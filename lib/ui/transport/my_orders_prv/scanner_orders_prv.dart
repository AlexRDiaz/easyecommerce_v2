import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerOrdersPrv extends StatefulWidget {
  const ScannerOrdersPrv({super.key});

  @override
  State<ScannerOrdersPrv> createState() => _ScannerOrdersPrvState();
}

class _ScannerOrdersPrvState extends State<ScannerOrdersPrv> {
  String? _barcode;
  String? _operador;
  late bool visible;
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
                  // barcode = "174248";

                  // var responseOrder = await Connections().getOrderByID(barcode);
                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);

                  List m = responseOrder['sub_ruta'];
                  if (m.isNotEmpty) {
                    // var response = await Connections()
                    //     .updateReviewStatus(barcode.toString());

                    var response = await Connections()
                        .updatenueva(barcode.toString(), {'revisado': 1});

                    setState(() {
                      // _barcode =
                      //     "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";

                      _operador = responseOrder['operadore'][0]['up_users'][0]
                          ['username'];

                      message = "SE MARCÓ COMO REVISADO";
                    });
                  } else {
                    setState(() {
                      // _barcode =
                      //     "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";

                      _operador = "OPERADOR Y SUB-RUTA NO ASIGNADOS";
                      message = "NO SE MARCÓ COMO REVISADO";
                    });
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(message,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN PROCESADA: $_barcode\n OPERADOR: $_operador',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null ||
                                    _operador ==
                                        "OPERADOR Y SUB-RUTA NO ASIGNADOS"
                                ? Colors.redAccent
                                : Colors.green)),
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
