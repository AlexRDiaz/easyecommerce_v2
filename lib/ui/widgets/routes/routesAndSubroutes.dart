import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutesandSubroutesModalv2 extends StatefulWidget {
  final idOrder;
  final bool someOrders;
  final String phoneClient;
  final String codigo;
  final String origin;
  final String? skuProduct;
  final String? quantity;

  const RoutesandSubroutesModalv2(
      {super.key,
      required this.idOrder,
      required this.someOrders,
      required this.phoneClient,
      required this.codigo,
      required this.origin,
      this.skuProduct,
      this.quantity});

  @override
  State<RoutesandSubroutesModalv2> createState() => _RoutesModalStatev2();
}

class _RoutesModalStatev2 extends State<RoutesandSubroutesModalv2> {
  TextEditingController textEditingController = TextEditingController();
  // TextEditingController textEditingControllerd = TextEditingController();

  List<String> routes = [];
  List<String> transports = [];
  String? selectedValueRoute;
  String? selectedValueTransport;

  List<String> subroutes = [];
  List<String> operator = [];
  String? selectedValueSubRoute;
  String? selectedValueOperator;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var routesList = [];

    setState(() {
      transports = [];
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

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getTransports() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var transportList = [];

    setState(() {
      transports = [];
    });

    transportList = await Connections().getTransportsByRouteLaravel(
        selectedValueRoute.toString().split("-")[1]);

    for (var i = 0; i < transportList.length; i++) {
      setState(() {
        transports
            .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getSubroutes() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var subroutesList = [];

    setState(() {
      subroutes = [];
    });

    print("Selected Route ID: ${selectedValueRoute.toString().split('-')[1]}");
    print(
        "Selected Transport ID: ${selectedValueTransport.toString().split('-')[1]}");

    subroutesList = await Connections().getSubRoutesbyRoute(
        selectedValueRoute.toString().split('-')[1],
        selectedValueTransport.toString().split('-')[1]);

    print("Subroutes response: $subroutesList");

    for (var i = 0; i < subroutesList.length; i++) {
      setState(() {
        subroutes = subroutesList.map((route) => '$route').toList();
      });
    }

    if (subroutes.isEmpty) {
      subroutes = ["N.A-9999"];
    }


    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getOperators() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var operatorsList = [];

    setState(() {
      operator = [];
    });

    operatorsList = await Connections()
        // .getOperatorBySubRoute(selectedValueSubRoute.toString().split("-")[1]);
        .getOperatorsbySubRoutes(selectedValueSubRoute.toString().split("-")[1],
            selectedValueTransport.toString().split('-')[1]);

    for (var i = 0; i < operatorsList.length; i++) {
      if (operatorsList[i] != null) {
        operator.add('${operatorsList[i]}');
      }
    }
    setState(() {});

    // print(subroutes);
    // print(operator);

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                    : (value) async {
                        setState(() {
                          selectedValueTransport = value as String;
                          selectedValueTransport;
                          subroutes.clear();
                          selectedValueSubRoute = null;
                        });

                        await getSubroutes();
                      },

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) async {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'SubRuta',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: subroutes
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueSubRoute,
                onChanged: (value) async {
                  setState(() {
                    selectedValueSubRoute = value as String;
                    // print("$selectedValueSubRoute");
                    selectedValueSubRoute;
                    operator.clear();
                    selectedValueOperator = null;
                  });
                  await getOperators();

                  // setState(() {});
                },

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Operador',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: operator
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueOperator,
                onChanged: selectedValueSubRoute == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedValueOperator = value as String;
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
                      selectedValueTransport == null ||
                      selectedValueSubRoute == null ||
                      selectedValueOperator == null
                  ? null
                  : () async {
                      if (widget.someOrders == false) {
                        // print("if just one");
                        var response = await Connections()
                            .updateOrderRouteAndTransportLaravel(
                                selectedValueRoute.toString().split("-")[1],
                                selectedValueTransport.toString().split("-")[1],
                                widget.idOrder);

                        var response2 = await Connections()
                            .updatenueva(widget.idOrder.toString(), {
                          "estado_interno": "CONFIRMADO",
                          "name_comercial": sharedPrefs!
                              .getString("NameComercialSeller")
                              .toString(),
                          "fecha_confirmacion":
                              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                        });

                        var response3 = await Connections().updateOrderWithTime(
                            widget.idOrder.toString(),
                            "estado_interno:CONFIRMADO",
                            sharedPrefs!.getString("id"),
                            "",
                            "");

                        var response4 = await Connections()
                            .updateOrderSubRouteAndOperatorLaravel(
                                selectedValueSubRoute.toString().split("-")[1],
                                selectedValueOperator.toString().split("-")[1],
                                widget.idOrder);

                        //for guides sent
                        if (widget.origin == "sent") {
                          var response3 = await Connections()
                              .updatenueva(widget.idOrder.toString(), {
                            "estado_logistico": "PENDIENTE",
                            "printed_by": null,
                            "marca_tiempo_envio": null,
                            'revisado': 0
                          });
                        }
                      } else {
                        for (var i = 0; i < widget.idOrder.length; i++) {
                          var response = await Connections()
                              .updateOrderRouteAndTransportLaravel(
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                  widget.idOrder);

                          var response2 = await Connections()
                              .updatenueva(widget.idOrder[i]['id'].toString(), {
                            "estado_interno": "CONFIRMADO",
                            "name_comercial": sharedPrefs!
                                .getString("NameComercialSeller")
                                .toString(),
                            "fecha_confirmacion":
                                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                          });

                          var response3 = await Connections()
                              .updateOrderWithTime(
                                  widget.idOrder.toString(),
                                  "estado_interno:CONFIRMADO",
                                  sharedPrefs!.getString("id"),
                                  "",
                                  "");

                          var response4 = await Connections()
                              .updateOrderSubRouteAndOperatorLaravel(
                                  selectedValueSubRoute
                                      .toString()
                                      .split("-")[1],
                                  selectedValueOperator
                                      .toString()
                                      .split("-")[1],
                                  widget.idOrder);

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
                          }
                        }
                      }
                      if (widget.phoneClient != "") {
                        sendMessage(widget.phoneClient, widget.codigo);
                      }

                      if (widget.origin == "order_entry") {
                        var responsereduceStock = await Connections()
                            .updateProductVariantStock(
                                widget.skuProduct, widget.quantity);

                        if (responsereduceStock == 0) {
                          print(true);
                        } else {
                          print(false);
                        }
                      }

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
