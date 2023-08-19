import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/sellers/order_entry/calendar_modal.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/sellers/order_entry/order_info.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/sellers/add_order.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

class OrderEntry extends StatefulWidget {
  const OrderEntry({super.key});

  @override
  State<OrderEntry> createState() => _OrderEntryState();
}

class _OrderEntryState extends State<OrderEntry> {
  OrderEntryControllers _controllers = OrderEntryControllers();

  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  int total = 0;
  bool isSearch = false;
  bool buttonLeft = false;
  bool buttonRigth = false;
  String pedido = '';
  String confirmado = 'TODO';
  String logistico = 'TODO';
  bool enabledBusqueda = true;
  bool isLoading = false;

  List filtersAnd = [];
  List filtersDefaultAnd = [
    {
      'operator': '\$and',
      'filter': 'IdComercial',
      'operator_attr': '\$eq',
      'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
    {
      'operator': '\$and',
      'filter': 'Estado_Interno',
      'operator_attr': '\$ne',
      'value': 'NO DESEA'
    },
    {
      'operator': '\$and',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'PEDIDO PROGRAMADO'
    },
  ];
  List filtersOrCont = [
    {'filter': 'CiudadShipping'},
    {'filter': 'NumeroOrden'},
    {'filter': 'NombreShipping'},
    {'filter': 'DireccionShipping'},
    {'filter': 'TelefonoShipping'},
    {'filter': 'ProductoP'},
    {'filter': 'ProductoExtra'},
    {'filter': 'PrecioTotal'},
  ];
  List populate = ['users', 'pedido_fecha'];

  NumberPaginatorController paginatorController = NumberPaginatorController();

  List<String> optEstadoConfirmado = ["TODO", 'PENDIENTE', 'CONFIRMADO'];
  List<String> optEstadoLogistico = ["TODO", 'PENDIENTE', 'IMPRESO', 'ENVIADO'];

  @override
  void didChangeDependencies() {
    if (Provider.of<FiltersOrdersProviders>(context).indexActive == 2) {
      setState(() {
        _controllers.searchController.text = "d/m/a,d/m/a";
        data = [];
      });
    } else {
      setState(() {
        data = [];

        _controllers.searchController.clear();
      });
    }
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      data.clear();
    });
    currentPage = 1;
    response = await Connections().getOrdersSellersFilter(
        _controllers.searchController.text,
        currentPage,
        pageSize,
        populate,
        filtersOrCont,
        filtersAnd,
        [],
        filtersDefaultAnd,
        []);

