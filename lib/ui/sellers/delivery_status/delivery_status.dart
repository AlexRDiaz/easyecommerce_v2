import 'dart:js_util';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/sellers/delivery_status/info_delivery.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';
import 'package:frontend/ui/widgets/OptionsWidget.dart';
import 'package:frontend/ui/transport/delivery_status_transport/delivery_details.dart';
import 'package:frontend/ui/transport/delivery_status_transport/scanner_delivery_status_transport.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/box_values.dart';
import 'package:frontend/ui/widgets/box_values_transport.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

class DeliveryStatus extends StatefulWidget {
  const DeliveryStatus({super.key});

  @override
  State<DeliveryStatus> createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List allData = [];

  List data = [];
  //List<String> transporterOperators = [];

  List<DateTime?> _dates = [];
  Map dataCounters = {};
  Map valuesTransporter = {};
  bool sort = false;
  String currentValue = "";
  int total = 0;
  int entregados = 0;
  int noEntregados = 0;
  int conNovedad = 0;
  int reagendados = 0;
  int enRuta = 0;
  int programado = 0;
  double costoDeEntregas = 0;
  double devoluciones = 0;
  double utilidad = 0;
  double totalValoresRecibidos = 0;
  double costoTransportadora = 0;
  bool isFirst = true;
  int counterLoad = 0;
  String transporterOperator = 'TODO';
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  List<String> listOperators = [];
  Color currentColor = Color.fromARGB(255, 108, 108, 109);
  List<Map<dynamic, dynamic>> arrayFiltersAndEq = [];
  var arrayDateRanges = [];
  TextEditingController operadorController =
      TextEditingController(text: "TODO");

