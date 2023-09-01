import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/returns/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

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

  NumberPaginatorController paginatorController = NumberPaginatorController();
  List populate = [
    'users',
    'pedido_fecha',
    'ruta',
    'transportadora',
    'users.vendedores',
    'operadore',
    'operadore.user'
  ];
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
    }
  ];

  List arrayFiltersDefaultOr = [
    {"status": "NOVEDAD"},
    {"status": "NO ENTREGADO"}
  ];

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
  ];

  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");

  List arrayFiltersNotEq = [];

  @override
  void didChangeDependencies() {
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
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        _controllers.searchController.text,
        arrayFiltersNotEq);

    // data = response[0]['data'];
    data = responseLaravel['data'];

    setState(() {
      pageCount = responseLaravel['last_page'];
      // total = response[0]['meta']['pagination']['total'];
      total = responseLaravel['total'];

      // print("metadatar"+pageCount.toString());
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    paginatorController.navigateToPage(0);
    setState(() {});
    isLoading = false;
  }

  paginateData() async {
    print("test de page return Pagina Actual=" + currentPage.toString());
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
    //     filtersAnd,
    //     filtersDefaultOr,
    //     filtersDefaultAnd, []);

    var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        _controllers.searchController.text,
        arrayFiltersNotEq);

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
    setState(() {});
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
                      const SizedBox(
                        width: 5,
                      ),
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

                          await paginateData();
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
                          ],
                        ),
                      ),
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
                          if (!isLoading) {
                            await paginateData();
                          }
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
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Fecha_Entrega");
                    },
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
                    label: Text('Detalle'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("DireccionShipping");
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
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Cantidad_Total");
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
                    label: Text('Producto Extra'),
                    size: ColumnSize.L,
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
                  DataColumn2(
                    label: Text('Status'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Status");
                    },
                  ),
                  DataColumn2(
                    label: SelectFilter(
                        'Estado Devolución',
                        'estado_devolucion',
                        estadoDevolucionController,
                        listEstadoDevolucion),
                    //label: Text('Estado Devolución'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Estado_Devolucion");
                    },
                  ),
                  DataColumn2(
                    label: Text('Comentario'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Comentario");
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
                                      _model(
                                          "Fecha: ${data[index]['fecha_entrega'].toString()}"),
                                      _model(
                                          "Código: ${data[index]['name_comercial']}-${data[index]['numero_orden']}"),
                                      _model(
                                          "Ciudad: ${data[index]['ciudad_shipping']}"),
                                      _model(
                                          "Nombre Cliente: ${data[index]['nombre_shipping']}"),
                                      _model(
                                          "Detalle: ${data[index]['direccion_shipping']}"),
                                      _model(
                                          "Teléfono: ${data[index]['telefono_shipping']}"),
                                      _model(
                                          "Cantidad: ${data[index]['cantidad_total']}"),
                                      _model(
                                          "Producto: ${data[index]['producto_p']}"),
                                      _model(
                                          "Producto Extra: ${data[index]['producto_extra']}"),
                                      _model(
                                          "Precio Total: ${data[index]['precio_total']}"),
                                      _model(
                                          "Status: ${data[index]['status']}"),
                                      _model(
                                          "Estado Devolución: ${data[index]['estado_devolucion']}"),
                                      _model(
                                          "Marca Fecha Confirmación: ${data[index]['fecha_confirmacion']}"),
                                      _model(
                                          "Comentario: ${data[index]['comentario']}"),
                                      _model(
                                          "Nsovedades: ${data[index]['novedades.url_image']}")
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      cells: [
                        DataCell(Text(
                          // data[index]['attributes']['Fecha_Entrega'].toString(),
                          data[index]['fecha_entrega'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        // DataCell(
                        //   Text(
                        //     // "${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}",
                        //     "${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}",
                        //     style: TextStyle(
                        //       color: GetColor(data[index]['status'].toString()),
                        //     ),
                        //   ),
                        // ),
                        DataCell(
                            Text(
                                style: TextStyle(
                                    color: GetColor(data[index]
                                            ['estado_devolucion']
                                        .toString())!),
                                '${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}'),
                            onTap: () {
                          //openDialog(context, index);
                        }),
                        DataCell(Text(
                            // '${data[index]['attributes']['CiudadShipping'].toString()}')),
                            '${data[index]['ciudad_shipping'].toString()}')),
                        DataCell(Text(
                          // data[index]['attributes']['NombreShipping']
                          //     .toString(),
                          data[index]['nombre_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['DireccionShipping']
                          //     .toString(),
                          data[index]['direccion_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['TelefonoShipping']
                          //     .toString(),
                          data[index]['telefono_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['Cantidad_Total']
                          //     .toString(),
                          data[index]['cantidad_total'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // '${data[index]['attributes']['ProductoP'].toString()}',
                          data[index]['producto_p'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // '${data[index]['attributes']['ProductoExtra'].toString()}',
                          data[index]['producto_extra'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // '\$${data[index]['attributes']['PrecioTotal'].toString()}',
                          data[index]['precio_total'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['Status'].toString(),
                          data[index]['status'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['Estado_Devolucion']
                          //     .toString(),
                          data[index]['estado_devolucion'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['attributes']['Comentario'].toString(),
                          data[index]['comentario'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          // data[index]['Fecha_Confirmacion']
                          //     .toString(),
                          data[index]['fecha_confirmacion'].toString(),
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
        color = 0xFF00FFFF;
        break;
      case "DEVOLUCION EN RUTA":
        color = 0xFF0000FF;
        break;
      case "EN BODEGA":
        color = 0xFFDAFF00;
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
}

paginateData() {}
