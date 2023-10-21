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
                        String value = "";
                        value = getKeyMDT(value);
                        await Connections().updateOrderReturnTransport(
                            barcode, widget.status, value);

                        //debit devolucion de pedidos
                        var datacostos = await Connections()
                            .getOrderByIDHistoryLaravel(barcode);

                        if (datacostos['estado_devolucion'] ==
                                "ENTREGADO EN OFICINA" ||
                            datacostos['estado_devolucion'] ==
                                "DEVOLUCION EN RUTA" ||
                            datacostos['estado_devolucion'] == "EN BODEGA") {
                          List existTransaction = await Connections()
                              .getExistTransaction(
                                  "debit",
                                  barcode,
                                  "devolucion",
                                  datacostos['users'][0]['vendedores'][0]
                                      ['id_master']);
                          if (existTransaction.isEmpty) {
                            var resDebit = await Connections().postDebit(
                                "${datacostos['users'][0]['vendedores'][0]['id_master']}",
                                "${datacostos['users'][0]['vendedores'][0]['costo_devolucion']}",
                                "${datacostos['id']}",
                                "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                                "devolucion",
                                "costo de devolucion de pedido ");
                            await Connections().updatenueva(barcode, {
                              "costo_devolucion": datacostos['users'][0]
                                  ['vendedores'][0]['costo_devolucion'],
                            });
                          }
                        }
                        setState(() {
                          _barcode =
                              "${responseOrder['attributes']['Name_Comercial']}-${responseOrder['attributes']['NumeroOrden']}";
                        });
                        Navigator.pop(context);

                        //-------------------------------------------------------------
                      } else {
                        await Connections()
                            .updateOrderReturnTransportRestart(barcode);
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
