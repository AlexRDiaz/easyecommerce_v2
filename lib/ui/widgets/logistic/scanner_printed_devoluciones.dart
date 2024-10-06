import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/providers/pin_input.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerPrintedDevoluciones extends StatefulWidget {
  final String from;

  const ScannerPrintedDevoluciones({
    super.key,
    required this.from,
  });

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
                  barcode = "409369";
                  //409438 gy
                  //409402 gy gtm
                  //409369 gy
                  //408668 uio
                  //407657 uio
                  //271879
                  // var responseOrder =
                  //     await Connections().getOrderByID(barcode.toString());

                  var responseOrder = await Connections().getOrderByIDLaravel(
                    barcode,
                    [
                      "vendor",
                      "product_s.warehouses.provider",
                      // "users.vendedores",
                      // 'operadore.up_users',
                      // 'ruta',
                    ],
                  );
                  // print(responseOrder);

                  // var responseOrder =
                  //     await Connections().getOrderByIDHistoryLaravel(barcode);
                  /*
                  'operadore.up_users',
                  'transportadora',
                  'users.vendedores',
                  'novedades',
                  'pedidoFecha',
                  'ruta',
                  'subRuta',
                  "statusLastModifiedBy",
                  "carrierExternal",
                  "ciudadExternal",
                  "pedidoCarrier"
                  */
                  // var status = responseOrder['attributes']['Status'];
                  var status = responseOrder['status'];

                  if (!visible) return;
                  getLoadingModal(context, false);

                  if (status == "NOVEDAD" || status == "NO ENTREGADO") {
                    // await Connections().updateOrderWithTime(barcode.toString(),
                    //     "estado_devolucion:EN BODEGA", idUser, "", "");

                    if (widget.from == "provider") {
                      print("Control para provider");
                      // print(responseOrder);
                      int provType = 0;
                      String idUser = sharedPrefs!.getString("id").toString();
                      String idProv =
                          sharedPrefs!.getString("idProvider").toString();
                      String idProvUser = sharedPrefs!
                          .getString("idProviderUserMaster")
                          .toString();

                      if (idProvUser == idUser) {
                        provType = 1; //prov principal
                      } else if (idProvUser != idUser) {
                        provType = 2; //sub principal
                      }

                      bool ready = true;

                      var productS =
                          responseOrder['product_s']; // Acceso a product_s

                      var warehouses = productS['warehouses'];
                      // print(warehouses);
                      var ultimoWarehouse =
                          warehouses.last; // Obtener el último almacén
                      var branchName = ultimoWarehouse['branch_name'];

                      var providerId = ultimoWarehouse['provider_id'];

                      List<dynamic> upUsers = ultimoWarehouse['up_users'];

                      List<int> userIds = [];

                      for (var user in upUsers) {
                        userIds.add(user['id_user']);
                      }

                      print('providerId: $providerId');
                      print('User IDs: $userIds');

                      //control de que si pertenezca al provider principal
                      if (int.parse(idProv.toString()) !=
                          int.parse(providerId.toString())) {
                        //
                        ready = false;
                        setState(() {
                          resStatus = false;
                          _barcode =
                              "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";
                          message =
                              "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                        });
                      } else {
                        if (provType == 2) {
                          // arrayFiltersAnd.add(
                          //     {"product_s.warehouses.up_users.id_user": idUser});
                          print("is sub_provProv");

                          if (userIds.contains(int.parse(idUser.toString()))) {
                            print("si tiene permitido admin el producto");
                            print("realizar transaccion");
                            //
                          } else {
                            ready = false;
                            print("NOOO tiene permitido admin el producto");
                            setState(() {
                              resStatus = false;
                              _barcode =
                                  "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";
                              message =
                                  "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                            });
                          }
                        }
                      }

                      if (ready) {
                        print("realizar transaccion");
                        paymentLogisticInWarehouse(
                            barcode.toString(), responseOrder);

                        setState(() {
                          _barcode =
                              "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";
                          message = "";
                        });
                      }

                      //
                    } else {
                      paymentLogisticInWarehouse(
                          barcode.toString(), responseOrder);

                      setState(() {
                        _barcode =
                            "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";
                        // "${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']}";
                        message = "";
                      });
                    }
                  } else {
                    setState(() {
                      resStatus = false;
                      _barcode =
                          "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";
                      // "Error al cambiar pedido: ${responseOrder['users'] != null ? responseOrder['users'][0]['vendedores'][0]['nombre_comercial'] : responseOrder['tienda_temporal'].toString()}-${responseOrder['numero_orden']} a estado EN BODEGA, el status debe encontrarse en NOVEDAD o NO ENTREGADO";
                      message =
                          "Error, el status debe encontrarse en NOVEDAD o NO ENTREGADO";
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
                    // Text(
                    //     _barcode == null
                    //         ? 'SCANNER VACIO'
                    //         : 'ORDEN PROCESADA: $_barcode',
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: _barcode == null || !resStatus
                    //             ? Colors.redAccent
                    //             : Colors.green)),
                    Text(
                        _barcode == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN: $_barcode\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _barcode == null || resStatus == false
                                ? Colors.redAccent
                                : Colors.green)),
                    Text(_barcode == null ? '' : 'RESPUESTA: $message',
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
