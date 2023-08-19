import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';

class SubRoutesModal extends StatefulWidget {
  final idOrder;
  final bool someOrders;

  const SubRoutesModal(
      {super.key, required this.idOrder, required this.someOrders});

  @override
  State<SubRoutesModal> createState() => _SubRoutesModalState();
}

class _SubRoutesModalState extends State<SubRoutesModal> {
  TextEditingController textEditingController = TextEditingController();
  List<String> routes = [];
  List<String> operator = [];
  String? selectedValueRoute;
  String? selectedValueTransport;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    // var routesList = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var routesList = await Connections().getSubRoutesSelect();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        if (!routes.contains(
            "${routesList[i]['attributes']['sub_ruta']['data']['attributes']['Titulo']}-${routesList[i]['attributes']['sub_ruta']['data']['id']}")) {
          routes.add(
              "${routesList[i]['attributes']['sub_ruta']['data']['attributes']['Titulo']}-${routesList[i]['attributes']['sub_ruta']['data']['id']}");
        }
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getOperators() async {
    var operatorsList = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    operatorsList = await Connections()
        .getOperatorBySubRoute(selectedValueRoute.toString().split("-")[0]);
    for (var i = 0; i < operatorsList.length; i++) {
      setState(() {
        if (operatorsList[i]['attributes']['user']['data'] != null) {
          operator.add(
              '${operatorsList[i]['attributes']['user']['data']['attributes']['username']}-${operatorsList[i]['id']}');
        }
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
                  'Ruta',
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
                    operator.clear();
                    selectedValueTransport = null;
                  });
                  await getOperators();
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
                              .updateOrderSubRouteAndOperator(
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                  widget.idOrder);
                        } else {
                          for (var i = 0; i < widget.idOrder.length; i++) {
                            var response = await Connections()
                                .updateOrderSubRouteAndOperator(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    widget.idOrder[i]['id']);
                          }
                        }
                        setState(() {});
                        Navigator.pop(context);
                      },
                child: Text(
                  "ACEPTAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }
}
