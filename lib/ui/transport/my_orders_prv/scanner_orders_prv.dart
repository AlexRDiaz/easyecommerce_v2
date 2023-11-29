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
                  // barcode = "112919";
                  if (!visible) return;
                  getLoadingModal(context, false);

                  var responseOrder = await Connections().getOrderByID(barcode);
                  var m = responseOrder['attributes']['sub_ruta'];
                  if (responseOrder['attributes']['sub_ruta']['data'] != null) {
                    var response = await Connections()
                        .updateReviewStatus(barcode.toString());

                    // await Connections().updateOrderWithTime(
                    //     barcode.toString(),
                    //     'received_carrier_at:OK',
                    //     sharedPrefs!.getString("id"),
                    //     '',
                    //     '');

                    setState(() {
                      _barcode =
                          "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                      _operador = responseOrder['attributes']['operadore']
                              ['data']['attributes']['user']['data']
                          ['attributes']['username'];

                      message = "SE MARCÓ COMO REVISADO";
                    });
                  } else {
                    setState(() {
                      _barcode =
                          "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
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
