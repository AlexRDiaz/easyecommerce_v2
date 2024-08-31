import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutesModalv2 extends StatefulWidget {
  final idOrder;
  final bool someOrders;
  final String phoneClient;
  final String codigo;
  final String origin;
  // final String? skuProduct;
  // final String? quantity;
  // final String? type;
  // final String? idComercial;

  const RoutesModalv2({
    super.key,
    required this.idOrder,
    required this.someOrders,
    required this.phoneClient,
    required this.codigo,
    required this.origin,
    // this.skuProduct,
    // this.quantity,
    // this.type,
    // this.idComercial
  });

  @override
  State<RoutesModalv2> createState() => _RoutesModalStatev2();
}

class _RoutesModalStatev2 extends State<RoutesModalv2> {
  TextEditingController textEditingController = TextEditingController();
  List<String> routes = [];
  List<String> transports = [];
  String? selectedValueRoute;
  String? selectedValueTransport;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var routesList = [];
    setState(() {
      transports = [];
      isLoading = true;
    });

    routesList = await Connections().getRoutesLaravel();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        // routes.add('${routesList[i]['titulo']}-${routesList[i]['id']}');
        routes = routesList
            .where((route) => route['titulo'] != "[Vacio]")
            .map<String>((route) => '${route['titulo']}-${route['id']}')
            .toList();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  getTransports() async {
    var transportList = [];

    setState(() {
      isLoading = true;
      transports = [];
    });

    transportList = await Connections().getTransportsByRouteLaravel(
        selectedValueRoute.toString().split("-")[1]);

    for (var i = 0; i < transportList.length; i++) {
      transports.add('${transportList[i]['nombre']}-${transportList[i]['id']}');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
      isLoading: isLoading,
      content: AlertDialog(
        content: Container(
          width: 400,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccione las opciones:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Ciudad',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold),
                  ),
                  items: routes
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.split('-')[0],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  value: selectedValueRoute,
                  onChanged: (value) async {
                    setState(() {
                      selectedValueRoute = value as String;
                      transports.clear();
                      selectedValueTransport = null;
                    });
                    await getTransports();
                  },

                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      textEditingController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Transportadora',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold),
                  ),
                  items: transports
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.split('-')[0],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  value: selectedValueTransport,
                  onChanged: selectedValueRoute == null
                      ? null
                      : (value) {
                          setState(() {
                            selectedValueTransport = value as String;
                          });
                        },

                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      textEditingController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: selectedValueRoute == null ||
                        selectedValueTransport == null
                    ? null
                    : () async {
                        if (widget.someOrders == false) {
                          // print("if just one");
                          var response = await Connections()
                              .updateOrderRouteAndTransportLaravel(
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                  widget.idOrder);

                          // var response2 = await Connections()
                          //     .updatenueva(widget.idOrder.toString(), {
                          //   "estado_interno": "CONFIRMADO",
                          //   "name_comercial": sharedPrefs!
                          //       .getString("NameComercialSeller")
                          //       .toString(),
                          //   "fecha_confirmacion":
                          //       "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                          // });

                          if (response != 1 && response != 2) {
                            var response3 =
                                await Connections().updateOrderWithTime(
                              widget.idOrder.toString(),
                              "estado_interno:CONFIRMADO",
                              sharedPrefs!.getString("id"),
                              "",
                              {
                                "carrier":
                                    "int:${selectedValueTransport.toString().split("-")[1]}"
                              },
                            );

                            //for guides sent
                            if (widget.origin == "sent") {
                              var response3 = await Connections()
                                  .updatenueva(widget.idOrder.toString(), {
                                "estado_logistico": "PENDIENTE",
                                "printed_by": null,
                                "marca_tiempo_envio": null,
                                'revisado': 0
                              });

                              var response4 = await Connections()
                                  .updateOrderWithTime(
                                      widget.idOrder.toString(),
                                      "estado_logistico:PENDIENTE",
                                      sharedPrefs!.getString("id"),
                                      "",
                                      "");
                            }
                          }
                        } else {
                          for (var i = 0; i < widget.idOrder.length; i++) {
                            var response = await Connections()
                                .updateOrderRouteAndTransportLaravel(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    widget.idOrder[i]['id']);

                            // var response2 = await Connections().updatenueva(
                            //     widget.idOrder[i]['id'].toString(), {
                            //   "estado_interno": "CONFIRMADO",
                            //   "name_comercial": sharedPrefs!
                            //       .getString("NameComercialSeller")
                            //       .toString(),
                            //   "fecha_confirmacion":
                            //       "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                            // });
                            if (response != 1 && response != 2) {
                              var response3 =
                                  await Connections().updateOrderWithTime(
                                widget.idOrder[i]['id'].toString(),
                                "estado_interno:CONFIRMADO",
                                sharedPrefs!.getString("id"),
                                "",
                                {
                                  "carrier":
                                      "int:${selectedValueTransport.toString().split("-")[1]}"
                                },
                              );

                              //for guides sent
                              if (widget.origin == "sent") {
                                var response3 = await Connections().updatenueva(
                                    widget.idOrder[i]['id'].toString(), {
                                  "estado_logistico": "PENDIENTE",
                                  "printed_at": null,
                                  "printed_by": null,
                                  "marca_tiempo_envio": null,
                                  "revisado": 0,
                                  // "fecha_entrega": null,
                                  // "sent_at": null,
                                  // "sent_by": null,
                                });

                                var response4 = await Connections()
                                    .updateOrderWithTime(
                                        widget.idOrder[i]['id'].toString(),
                                        "estado_logistico:PENDIENTE",
                                        sharedPrefs!.getString("id"),
                                        "",
                                        "");
                              }
                            }
                          }
                        }
                        if (widget.phoneClient != "") {
                          sendMessage(widget.phoneClient, widget.codigo);
                        }

                        // if (widget.origin == "order_entry") {
                        //   var responsereduceStock = await Connections()
                        //       .updateProductVariantStock(
                        //           widget.skuProduct,
                        //           widget.quantity,
                        //           widget.type,
                        //           widget.idComercial);

                        //   if (responsereduceStock == 0) {
                        //     print(true);
                        //   } else {
                        //     print(false);
                        //   }
                        // }

                        setState(() {});
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: const Color(0xFF4688B1),
                  elevation: 5,
                  shadowColor: const Color.fromARGB(255, 97, 162, 203),
                ),
                child: const Text(
                  "ACEPTAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  sendMessage(phone, codigo) async {
    String message =
        "Gracias por confirmar tu compra, tu pedido ha sido enviado a tu Ciudad, el código de tu pedido es $codigo, si tu producto llega sin envoltura, sin caja o sin guía no lo reciba y comuniquese a este número caso contrario perderá su garantía";
    var _url =
        Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$message");
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
