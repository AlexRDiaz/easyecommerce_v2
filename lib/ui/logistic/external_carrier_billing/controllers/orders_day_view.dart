import 'dart:math';

import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/payment_vouchers_transport_new.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class OrdersDayViewExtenalCarrier extends StatefulWidget {
  final String chozenDate;
  final double dailyProceeds;
  final double dailyShippingCost;
  final double dailyTotal;
  final int idExternalCarrier;

  const OrdersDayViewExtenalCarrier(
      {super.key,
      required this.chozenDate,
      required this.dailyProceeds,
      required this.dailyShippingCost,
      required this.dailyTotal,
      required this.idExternalCarrier});

  @override
  State<OrdersDayViewExtenalCarrier> createState() =>
      _OrdersDayViewExtenalCarrierState();
}

class _OrdersDayViewExtenalCarrierState
    extends State<OrdersDayViewExtenalCarrier> {
  TextEditingController searchController = TextEditingController();
  List ordersDay = [];

  int currentPage = 1;
  int pageSize = 500;
  int pageCount = 0;
  bool isLoading = false;
  List populate = [
    "pedidos_shopify.carrierExternal",
    "transportadora",
    "operadore.up_users",
    "transportadora_externa"
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersNot = [];
  List arrayFiltersOr = [];

  String sortFieldDefaultValue = "id:DESC";

  double dailyProceedsC = 0;
  double dailyShippingCostC = 0;
  double dailyTotalC = 0;
  List<String> listOperators = ['TODO'];
  TextEditingController operadorController =
      TextEditingController(text: "TODO");
  TextEditingController statusController = TextEditingController(text: "TODO");
  List<String> listStatus = [
    'TODO',
    'ENTREGADO',
    'NO ENTREGADO',
  ];
  bool changevalue = false;
  int total = 0;
  int totalC = 0;

  double totalOperatorCost = 0;

  @override
  void initState() {
    ordersDay = [];
    loadData();
    super.initState();
  }

  loadData() async {
    currentPage = 1;
    setState(() {
      isLoading = true;
    });

    try {
      // if (listOperators.length == 1) {
      // var responsetransportadoras = await Connections()
      //     .getOperatoresbyTransport(
      //         sharedPrefs!.getString("idTransportadora").toString());
      // List<dynamic> transportadorasList =
      //     responsetransportadoras['operadores'];
      // for (var transportadora in transportadorasList) {
      //   listOperators.add(transportadora);
      // }
      // }

      arrayFiltersAnd.add(
          {"/pedidos_shopify.carrier_external_id": widget.idExternalCarrier});

      // var response = await Connections().getOrdersPerDayByCarrier(
      //     sharedPrefs!.getString("idTransportadora"),
      // widget.chozenDate,
      //     populate,
      //     pageSize,
      //     currentPage,
      //     arrayFiltersAnd,
      //     sortFieldDefaultValue,
      //     searchController.text);

      var response = await Connections().generalData(
          pageSize,
          pageCount,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersOr,
          [],
          [],
          "",
          "TransaccionPedidoTransportadora",
          // "",
          // widget.chozenDate,
          // widget.chozenDate,
          "",
          "",
          "",
          "");

      if (response['data'] == null) {
        setState(() {
          ordersDay = [];
          isLoading = false;
          totalOperatorCost = 0;
        });
      } else {
        setState(() {
          print(response["data"]);
          ordersDay = response["data"];
          pageCount = response['last_page'];
          total = response['total'];
          // paginatorController.navigateToPage(0);
          // ! se comenta
          // dailyProceedsC =
          //     double.parse((response['total_proceeds']).toStringAsFixed(2));
          // dailyShippingCostC =
          //     double.parse((response['shipping_total']).toStringAsFixed(2));
          // dailyTotalC =
          //     double.parse((response['total_day']).toStringAsFixed(2));

          // //  ****
          // String costOperador = ordersDay[0]["operadore"] == null
          //     ? ""
          //     : ordersDay[0]['operadore']['costo_operador'].toString();
          // // print('${ordersDay[0]['operadore']['up_users'][0]['username']}');
          // double cost = double.parse(costOperador);
          // double costPerOperator = total * cost;
          // totalOperatorCost = costPerOperator;
        });
        isLoading = false;
      }
    } catch (e) {
      print(e);
    }
  }

  void resetFilters() {
    // getOldValue(true);

    operadorController.text = 'TODO';
    statusController.text = "TODO";

    arrayFiltersAnd = [];
    // _controllers.searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                // color: Colors.grey[300],
                color: Colors.white,
                child: Center(
                  child: Container(
                    // margin: const EdgeInsets.all(6.0),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.arrow_circle_left,
                                    size: 35,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () async {
                                    resetFilters();
                                    loadData();
                                  },
                                  icon: Icon(
                                    Icons.autorenew_rounded,
                                    size: 35,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Fecha:",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF031749)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.chozenDate,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF031749)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "DETALLES DE GUÍAS",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800]),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Valores Recibidos: \$${dailyProceedsC}"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Costo Entrega: \$${dailyShippingCostC}"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Total: \$${dailyTotalC}"),
                          ],
                        ),
                        const Divider(),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Registros: "),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(total.toString()),
                            const SizedBox(
                              width: 20,
                            ),
                            Visibility(
                                visible: operadorController.text != "TODO" &&
                                    totalOperatorCost != 0,
                                child: const Text("Costo Operador: ")),
                            const SizedBox(
                              width: 10,
                            ),
                            Visibility(
                                visible: operadorController.text != "TODO" &&
                                    totalOperatorCost != 0,
                                child:
                                    Text('\$ ${totalOperatorCost.toString()}')),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        responsive(
                            webMainContainer(width, heigth, context),
                            mobileMainContainer(width, heigth, context),
                            context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              // _searchBar(width, heigth, context),
              SizedBox(height: 10),
              _dataTableOrders(heigth),
            ],
          ),
        ),
      ],
    );
  }

  Container _dataTableOrders(height) {
    return Container(
      height: height * 0.60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: ordersDay.length > 0
          ? DataTableModelPrincipal(
              columnWidth: 200,
              columns: getColumns(),
              rows: buildDataRows(ordersDay))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  mobileMainContainer(double width, double heigth, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // _searchBar(width, heigth, context),
          _dataTableOrdersMobile(heigth),
        ],
      ),
    );
  }

  _dataTableOrdersMobile(height) {
    return ordersDay.length > 0
        ? Container(
            height: height * 0.70,
            child: DataTableModelPrincipal(
                columnWidth: 400,
                columns: getColumns(),
                rows: buildDataRows(ordersDay)),
          )
        : const Center(
            child: Text("Sin datos"),
          );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text("Fecha Envio"),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Fecha Entrega'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Nombre Cliente'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Teléfono Cliente'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Producto'),
        size: ColumnSize.L,
      ),
      const DataColumn2(
        label: Text('Producto Extra'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Precio Total'),
        size: ColumnSize.S,
      ),
      // DataColumn2(
      //   label: Text('Status'),
      //   size: ColumnSize.M,
      // ),
      DataColumn2(
        label: SelectFilterStatus(
            'Estado de entrega', 'status', statusController, listStatus),
        size: ColumnSize.L,
        // onSort: (columnIndex, ascending) {
        //   sortFunc("status", changevalue);
        // },
      ),
      // DataColumn2(
      //   label: Text('Operador'),
      //   size: ColumnSize.L,
      // ),
      DataColumn2(
        label: SelectFilter('Operador', 'operadore.up_users.operadore_id',
            operadorController, listOperators),
        size: ColumnSize.L,
        // onSort: (columnIndex, ascending) {},
      ),
      // const DataColumn2(
      //   label: Text('Costo Operador'),
      //   size: ColumnSize.S,
      // ),
      const DataColumn2(
        label: Text('Estado Devolución'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Est. Pago Operador'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Est. Pago Logistica'),
        size: ColumnSize.M,
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    ordersDay = data;

    List<DataRow> rows = [];
    for (int index = 0; index < ordersDay.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            InkWell(
              child: Text(
                ordersDay[index]["pedidos_shopify"]['marca_tiempo_envio'] ==
                        null
                    ? ""
                    : ordersDay[index]["pedidos_shopify"]['marca_tiempo_envio']
                        .toString(),
              ),
            ),
          ),
          DataCell(
            Text(ordersDay[index]['fecha_entrega'].toString()),
          ),
          DataCell(
            // Text(
            //     '${ordersDay[index]["pedidos_shopify"]["name_comercial"] != null && ordersDay[index]["pedidos_shopify"]["name_comercial"].isNotEmpty ? ordersDay[index]["pedidos_shopify"]["name_comercial"] : "NaN"}-${ordersDay[index]["pedidos_shopify"]['numero_orden'].toString()}'),
            InkWell(
              child: Text(
                  //  '${ordersDay[index]["pedidos_shopify"]['users'] != null && ordersDay[index]["pedidos_shopify"]['users'].isNotEmpty ? ordersDay[index]["pedidos_shopify"]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${ordersDay[index]["pedidos_shopify"]['numero_orden'].toString()}',
                  '${ordersDay[index]["pedidos_shopify"]["name_comercial"] != null && ordersDay[index]["pedidos_shopify"]["name_comercial"].isNotEmpty ? ordersDay[index]["pedidos_shopify"]["name_comercial"] : "NaN"}-${ordersDay[index]["pedidos_shopify"]['numero_orden'].toString()}',
                  style: TextStyle(
                      color: setColor(ordersDay[index]["pedidos_shopify"]
                              ['status']
                          .toString()))),
            ),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['nombre_shipping']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['ciudad_shipping']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['direccion_shipping']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['telefono_shipping']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['cantidad_total']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['producto_p'].toString()),
          ),
          DataCell(
            Text(
                ordersDay[index]["pedidos_shopify"]['producto_extra'] == null ||
                        ordersDay[index]["pedidos_shopify"]['producto_extra']
                                .toString() ==
                            "null"
                    ? ""
                    : ordersDay[index]["pedidos_shopify"]['producto_extra']
                        .toString()),
          ),
          DataCell(
            Text(
                "\$ ${ordersDay[index]["pedidos_shopify"]['precio_total'].toString()}"),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['status'].toString()),
          ),
          DataCell(
            Text(ordersDay[index]["operadore"] == null
                ? ""
                : ordersDay[index]['operadore']['up_users'][0]['username']
                    .toString()),
          ),
          // DataCell(
          //   Text(ordersDay[index]["operadore"] == null
          //       ? ""
          //       : ordersDay[index]['operadore']['costo_operador'].toString()),
          // ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['estado_devolucion']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['estado_pagado']
                .toString()),
          ),
          DataCell(
            Text(ordersDay[index]["pedidos_shopify"]['estado_pago_logistica']
                .toString()),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.black),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";

                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                    // reemplazarValor(value, newValue!);
                    //  print(value);
                  }

                  // paginateData();
                  loadData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value.split("-")[0], style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Column SelectFilterStatus(String title, filter,
      TextEditingController controller, List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
            ),
            height: 0,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    if (filter is String) {
                      arrayFiltersAnd.add({filter: newValue});
                    } else {
                      reemplazarValor(filter, newValue!);
                      arrayFiltersAnd.add(filter);
                    }
                    print(filter);
                  } else {}

                  // paginateData();
                  loadData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  setColor(status) {
    final color = status == "ENTREGADO" ? Colors.green : Colors.red;
    return color;
  }

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: responsive(
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.5,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),

              // IconButton(
              //     onPressed: () => loadData(),
              //     icon: Icon(Icons.replay_outlined)),
              // Spacer(),
              // Container(width: width * 0.3, child: numberPaginator()),

              //   Expanded(child: numberPaginator()),
            ],
          ),
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),

              // IconButton(
              //     onPressed: () => loadData(),
              //     icon: Icon(Icons.replay_outlined)),
              // Expanded(child: numberPaginator()),

              //   Expanded(child: numberPaginator()),
            ],
          ),
          context),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // loadData();
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
