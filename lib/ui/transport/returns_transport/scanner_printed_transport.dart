import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerPrintedTransport extends StatefulWidget {
  final String status;
  const ScannerPrintedTransport({super.key, required this.status});

  @override
  State<ScannerPrintedTransport> createState() =>
      _ScannerPrintedTransportState();
}

class _ScannerPrintedTransportState extends State<ScannerPrintedTransport> {
  String? _barcode;
  late bool visible;
  String? _resTransaction;
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
                  barcode = "126669";
                  if (!visible) return;
                  getLoadingModal(context, false);

                  var responseOrder = await Connections().getOrderByID(barcode);
                  if (responseOrder['attributes']['Status'] == 'NO ENTREGADO' ||
                      responseOrder['attributes']['Status'] == 'NOVEDAD') {
                    if (responseOrder['attributes']['Estado_Devolucion'] ==
                            "DEVOLUCION EN RUTA" &&
                        widget.status == "ENTREGADO EN OFICINA") {
                      setState(() {
                        _barcode =
                            "El pedido ${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']} no se puede cambiar a entregado en oficina porque tiene estado "
                            "DEVOLUCION EN RUTA";
                      });
                      Navigator.pop(context);
                    } else {
                      if (widget.status != "PENDIENTE") {
                        paymentTransportByReturnStatus(
                            barcode, widget.status, responseOrder);

                        Navigator.pop(context);

                        //-------------------------------------------------------------
                      } else {
                        var resReiniciar = await Connections()
                            .updateOrderReturnTransportRestart(barcode);
                        setState(() {
                          _barcode =
                              "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                        });
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    setState(() {
                      _barcode =
                          "No se puede alterar el pedido con código ${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                    });
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("MARCAR DEVOLUCIÓN CON ESTADO ${widget.status}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN PROCESADA: $_barcode',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null
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

  Future<void> paymentTransportByReturnStatus(
      id, returnStatus, responseOrder) async {
    var resNovelty = await Connections()
        .paymentTransportByReturnStatus(id, "", "", returnStatus);

    dialogNovedad(resNovelty, returnStatus, responseOrder);
  }

  Future<void> dialogNovedad(resNovelty, returnStatus, responseOrder) async {
    if (resNovelty == 1 || resNovelty == 2) {
      // ignore: use_build_context_synchronously
      setState(() {
        _barcode = "Error al cambiar estado a $returnStatus";
      });
    } else {
      // ignore: use_build_context_synchronously
      setState(() {
        _resTransaction = resNovelty["res"];

        _barcode =
            "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
      });
    }
  }

  String getKeyMDT(String value) {
    if (widget.status == "ENTREGADO EN OFICINA") {
      value = "Marca_T_D";
    }
    if (widget.status == "DEVOLUCION EN RUTA") {
      value = "Marca_T_D_T";
    }

    return value;
  }
}