    setState(() {
      data = response[0]['data'];
      pageCount = response[0]['meta']['pagination']['pageCount'];
      total = response[0]['meta']['pagination']['total'];

      // print("metadatar"+pageCount.toString());
    });
    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "NumeroOrden": ""});
    }
    paginatorController.navigateToPage(0);

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    counterChecks = 0;
    isLoading = false;
    setState(() {});
  }

  paginateData() async {
    // print("Pagina Actual="+currentPage.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      data.clear();
    });

    // print("actual pagina valor" + currentPage.toString());

    response = await Connections().getOrdersSellersFilter(
        _controllers.searchController.text,
        currentPage,
        pageSize,
        populate,
        filtersOrCont,
        filtersAnd,
        [],
        filtersDefaultAnd,
        []);
    data = response[0]['data'];
    setState(() {
      pageCount = response[0]['meta']['pagination']['pageCount'];
      total = response[0]['meta']['pagination']['total'];
    });

    await Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String logisticoVal = logistico;
    String confirmadoVal = confirmado;

    return Scaffold(
      //
      body: Container(
        padding: EdgeInsets.all(15),
        color: Colors.grey[100],
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    optionsCheckBox = [];
                    counterChecks = 0;
                    enabledBusqueda = true;
                  });
                  await loadData();
                },
                child: Container(
                  color: Colors.transparent,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.replay_outlined,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Recargar Información",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.green),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 5),
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Busqueda",
                            controller: _controllers.searchController),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 5),
                              child: Text(
                                "Registros: ${total}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Row(
                                children: [
                                  Text(
                                    counterChecks > 0
                                        ? "Seleccionados: ${counterChecks}"
                                        : "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  counterChecks > 0
                                      ? Visibility(
                                          visible: true,
                                          child: IconButton(
                                            iconSize: 20,
                                            onPressed: () => {clearSelected()},
                                            icon: Icon(Icons.close_rounded),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50.0,
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed: counterChecks > 0
                                    ? () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Ateneción'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                        '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                    Text('' + listToDelete()),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () {
                                                    // Acción al presionar el botón de cancelar
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Aceptar'),
                                                  onPressed: () async {
                                                    for (var i = 0;
                                                        i <
                                                            optionsCheckBox
                                                                .length;
                                                        i++) {
                                                      if (optionsCheckBox[i]
                                                                  ['id']
                                                              .toString()
                                                              .isNotEmpty &&
                                                          optionsCheckBox[i]
                                                                      ['id']
                                                                  .toString() !=
                                                              '' &&
                                                          optionsCheckBox[i]
                                                                  ['check'] ==
                                                              true) {
                                                        var response = await Connections()
                                                            .updateOrderInteralStatus(
                                                                "NO DESEA",
                                                                optionsCheckBox[
                                                                        i]['id']
                                                                    .toString());
                                                        counterChecks = 0;
                                                      }
                                                    }

                                                    loadData();
                                                    setState(() {});
                                                    enabledBusqueda = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: const Text(
                                  "No Desea",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: (context),
                                      builder: (context) {
                                        return AddOrderSellers();
                                      });
                                  await loadData();
                                },
                                child: const Row(
                                  children: [Text(" Nuevo"), Icon(Icons.add)],
                                )),
                          ],
                        ),
                      ),
                      Expanded(child: numberPaginator()),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        child: _modelTextField(
                            text: "Busqueda",
                            controller: _controllers.searchController),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              "Registros: ${total}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              counterChecks > 0
                                  ? "Seleccionados: ${counterChecks}"
                                  : "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50.0,
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed: counterChecks > 0
                                    ? () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Atenecion'),
                                              content: Column(
                                                children: [
                                                  const Text(
                                                      '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                  Text('' + listToDelete()),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () {
                                                    // Acción al presionar el botón de cancelar
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Aceptar'),
                                                  onPressed: () async {
                                                    for (var i = 0;
                                                        i <
                                                            optionsCheckBox
                                                                .length;
                                                        i++) {
                                                      if (optionsCheckBox[i]
                                                                  ['id']
                                                              .toString()
                                                              .isNotEmpty &&
                                                          optionsCheckBox[i]
                                                                      ['id']
                                                                  .toString() !=
                                                              '' &&
                                                          optionsCheckBox[i]
                                                                  ['check'] ==
                                                              true) {
                                                        var response = await Connections()
                                                            .updateOrderInteralStatus(
                                                                "NO DESEA",
                                                                optionsCheckBox[
                                                                        i]['id']
                                                                    .toString());
                                                        counterChecks = 0;
                                                      }
                                                    }
                                                    setState(() {});
                                                    loadData();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: const Text(
                                  "No Desea",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: (context),
                                      builder: (context) {
                                        return AddOrderSellers();
                                      });
                                  await loadData();
                                },
                                child: const Text(
                                  "Nuevo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                      ),
                      Container(child: numberPaginator()),
                    ],
                  ),
                  context),
            ),
            const SizedBox(
              width: 10,
            ),
            const Row(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  dividerThickness: 1,
                  dataRowColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue
                          .withOpacity(0.5); // Color para fila seleccionada
                    } else if (states.contains(MaterialState.hovered)) {
                      return Colors.grey.withOpacity(
                          0.5); // Color para fila con el mouse encima
                    }
                    return Colors
                        .transparent; // Color para filas pares e impares
                  }),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  headingRowHeight: 80,
                  horizontalMargin: 12,
                  minWidth: 3500,
                  columns: [
                    const DataColumn2(
                      label: Text(''),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: const Text('Marca de Tiempo'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_T_I");
                      },
                    ),
                    const DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Código'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("CiudadShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Nombre Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NombreShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Dirección'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Cantidad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Cantidad_Total");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoP");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto Extra'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoExtra");
                      },
                    ),
                    DataColumn2(
                      label: Text('Precio Total'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
                      },
                    ),
                    const DataColumn2(
                      label: Text('Observación'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: const Text('Estado Pedido'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Estado Confirmado'),
                          DropdownButton<String>(
                            value: confirmadoVal,
                            elevation: 16,
                            onChanged: (String? value) {
                              AddFilterAndEq(value, 'Estado_Interno');
                              confirmado = value!;
                            },
                            items: optEstadoConfirmado
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Interno");
                      },
                    ),
                    DataColumn2(
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Estado Logistico'),

                          DropdownButton<String>(
                            value: logisticoVal,
                            elevation: 16,
                            onChanged: (String? value) {
                              AddFilterAndEq(value, 'Estado_Logistico');
                              logistico = value!;
                            },
                            items: optEstadoLogistico
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),

                          // DropdownButton<String>(
                          //   value: logisticoVal,
                          //   elevation: 16,
                          //   onChanged: (String? value) {
                          //     AddFilterAndEq(value, 'Estado_Logistico');
                          //   },
                          //   items: optEstadoLogistico
                          //       .map<DropdownMenuItem<String>>((String value) {
                          //     return DropdownMenuItem<String>(
                          //       value: value,
                          //       child: Text(value),
                          //     );
                          //   }).toList(),
                          // ),
                        ],
                      ),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Logistico");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca Fecha Confirmación'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Fecha_Confirmacion");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(cells: [
                            DataCell(Checkbox(
                                //  verificarIndice
                                value: verificarIndice(index),

                                // value: optionsCheckBox[index]['check'],
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      optionsCheckBox[index +
                                              ((currentPage - 1) * pageSize)]
                                          ['check'] = value;
                                      optionsCheckBox[index +
                                              ((currentPage - 1) * pageSize)]
                                          ['id'] = data[index]['id'];
                                      optionsCheckBox[index +
                                              ((currentPage - 1) *
                                                  pageSize)]['NumeroOrden'] =
                                          data[index]['attributes']
                                              ['NumeroOrden'];

                                      counterChecks += 1;
                                    } else {
                                      optionsCheckBox[index +
                                              ((currentPage - 1) * pageSize)]
                                          ['check'] = value;

                                      optionsCheckBox[index +
                                              (currentPage - 1) * pageSize]
                                          ['id'] = '';
                                      counterChecks -= 1;
                                    }
                                    counterChecks > 0
                                        ? enabledBusqueda = false
                                        : enabledBusqueda = true;
                                  });
                                })),
                            DataCell(
                                Text(
                                    '${data[index]['attributes']['Marca_T_I'].toString()}'),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '${data[index]['attributes']['TelefonoShipping'].toString()}');

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: const Icon(
                                    Icons.call,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${data[index]['attributes']['TelefonoShipping'].toString()}&text=Hola ${data[index]['attributes']['NombreShipping'].toString()}, te saludo de la tienda ${data[index]['attributes']['Tienda_Temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['attributes']['ProductoP'].toString()} y  ${data[index]['attributes']['ProductoExtra'].toString()}, por un valor total de: ${data[index]['attributes']['PrecioTotal'].toString()}. Su dirección de entrega será: ${data[index]['attributes']['DireccionShipping'].toString()} Es correcto...? Desea mas información del producto?""");
                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.message_outlined,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var response = await Connections()
                                        .updateOrderInteralStatus("CONFIRMADO",
                                            data[index]['id'].toString());
                                    setState(() {});
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return RoutesModal(
                                            idOrder:
                                                data[index]['id'].toString(),
                                            someOrders: false,
                                            phoneClient: "",
                                            codigo:
                                                "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['attributes']['NumeroOrden']}",
                                          );
                                        });
                                    loadData();
                                  },
                                  child: Icon(
                                    Icons.check,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                data[index]['attributes']['Estado_Logistico']
                                            .toString() ==
                                        "ENVIADO"
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () async {
                                          var response = await Connections()
                                              .updateOrderInteralStatus(
                                                  "NO DESEA",
                                                  data[index]['id'].toString());
                                          setState(() {});
                                          loadData();
                                        },
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          size: 20,
                                        ),
                                      )
                              ],
                            )),
                            DataCell(
                                Text(
                                    "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['attributes']['NumeroOrden']}"
                                        .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoP']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Observacion']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Status']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Interno']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Logistico']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      child: Text(data[index]['attributes']
                                              ['Fecha_Confirmacion']
                                          .toString()),
                                    ),
                                    data[index]['attributes']
                                                ['Estado_Interno'] ==
                                            "PENDIENTE"
                                        ? TextButton(
                                            onPressed: () {
                                              Calendar(data[index]['id']
                                                      .toString())
                                                  .then((value) =>
                                                      paginateData());
                                            },
                                            child: Icon(Icons.calendar_today),
                                          )
                                        : Container(),
                                  ],
                                ), onTap: () {
                              info(context, index);
                            }),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      // initialPage: 0,
      onPageChange: (index) async {
        //  print("indice="+index.toString());
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  String listToDelete() {
    String res = "";

    for (var i = 0; i < optionsCheckBox.length; i++) {
      if (optionsCheckBox[i]['check'] == true) {
        res += sharedPrefs!.getString("NameComercialSeller").toString() +
            "-" +
            optionsCheckBox[i]['NumeroOrden'] +
            '\n';
      }
    }
    return res;
  }

  AddFilterAndEq(value, filtro) {
    setState(() {
      if (value != 'TODO') {
        bool contains = false;

        for (var filter in filtersAnd) {
          if (filter['filter'] == filtro) {
            contains = true;
            break;
          }
        }
        if (contains == false) {
          filtersAnd
              .add({'filter': filtro, 'operator_attr': '\$eq', 'value': value});
        } else {
          for (var filter in filtersAnd) {
            if (filter['filter'] == filtro) {
              filter['value'] = value;
              break;
            }
          }
        }
      } else {
        for (var filter in filtersAnd) {
          if (filter['filter'] == filtro) {
            filtersAnd.remove(filter);
            break;
          }
        }
      }

      currentPage = 1;
    });
    loadData();
  }

  Future<dynamic> Calendar(String id) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(child: CalendarModal(id: id)),
                ],
              ),
            ),
          );
        });
  }

  Future<void> sumarNumero(BuildContext context, int numero) async {
    print('Sumando el número: $numero');
    await paginateData();
    // await Future.delayed(Duration(milliseconds: 1000), () {
    Navigator.pop(context);

    //});
    info(context, numero);
  }

  NextInfo(index) {
    Navigator.pop(context);

    if (index + 1 < pageSize) {
      info(context, index + 1);
    }
  }

  PreviusInfo(index) {
    Navigator.pop(context);
    if (index - 1 >= 0) {
      info(context, index - 1);
    }
  }

  Future<dynamic> info(BuildContext context, int index) {
    if (index - 1 >= 0) {
      buttonLeft = true;
    } else {
      buttonLeft = false;
    }
    if (index + 1 < data.length) {
      buttonRigth = true;
    } else {
      buttonRigth = false;
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: responsive(
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ),
                      Expanded(
                          child: OrderInfo(
                        id: data[index]['id'].toString(),
                        index: index,
                        sumarNumero: sumarNumero,
                        codigo:
                            "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['attributes']['NumeroOrden']}",
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: buttonLeft,
                            child: IconButton(
                              iconSize: 60,
                              onPressed: () => {PreviusInfo(index)},
                              icon: Icon(Icons.arrow_circle_left),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                          ),
                          Visibility(
                            visible: buttonRigth,
                            child: IconButton(
                              iconSize: 60,
                              onPressed: () => {NextInfo(index)},
                              icon: Icon(Icons.arrow_circle_right),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx < 0) {
                      NextInfo(index);
                    } else if (details.delta.dx > 0) {
                      PreviusInfo(index);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close),
                          ),
                        ),
                        Expanded(
                            child: OrderInfo(
                          id: data[index]['id'].toString(),
                          index: index,
                          sumarNumero: sumarNumero,
                          codigo:
                              "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['attributes']['NumeroOrden']}",
                        )),
                      ],
                    ),
                  ),
                ),
                context),
          );
        });
  }

  bool verificarIndice(int index) {
    try {
      dynamic elemento =
          optionsCheckBox.elementAt(index + ((currentPage - 1) * pageSize));
      // print("elemento="+elemento.toString());
      if (elemento['id'] != data[index]['id']) {
        return false;
      } else {
        return true;
      }
    } catch (error) {
      return false;
    }
  }

  clearSelected() {
    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "NumeroOrden": ""});
    }
    setState(() {
      counterChecks = 0;
      enabledBusqueda = true;
    });
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        enabled: enabledBusqueda,
        controller: controller,
        onSubmitted: (value) async {
          setState(() {
            _controllers.searchController.text = value;
          });
          loadData();
          getLoadingModal(context, false);

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                      filtersAnd = [];
                      confirmado = "TODO";
                      logistico = "TODO";
                    });

                    setState(() {
                      loadData();
                    });
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return 1;
        } else if (dateB == null) {
          return -1;
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return -1;
        } else if (dateB == null) {
          return 1;
        } else {
          return dateA.compareTo(dateB);
        }
      });
    }
  }

  sortFunc(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes'][name]
          .toString()
          .compareTo(a['attributes'][name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes'][name]
          .toString()
          .compareTo(b['attributes'][name].toString()));
    }
  }
}
