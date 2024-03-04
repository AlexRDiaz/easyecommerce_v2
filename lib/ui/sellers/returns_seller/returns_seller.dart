import 'dart:html';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/returns/controllers/controllers.dart';
import 'package:frontend/ui/sellers/returns_seller/return_details_data.dart';
import 'package:frontend/ui/sellers/returns_seller/scanner_return.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

import 'return_details.dart';
import '../../widgets/show_error_snackbar.dart';

class ReturnsSeller extends StatefulWidget {
  const ReturnsSeller({super.key});

  @override
  State<ReturnsSeller> createState() => _ReturnsSellerState();
}

class _ReturnsSellerState extends State<ReturnsSeller> {
  final ReturnsControllers _controllers = ReturnsControllers();
  List data = [];
  List dataTemporal = [];
  bool sort = false;
  bool isLoading = false;
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  int total = 0;
  bool isFirst = true;

  NumberPaginatorController paginatorController = NumberPaginatorController();
  // List populate = [
  //   'users',
  //   'pedido_fecha',
  //   'ruta',
  //   'transportadora',
  //   'users.vendedores',
  //   'operadore',
  //   'operadore.user'
  // ];
  List filtersAnd = [];
  List filtersDefaultOr = [
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NOVEDAD'
    },
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NO ENTREGADO'
    },
  ];

  List filtersDefaultAnd = [
    {
      'operator': '\$and',
      'filter': 'IdComercial',
      'operator_attr': '\$eq',
      'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
    }
  ];

  var arrayfiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "ENVIADO"},
  ];

  List arrayFiltersDefaultOr = [
    {
      "status": ["NOVEDAD", "NO ENTREGADO"]
    }
    // {"status": "NOVEDAD"},
    // {"status": "NO ENTREGADO"}
  ];

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

  var sortFieldDefaultValue = "id:DESC";
  var sortField = "";

  bool changevalue = false;

