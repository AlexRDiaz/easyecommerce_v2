import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/returns/controllers/controllers.dart';
import 'package:frontend/ui/transport/returns_transport/scanner_printed_transport.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/transport/select_status_return.dart';
import 'package:frontend/ui/widgets/transport/transport_returns.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

class ReturnsTransport extends StatefulWidget {
  const ReturnsTransport({super.key});

  @override
  State<ReturnsTransport> createState() => _ReturnsTransportState();
}

class _ReturnsTransportState extends State<ReturnsTransport> {
  final ReturnsControllers _controllers = ReturnsControllers();
  List allData = [];

  List data = [];
  List dataTemporal = [];
  String option = "";
  bool sort = false;
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  List filtersAnd = [];
  // List<String> listOperators = [];
  List<String> listOperators = ['TODO'];

  // List arrayFiltersAnd = [];
  int total = 0;
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");
//for strapi
  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'DEVOLUCION EN RUTA',
    'ENTREGADO EN OFICINA',
    'EN BODEGA',
    'EN BODEGA PROVEEDOR',
  ];
//   List populate = [
//     'transportadora.operadores.user',
//     'pedido_fecha',
//     'ruta',
//     'operadore',
//     'operadore.user',
//     'users',
//     'users.vendedores'
//   ];
//   List filtersDefaultOr = [
//     {
//       'operator': '\$or',
//       'filter': 'Status',
//       'operator_attr': '\$eq',
//       'value': 'NO ENTREGADO'
//     },
//     {
//       'operator': '\$or',
//       'filter': 'Status',
//       'operator_attr': '\$eq',
//       'value': 'NOVEDAD'
//     },
//   ];
//   List filtersDefaultAnd = [
//     //  {
//     //   'operator': '\$and',
//     //   'filter': 'IdComercial',
//     //   'operator_attr': '\$eq',
//     //   'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
//     // }
//   ];
//   //filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora")}&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
// //  "Fecha",
// //     "Devolución"
//   List filtersOrCont = [
//     {'filter': 'Fecha_Entrega'},
//     {'filter': 'NumeroOrden'},
//     {'filter': 'NombreShipping'},
//     {'filter': 'CiudadShipping'},
//     {'filter': 'DireccionShipping'},
//     {'filter': 'TelefonoShipping'},
//     {'filter': 'Cantidad_Total'},
//     {'filter': 'ProductoP'},
//     {'filter': 'ProductoExtra'},
//     {'filter': 'PrecioTotal'},
//     {'filter': 'Observacion'},
//     {'filter': 'Comentario'},
//     {'filter': 'Status'},
//     {'filter': 'TipoPago'},
//     {'filter': 'Estado_Pagado'},
//   ];
//   List arrayUniqueFilters = [
//     "filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora")}&"
//   ];

  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController operadorController =
      TextEditingController(text: "TODO");
