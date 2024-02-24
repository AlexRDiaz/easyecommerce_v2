import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';

class SubRoutesModalNew extends StatefulWidget {
  final idOrder;
  final bool someOrders;

  const SubRoutesModalNew(
      {super.key, required this.idOrder, required this.someOrders});

  @override
  State<SubRoutesModalNew> createState() => _SubRoutesModalNewState();
}

class _SubRoutesModalNewState extends State<SubRoutesModalNew> {
  TextEditingController textEditingController = TextEditingController();
  // List<String> routes = [];
  // List<String> operator = [];
  // String? selectedValueRoute;
  // String? selectedValueTransport;
  List<String> subRoutesToSelect = [];
  List<String> operatorsToSelect = [];
  String? selectedValueSubRoute;
  String? selectedOperator;

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

    // var routesList = await Connections().getSubRoutesSelect();
    // for (var i = 0; i < routesList.length; i++) {
    //   setState(() {
    //     if (!routes.contains(
    //         "${routesList[i]['attributes']['sub_ruta']['data']['attributes']['Titulo']}-${routesList[i]['attributes']['sub_ruta']['data']['id']}")) {
    //       routes.add(
    //           "${routesList[i]['attributes']['sub_ruta']['data']['attributes']['Titulo']}-${routesList[i]['attributes']['sub_ruta']['data']['id']}");
    //     }
    //   });
    // }
    var routesList = [];
    setState(() {
      subRoutesToSelect = [];
    });
    routesList = await Connections().getSubroutesByTransportadoraId(
        sharedPrefs!.getString("idTransportadora").toString());
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        subRoutesToSelect.add('${routesList[i]}');
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getOperators() async {
    var operatorsList = [];

    setState(() {
      operatorsToSelect = [];
    });
    operatorsList = await Connections().getOperatorsbySubRoutes(
        selectedValueSubRoute.toString().split("-")[1],
        sharedPrefs!.getString("idTransportadora").toString());
    for (var i = 0; i < operatorsList.length; i++) {
      if (operatorsList[i] != null) {
        operatorsToSelect.add('${operatorsList[i]}');
      }
    }
    setState(() {});
    // var operatorsList = [];
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });

    // operatorsList = await Connections()
    //     .getOperatorBySubRoute(selectedValueRoute.toString().split("-")[1]);
    // for (var i = 0; i < operatorsList.length; i++) {
    //   setState(() {
    //     if (operatorsList[i]['attributes']['user']['data'] != null) {
    //       operator.add(
    //           '${operatorsList[i]['attributes']['user']['data']['attributes']['username']}-${operatorsList[i]['id']}');
    //     }
    //   });
    // }

    // Future.delayed(Duration(milliseconds: 500), () {
    //   Navigator.pop(context);
    // });
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: Container(
        width: width * 0.3,
        // height: heigth * 0.5,
        height: heigth,
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
                items: subRoutesToSelect
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
                    // print(selectedValueSubRoute);

                    operatorsToSelect.clear();
                    selectedOperator = null;
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
            const SizedBox(height: 10),
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
                items: operatorsToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedOperator,
                onChanged: selectedValueSubRoute == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedOperator = value as String;
                          // print(selectedOperator);
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
              onPressed: selectedValueSubRoute == null ||
                      selectedOperator == null
                  ? null
                  : () async {
                      if (widget.someOrders == false) {
                        // print("one");
                        // print(
                        //     "${selectedValueSubRoute.toString().split("-")[1]}");
                        // print("${selectedOperator.toString().split("-")[1]}");
                        // print("${widget.idOrder}");
                        var response = await Connections()
                            .updateOrderSubRouteAndOperatorLaravel(
                                selectedValueSubRoute.toString().split("-")[1],
                                selectedOperator.toString().split("-")[1],
                                widget.idOrder);
                        // var response = await Connections()
                        //     .updateOrderSubRouteAndOperator(
                        //         selectedValueSubRoute.toString().split("-")[1],
                        //         selectedValueOperator.toString().split("-")[1],
                        //         widget.idOrder);
                        if (response != 0) {
                          // ignore: use_build_context_synchronously
                          showSuccessModal(
                              context,
                              "Error, Ocurrio un error en la solicitud.",
                              Icons8.warning_1);
                        }
                      } else {
                        // print("multi");

                        for (var i = 0; i < widget.idOrder.length; i++) {
                          // print("${widget.idOrder[i]['id']}");

                          var response = await Connections()
                              .updateOrderSubRouteAndOperatorLaravel(
                                  selectedValueSubRoute
                                      .toString()
                                      .split("-")[1],
                                  selectedOperator.toString().split("-")[1],
                                  widget.idOrder[i]['id']);

                          // var response = await Connections()
                          //     .updateOrderSubRouteAndOperator(
                          //         selectedValueSubRoute
                          //             .toString()
                          //             .split("-")[1],
                          //         selectedValueSubRoute
                          //             .toString()
                          //             .split("-")[1],
                          //         widget.idOrder[i]['id']);
                        }
                      }
                      setState(() {});
                      Navigator.pop(context);
                    },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color(0xFF031749),
                ),
              ),
              child: const Text(
                "ACEPTAR",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
