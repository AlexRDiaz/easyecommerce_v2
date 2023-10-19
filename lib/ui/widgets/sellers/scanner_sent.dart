import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerSent extends StatefulWidget {
  const ScannerSent({super.key});

  @override
  State<ScannerSent> createState() => _ScannerStateSent();
}

class _ScannerStateSent extends State<ScannerSent> {
  String? _barcode;
  late bool visible;
  bool edited = false;
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
                  // barcode = "99205";
                  if (!visible) return;
                  getLoadingModal(context, false);

                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);

                  if (responseOrder['estado_logistico'] == 'ENVIADO') {
                    setState(() {
                      _barcode =
                          "El pedido con código ${responseOrder['name_comercial']}-${responseOrder['numero_orden']} ya se encuentra enviado"
                          "";
                    });
                    edited = false;
                  } else {
                    var response = await Connections().updatenueva(
                        barcode.toString(),
                        {'estado_logistico': "ENVIADO", 'revisado': 1});

                    setState(() {
                      _barcode =
                          "${responseOrder['name_comercial']}-${responseOrder['numero_orden']}";
                    });
                    edited = true;
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("MARCAR ORDENES COMO ENVIADAS",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN PROCESADA: $_barcode',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || edited == false
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