//   List bools = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ];
//   List titlesFilters = [
//     "Fecha",
//     "Código",
//     "Ciudad",
//     "Nombre Cliente",
//     "Dirección",
//     "Teléfono Cliente",
//     "Cantidad",
//     "Producto",
//     "Producto Extra",
//     "Precio Total",
//     "Observación",
//     "Comentario",
//     "Status",
//     "Fecha Entrega",
//     "Devolución"
//   ];

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
    }
    // {"status": "NOVEDAD"},
    // {"status": "NO ENTREGADO"}
  ];

  var arrayfiltersDefaultAnd = [
    {
      "transportadora.transportadora_id":
          sharedPrefs!.getString("idTransportadora")
    }
  ];

  List arrayFiltersAnd = [];
  List arrayFiltersNotEq = [];
  var sortFieldDefaultValue = "id:DESC";
  bool changevalue = false;

  var idUser = sharedPrefs!.getString("id");
  List populate = [
    "operadore.up_users",
    "transportadora",
    "users.vendedores",
    "novedades",
    "pedidoFecha",
    "ruta",
    "subRuta",
    "receivedBy"
  ];

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  @override
  void didChangeDependencies() {
    loadData();
    // getOperatorsList();

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

    if (listOperators.length == 1) {
      var responsetransportadoras = await Connections()
          .getOperatoresbyTransport(
              sharedPrefs!.getString("idTransportadora").toString());
      List<dynamic> transportadorasList = responsetransportadoras['operadores'];
      for (var transportadora in transportadorasList) {
        listOperators.add(transportadora);
      }
    }

    // response = await Connections().getOrdersSellersFilter(
    //     _controllers.searchController.text,
    //     currentPage,
    //     pageSize,
    //     populate,
    //     filtersOrCont,
    //     arrayFiltersAnd,
    //     filtersDefaultOr,
    //     filtersDefaultAnd,
    //     arrayUniqueFilters);

    // data = response[0]['data'];

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
        sortFieldDefaultValue.toString());
    data = responseLaravel['data'];
    setState(() {
      // pageCount = response[0]['meta']['pagination']['pageCount'];
      // total = response[0]['meta']['pagination']['total'];
      pageCount = responseLaravel['last_page'];
      if (sortFieldDefaultValue.toString() == "id:DESC") {
        total = responseLaravel['total'];
      }
    });

    print("totalLa:" + total.toString());

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    paginatorController.navigateToPage(0);
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
      data.clear();
    });

    // print("actual pagina valor" + currentPage.toString());

    // response = await Connections().getOrdersSellersFilter(
    //     _controllers.searchController.text,
    //     currentPage,
    //     pageSize,
    //     populate,
    //     filtersOrCont,
    //     [],
    //     filtersDefaultOr,
    //     filtersDefaultAnd,
    //     arrayUniqueFilters);
    // data = response[0]['data'];
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
        sortFieldDefaultValue.toString());
    data = responseLaravel['data'];
    setState(() {
      // pageCount = response[0]['meta']['pagination']['pageCount'];
      // total = response[0]['meta']['pagination']['total'];
      pageCount = responseLaravel['last_page'];
      total = responseLaravel['total'];
      print("totalPag: $total");
    });

    await Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getOperatorsList() async {
    var opertators = await Connections().getOperatorsByTransport(
        sharedPrefs!.getString("idTransportadora").toString());
    listOperators.add('TODO');
    for (var operator in opertators) {
      if (operator['user'] != null) {
        listOperators.add(operator['user']['username']);
      }
    }
    //print(listOperators);
  }

  int calcularTotalPaginas(int totalRegistros, int registrosPorPagina) {
    final int totalPaginas = totalRegistros ~/ registrosPorPagina;
    final int registrosRestantes = totalRegistros % registrosPorPagina;

    return registrosRestantes > 0
        ? totalPaginas + 1
        : totalPaginas == 0
            ? 1
            : totalPaginas;
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
            // _filters(context),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 45, right: 15),
                        child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SelectStatusReturn(
                                        function: setSelectedStatus);
                                  });
                              //   await loadData();
                            },
                            child: Text(
                              "SCANNER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      Expanded(child: numberPaginator()),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                      Container(
                        child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SelectStatusReturn(
                                        function: setSelectedStatus);
                                  });

                              await loadData();
                            },
                            child: Text(
                              "SCANNER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      numberPaginator(),
                    ],
                  ),
                  context),
            ),

            // Container(
            //   width: double.infinity,
            //   color: Colors.white,
            //   padding: EdgeInsets.only(top: 5, bottom: 5),
            //   child: Row(
            //     children: [
            //       responsive(
            //           Row(
            //             children: [
            //               Expanded(
            //                 child: _modelTextField(
            //                     text: "Buscar",
            //                     controller: _controllers.searchController),
            //               ),
            //               Expanded(child: numberPaginator()),
            //             ],
            //           ),
            //           Column(
            //             children: [
            //               Container(
            //                 child: _modelTextField(
            //                     text: "Buscar",
            //                     controller: _controllers.searchController),
            //               ),
            //               Expanded(child: numberPaginator()),
            //             ],
            //           ),
            //           context),
            //     ],
            //   ),
            // ),

            Expanded(
              child: DataTable2(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.blueGrey),
                ),
                headingRowHeight: 83,
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 2500,
                columns: [
                  const DataColumn2(
                    label: Text(''),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: const Text('Código'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("NumeroOrden");
                      sortFunc2("numero_orden", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Marca de Tiempo'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFuncDate("Marca_T_I");
                      sortFunc2("marca_t_i", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFuncDate("Marca_Tiempo_Envio");
                      sortFunc2("marca_tiempo_envio", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Direccion'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("direccion_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Cantidad'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("cantidad_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Precio Total'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("precio_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Producto'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("producto_p", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Ciudad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("ciudad_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text("Status"),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("status", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Comentario'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("comentario", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Fecha de Entrega'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("fecha_entrega", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Nombre Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("nombre_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Teléfono'),
                    numeric: true,
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("telefono_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: SelectFilter(
                        'Operador',
                        'operadore.up_users.operadore_id',
                        operadorController,
                        listOperators),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {},
                  ),
                  DataColumn2(
                    label: SelectFilter2(
                        'Estado Devolución',
                        'estado_devolucion',
                        estadoDevolucionController,
                        listEstadoDevolucion),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("estado_devolucion", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('MDT.OF'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("marca_t_d", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('MDT.RUTA'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("marca_t_d_t", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('MDT. BOD'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("marca_t_d_l", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Recibido por'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Marca_T_D_L");
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.black;

                    return DataRow(
                      // onSelectChanged: (bool? selected) {},
                      cells: [
                        DataCell(ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return TransportReturn(
                                      id: data[index]['id'].toString(),
                                      status: data[index]['estado_devolucion']
                                          .toString(),
                                    );
                                  });
                              await loadData();
                            },
                            child: const Text(
                              "Devolver",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ))),
                        DataCell(
                            Text(
                              "${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}",
                              style: TextStyle(
                                color:
                                    getColor(data[index]['estado_devolucion']),
                              ),
                            ),
                            onTap: () {}),
                        DataCell(Text(
                          data[index]['marca_t_i'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_tiempo_envio'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['direccion_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['cantidad_total'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '\$${data[index]['precio_total'].toString()}',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['producto_p'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(
                            Text(data[index]['ciudad_shipping'].toString())),
                        DataCell(Text(
                          data[index]['status'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['comentario'] == null ||
                                  data[index]['comentario'] == "null"
                              ? ""
                              : data[index]['comentario'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['fecha_entrega'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['nombre_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['telefono_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(
                            Text(
                              data[index]['operadore'] != null &&
                                      data[index]['operadore'].toString() !=
                                          "[]"
                                  ? data[index]['operadore'][0]['up_users'][0]
                                          ['username']
                                      .toString()
                                  : "",
                            ),
                            onTap: () {}),
                        DataCell(Text(
                          data[index]['estado_devolucion'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d'] ?? "".toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d_t'] ?? "".toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d_l'] ?? "".toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(
                          Text(
                            data[index]['received_by'] != null &&
                                    data[index]['received_by'].isNotEmpty
                                ? "${data[index]['received_by']['username'].toString()}-${data[index]['received_by']['id'].toString()}"
                                : '',
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ),
                        ),
                      ],
                    );
                    /*
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
                      sortFuncDate("Marca_T_I");
                    },
                  ),
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Marca_Tiempo_Envio");
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
                    label: Text("Status"),
                    size: ColumnSize.L,
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
                      sortFuncDate("Fecha_Entrega");
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
                    label: SelectFilter(
                        'Operador',
                        'filters[operadore][user][username][\$eq]',
                        "",
                        operadorController,
                        listOperators),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Estado_Devolucion");
                    },
                  ),
                  DataColumn2(
                    label: SelectFilter(
                        'Devolucion',
                        'filters[Estado_Devolucion][\$eq]',
                        '',
                        estadoDevolucionController,
                        listEstadoDevolucion),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Estado_Devolucion");
                    },
                  ),
                  DataColumn2(
                    label: Text('MDT.OF'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Marca_T_D");
                    },
                  ),
                  DataColumn2(
                    label: Text('MDT.RUTA'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Marca_T_D_T");
                    },
                  ),
                  DataColumn2(
                    label: Text('MDT. BOD'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Marca_T_D_L");
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.black;

                    return DataRow(
                      // onSelectChanged: (bool? selected) {},
                      cells: [
                        DataCell(ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return TransportReturn(
                                      id: data[index]['id'].toString(),
                                      status: data[index]['attributes']
                                              ['Estado_Devolucion']
                                          .toString(),
                                    );
                                  });
                              await loadData();
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
                                color: getColor(data[index]['attributes']
                                    ['Estado_Devolucion']),
                              ),
                            ),
                            onTap: () {}),
                        DataCell(Text(
                          data[index]['attributes']['Marca_T_I'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Marca_Tiempo_Envio']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['DireccionShipping']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Cantidad_Total']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '\$${data[index]['attributes']['PrecioTotal'].toString()}',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '${data[index]['attributes']['ProductoP'].toString()}',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                            '${data[index]['attributes']['CiudadShipping'].toString()}')),
                        DataCell(Text(
                          data[index]['attributes']['Status'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Comentario'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Fecha_Entrega'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['NombreShipping']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['TelefonoShipping']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(
                            Text(data[index]['attributes']['operadore']
                                        ['data'] !=
                                    null
                                ? data[index]['attributes']['operadore']['data']
                                        ['attributes']['user']['data']
                                    ['attributes']['username']
                                : "".toString()),
                            onTap: () {}),
                        DataCell(Text(
                          data[index]['attributes']['Estado_Devolucion']
                              .toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Marca_T_D'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Marca_T_D_T'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['attributes']['Marca_T_D_L'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                      ],
                    );
                    */
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Column SelectFilter2(String title, filter, TextEditingController controller,
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

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  void resetFilters() {
    operadorController.text = "TODO";
    estadoDevolucionController.text = "TODO";

    _controllers.searchController.clear();
    arrayFiltersAnd = [];
  }

/*
  _filters(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        content: Container(
                          width: 500,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.close)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Filtros:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    children: [
                                      Wrap(
                                        children: [
                                          ...List.generate(
                                              titlesFilters.length,
                                              (index) => Container(
                                                    width: 140,
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                            value: bools[index],
                                                            onChanged: (v) {
                                                              if (bools[
                                                                      index] ==
                                                                  true) {
                                                                setState(() {
                                                                  bools[index] =
                                                                      false;
                                                                  option = "";
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  bools[index] =
                                                                      true;
                                                                  option =
                                                                      titlesFilters[
                                                                          index];
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          bools
                                                                              .length;
                                                                      i++) {
                                                                    if (i !=
                                                                        index) {
                                                                      bools[i] =
                                                                          false;
                                                                    }
                                                                  }
                                                                });
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          titlesFilters[index],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  });
              setState(() {});
            },
            icon: Icon(Icons.filter_alt_outlined)),
        Flexible(
            child: Text(
          "Activo: $option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ))
      ],
    );
  }
*/
  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
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

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
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

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
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
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
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

  Color getColor(returnStatus) {
    Color color = Colors.black;
    switch (returnStatus) {
      case "PENDIENTE":
        color = Colors.red;
        break;
      case "ENTREGADO EN OFICINA":
        color = Colors.lightBlue;
        break;
      case "DEVOLUCION EN RUTA":
        color = Color.fromARGB(255, 8, 61, 153);
        break;
      case "EN BODEGA":
        color = Color.fromARGB(255, 216, 200, 54);
        break;
      default:
    }

    return color;
  }

  setSelectedStatus(value) async {
    print(value);
    await showDialog(
        context: context,
        builder: (context) {
          return ScannerPrintedTransport(
            status: value,
          );
        });
    await loadData();
    Navigator.pop(context);
  }

/*
  Column SelectFilter(String title, filter, value,
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
            height: 50,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";

                  for (String element in arrayUniqueFilters) {
                    if (element.contains(filter)) {
                      arrayUniqueFilters.remove(element);
                    }
                  }
                  if (newValue != 'TODO') {
                    arrayUniqueFilters.add(filter + "=" + newValue + "&");
                  }

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
  */
}
