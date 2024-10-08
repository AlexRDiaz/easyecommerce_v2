import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerPrintedDevoluciones extends StatefulWidget {
  const ScannerPrintedDevoluciones({super.key});

  @override
  State<ScannerPrintedDevoluciones> createState() =>
      _ScannerPrintedDevolucionesState();
}

class _ScannerPrintedDevolucionesState
    extends State<ScannerPrintedDevoluciones> {
  String? _barcode;
  late bool visible;
  String? _resTransaction;

  var idUser = sharedPrefs!.getString("id");
  bool resStatus = true;

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
                  // barcode = "246434";
                  // var responseOrder =
                  //     await Connections().getOrderByID(barcode.toString());
                  var responseOrder =
                      await Connections().getOrderByIDHistoryLaravel(barcode);
                  // var status = responseOrder['attributes']['Status'];
                  var status = responseOrder['status'];

                  if (!visible) return;
                  getLoadingModal(context, false);

                  if (status == "NOVEDAD" || status == "NO ENTREGADO") {
                    // await Connections().updateOrderWithTime(barcode.toString(),
                    //     "estado_devolucion:EN BODEGA", idUser, "", "");

                    paymentLogisticInWarehouse(
                        barcode.toString(), responseOrder);

                    setState(() {
                      _barcode =
                          "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                      // "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                    });
                  } else {
                    setState(() {
                      resStatus = false;
                      _barcode =
                          "Error al cambiar pedido: ${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']} a estado EN BODEGA, el status debe encontrarse en NOVEDAD o NO ENTREGADO";
                      // "Error al cambiar pedido: ${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']} a estado EN BODEGA, el status debe encontrarse en NOVEDAD o NO ENTREGADO";
                    });
                  }

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("MARCAR EL PEDIDO EN BODEGA",
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
                            color: _barcode == null || !resStatus
                                ? Colors.redAccent
                                : Colors.green)),
                    Text(
                        _resTransaction == null
                            ? ''
                            : 'Transaccion: $_resTransaction',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
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

  Future<void> paymentLogisticInWarehouse(id, responseOrder) async {
    var resNovelty = await Connections().paymentLogisticInWarehouse(id, "", "");

    dialogNovedad(resNovelty, responseOrder);
  }

  Future<void> dialogNovedad(resNovelty, responseOrder) async {
    if (resNovelty == 1 || resNovelty == 2) {
      // ignore: use_build_context_synchronously
      setState(() {
        _barcode = "Error al cambiar estado a EN BODEGA";
        resStatus = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      setState(() {
        _resTransaction = resNovelty["res"];

        _barcode =
            "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
        // "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
      });
    }
  }
}
