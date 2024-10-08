import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerService extends StatefulWidget {
  final String from;
  // final Function onClose;

  const ScannerService({
    super.key,
    required this.from,
    // required this.onClose,
  });

  @override
  State<ScannerService> createState() => _ScannerServiceState();
}

class _ScannerServiceState extends State<ScannerService> {
  String? _code;
  late bool visible;
  Map<String, dynamic>? scanResult;
  List ordersScaned = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width * 0.7,
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
                  if (!visible) {
                    print("El lector no está visible.");
                    return;
                  }
                  print("El lector está visible. Procesando el escaneo...");

                  getLoadingModal(context, false);
                  // barcode = "400543";
                  // barcode = "409402";
                  // barcode = "389979";
                  print("Escaneo recibido: $barcode");

                  bool resStatus = true;
                  String message = "";
                  String status = "";
                  String estado_devolucion = "";
                  String producto = "";
                  String quantity = "";
                  String receivedBy = "";

                  if (barcode != "") {
                    if (widget.from == "provider") {
                      var responseOrder =
                          await Connections().getOrderByIDLaravel(
                        barcode,
                        [
                          "vendor",
                          "receivedBy",
                          "product_s.warehouses.provider",
                        ],
                      );
                      // print(responseOrder);

                      if (responseOrder != null) {
                        status = responseOrder['status'];
                        estado_devolucion = responseOrder['estado_devolucion'];
                        producto = responseOrder['producto_p'];
                        quantity = responseOrder['cantidad_total'];
                        receivedBy = responseOrder['received_by'] != null &&
                                responseOrder['received_by']['username'] !=
                                    null &&
                                responseOrder['received_by']['id'] != null
                            ? "${responseOrder['received_by']['username']}-${responseOrder['received_by']['id']}"
                            : '';

                        _code =
                            "${responseOrder['vendor']['nombre_comercial']}-${responseOrder['numero_orden']}";

                        if (status == "NOVEDAD" || status == "NO ENTREGADO") {
                          print("Control para provider");

                          int provType = 0;
                          String idUser =
                              sharedPrefs!.getString("id").toString();
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
                          if (responseOrder['product_s'] != null) {
                            var productS = responseOrder[
                                'product_s']; // Acceso a product_s

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
                              setState(() {
                                resStatus = false;

                                message =
                                    "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                              });
                            } else {
                              if (provType == 2) {
                                // arrayFiltersAnd.add(
                                //     {"product_s.warehouses.up_users.id_user": idUser});
                                print("is sub_provProv");

                                if (userIds
                                    .contains(int.parse(idUser.toString()))) {
                                  print("si tiene permitido admin el producto");
                                  print("realizar transaccion");
                                  //
                                } else {
                                  print(
                                      "NOOO tiene permitido admin el producto");
                                  setState(() {
                                    resStatus = false;

                                    message =
                                        "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                                  });
                                }
                              }
                            }
                          } else {
                            setState(() {
                              resStatus = false;

                              message =
                                  "Error, Este pedido no tiene registrado un producto interno.";
                            });
                          }
                        } else {
                          setState(() {
                            resStatus = false;

                            message =
                                "Error, el status debe encontrarse en NOVEDAD o NO ENTREGADO";
                          });
                        }

                        //
                      } else {
                        resStatus = false;

                        message = "Error, Orden no encontrada";
                      }
                    }

                    setState(() {
                      scanResult = {
                        "id": barcode,
                        "code": _code,
                        "product": producto,
                        "quantity": quantity,
                        "status_return": estado_devolucion,
                        "received_by": receivedBy,
                        "detail": message,
                        "status": resStatus,
                      };
                    });

                    bool exists = ordersScaned
                        .any((order) => order['id'] == scanResult?['id']);

                    // setState(() {
                    //   ordersScaned.add(scanResult);
                    // });

                    if (!exists) {
                      ordersScaned.add(scanResult);
                    } else {
                      print("El ID ya existe en la lista.");
                    }
                    //
                  }
                  setState(() {});

                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("BUSCAR GUÍA",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                        _code == null
                            ? 'SCANNER VACIO'
                            : 'ORDEN PROCESADA: $_code',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _code == null
                                ? Colors.redAccent
                                : Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const Center(
              child: Text(
                "Pedidos Scaneados",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: height * 0.45,
              width: width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.deepPurple[100],
              ),
              child: DataTable2(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                dataRowColor: MaterialStateColor.resolveWith((states) {
                  return Colors.white;
                }),
                dividerThickness: 1,
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(color: Colors.black),
                columnSpacing: 12,
                headingRowHeight: 40,
                horizontalMargin: 32,
                minWidth: 100,
                dataRowHeight: 70,
                columns: const [
                  DataColumn2(label: Text(""), fixedWidth: 40),
                  // DataColumn2(label: Text("ID"), fixedWidth: 100),
                  DataColumn2(
                    label: Text("Código"),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Producto"),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(label: Text("Cantidad"), fixedWidth: 70),
                  DataColumn2(
                    label: Text("Estado Dev."),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Recibido por"),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Observación"),
                    size: ColumnSize.L,
                  ),
                ],
                rows: List<DataRow>.generate(
                  ordersScaned.length,
                  (index) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            (index + 1).toString(),
                          ),
                        ),
                        // DataCell(
                        //   Text(
                        //     ordersScaned[index]['id'].toString(),
                        //     style: TextStyle(
                        //       color: !ordersScaned[index]['status']
                        //           ? Colors.red
                        //           : Colors.black,
                        //     ),
                        //   ),
                        // ),
                        DataCell(
                          Text(
                            ordersScaned[index]['code'].toString(),
                            style: TextStyle(
                              color: !ordersScaned[index]['status']
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ),
                        DataCell(Text(
                          ordersScaned[index]['product'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        )),
                        DataCell(Text(
                          ordersScaned[index]['quantity'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        )),
                        DataCell(Text(
                          ordersScaned[index]['status_return'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        )),
                        DataCell(Text(
                          ordersScaned[index]['received_by'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        )),
                        DataCell(Text(
                          ordersScaned[index]['detail'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // widget.onClose(); // Llamar a la función `loadData`

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "CERRAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    getLoadingModal(context, false);
                    // print("Cambiar a enBodega");
                    List<Map<String, dynamic>> ordersRespuestas = [];

                    for (var order in ordersScaned) {
                      if (order['status'] == true) {
                        // print("Actualizar estado");

                        var resNovelty = await Connections()
                            .paymentLogisticInWarehouse(order['id'], "", "");

                        if (resNovelty == 1 || resNovelty == 2) {
                          ordersRespuestas.add({
                            "id": order['id'],
                            "code": order['code'],
                            "status": "Error al cambiar estado a EN BODEGA"
                          });
                        } else {
                          ordersRespuestas.add({
                            "id": order['id'],
                            "code": order['code'],
                            "status": resNovelty["res"],
                          });
                        }
                      }
                    }

                    if (ordersRespuestas.isEmpty) {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }

                    if (ordersRespuestas.isNotEmpty) {
                      // print(ordersRespuestas);
                      ordersScaned.removeWhere((order) => ordersRespuestas
                          .any((response) => response['id'] == order['id']));

                      List<String> descriptions = [];
                      for (var order in ordersRespuestas) {
                        descriptions
                            .add("${order['code']}: ${order['status']}");
                      }
                      String desc = descriptions.join('\n');

                      if (mounted) {
                        AwesomeDialog(
                          width: 650,
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'Estado de solicitudes',
                          desc: desc,
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,
                          // btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            //
                            Navigator.pop(context);

                            setState(() {});
                          },
                        ).show();
                      }
                    }
                    //
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.green,
                    ),
                  ),
                  child: const Text(
                    "Cambiar a EN BODEGA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
