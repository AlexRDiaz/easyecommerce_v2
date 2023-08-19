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
  List<String> listOperators = [];
  List arrayFiltersAnd = [];
  int total = 0;
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");
  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'DEVOLUCION EN RUTA',
    'ENTREGADO EN OFICINA',
    'NO ENTREGADO'
  ];
  List populate = [
    'transportadora.operadores.user',
    'pedido_fecha',
    'ruta',
    'operadore',
    'operadore.user',
    'users',
    'users.vendedores'
  ];
  List filtersDefaultOr = [
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NO ENTREGADO'
    },
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NOVEDAD'
    },
  ];
  List filtersDefaultAnd = [
    //  {
    //   'operator': '\$and',
    //   'filter': 'IdComercial',
    //   'operator_attr': '\$eq',
    //   'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
    // }
  ];
  //filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora")}&filters[NumeroOrden][\$contains]=$code&filters[\$or][0][Status][\$eq]=NOVEDAD&filters[\$or][1][Status][\$eq]=NO ENTREGADO&pagination[limit]=-1"),
//  "Fecha",
//     "Devolución"
  List filtersOrCont = [
    {'filter': 'Fecha_Entrega'},
    {'filter': 'NumeroOrden'},
    {'filter': 'NombreShipping'},
    {'filter': 'CiudadShipping'},
    {'filter': 'DireccionShipping'},
    {'filter': 'TelefonoShipping'},
    {'filter': 'Cantidad_Total'},
    {'filter': 'ProductoP'},
    {'filter': 'ProductoExtra'},
    {'filter': 'PrecioTotal'},
    {'filter': 'Observacion'},
    {'filter': 'Comentario'},
    {'filter': 'Status'},
    {'filter': 'TipoPago'},
    {'filter': 'Estado_Pagado'},
  ];
  List arrayUniqueFilters = [
    "filters[transportadora][id][\$eq]=${sharedPrefs!.getString("idTransportadora")}&"
  ];

  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController operadorController =
      TextEditingController(text: "TODO");
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

  @override
  void didChangeDependencies() {
    loadData();
    getOperatorsList();

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
        arrayFiltersAnd,
        filtersDefaultOr,
        filtersDefaultAnd,
        arrayUniqueFilters);

    data = response[0]['data'];
    setState(() {
      pageCount = response[0]['meta']['pagination']['pageCount'];
      total = response[0]['meta']['pagination']['total'];
    });

    //print("total" + total.toString());

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

    response = await Connections().getOrdersSellersFilter(
        _controllers.searchController.text,
        currentPage,
        pageSize,
        populate,
        filtersOrCont,
        [],
        filtersDefaultOr,
        filtersDefaultAnd,
        arrayUniqueFilters);
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
            _filters(context),
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        color = Colors.yellow;
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
}