  List arrayfiltersDefaultAnd = [
    {
      'filter': 'IdComercial',
      'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
    }
  ];
  var arrayFiltersNotEq = [
    {'Status': 'PEDIDO PROGRAMADO'}
  ];
  List populate = [
    'transportadora',
    'users',
    'users.vendedores',
    'pedido_fecha',
    'sub_ruta',
    'operadore',
    'operadore.user',
    'novedades'
  ];

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
    {'filter': 'Marca_T_D'},
    {'filter': 'Marca_T_D_L'},
    {'filter': 'Marca_T_D_T'},
    {'filter': 'Marca_T_I'},
    {'filter': 'Estado_Pagado'},
  ];

  NumberPaginatorController paginatorController = NumberPaginatorController();

  @override
  void didChangeDependencies() {
    initializeDates();

    loadData();
    super.didChangeDependencies();
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var responseCounters =
        await Connections().getOrdersDashboardSellers(populate, [
      {
        "transportadora": {"\$not": null}
      },
      {
        'IdComercial':
            sharedPrefs!.getString("idComercialMasterSeller").toString()
      }
    ]);

    var responseValues = await Connections().getValuesSeller(populate, [
      {
        "transportadora": {"\$not": null}
      },
      {
        'IdComercial':
            sharedPrefs!.getString("idComercialMasterSeller").toString()
      }
    ]);

    var response = await Connections()
        .getOrdersForSellerStateSearchForDateSeller(
            _controllers.searchController.text,
            filtersOrCont,
            arrayFiltersAndEq,
            arrayFiltersNotEq,
            arrayfiltersDefaultAnd,
            [],
            populate,
            currentPage,
            pageSize);

    valuesTransporter = responseValues;
    dataCounters = responseCounters;
    data = response['data'];
    total = response['meta']['total'];
    pageCount = updateTotalPages(total, pageSize);

    // print(sharedPrefs!.getString("idTransportadora").toString());

    //paginate();

    paginatorController.navigateToPage(0);

    updateCounters();
    calculateValues();

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    setState(() {
      isFirst = false;

      isLoading = false;
    });
  }

  int updateTotalPages(int totalRegistros, int registrosPorPagina) {
    final int totalPaginas = totalRegistros ~/ registrosPorPagina;
    final int registrosRestantes = totalRegistros % registrosPorPagina;

    return registrosRestantes > 0
        ? totalPaginas + 1
        : totalPaginas == 0
            ? 1
            : totalPaginas;
  }

  initializeDates() {
    if (sharedPrefs!.getString("dateDesdeVendedor") == null) {
      sharedPrefs!.setString("dateDesdeVendedor",
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
    }
    _controllers.startDateController.text =
        sharedPrefs!.getString("dateDesdeVendedor")!;

    if (sharedPrefs!.getString("dateHastaVendedor") == null) {
      sharedPrefs!.setString("dateHastaVendedor", "1/1/2200");
    }
    _controllers.endDateController.text =
        sharedPrefs!.getString("dateHastaVendedor") != "1/1/2200"
            ? sharedPrefs!.getString("dateHastaVendedor")!
            : "";
  }

  paginateData() async {
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var response = await Connections()
        .getOrdersForSellerStateSearchForDateSeller(
            _controllers.searchController.text,
            filtersOrCont,
            arrayFiltersAndEq,
            arrayFiltersNotEq,
            arrayfiltersDefaultAnd,
            [],
            populate,
            currentPage,
            pageSize);

    setState(() {
      data = response['data'];

      pageCount = updateTotalPages(response['meta']['total'], pageSize);
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {
      isFirst = false;

      isLoading = false;
    });
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

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.day}/${now.month}/20${now.year.toString().substring(2)}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    List<Opcion> opciones = [
      Opcion(
          icono: Icon(Icons.all_inbox),
          titulo: 'Total',
          filtro: 'Total',
          valor: total,
          color: Color.fromARGB(255, 108, 108, 109)),
      Opcion(
          icono: Icon(Icons.send),
          titulo: 'Entregado',
          filtro: 'Entregado',
          valor: entregados,
          color: const Color.fromARGB(255, 102, 187, 106)),
      Opcion(
          icono: Icon(Icons.error),
          titulo: 'No Entregado',
          filtro: 'No Entregado',
          valor: noEntregados,
          color: Color.fromARGB(255, 243, 33, 33)),
      Opcion(
          icono: Icon(Icons.ac_unit),
          titulo: 'Novedad',
          filtro: 'Novedad',
          valor: conNovedad,
          color: const Color.fromARGB(255, 244, 225, 57)),
      Opcion(
          icono: Icon(Icons.schedule),
          titulo: 'Reagendado',
          filtro: 'Reagendado',
          valor: reagendados,
          color: Color.fromARGB(255, 227, 32, 241)),
      Opcion(
          icono: Icon(Icons.route),
          titulo: 'En Ruta',
          filtro: 'En Ruta',
          valor: enRuta,
          color: const Color.fromARGB(255, 33, 150, 243)),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        color: Colors.grey[100],
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 5),
                              child: responsive(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: fechaFinFechaIni(),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: fechaFinFechaIni(),
                                  ),
                                  context),
                            ),
                          ],
                        ),
                      ),
                      boxValues(
                          totalValoresRecibidos: totalValoresRecibidos,
                          costoDeEntregas: costoDeEntregas,
                          devoluciones: devoluciones,
                          utilidad: utilidad),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 5),
                            child: responsive(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: fechaFinFechaIni(),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: fechaFinFechaIni(),
                              ),
                              context,
                            ),
                          ),
                        ],
                      ),
                      // boxValues(
                      //     totalValoresRecibidos: totalValoresRecibidos,
                      //     costoDeEntregas: costoDeEntregas,
                      //     devoluciones: devoluciones,
                      //     utilidad: utilidad),
                    ],
                  ),
                  context),
            ),
            responsive(
                Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: OptionsWidget(
                        function: addFilter,
                        options: opciones,
                        currentValue: currentValue)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: OptionsWidget(
                        function: addFilter,
                        options: opciones,
                        currentValue: currentValue)),
                context),
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              color: currentColor.withOpacity(0.3),
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                      // Expanded(
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         padding:
                      //             const EdgeInsets.only(left: 15, right: 5),
                      //         child: responsive(
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: fechaFinFechaIni(),
                      //             ),
                      //             Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: fechaFinFechaIni(),
                      //             ),
                      //             context),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(child: numberPaginator()),
                      // boxValues(
                      //     totalValoresRecibidos: totalValoresRecibidos,
                      //     costoDeEntregas: costoDeEntregas,
                      //     devoluciones: devoluciones,
                      //     utilidad: utilidad),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                      // // Row(
                      // //   children: [
                      // //     Container(
                      // //       padding: const EdgeInsets.only(left: 15, right: 5),
                      // //       child: responsive(
                      // //         Row(
                      // //           mainAxisAlignment: MainAxisAlignment.center,
                      // //           children: fechaFinFechaIni(),
                      // //         ),
                      // //         Column(
                      // //           mainAxisAlignment: MainAxisAlignment.center,
                      // //           children: fechaFinFechaIni(),
                      // //         ),
                      // //         context,
                      // //       ),
                      // //     ),
                      // //   ],
                      // ),
                      // boxValues(
                      //     totalValoresRecibidos: totalValoresRecibidos,
                      //     costoDeEntregas: costoDeEntregas,
                      //     devoluciones: devoluciones,
                      //     utilidad: utilidad),
                      numberPaginator()
                    ],
                  ),
                  context),
            ),
            Expanded(
              child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(
                            0, 2), // Desplazamiento en X e Y de la sombra
                        blurRadius: 4, // Radio de desenfoque de la sombra
                        spreadRadius: 1, // Extensión de la sombra
                      ),
                    ],
                  ),
                  headingRowHeight: 53,
                  showBottomBorder: true,
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
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Fecha_Entrega");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Código'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Ciudad'),
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
                      numeric: true,
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
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
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
                      label: Text('Status'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: Text('Confirmado'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Interno");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Logístico'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Logistico");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Costo Entrega'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        //sortFuncCost("CostoEnvio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Costo Devolución'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFuncCost("CostoDevolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha Ingreso'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_T_I");
                      },
                    ),
                    DataColumn2(
                      label: Text('N. intentos'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {},
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            DataCell(
                                Row(
                                  children: [
                                    Text(data[index]['attributes']
                                            ['Fecha_Entrega']
                                        .toString()),
                                    data[index]['attributes']['Status'] ==
                                                'NOVEDAD' &&
                                            data[index]['attributes']
                                                    ['Estado_Devolucion'] ==
                                                'PENDIENTE'
                                        ? IconButton(
                                            icon: Icon(Icons.schedule_outlined),
                                            onPressed: () async {
                                              reSchedule(data[index]['id'],
                                                  'REAGENDADO');
                                            },
                                          )
                                        : Container(),
                                  ],
                                ), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                                ['attributes']['Status']
                                            .toString())!),
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}'),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoP']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Comentario']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                                ['attributes']['Status']
                                            .toString())!),
                                    data[index]['attributes']['Status']
                                        .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Interno']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Logistico']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Devolucion']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['users'] != null
                                    ? data[index]['attributes']['Status']
                                                    .toString() ==
                                                "ENTREGADO" ||
                                            data[index]['attributes']['Status']
                                                    .toString() ==
                                                "NO ENTREGADO"
                                        ? data[index]['attributes']['users'][0]
                                                ['vendedores'][0]['CostoEnvio']
                                            .toString()
                                        : ""
                                    : ""), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['users'] != null
                                    ? data[index]['attributes']['Status'].toString() ==
                                            "NOVEDAD"
                                        ? data[index]['attributes']['Estado_Devolucion']
                                                        .toString() ==
                                                    "ENTREGADO EN OFICINA" ||
                                                data[index]['attributes']['Status']
                                                        .toString() ==
                                                    "EN RUTA" ||
                                                data[index]['attributes'][
                                                            'Estado_Devolucion']
                                                        .toString() ==
                                                    "EN BODEGA"
                                            ? data[index]['attributes']['users']
                                                        [0]['vendedores'][0]
                                                    ['CostoDevolucion']
                                                .toString()
                                            : ""
                                        : ""
                                    : ""), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Marca_T_I']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                getLengthArrayMap(
                                    data[index]['attributes']['novedades']),
                                onTap: () {
                              openDialog(context, index);
                            }),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  calculateValues() {
    totalValoresRecibidos = 0;
    costoDeEntregas = 0;
    devoluciones = 0;

    setState(() {
      totalValoresRecibidos =
          double.parse(valuesTransporter['totalValoresRecibido'].toString());
      costoDeEntregas =
          double.parse(valuesTransporter['costoDeEntregas'].toString());
      devoluciones = double.parse(valuesTransporter['devoluciones'].toString());
      utilidad = double.parse(valuesTransporter['utilidad'].toString());
    });
  }

  getLengthArrayMap(List data) {
    var arraylength = data.length;
    return Text(
      arraylength.toString(),
      style: TextStyle(
          color: arraylength > 3
              ? const Color.fromARGB(255, 54, 244, 73)
              : Colors.black),
    );
  }

  addFilter(value) {
    arrayFiltersAndEq.removeWhere((element) => element.containsKey("Status"));
    if (value["filtro"] != "Total") {
      arrayFiltersAndEq.add({"Status": value["filtro"]});
    }

    setState(() {
      currentColor = value['color'];
    });
    paginateData();
  }

  Future<dynamic> OpenShowDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
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
                      child: TransportProDeliveryHistoryDetails(
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> OpenScannerShowDialog(BuildContext context, String id) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
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
                      child: TransportProDeliveryHistoryDetails(
                    id: id,
                  ))
                ],
              ),
            ),
          );
        });
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        onChanged: (value) {
          setState(() {});
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

  OpenScannerInfo(value) {
    var m = value;
    OpenScannerShowDialog(context, value);
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

  sortFuncOperator() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(a['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(b['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    }
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

  fechaFinFechaIni() {
    return [
      Row(
        children: [
          Text(_controllers.startDateController.text),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              _controllers.startDateController.text = await OpenCalendar();
            },
          ),
          const Text(' - '),
          Text(_controllers.endDateController.text),
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () async {
              _controllers.endDateController.text = await OpenCalendar();
            },
          ),
          ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 67, 67, 67))),
              onPressed: () async {
                await applyDateFilter();
              },
              child: Text('Filtrar'))
        ],
      ),
    ];
  }

  Future<String> OpenCalendar() async {
    String nuevaFecha = "";

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedYearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );

    setState(() {
      if (results != null) {
        String fechaOriginal = results![0]
            .toString()
            .split(" ")[0]
            .split('-')
            .reversed
            .join('-')
            .replaceAll("-", "/");
        List<String> componentes = fechaOriginal.split('/');

        String dia = int.parse(componentes[0]).toString();
        String mes = int.parse(componentes[1]).toString();
        String anio = componentes[2];

        nuevaFecha = "$dia/$mes/$anio";
      }
    });
    return nuevaFecha;
  }

  Future<void> applyDateFilter() async {
    isFirst = true;
    arrayDateRanges = [];
    arrayFiltersAndEq = [];
    _controllers.searchController.text = '';
    if (_controllers.startDateController.text != '' &&
        _controllers.endDateController.text != '') {
      if (compareDates(_controllers.startDateController.text,
          _controllers.endDateController.text)) {
        var aux = _controllers.endDateController.text;

        setState(() {
          _controllers.endDateController.text =
              _controllers.startDateController.text;

          _controllers.startDateController.text = aux;
        });
      }
    }
    arrayDateRanges.add({
      'body_param': 'start',
      'value': _controllers.startDateController.text != ""
          ? _controllers.startDateController.text
          : '1/1/2000'
    });

    arrayDateRanges.add({
//        'filter': 'Fecha_Entrega',
      'body_param': 'end',
      'value': _controllers.endDateController.text != ""
          ? _controllers.endDateController.text
          : '1/1/2200'
    });

    setState(() {
      sharedPrefs!.setString(
          "dateDesdeVendedor",
          _controllers.startDateController.text != ""
              ? _controllers.startDateController.text
              : '1/1/1900');
      sharedPrefs!.setString(
          "dateHastaVendedor",
          _controllers.endDateController.text != ""
              ? _controllers.endDateController.text
              : '1/1/2200');
    });
    await loadData();
    calculateValues();
    isFirst = false;
  }

  bool compareDates(String string1, String string2) {
    List<String> parts1 = string1.split('/');
    List<String> parts2 = string2.split('/');

    int day1 = int.parse(parts1[0]);
    int month1 = int.parse(parts1[1]);
    int year1 = int.parse(parts1[2]);

    int day2 = int.parse(parts2[0]);
    int month2 = int.parse(parts2[1]);
    int year2 = int.parse(parts2[2]);

    if (year1 > year2) {
      return true;
    } else if (year1 < year2) {
      return false;
    } else {
      if (month1 > month2) {
        return true;
      } else if (month1 < month2) {
        return false;
      } else {
        if (day1 > day2) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  exeReSchedule(value) {
    reSchedule(value['id'], value['status']);
  }

  updateCounters() {
    entregados = 0;
    noEntregados = 0;
    conNovedad = 0;
    reagendados = 0;
    enRuta = 0;
    // programado = 0;
    setState(() {
      entregados = int.parse(dataCounters['ENTREGADO'].toString()) ?? 0;
      noEntregados = int.parse(dataCounters['NO ENTREGADO'].toString()) ?? 0;
      conNovedad = int.parse(dataCounters['NOVEDAD'].toString()) ?? 0;
      reagendados = int.parse(dataCounters['REAGENDADO'].toString()) ?? 0;
      enRuta = int.parse(dataCounters['EN RUTA'].toString()) ?? 0;
      // programado = int.parse(data['EN OFICINA'].toString()) ?? 0;
      // programado = int.parse(dataCounters['PEDIDO PROGRAMADO'].toString()) ?? 0;
    });
  }

  AddFilterAndEq(value, filtro) {
    setState(() {
      if (value != 'TODO') {
        bool contains = false;

        for (var filter in arrayFiltersAndEq) {
          if (filter['filter'] == filtro) {
            contains = true;
            break;
          }
        }
        if (contains == false) {
          arrayFiltersAndEq.add({
            'filter': filtro,
            'value': {
              'user': {'username': value}
            }
          });
        } else {
          for (var filter in arrayFiltersAndEq) {
            if (filter['filter'] == filtro) {
              filter['value'] = {
                'user': {'username': value}
              };
              break;
            }
          }
        }
      } else {
        for (var filter in arrayFiltersAndEq) {
          if (filter['filter'] == filtro) {
            arrayFiltersAndEq.remove(filter);
            break;
          }
        }
      }
    });
    loadData();
  }

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF33FF6D;
        break;
      case "NOVEDAD":
        color = 0xFFD6DC27;
        break;
      case "NO ENTREGADO":
        color = 0xFFFF3333;
        break;
      case "REAGENDADO":
        color = 0xFFFA37BF;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
  }

  Future<dynamic> openDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
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
                      child: DeliveryStatusSellerInfo(
                    id: data[index]['id'].toString(),
                    function: exeReSchedule,
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future<void> reSchedule(id, estado) async {
    var fecha = await OpenCalendar();
    print(fecha);

    confirmDialog(id, estado, fecha);
  }

  confirmDialog(id, estado, fecha) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Establece el fondo transparente

          child: Container(
            width: 400.0, // Ancho deseado para el AlertDialog
            height: 300.0,
            child: AlertDialog(
              title: Text('Ateneción'),
              content: Column(
                children: [
                  Text('Se reagendará esta entrega para $fecha'),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Continuar'),
                  onPressed: () async {
                    await Connections()
                        .updateDateDeliveryAndState(id, fecha, estado);
                    loadData();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // calculateValues() {
  //   totalValoresRecibidos = 0;
  //   costoTransportadora = 0;

  //   for (var element in allData) {
  //     element['attributes']['transportadora']['Costo_Transportadora'] != null
  //         ? element['attributes']['transportadora']['Costo_Transportadora']
  //             .replaceAll(',', '.')
  //         : 0;

  //     if (element['attributes']['Status'] == 'ENTREGADO') {
  //       if (element['attributes']['PrecioTotal'].toString().contains(',')) {
  //         element['attributes']['PrecioTotal'] = element['attributes']
  //                 ['PrecioTotal']
  //             .toString()
  //             .replaceAll(',', '.');
  //       }
  //       totalValoresRecibidos +=
  //           double.parse(element['attributes']['PrecioTotal']);
  //     }

  //     if (element['attributes']['Status'] == 'ENTREGADO' ||
  //         element['attributes']['Status'] == 'NO ENTREGADO') {
  //       costoTransportadora += double.parse(element['attributes']
  //               ['transportadora']['Costo_Transportadora'] ??
  //           0);
  //     }
  //   }
  // }

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

                  arrayFiltersAndEq = arrayFiltersAndEq
                      .where((element) => element['filter'] != filter)
                      .toList();

                  // for (Map element in arrayFiltersAndEq) {
                  //   if (element['filter'] == filter) {
                  //     arrayFiltersAndEq.remove(element);
                  //   }
                  // }
                  if (newValue != 'TODO') {
                    reemplazarValor(value, newValue!);
                    //  print(value);

                    arrayFiltersAndEq.add({'filter': filter, 'value': value});
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

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
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

  sortFuncSubRoute() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(a['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(b['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    }
  }
}









// import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:frontend/connections/connections.dart';
// import 'package:frontend/helpers/responsive.dart';
// import 'package:frontend/main.dart';
// import 'package:frontend/ui/operator/orders_operator/info_novedades.dart';
// import 'package:frontend/ui/sellers/delivery_status/info_delivery.dart';
// import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';
// import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
// import 'package:frontend/ui/widgets/OpcionesWidget.dart';
// import 'package:frontend/ui/widgets/box_values.dart';
// import 'package:frontend/ui/widgets/loading.dart';
// import 'package:intl/intl.dart';
// import 'package:number_paginator/number_paginator.dart';

// class DeliveryStatus extends StatefulWidget {
//   const DeliveryStatus({super.key});

//   @override
//   State<DeliveryStatus> createState() => _DeliveryStatusState();
// }

// class _DeliveryStatusState extends State<DeliveryStatus> {
//   final MyOrdersPRVTransportControllers _controllers =
//       MyOrdersPRVTransportControllers();
//   List data = [];
//   List<DateTime?> _dates = [];
//   int currentPage = 1;
//   String currentValue = "";

//   List allData = [];
//   bool sort = false;
//   int pageSize = 70;
//   int pageCount = 100;
//   int total = 0;
//   int entregados = 0;
//   int noEntregados = 0;
//   int conNovedad = 0;
//   int reagendados = 0;
//   int enRuta = 0;
//   double totalValoresRecibidos = 0;
//   double costoDeEntregas = 0;
//   double devoluciones = 0;
//   double utilidad = 0;
//   bool isFirst = true;
//   int counterLoad = 0;
//   var arrayFiltersAndEq = [];
//   var arrayDateRanges = [];
//   Color currentColor = Color.fromARGB(255, 108, 108, 109);

//   NumberPaginatorController paginatorController = NumberPaginatorController();

//   List arrayfiltersDefaultAnd = [
//     {
//       'filter': 'IdComercial',
//       'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
//     }
//   ];
//   bool isLoading = false;

//   var arrayFiltersNotEq = [
//     {'Status': 'PEDIDO PROGRAMADO'}
//   ];
//   List populate = [
//     'transportadora',
//     'users',
//     'users.vendedores',
//     'pedido_fecha',
//     'sub_ruta',
//     'operadore',
//     'operadore.user',
//     'novedades'
//   ];

//   List arrayFitersOrCont = [
//     [
//       {'filter': 'NumeroOrden'},
//       {'filter': 'Fecha_Entrega'},
//       {'filter': 'CiudadShipping'},
//       {'filter': 'NombreShipping'},
//       {'filter': 'DireccionShipping'},
//       {'filter': 'TelefonoShipping'},
//       {'filter': 'Cantidad_Total'},
//       {'filter': 'ProductoP'},
//       {'filter': 'ProductoExtra'},
//       {'filter': 'PrecioTotal'},
//       {'filter': 'Comentario'},
//       {'filter': 'Status'},
//       {'filter': 'Estado_Interno'},
//       {'filter': 'Estado_Logistico'},
//       {'filter': 'Estado_Devolucion'},
//       {'filter': 'Marca_T_I'},
//     ]
//   ];

//   @override
//   void didChangeDependencies() {
//     if (_controllers.startDateController.text == "") {
//       _controllers.startDateController.text = getCurrentDate();
//     }
//     loadData();
//     super.didChangeDependencies();
//   }

//   String getCurrentDate() {
//     DateTime now = DateTime.now();
//     String formattedDate =
//         "${now.day}/${now.month}/20${now.year.toString().substring(2)}";
//     return formattedDate;
//   }

//   loadData() async {
//     var response = [];
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getLoadingModal(context, false);
//     });
//     // arrayFiltersAndEq.add({
//     //   'filter': 'IdComercial',
//     //   'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
//     // });
//     response = await Connections().getOrdersForSellerStateSearchForDate(
//         _controllers.searchController.text,
//         arrayFitersOrCont,
//         arrayFiltersAndEq,
//         arrayDateRanges,
//         arrayFiltersNotEq,
//         arrayfiltersDefaultAnd,
//         [],
//         populate);

//     allData = response;
//     pageCount = calcularTotalPaginas(allData.length, pageSize);

//     // print(sharedPrefs!.getString("idTransportadora").toString());

//     paginate();

//     paginatorController.navigateToPage(0);

//     updateCounters();

//     Future.delayed(Duration(milliseconds: 500), () {
//       Navigator.pop(context);
//     });
//     setState(() {
//       isFirst = false;

//       isLoading = false;
//     });
//   }

//   paginateData() {
//     paginate();
//   }

//   paginate() {
//     if (allData.isNotEmpty) {
//       if (currentPage == pageCount) {
//         data = allData.sublist((pageSize * (currentPage - 1)), allData.length);
//       } else {
//         data = allData.sublist(
//             (pageSize * (currentPage - 1)), (pageSize * currentPage));
//       }
//     } else {
//       data = [];
//     }
//     var res = 1;
//   }

//   int calcularTotalPaginas(int totalRegistros, int registrosPorPagina) {
//     final int totalPaginas = totalRegistros ~/ registrosPorPagina;
//     final int registrosRestantes = totalRegistros % registrosPorPagina;

//     return registrosRestantes > 0
//         ? totalPaginas + 1
//         : totalPaginas == 0
//             ? 1
//             : totalPaginas;
//   }

//   Future loadDataNoCounts(value) async {
//     isLoading = true;
//     setState(() {
//       isFirst = false;
//       arrayFiltersAndEq = [];
//       if (value['titulo'] != "Total") {
//         arrayFiltersAndEq.add({
//           'filter': 'Status',
//           'value': value['titulo'] == 'Programado'
//               ? "PEDIDO PROGRAMADO"
//               : value['titulo']
//         });
//       }
//       currentColor = value['color'] as Color;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getLoadingModal(context, false);
//     });
//     var response = [];
//     var operators = [];
//     currentPage = 1;
//     response = await Connections().getOrdersForSellerStateSearchForDate(
//         _controllers.searchController.text,
//         arrayFitersOrCont,
//         arrayFiltersAndEq,
//         arrayDateRanges,
//         arrayFiltersNotEq,
//         arrayfiltersDefaultAnd,
//         [],
//         populate);

//     allData = response;
//     pageCount = calcularTotalPaginas(allData.length, pageSize);
//     //if (allData.isEmpty) {
//     paginate();
//     //}
//     paginatorController.navigateToPage(0);

//     Future.delayed(Duration(milliseconds: 500), () {
//       Navigator.pop(context);
//     });
//     setState(() {});
//     isFirst = false;
//     isLoading = false;
//   }

//   updateCounters() {
//     total = 0;
//     entregados = 0;
//     noEntregados = 0;
//     conNovedad = 0;
//     reagendados = 0;
//     enRuta = 0;
//     total = allData.length;
//     // print(data.toString());
//     for (var element in allData) {
//       element['attributes']['Status'];
//       switch (element['attributes']['Status']) {
//         case 'ENTREGADO':
//           entregados++;
//           break;

//         case 'NO ENTREGADO':
//           noEntregados++;
//           break;

//         case 'NOVEDAD':
//           conNovedad++;
//           break;
//         case 'REAGENDADO':
//           reagendados++;
//           break;
//         case 'EN RUTA':
//           enRuta++;
//           break;
      

//         default:
//       }
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     List<Opcion> opciones = [
//       Opcion(
//           icono: Icon(Icons.all_inbox),
//           titulo: 'Total',
//           valor: total,
//           color: Color.fromARGB(255, 108, 108, 109)),
//       Opcion(
//           icono: Icon(Icons.send),
//           titulo: 'Entregado',
//           valor: entregados,
//           color: const Color.fromARGB(255, 102, 187, 106)),
//       Opcion(
//           icono: Icon(Icons.error),
//           titulo: 'No Entregado',
//           valor: noEntregados,
//           color: Color.fromARGB(255, 243, 33, 33)),
//       Opcion(
//           icono: Icon(Icons.ac_unit),
//           titulo: 'Novedad',
//           valor: conNovedad,
//           color: const Color.fromARGB(255, 244, 225, 57)),
//       Opcion(
//           icono: Icon(Icons.schedule),
//           titulo: 'Reagendado',
//           valor: reagendados,
//           color: Color.fromARGB(255, 227, 32, 241)),
//       Opcion(
//           icono: Icon(Icons.route),
//           titulo: 'En Ruta',
//           valor: enRuta,
//           color: const Color.fromARGB(255, 33, 150, 243)),
//     ];

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
//         color: Colors.grey[100],
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               color: Colors.white,
//               child: responsive(
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding:
//                                   const EdgeInsets.only(left: 15, right: 5),
//                               child: responsive(
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: fechaFinFechaIni(),
//                                   ),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: fechaFinFechaIni(),
//                                   ),
//                                   context),
//                             ),
//                           ],
//                         ),
//                       ),
//                       boxValues(
//                           totalValoresRecibidos: totalValoresRecibidos,
//                           costoDeEntregas: costoDeEntregas,
//                           devoluciones: devoluciones,
//                           utilidad: utilidad),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.only(left: 15, right: 5),
//                             child: responsive(
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: fechaFinFechaIni(),
//                               ),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: fechaFinFechaIni(),
//                               ),
//                               context,
//                             ),
//                           ),
//                         ],
//                       ),
//                       boxValues(
//                           totalValoresRecibidos: totalValoresRecibidos,
//                           costoDeEntregas: costoDeEntregas,
//                           devoluciones: devoluciones,
//                           utilidad: utilidad),
//                     ],
//                   ),
//                   context),
//             ),
//             responsive(
//                 Container(
//                     height: MediaQuery.of(context).size.height * 0.10,
//                     child: OpcionesWidget(
//                         function: loadDataNoCounts,
//                         opciones: opciones,
//                         currentValue: currentValue)),
//                 Container(
//                     height: MediaQuery.of(context).size.height * 0.16,
//                     child: OpcionesWidget(
//                         function: loadDataNoCounts,
//                         opciones: opciones,
//                         currentValue: currentValue)),
//                 context),
//             const SizedBox(height: 8.0),
//             Container(
//               width: double.infinity,
//               color: currentColor.withOpacity(0.3),
//               padding: EdgeInsets.only(top: 5, bottom: 5),
//               child: responsive(
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _modelTextField(
//                             text: "Buscar",
//                             controller: _controllers.searchController),
//                       ),
//                       // Expanded(
//                       //   child: Row(
//                       //     children: [
//                       //       Container(
//                       //         padding:
//                       //             const EdgeInsets.only(left: 15, right: 5),
//                       //         child: responsive(
//                       //             Row(
//                       //               mainAxisAlignment: MainAxisAlignment.center,
//                       //               children: fechaFinFechaIni(),
//                       //             ),
//                       //             Column(
//                       //               mainAxisAlignment: MainAxisAlignment.center,
//                       //               children: fechaFinFechaIni(),
//                       //             ),
//                       //             context),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                       Expanded(child: numberPaginator()),
//                       // boxValues(
//                       //     totalValoresRecibidos: totalValoresRecibidos,
//                       //     costoDeEntregas: costoDeEntregas,
//                       //     devoluciones: devoluciones,
//                       //     utilidad: utilidad),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                         child: _modelTextField(
//                             text: "Buscar",
//                             controller: _controllers.searchController),
//                       ),
//                       // // Row(
//                       // //   children: [
//                       // //     Container(
//                       // //       padding: const EdgeInsets.only(left: 15, right: 5),
//                       // //       child: responsive(
//                       // //         Row(
//                       // //           mainAxisAlignment: MainAxisAlignment.center,
//                       // //           children: fechaFinFechaIni(),
//                       // //         ),
//                       // //         Column(
//                       // //           mainAxisAlignment: MainAxisAlignment.center,
//                       // //           children: fechaFinFechaIni(),
//                       // //         ),
//                       // //         context,
//                       // //       ),
//                       // //     ),
//                       // //   ],
//                       // ),
//                       // boxValues(
//                       //     totalValoresRecibidos: totalValoresRecibidos,
//                       //     costoDeEntregas: costoDeEntregas,
//                       //     devoluciones: devoluciones,
//                       //     utilidad: utilidad),
//                       numberPaginator()
//                     ],
//                   ),
//                   context),
//             ),
//             Expanded(
//               child: DataTable2(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: const BorderRadius.all(Radius.circular(4)),
//                     border: Border.all(color: Colors.blueGrey),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.grey,
//                         offset: Offset(
//                             0, 2), // Desplazamiento en X e Y de la sombra
//                         blurRadius: 4, // Radio de desenfoque de la sombra
//                         spreadRadius: 1, // Extensión de la sombra
//                       ),
//                     ],
//                   ),
//                   headingRowHeight: 53,
//                   showBottomBorder: true,
//                   headingTextStyle: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.black),
//                   dataTextStyle: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                   columnSpacing: 12,
//                   horizontalMargin: 12,
//                   minWidth: 2500,
//                   columns: [
//                     DataColumn2(
//                       label: Text('Fecha de Entrega'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFuncDate("Fecha_Entrega");
//                       },
//                     ),
//                     DataColumn2(
//                       label: const Text('Código'),
//                       size: ColumnSize.S,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("NumeroOrden");
//                       },
//                     ),
//                     DataColumn2(
//                       label: const Text('Ciudad'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("CiudadShipping");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Nombre Cliente'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("NombreShipping");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Dirección'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("DireccionShipping");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Teléfono Cliente'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("TelefonoShipping");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Cantidad'),
//                       size: ColumnSize.M,
//                       numeric: true,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Cantidad_Total");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Producto'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("ProductoP");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Producto Extra'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("ProductoExtra");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Precio Total'),
//                       size: ColumnSize.M,
//                       numeric: true,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("PrecioTotal");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Comentario'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Comentario");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Status'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Status");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Confirmado'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Estado_Interno");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Estado Logístico'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Estado_Logistico");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Estado Devolución'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFunc("Estado_Devolucion");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Costo Entrega'),
//                       size: ColumnSize.S,
//                       onSort: (columnIndex, ascending) {
//                         //sortFuncCost("CostoEnvio");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Costo Devolución'),
//                       size: ColumnSize.S,
//                       onSort: (columnIndex, ascending) {
//                         // sortFuncCost("CostoDevolucion");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('Fecha Ingreso'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {
//                         sortFuncDate("Marca_T_I");
//                       },
//                     ),
//                     DataColumn2(
//                       label: Text('N. intentos'),
//                       size: ColumnSize.M,
//                       onSort: (columnIndex, ascending) {},
//                     ),
//                   ],
//                   rows: List<DataRow>.generate(
//                       data.isNotEmpty ? data.length : [].length,
//                       (index) => DataRow(cells: [
//                             DataCell(
//                                 Row(
//                                   children: [
//                                     Text(data[index]['attributes']
//                                             ['Fecha_Entrega']
//                                         .toString()),
//                                     data[index]['attributes']['Status'] ==
//                                                 'NOVEDAD' &&
//                                             data[index]['attributes']
//                                                     ['Estado_Devolucion'] ==
//                                                 'PENDIENTE'
//                                         ? IconButton(
//                                             icon: Icon(Icons.schedule_outlined),
//                                             onPressed: () async {
//                                               reSchedule(data[index]['id'],
//                                                   'REAGENDADO');
//                                             },
//                                           )
//                                         : Container(),
//                                   ],
//                                 ), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(
//                                     style: TextStyle(
//                                         color: GetColor(data[index]
//                                                 ['attributes']['Status']
//                                             .toString())!),
//                                     '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}'),
//                                 onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['CiudadShipping']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['NombreShipping']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']
//                                         ['DireccionShipping']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']
//                                         ['TelefonoShipping']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['Cantidad_Total']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['ProductoP']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['ProductoExtra']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['PrecioTotal']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['Comentario']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(
//                                     style: TextStyle(
//                                         color: GetColor(data[index]
//                                                 ['attributes']['Status']
//                                             .toString())!),
//                                     data[index]['attributes']['Status']
//                                         .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['Estado_Interno']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']
//                                         ['Estado_Logistico']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']
//                                         ['Estado_Devolucion']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['users'] != null
//                                     ? data[index]['attributes']['Status']
//                                                     .toString() ==
//                                                 "ENTREGADO" ||
//                                             data[index]['attributes']['Status']
//                                                     .toString() ==
//                                                 "NO ENTREGADO"
//                                         ? data[index]['attributes']['users'][0]
//                                                 ['vendedores'][0]['CostoEnvio']
//                                             .toString()
//                                         : ""
//                                     : ""), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['users'] != null
//                                     ? data[index]['attributes']['Status'].toString() ==
//                                             "NOVEDAD"
//                                         ? data[index]['attributes']['Estado_Devolucion']
//                                                         .toString() ==
//                                                     "ENTREGADO EN OFICINA" ||
//                                                 data[index]['attributes']['Status']
//                                                         .toString() ==
//                                                     "EN RUTA" ||
//                                                 data[index]['attributes'][
//                                                             'Estado_Devolucion']
//                                                         .toString() ==
//                                                     "EN BODEGA"
//                                             ? data[index]['attributes']['users']
//                                                         [0]['vendedores'][0]
//                                                     ['CostoDevolucion']
//                                                 .toString()
//                                             : ""
//                                         : ""
//                                     : ""), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 Text(data[index]['attributes']['Marca_T_I']
//                                     .toString()), onTap: () {
//                               openDialog(context, index);
//                             }),
//                             DataCell(
//                                 getLengthArrayMap(
//                                     data[index]['attributes']['novedades']),
//                                 onTap: () {
//                               openDialog(context, index);
//                             }),
//                           ]))),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   getLengthArrayMap(List data) {
//     var arraylength = data.length;
//     return Text(
//       arraylength.toString(),
//       style: TextStyle(color: arraylength > 3 ? Colors.red : Colors.black),
//     );
//   }

//   Future<dynamic> openDialog(BuildContext context, int index) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             content: Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 children: [
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Icon(Icons.close),
//                     ),
//                   ),
//                   Expanded(
//                       child: DeliveryStatusSellerInfo(
//                     id: data[index]['id'].toString(),
//                     function: exeReSchedule,
//                   ))
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   NumberPaginator numberPaginator() {
//     return NumberPaginator(
//       config: NumberPaginatorUIConfig(
//         buttonUnselectedForegroundColor: Color.fromARGB(255, 67, 67, 67),
//         buttonSelectedBackgroundColor: Color.fromARGB(255, 67, 67, 67),
//         buttonShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5), // Customize the button shape
//         ),
//       ),
//       controller: paginatorController,
//       numberPages: pageCount > 0 ? pageCount : 1,
//       onPageChange: (index) async {
//         setState(() {
//           currentPage = index + 1;
//         });
//         if (!isLoading) {
//           await paginateData();
//         }
//       },
//     );
//   }

//   sortFuncDate(name) {
//     if (sort) {
//       setState(() {
//         sort = false;
//       });
//       data.sort((a, b) {
//         DateTime? dateA = a['attributes'][name] != null &&
//                 a['attributes'][name].toString().isNotEmpty
//             ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
//             : null;
//         DateTime? dateB = b['attributes'][name] != null &&
//                 b['attributes'][name].toString().isNotEmpty
//             ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
//             : null;
//         if (dateA == null && dateB == null) {
//           return 0;
//         } else if (dateA == null) {
//           return 1;
//         } else if (dateB == null) {
//           return -1;
//         } else {
//           return dateB.compareTo(dateA);
//         }
//       });
//     } else {
//       setState(() {
//         sort = true;
//       });
//       data.sort((a, b) {
//         DateTime? dateA = a['attributes'][name] != null &&
//                 a['attributes'][name].toString().isNotEmpty
//             ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
//             : null;
//         DateTime? dateB = b['attributes'][name] != null &&
//                 b['attributes'][name].toString().isNotEmpty
//             ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
//             : null;
//         if (dateA == null && dateB == null) {
//           return 0;
//         } else if (dateA == null) {
//           return -1;
//         } else if (dateB == null) {
//           return 1;
//         } else {
//           return dateA.compareTo(dateB);
//         }
//       });
//     }
//   }

//   _modelTextField({text, controller}) {
//     // setState(() {
//     //   isFirst = true;
//     // });
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Color.fromARGB(255, 245, 244, 244),
//       ),
//       child: TextField(
//         controller: controller,
//         onSubmitted: (value) {
//           arrayFiltersAndEq = [];
//           loadData();
//         },
//         onChanged: (value) {
//           setState(() {});
//         },
//         style: TextStyle(fontWeight: FontWeight.bold),
//         decoration: InputDecoration(
//           fillColor: Colors.grey[500],
//           prefixIcon: Icon(Icons.search),
//           suffixIcon: _controllers.searchController.text.isNotEmpty
//               ? GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _controllers.searchController.clear();
//                     });
//                   },
//                   child: Icon(Icons.close))
//               : null,
//           hintText: text,
//           border: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey),
//           ),
//           focusColor: Colors.black,
//           iconColor: Colors.black,
//         ),
//       ),
//     );
//   }

//   sortFunc(name) {
//     if (sort) {
//       setState(() {
//         sort = false;
//       });
//       data.sort((a, b) => b['attributes'][name]
//           .toString()
//           .compareTo(a['attributes'][name].toString()));
//     } else {
//       setState(() {
//         sort = true;
//       });
//       data.sort((a, b) => a['attributes'][name]
//           .toString()
//           .compareTo(b['attributes'][name].toString()));
//     }
//   }

//   bool compareDates(String string1, String string2) {
//     List<String> parts1 = string1.split('/');
//     List<String> parts2 = string2.split('/');

//     int day1 = int.parse(parts1[0]);
//     int month1 = int.parse(parts1[1]);
//     int year1 = int.parse(parts1[2]);

//     int day2 = int.parse(parts2[0]);
//     int month2 = int.parse(parts2[1]);
//     int year2 = int.parse(parts2[2]);

//     if (year1 > year2) {
//       return true;
//     } else if (year1 < year2) {
//       return false;
//     } else {
//       if (month1 > month2) {
//         return true;
//       } else if (month1 < month2) {
//         return false;
//       } else {
//         if (day1 > day2) {
//           return true;
//         } else {
//           return false;
//         }
//       }
//     }
//   }

//   Color? GetColor(state) {
//     int color = 0xFF000000;

//     switch (state) {
//       case "ENTREGADO":
//         color = 0xFF33FF6D;
//         break;
//       case "NOVEDAD":
//         color = 0xFFD6DC27;
//         break;
//       case "NO ENTREGADO":
//         color = 0xFFFF3333;
//         break;
//       case "REAGENDADO":
//         color = 0xFFFA37BF;
//         break;
//       case "EN RUTA":
//         color = 0xFF3341FF;
//         break;
//       case "EN OFICINA":
//         color = 0xFF4B4C4B;
//         break;

//       default:
//         color = 0xFF000000;
//     }

//     return Color(color);
//   }

//   Future<void> applyDateFilter() async {
//     arrayDateRanges = [];
//     if (_controllers.startDateController.text != '' &&
//         _controllers.endDateController.text != '') {
//       if (compareDates(_controllers.startDateController.text,
//           _controllers.endDateController.text)) {
//         var aux = _controllers.endDateController.text;

//         setState(() {
//           _controllers.endDateController.text =
//               _controllers.startDateController.text;

//           _controllers.startDateController.text = aux;
//         });
//       }
//     }
//     arrayDateRanges.add({
//       'body_param': 'start',
//       'value': _controllers.startDateController.text != ""
//           ? _controllers.startDateController.text
//           : '1/1/1991'
//     });

//     arrayDateRanges.add({
// //        'filter': 'Fecha_Entrega',
//       'body_param': 'end',
//       'value': _controllers.endDateController.text != ""
//           ? _controllers.endDateController.text
//           : '1/1/2200'
//     });
//     isFirst = true;
//     await loadData();
//     calculateValues();
//   }

//   calculateValues() {
//     totalValoresRecibidos = 0;
//     costoDeEntregas = 0;
//     devoluciones = 0;

//     for (var element in data) {
//       if (element['id'] == 567) {
//         print('hello');
//       }
//       var test =
//           element['attributes']['users'][0]['vendedores'][0]['CostoEnvio'];
//       print("aqui esta el test" + test);
//       var m = 2;
//       element['attributes']['PrecioTotal'] =
//           element['attributes']['PrecioTotal'].replaceAll(',', '.');
//       if (element['attributes']['users'][0]['vendedores'][0]['CostoEnvio'] !=
//           null) {
//         element['attributes']['users'][0]['vendedores'][0]['CostoEnvio'] =
//             element['attributes']['users'][0]['vendedores'][0]['CostoEnvio']
//                 .replaceAll(',', '.');
//       } else {
//         element['attributes']['users'][0]['vendedores'][0]['CostoEnvio'] = 0;
//       }

//       if (element['attributes']['users'][0]['vendedores'][0]
//               ['CostoDevolucion'] !=
//           null) {
//         element['attributes']['users'][0]['vendedores'][0]['CostoDevolucion'] =
//             element['attributes']['users'][0]['vendedores'][0]
//                     ['CostoDevolucion']
//                 .replaceAll(',', '.');
//       } else {
//         element['attributes']['users'][0]['vendedores'][0]['CostoDevolucion'] =
//             0;
//       }

//       if (element['attributes']['Status'] == 'ENTREGADO') {
//         totalValoresRecibidos +=
//             double.parse(element['attributes']['PrecioTotal']);
//       }

//       if (element['attributes']['Status'] == 'ENTREGADO' ||
//           element['attributes']['Status'] == 'NO ENTREGADO') {
//         costoDeEntregas += double.parse(element['attributes']['users'][0]
//                 ['vendedores'][0]['CostoEnvio'] ??
//             0);
//       }
//       if (element['attributes']['Status'] == 'NOVEDAD' &&
//           element['attributes']['Estado_Devolucion'] != 'PENDIENTE') {
//         devoluciones += double.parse(element['attributes']['users'][0]
//             ['vendedores'][0]['CostoDevolucion']);
//       }
//     }
//     utilidad = totalValoresRecibidos - costoDeEntregas - devoluciones;
//   }

//   Future<String> OpenCalendar() async {
//     String nuevaFecha = "";

//     var results = await showCalendarDatePicker2Dialog(
//       context: context,
//       config: CalendarDatePicker2WithActionButtonsConfig(
//         dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
//         yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
//         selectedYearTextStyle: TextStyle(fontWeight: FontWeight.bold),
//         weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       dialogSize: const Size(325, 400),
//       value: _dates,
//       borderRadius: BorderRadius.circular(15),
//     );

//     setState(() {
//       if (results != null) {
//         String fechaOriginal = results![0]
//             .toString()
//             .split(" ")[0]
//             .split('-')
//             .reversed
//             .join('-')
//             .replaceAll("-", "/");
//         List<String> componentes = fechaOriginal.split('/');

//         String dia = int.parse(componentes[0]).toString();
//         String mes = int.parse(componentes[1]).toString();
//         String anio = componentes[2];

//         nuevaFecha = "$dia/$mes/$anio";
//       }
//     });
//     return nuevaFecha;
//   }

//   fechaFinFechaIni() {
//     return [
//       Row(
//         children: [
//           Text(_controllers.startDateController.text),
//           IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () async {
//               _controllers.startDateController.text = await OpenCalendar();
//             },
//           ),
//           const Text(' - '),
//           Text(
//             _controllers.endDateController.text,
//           ),
//           IconButton(
//             icon: Icon(Icons.calendar_month),
//             onPressed: () async {
//               _controllers.endDateController.text = await OpenCalendar();
//             },
//           ),
//           ElevatedButton(
//               style: const ButtonStyle(
//                   backgroundColor: MaterialStatePropertyAll(
//                       Color.fromARGB(255, 67, 67, 67))),
//               onPressed: () async {
//                 await applyDateFilter();
//               },
//               child: Text('Filtrar'))
//         ],
//       ),
//     ];
//   }

//   // fechaFinFechaIni() {
//   //   return [
//   //     Row(
//   //       children: [
//   //         const Text('Desde:'),
//   //         Text(_controllers.startDateController.text),
//   //         IconButton(
//   //           icon: const Icon(Icons.calendar_month),
//   //           onPressed: () async {
//   //             _controllers.startDateController.text = await OpenCalendar();
//   //           },
//   //         ),
//   //         const SizedBox(
//   //           width: 5,
//   //         ),
//   //         const Text('Hasta:'),
//   //         Text(
//   //           _controllers.endDateController.text,
//   //         ),
//   //         IconButton(
//   //           icon: Icon(Icons.calendar_month),
//   //           onPressed: () async {
//   //             _controllers.endDateController.text = await OpenCalendar();
//   //           },
//   //         ),
//   //       ],
//   //     ),
//   //     ElevatedButton(
//   //         style: const ButtonStyle(
//   //             backgroundColor:
//   //                 MaterialStatePropertyAll(Color.fromARGB(255, 67, 67, 67))),
//   //         onPressed: () async {
//   //           await applyDateFilter();
//   //         },
//   //         child: Text('Filtrar'))
//   //   ];
//   // }

//   exeReSchedule(value) {
//     reSchedule(value['id'], value['status']);
//   }

//   Future<void> reSchedule(id, estado) async {
//     var fecha = await OpenCalendar();
//     print(fecha);

//     confirmDialog(id, estado, fecha);
//   }

//   confirmDialog(id, estado, fecha) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor:
//               Colors.transparent, // Establece el fondo transparente

//           child: Container(
//             width: 400.0, // Ancho deseado para el AlertDialog
//             height: 300.0,
//             child: AlertDialog(
//               title: Text('Ateneción'),
//               content: Column(
//                 children: [
//                   Text('Se reagendará esta entrega para $fecha'),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text('Cancelar'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 TextButton(
//                   child: Text('Continuar'),
//                   onPressed: () async {
//                     await Connections()
//                         .updateDateDeliveryAndState(id, fecha, estado);
//                     loadData();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
