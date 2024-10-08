import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';

import '../../widgets/sellers/add_order.dart';
import 'controllers/controllers.dart';

class ReturnsInWarehouse extends StatefulWidget {
  const ReturnsInWarehouse({super.key});

  @override
  State<ReturnsInWarehouse> createState() => _ReturnsInWarehouseState();
}

class _ReturnsInWarehouseState extends State<ReturnsInWarehouse> {
  ReturnsInWarehouseControllers _controllers = ReturnsInWarehouseControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  List dataTemporal = [];
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  int total = 0;
  String pedido = '';
  bool enabledBusqueda = true;
  bool isLoading = false;
  NumberPaginatorController paginatorController = NumberPaginatorController();
  // List filtersDefaultOr = [
  //   {
  //     'operator': '\$or',
  //     'filter': 'Status',
  //     'operator_attr': '\$eq',
  //     'value': 'NOVEDAD'
  //   },
  //   {
  //     'operator': '\$or',
  //     'filter': 'Status',
  //     'operator_attr': '\$eq',
  //     'value': 'NO ENTREGADO'
  //   },
  // ];

  // List filtersDefaultAnd = [
  //   {
  //     'operator': '\$and',
  //     'filter': 'Estado_Devolucion',
  //     'operator_attr': '\$eq',
  //     'value': 'EN BODEGA'
  //   },
  // ];
  // List populate = [
  //   'users',
  //   'pedido_fecha',
  //   'ruta',
  //   'transportadora',
  //   'users.vendedores',
  //   'operadore',
  //   'operadore.user'
  // ];
  // List filtersAnd = [];

  // List filtersOrCont = [
  //   {'filter': 'Marca_T_I'},
  //   {'filter': 'CiudadShipping'},
  //   {'filter': 'NombreShipping'},
  //   {'filter': 'DireccionShipping'},
  //   {'filter': 'TelefonoShipping'},
  //   {'filter': 'NumeroOrden'},
  //   {'filter': 'Cantidad_Total'},
  //   {'filter': 'ProductoP'},
  //   {'filter': 'ProductoExtra'},
  //   {'filter': 'PrecioTotal'},
  //   {'filter': 'Observacion'},
  //   {'filter': 'Status'},
  //   {'filter': 'Estado_Interno'},
  //   {'filter': 'Estado_Logistico'},
  // ];

  //  *

  bool isFirst = true;

  List filtersOrCont = [
    'name_comercial',
    'numero_orden',
    'marca_tiempo_envio',
    'direccion_shipping',
    'cantidad_total',
    'precio_total',
    'producto_p',
    'ciudad_shipping',
    'status',
    'comentario',
    'fecha_entrega',
    'nombre_shipping',
    'telefono_shipping',
    'estado_devolucion',
    'marca_t_d',
    'marca_t_d_t',
    'marca_t_d_l'
  ];

  List arrayFiltersDefaultOr = [
    {
      "status": ["NOVEDAD", "NO ENTREGADO"]
    },
    {
      "estado_devolucion": ["EN BODEGA", "EN BODEGA PROVEEDOR"]
    }
    // {"status": "NOVEDAD"},
    // {"status": "NO ENTREGADO"},
    // {"estado_devolucion": "EN BODEGA"},
    // {"estado_devolucion": "EN BODEGA PROVEEDOR"},
  ];

