import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerReturn extends StatefulWidget {
  const ScannerReturn({super.key});

  @override
  State<ScannerReturn> createState() => _ScannerReturnState();
}

class _ScannerReturnState extends State<ScannerReturn> {
  String? _barcode;
  String? _operador;
  late bool visible;
  String message = "";
  bool statusUpt = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
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
                  // barcode = "65099";

                  if (!visible) return;
                  getLoadingModal(context, false);

                  var userIdComercial =
                      sharedPrefs!.getString("idComercialMasterSeller");
                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);
                  var idComercialOrder = responseOrder['users'] != null &&
                          responseOrder['users'].isNotEmpty
                      ? responseOrder['users'][0]['vendedores'][0]['id_master']
                      : "NaN";

                  if (userIdComercial == idComercialOrder) {
                    //
                    var responseUpt = await Connections().updateOrderWithTime(
                        barcode.toString(),
                        "estado_devolucion:EN BODEGA PROVEEDOR",
                        sharedPrefs!.getString("id"),
                        "seller",
                        "");

                    if (responseUpt == 0) {
                      statusUpt = true;
                      setState(() {
                        _barcode =
                            "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";

                        message = "ORDEN PROCESADA EXITOSAMENTE";
                      });
                    } else {
                      message = "OCURRIÓ UN ERROR EN EL PROCESO";
                    }
                  } else {
                    setState(() {
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                      message =
                          "ESTE PEDIDO NO ES DE SU TIENDA, REVISE LA CUENTA CON LA QUE INICIÓ SESION";
                    });
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("SCANNEAR PEDIDO",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN: $_barcode\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || !statusUpt
                                ? Colors.black
                                : Colors.green)),
                    Text(_barcode == null ? '' : 'RESPUESTA: $message\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || !statusUpt
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