// ][Status][\$eq]=NOVEDAD&",
//     "filters[\$and][1][\$or][1][Status][\$eq]=NO ENTREGADO&",
//     "filters[\$and][2][\$or][1][IdComercial][\$eq]=${sharedPrefs!.getString("idComercialMasterSeller").toString()}&"

  // List filtersOrCont = [
  //   {'filter': 'Fecha_Entrega'},
  //   {'filter': 'NumeroOrden'},
  //   {'filter': 'CiudadShipping'},
  //   {'filter': 'NombreShipping'},
  //   {'filter': 'DireccionShipping'},
  //   {'filter': 'TelefonoShipping'},
  //   {'filter': 'Cantidad_Total'},
  //   {'filter': 'ProductoP'},
  //   {'filter': 'ProductoExtra'},
  //   {'filter': 'PrecioTotal'},
  //   {'filter': 'Status'},
  //   {'filter': 'Estado_Devolucion'},
  //   {'filter': 'Fecha_Confirmacion'},
  // ];

  List filtersOrCont = [
    'fecha_entrega',
    'numero_orden',
    'ciudad_shipping',
    'nombre_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    'status',
    "estado_devolucion",
    "fecha_confirmacion",
    'comentario',
  ];

  String option = "";
  List bools = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List titlesFilters = [
    "Fecha",
    "Código",
    "Ciudad",
    "Nombre Cliente",
    "Dirección",
    "Teléfono Cliente",
    "Cantidad",
    "Producto",
    "Producto Extra",
    "Precio Total",
    "Observación",
    "Comentario",
    "Status",
    "Fecha Entrega",
    "Devolución"
  ];

  List arrayFiltersAnd = [];
  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'ENTREGADO EN OFICINA',
    'DEVOLUCION EN RUTA',
    'EN BODEGA',
    'EN BODEGA PROVEEDOR'
  ];
  List<String> listStatus = ["TODO", "NOVEDAD", "NO ENTREGADO"];

  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");
  TextEditingController statusController = TextEditingController(text: "TODO");

  List arrayFiltersNotEq = [];

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
    super.didChangeDependencies();
  }

  loadData() async {
    isLoading = true;
    currentPage = 1;
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var response = [];
      setState(() {
        data.clear();
      });

      // response = await Connections().getOrdersSellersFilter(
      //     _controllers.searchController.text,
      //     currentPage,
      //     pageSize,
      //     populate,
      //     filtersOrCont,
      //     filtersAnd,
      //     filtersDefaultOr,
      //     filtersDefaultAnd, []);

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
          populate,
          filtersOrCont,
          arrayFiltersDefaultOr,
          arrayfiltersDefaultAnd,
          arrayFiltersAnd,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          arrayFiltersNotEq,
          sortFieldDefaultValue.toString());

      // data = response[0]['data'];

      setState(() {
        data = responseLaravel['data'];

        pageCount = responseLaravel['last_page'];
        // total = response[0]['meta']['pagination']['total'];
        //total = responseLaravel['total'];

        if (sortFieldDefaultValue.toString() == "id:DESC") {
          total = responseLaravel['total'];
        }

        paginatorController.navigateToPage(0);
      });

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      print("datos cargados correctamente");
      setState(() {
        isFirst = false;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var response = [];
      setState(() {
        isLoading = true;
        data.clear();
      });

      // response = await Connections().getOrdersSellersFilter(
      //     _controllers.searchController.text,
      //     currentPage,
      //     pageSize,
      //     populate,
      //     filtersOrCont,
      //     filtersAnd,
      //     filtersDefaultOr,
      //     filtersDefaultAnd, []);

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
          populate,
          filtersOrCont,
          arrayFiltersDefaultOr,
          arrayfiltersDefaultAnd,
          arrayFiltersAnd,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          arrayFiltersNotEq,
          sortFieldDefaultValue.toString());

      // data = response[0]['data'];
      data = responseLaravel['data'];

      setState(() {
        // pageCount = response[0]['meta']['pagination']['pageCount'];
        // total = response[0]['meta']['pagination']['total'];

        pageCount = responseLaravel['last_page'];
        total = responseLaravel['total'];
      });

      await Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      print("datos paginados");
    } catch (e) {
      Navigator.pop(context);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
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
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    // optionsCheckBox = [];
                    // counterChecks = 0;
                    // enabledBusqueda = true;
                  });
                  resetFilters();
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
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ScannerReturn();
                                  });
                              await loadData();
                            },
                            child: const Text(
                              "SCANNER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      const SizedBox(
                        width: 5,
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
                      const SizedBox(
                        height: 10,
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ScannerReturn();
                                  });
                              await loadData();
                            },
                            child: const Text(
                              "SCANNER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
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
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                headingRowHeight: 63,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("fecha_entrega", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Código'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("numero_orden", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Ciudad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("ciudad_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Nombre Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("nombre_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Dirección'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("direccion_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Teléfono'),
                    numeric: true,
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("telefono_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("cantidad_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("producto_p", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto Extra'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("producto_extra", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Precio Total'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("precio_total", changevalue);
                    },
                  ),
                  // DataColumn2(
                  //   label: Text('Status'),
                  //   size: ColumnSize.S,
                  //   onSort: (columnIndex, ascending) {
                  //     sortFunc2("status", changevalue);
                  //   },
                  // ),
                  DataColumn2(
                    label: SelectFilter(
                        'Status',
                        'status',
                        statusController,
                        listStatus),
                    size: ColumnSize.L,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("status", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: SelectFilter(
                        'Estado Devolución',
                        'estado_devolucion',
                        estadoDevolucionController,
                        listEstadoDevolucion),
                    size: ColumnSize.L,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("estado_devolucion", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Comentario'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("comentario", changevalue);
                    },
                  ),
                  // DataColumn2(
                  //   label: Text('Marca Fecha Confirmación'),
                  //   size: ColumnSize.L,
                  //   onSort: (columnIndex, ascending) {
                  //     sortFunc2("fecha_confirmacion", changevalue);
                  //   },
                  // ),
                  DataColumn2(
                    label: const Text('Marca T. Dev. L'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("marca_t_d_l", changevalue);
                    },
                  ),
                  const DataColumn2(
                    label: Text('Transportadora'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: const Text('Recibido por'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("received_by", changevalue);
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.black;
                    return DataRow(
                      onSelectChanged: (bool? selected) {
                        showDialog(
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
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      cells: [
                        DataCell(
                            Text(
                              data[index]['fecha_entrega'] == null ||
                                      data[index]['fecha_entrega'] == "null"
                                  ? ""
                                  : data[index]['fecha_entrega'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                                style: TextStyle(
                                    color: GetColor(data[index]
                                            ['estado_devolucion']
                                        .toString())!),
                                '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}'),
                            onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['ciudad_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['nombre_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['direccion_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['telefono_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['cantidad_total'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['producto_p'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['producto_extra'] == null ||
                                      data[index]['producto_extra'] == "null"
                                  ? ""
                                  : data[index]['producto_extra'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['precio_total'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['status'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['estado_devolucion'] == null ||
                                      data[index]['estado_devolucion'] == "null"
                                  ? ""
                                  : data[index]['estado_devolucion'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['comentario'] == null ||
                                      data[index]['comentario'] == "null"
                                  ? ""
                                  : data[index]['comentario'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        // DataCell(
                        //     Text(
                        //       data[index]['fecha_confirmacion'] == null ||
                        //               data[index]['fecha_confirmacion'] ==
                        //                   "null"
                        //           ? ""
                        //           : data[index]['fecha_confirmacion']
                        //               .toString(),
                        //       style: TextStyle(
                        //         color: rowColor,
                        //       ),
                        //     ), onTap: () {
                        //   showDialogInfoData(data[index]);
                        // }),
                        DataCell(
                            Text(
                              data[index]['marca_t_d_l'] == null ||
                                      data[index]['marca_t_d_l'] == "null"
                                  ? ""
                                  : data[index]['marca_t_d_l'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),

                        DataCell(
                            Text(data[index]['transportadora'] != null &&
                                    data[index]['transportadora'].isNotEmpty
                                ? data[index]['transportadora'][0]['nombre']
                                    .toString()
                                : ''), onTap: () {
                          showDialogInfoData(data[index]);
                        }),

                        DataCell(
                            Text(data[index]['received_by'] != null &&
                                    data[index]['received_by'].isNotEmpty
                                ? "${data[index]['received_by']['username'].toString()}-${data[index]['received_by']['id'].toString()}"
                                : ''), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showDialogInfoData(data) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // paginateData();
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                      child: SellerReturnDetailsData(
                    data: data,
                  ))
                ],
              ),
            ),
          );
        });
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

  void resetFilters() {
    getOldValue(true);

    estadoDevolucionController.text = "TODO";
    arrayFiltersAnd = [];
    _controllers.searchController.text = "";
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

  Padding _model(text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "PENDIENTE":
        color = 0xFFFF0000;
        break;
      case "ENTREGADO EN OFICINA":
        color = 0xD300BBFF;
        break;
      case "DEVOLUCION EN RUTA":
        color = 0xFF0000FF;
        break;
      case "EN BODEGA":
        color = 0xFFD6DC27;
        break;
      case "EN BODEGA PROVEEDOR":
        color = 0xFFE662DF;
        break;
      default:
        color = 0xFF000000;
    }

    return Color(color);
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
                    //print(filter);
                  } else {}
                  getOldValue(true);
                  paginatorController.navigateToPage(0);
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
        },
        // onSubmitted: (value) async {
        //   setState(() {
        //     _controllers.searchController.text = value;
        //   });
        //   //loadData();
        //   paginateData();
        //   getLoadingModal(context, false);

        //   Future.delayed(Duration(milliseconds: 500), () {
        //     paginatorController.navigateToPage(0);

        //     Navigator.pop(context);
        //   });
        // },
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

                    // setState(() {
                    //   // loadData();
                    //   resetFilters();
                    //   // paginateData();
                    // });
                    resetFilters();
                    paginatorController.navigateToPage(0);

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

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonUnselectedForegroundColor: Color.fromARGB(255, 67, 67, 67),
        buttonSelectedBackgroundColor: Color.fromARGB(255, 67, 67, 67),
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }
}

paginateData() {}