  var arrayfiltersDefaultAnd = [
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "ENVIADO"},
    // {"estado_devolucion": "EN BODEGA"},
    //estado_interno:confirmado y estado_logistico: enviado
  ];

  List arrayFiltersAnd = [];
  List arrayFiltersNotEq = [];
  var sortFieldDefaultValue = "id:DESC";
  bool changevalue = false;

  var idUser = sharedPrefs!.getString("id");
  TextEditingController statusController = TextEditingController(text: "TODO");
  List<String> listStatus = [
    'TODO',
    // 'PEDIDO PROGRAMADO',
    'NOVEDAD',
    // 'NOVEDAD RESUELTA',
    // 'ENTREGADO',
    'NO ENTREGADO',
    // 'REAGENDADO',
    // 'EN OFICINA',
    // 'EN RUTA'
  ];
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");
  List<String> listEstadoDevolucion = [
    'TODO',
    // 'PENDIENTE',
    // 'ENTREGADO EN OFICINA',
    // 'DEVOLUCION EN RUTA',
    'EN BODEGA',
    'EN BODEGA PROVEEDOR',
  ];

  List<String> listTransportadoras = ['TODO'];
  List<String> listOperators = ['TODO'];
  TextEditingController transportadorasController =
      TextEditingController(text: "TODO");
  TextEditingController operadorController =
      TextEditingController(text: "TODO");

  List populate = [
    "operadore.up_users",
    "transportadora",
    "users.vendedores",
    "novedades",
    "pedidoFecha",
    "ruta",
    "subRuta",
    "receivedBy",
    "pedidoCarrier"
  ];

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  void resetFilters() {
    getOldValue(true);

    transportadorasController.text = 'TODO';
    operadorController.text = 'TODO';
    statusController.text = "TODO";
    estadoDevolucionController.text = "TODO";
    arrayFiltersAnd = [];
    _controllers.searchController.text = "";
  }

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
/*
  loadData2() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    response = await Connections()
        .getOrdersForReturnsLogistic(_controllers.searchController.text);
    data = [];
    dataTemporal = [];

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }
  */

  loadData() async {
    isLoading = true;
    currentPage = 1;

    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      data.clear();
    });

    var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
      populate,
      filtersOrCont,
      arrayFiltersDefaultOr,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      pageSize,
      _controllers.searchController.text,
      [],
      sortFieldDefaultValue.toString(),
      [],
      [],
    );
    data = responseLaravel['data'];

    // response = await Connections().getOrdersSellersFilter(
    //     _controllers.searchController.text,
    //     currentPage,
    //     pageSize,
    //     populate,
    //     filtersOrCont,
    //     filtersAnd,
    //     filtersDefaultOr,
    //     filtersDefaultAnd, []);

    // data = response[0]['data'];

    setState(() {
      pageCount = responseLaravel['last_page'];
      if (sortFieldDefaultValue.toString() == "id:DESC") {
        total = responseLaravel['total'];
      }
      // pageCount = response[0]['meta']['pagination']['pageCount'];
      // total = response[0]['meta']['pagination']['total'];

      // print("metadatar"+pageCount.toString());
    });

    if (listTransportadoras.length == 1) {
      var responseTransportadoras = await Connections().getTransportadoras();
      List<dynamic> transportadorasList =
          responseTransportadoras['transportadoras'];
      for (var transportadora in transportadorasList) {
        listTransportadoras.add(transportadora);
      }
    }

    if (listOperators.length == 1) {
      var responseOpertators = await Connections().getOperatorsAvailables();
      List<dynamic> operadoresList = responseOpertators;
      for (var operador in operadoresList) {
        listOperators.add(operador);
      }
    }

    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "NumeroOrden": ""});
    }
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    paginatorController.navigateToPage(0);
    counterChecks = 0;
    setState(() {});
    isLoading = false;
  }

  paginateData() async {
    // print("Pagina Actual="+currentPage.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      isLoading = true;
      data.clear();
    });

    // print("actual pagina valor" + currentPage.toString());

    var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
      populate,
      filtersOrCont,
      arrayFiltersDefaultOr,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      pageSize,
      _controllers.searchController.text,
      [],
      sortFieldDefaultValue.toString(),
      [],
      [],
    );
    data = responseLaravel['data'];

    // response = await Connections().getOrdersSellersFilter(
    //     _controllers.searchController.text,
    //     currentPage,
    //     pageSize,
    //     populate,
    //     filtersOrCont,
    //     filtersAnd,
    //     [],
    //     filtersDefaultAnd,
    //     []);
    // data = response[0]['data'];

    setState(() {
      pageCount = responseLaravel['last_page'];
      total = responseLaravel['total'];
      // pageCount = response[0]['meta']['pagination']['pageCount'];
      // total = response[0]['meta']['pagination']['total'];
    });

    await Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {
      isFirst = false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        color: Colors.grey[100],
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 150,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              resetFilters();
                              paginatorController.navigateToPage(0);
                            });
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete_forever_sharp),
                              SizedBox(width: 5),
                              Text('Limpiar Filtros'),
                            ],
                          ),
                        ),
                      )),
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
              ],
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
                      /*
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
                                
                          ],
                        ),
                      ),
                      */
                      Expanded(
                          child: NumberPaginator(
                        config: NumberPaginatorUIConfig(
                          buttonShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Customize the button shape
                          ),
                        ),
                        controller: paginatorController,
                        numberPages: pageCount > 0 ? pageCount : 1,
                        initialPage: 0,
                        onPageChange: (index) async {
                          //  print("indice="+index.toString());

                          setState(() {
                            currentPage = index + 1;
                          });
                          if (!isLoading) {
                            await paginateData();
                          }
                        },
                      )),
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
                      /*
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
                      */
                      Container(
                          child: NumberPaginator(
                        config: NumberPaginatorUIConfig(
                          buttonShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Customize the button shape
                          ),
                        ),
                        numberPages: pageCount > 0 ? pageCount : 1,
                        onPageChange: (index) async {
                          //  print("indice="+index.toString());
                          setState(() {
                            currentPage = index + 1;
                          });

                          await paginateData();
                        },
                      )),
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
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                  ),
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
                    // const DataColumn2(
                    //   label: Text(''),
                    //   size: ColumnSize.S,
                    // ),
                    // DataColumn2(label: Text('Transportadora')),
                    DataColumn2(
                      label: SelectFilter(
                          'Transportadora',
                          'transportadora.transportadora_id',
                          transportadorasController,
                          listTransportadoras),
                      size: ColumnSize.L,
                    ),
                    // DataColumn2(label: Text('Operador')),
                    DataColumn2(
                      label: SelectFilter(
                          'Operador',
                          'operadore.up_users.user_id',
                          operadorController,
                          listOperators),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: const Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ciudad_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Código'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("numero_orden", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: SelectFilterStatus('Estado de entrega', 'status',
                          statusController, listStatus),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("status", changevalue);
                      },
                    ),
                    // DataColumn2(
                    //   label: const Text('Estado Devolución'),
                    //   size: ColumnSize.M,
                    //   onSort: (columnIndex, ascending) {
                    //     sortFunc("estado_devolucion", changevalue);
                    //   },
                    // ),
                    DataColumn2(
                      label: SelectFilterStatus(
                          'Estado Devolución',
                          'estado_devolucion',
                          estadoDevolucionController,
                          listEstadoDevolucion),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("estado_devolucion", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("fecha_entrega", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marca T. Dev. O'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("marca_t_d", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marca T. Dev. T'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("marca_t_d_t", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marca T. Dev. L'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("marca_t_d_l", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Recibido por'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("received_by");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marca Tiempo Envio'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("marca_tiempo_envio", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Nombre Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("nombre_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Dirección'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("direccion_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Teléfono'),
                      numeric: true,
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("telefono_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Center(child: Text('Cantidad')),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("cantidad_total", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Producto'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("producto_p", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Producto Extra'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("producto_extra", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Comentario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("comentario", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Precio Total'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("precio_total", changevalue);
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(data.length, (index) {
                    Color rowColor = Colors.black;

                    return DataRow(cells: [
                      /*
                      DataCell(ElevatedButton(
                          onPressed:
                              // data[index]['attributes']
                              //                 ['Estado_Devolucion']
                              //             .toString() ==
                              //         "EN BODEGA"
                              data[index]['estado_devolucion'].toString() ==
                                      "EN BODEGA"
                                  ? null
                                  : () {
                                      AwesomeDialog(
                                        width: 500,
                                        context: context,
                                        dialogType: DialogType.info,
                                        animType: AnimType.rightSlide,
                                        title:
                                            '¿Estás seguro de marcar el pedido en BODEGA?',
                                        desc: '',
                                        btnOkText: "Confirmar",
                                        btnCancelText: "Cancelar",
                                        btnOkColor: Colors.blueAccent,
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () async {
                                          getLoadingModal(context, false);
                                          // await Connections()
                                          //     .updateOrderReturnLogistic(
                                          //         data[index]['id']);

                                          //new
                                          await Connections()
                                              .updateOrderWithTime(
                                                  data[index]['id'].toString(),
                                                  "estado_devolucion:EN BODEGA",
                                                  idUser,
                                                  "",
                                                  "");

                                          await loadData();
                                          Navigator.pop(context);
                                        },
                                      ).show();
                                    },
                          child: Text(
                            "Devolver",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10),
                          ))),
                      */
                      DataCell(
                        Text(data[index]['transportadora'] != null &&
                                data[index]['transportadora'].isNotEmpty
                            ? data[index]['transportadora'][0]['nombre']
                                .toString()
                            : data[index]['pedido_carrier'].isNotEmpty
                                ? data[index]['pedido_carrier'][0]['carrier']
                                        ['name']
                                    .toString()
                                : ""),
                      ),
                      DataCell(
                          Text(
                            data[index]['operadore'] != null &&
                                    data[index]['operadore'].toString() != "[]"
                                ? data[index]['operadore'][0]['up_users'][0]
                                        ['username']
                                    .toString()
                                : "",
                          ),
                          onTap: () {}),
                      DataCell(
                        Text(
                          data[index]['ciudad_shipping'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                          Text(
                            '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}',
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                        Text(
                          data[index]['status'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['estado_devolucion'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['fecha_entrega'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['marca_t_d'] == null
                              ? ""
                              : data[index]['marca_t_d'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['marca_t_d_t'] == null
                              ? ""
                              : data[index]['marca_t_d_t'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['marca_t_d_l'] == null
                              ? ""
                              : data[index]['marca_t_d_l'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['received_by'] != null &&
                                  data[index]['received_by'].isNotEmpty
                              ? "${data[index]['received_by']['username'].toString()}-${data[index]['received_by']['id'].toString()}"
                              : '',
                        ),
                      ),
                      DataCell(
                        Text(
                          data[index]['marca_tiempo_envio'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['nombre_shipping'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['direccion_shipping'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['telefono_shipping'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            data[index]['cantidad_total'].toString(),
                          ),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['producto_p'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['producto_extra'] == null ||
                                  data[index]['producto_extra'].toString() ==
                                      "null"
                              ? ""
                              : data[index]['producto_extra'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Text(
                          data[index]['comentario'] == null ||
                                  data[index]['comentario'] == "null"
                              ? ""
                              : data[index]['comentario'].toString(),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            '\$${data[index]['precio_total'].toString()}',
                          ),
                        ),
                        onTap: () {
                          getInfoModal(index);
                        },
                      ),
                    ]);
                  })),
            ),
            /*
            Expanded(
              child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                  ),
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
                    DataColumn2(
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
                      label: Text('Marca de Tiempo'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Detalle'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Cantidad'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Cantidad_Total");
                      },
                    ),
                    DataColumn2(
                      label: Text('Precio Total'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoP");
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
                      label: Text('Status'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: Text('Comentario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Comentario");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Fecha_Entrega");
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
                      label: Text('Teléfono'),
                      numeric: true,
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca. O'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca TR'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D_T");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca TL'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D_L");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(data.length, (index) {
                    Color rowColor = Colors.black;

                    return DataRow(cells: [
                      DataCell(ElevatedButton(
                          onPressed: data[index]['attributes']
                                          ['Estado_Devolucion']
                                      .toString() ==
                                  "EN BODEGA"
                              ? null
                              : () {
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.rightSlide,
                                    title:
                                        '¿Estás seguro de marcar el pedido en BODEGA?',
                                    desc: '',
                                    btnOkText: "Confirmar",
                                    btnCancelText: "Cancelar",
                                    btnOkColor: Colors.blueAccent,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () async {
                                      getLoadingModal(context, false);
                                      await Connections()
                                          .updateOrderReturnLogistic(
                                              data[index]['id']);
                                      await loadData();
                                      Navigator.pop(context);
                                    },
                                  ).show();
                                },
                          child: Text(
                            "Devolver",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10),
                          ))),
                      DataCell(
                          Text(
                            "${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}",
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_Tiempo_Envio']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_Tiempo_Envio']
                                .toString()
                                .split(" ")[0]
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['DireccionShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Cantidad_Total']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            '\$${data[index]['attributes']['PrecioTotal'].toString()}',
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            '${data[index]['attributes']['ProductoP'].toString()}',
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                              '${data[index]['attributes']['CiudadShipping'].toString()}'),
                          onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Status'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Comentario'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Fecha_Entrega']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['NombreShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['TelefonoShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Estado_Devolucion']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D_T'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D_L'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                    ]);
                  })),
            ),
            */
          ],
        ),
      ),
    );
  }

  getInfoModal(index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: 500,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close)),
                      )
                    ],
                  ),
                  _model(
                      "Código: ${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}"),
                  _model(
                      "Marca de Tiempo: ${data[index]['marca_tiempo_envio'].toString()}"),
                  _model(
                      "Fecha: ${data[index]['marca_tiempo_envio'].toString().split(" ")[0].toString()}"),
                  _model(
                      "Direccion: ${data[index]['direccion_shipping'].toString()}"),
                  _model(
                      "Cantidad: ${data[index]['cantidad_total'].toString()}"),
                  _model(
                      "Precio Total: ${data[index]['precio_total'].toString()}"),
                  _model("Producto: ${data[index]['producto_p'].toString()}"),
                  _model(
                      "Producto Extra: ${data[index]['producto_extra'] == null || data[index]['producto_extra'] == "null" ? "" : data[index]['producto_extra'].toString()}"),
                  _model("Ciudad: ${data[index]['ciudad_shipping']}"),
                  _model("Status: ${data[index]['status']}"),
                  _model(
                      "Comentario: ${data[index]['comentario'] == null || data[index]['comentario'] == "null" ? "" : data[index]['comentario']}"),
                  _model("Fecha de Entrega: ${data[index]['fecha_entrega']}"),
                  _model("Nombre Cliente: ${data[index]['nombre_shipping']}"),
                  _model("Teléfono: ${data[index]['telefono_shipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['estado_devolucion']}"),
                  _model(
                      "Marca. O: ${data[index]['marca_t_d'] == null || data[index]['marca_t_d'] == "null" ? "" : data[index]['marca_t_d']}"),
                  _model(
                      "Marca. TR: ${data[index]['marca_t_d_t'] == null || data[index]['marca_t_d_t'] == "null" ? "" : data[index]['marca_t_d_t']}"),
                  _model("Marca. TL: ${data[index]['marca_t_d_l']}")
                  /* strapi version
                  _model(
                      "Código: ${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}"),
                  _model(
                      "Marca de Tiempo: ${data[index]['attributes']['Marca_Tiempo_Envio']}"),
                  _model(
                      "Fecha: ${data[index]['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0].toString()}"),
                  _model(
                      "Detalle: ${data[index]['attributes']['DireccionShipping']}"),
                  _model(
                      "Cantidad: ${data[index]['attributes']['Cantidad_Total']}"),
                  _model(
                      "Precio Total: ${data[index]['attributes']['PrecioTotal']}"),
                  _model("Producto: ${data[index]['attributes']['ProductoP']}"),
                  _model(
                      "Producto Extra: ${data[index]['attributes']['ProductoExtra']}"),
                  _model(
                      "Ciudad: ${data[index]['attributes']['CiudadShipping']}"),
                  _model("Status: ${data[index]['attributes']['Status']}"),
                  _model(
                      "Comentario: ${data[index]['attributes']['Comentario']}"),
                  _model(
                      "Fecha de Entrega: ${data[index]['attributes']['Fecha_Entrega']}"),
                  _model(
                      "Nombre Cliente: ${data[index]['attributes']['NombreShipping']}"),
                  _model(
                      "Teléfono: ${data[index]['attributes']['TelefonoShipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['attributes']['Estado_Devolucion']}"),
                  _model("Marca. O: ${data[index]['attributes']['Marca_T_D']}"),
                  _model(
                      "Marca. TR: ${data[index]['attributes']['Marca_T_D_T']}"),
                  _model(
                      "Marca. TL: ${data[index]['attributes']['Marca_T_D_L']}")
                      */
                ],
              ),
            ),
          );
        });
  }

  sortFunc2(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
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

                  paginateData();
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

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
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

                  paginateData();
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

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  Container _buttons() {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    var response = await Connections().updateOrderInteralStatus(
                        "NO DESEA", optionsCheckBox[i]['id'].toString());
                  }
                }
                setState(() {});
                loadData();
              },
              child: Text(
                "No Desea",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    var response = await Connections().updateOrderInteralStatus(
                        "CONFIRMADO", optionsCheckBox[i]['id'].toString());
                  }
                }
                await showDialog(
                    context: context,
                    builder: (context) {
                      return RoutesModal(
                          idOrder: optionsCheckBox,
                          someOrders: true,
                          phoneClient: "",
                          codigo: "");
                    });

                setState(() {});
                loadData();
              },
              child: Text(
                "Confirmar",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          getOldValue(true);
          paginatorController.navigateToPage(0);
          // loadData();
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
                    });
                    resetFilters();
                    paginatorController.navigateToPage(0);
                    // loadData();

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

/*
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
            pedido = "";
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
                      // filtersAnd = [];
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
  */

  sortFunc(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
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

  Padding _model(text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
