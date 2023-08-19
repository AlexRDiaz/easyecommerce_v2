import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutesModal extends StatefulWidget {
  final idOrder;
  final bool someOrders;
  final String phoneClient;
  final String codigo;

  const RoutesModal(
      {super.key,
      required this.idOrder,
      required this.someOrders,
      required this.phoneClient,
      required this.codigo});

  @override
  State<RoutesModal> createState() => _RoutesModalState();
}

class _RoutesModalState extends State<RoutesModal> {
  TextEditingController textEditingController = TextEditingController();
  List<String> routes = [];
  List<String> transports = [];
  String? selectedValueRoute;
  String? selectedValueTransport;

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

    routesList = await Connections().getRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
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

    transportList = await Connections()
        .getTransportsByRoute(selectedValueRoute.toString().split("-")[0]);
    for (var i = 0; i < transportList.length; i++) {
      setState(() {
        transports.add(
            '${transportList[i]['attributes']['Nombre']}-${transportList[i]['id']}');
      });
    }

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
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SizedBox(
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
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: selectedValueRoute == null ||
                        selectedValueTransport == null
                    ? null
                    : () async {
                        if (widget.someOrders == false) {
                          var response = await Connections()
                              .updateOrderRouteAndTransport(
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                  widget.idOrder);
                        } else {
                          for (var i = 0; i < widget.idOrder.length; i++) {
                            var response = await Connections()
                                .updateOrderRouteAndTransport(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    widget.idOrder[i]['id']);
                          }
                        }
                        if (widget.phoneClient != "") {
                          sendMessage(widget.phoneClient, widget.codigo);
                        }
                        setState(() {});
                        Navigator.pop(context);
                      },
                child: const Text(
                  "ACEPTAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
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
