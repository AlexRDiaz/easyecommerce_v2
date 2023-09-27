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
import '../../widgets/show_error_snackbar.dart';

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
  int totallast = 0;
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
  var sortFieldDefaultValue = "id:DESC";
  Color currentColor = Color.fromARGB(255, 108, 108, 109);
  List<Map<dynamic, dynamic>> arrayFiltersAndEq = [];
  var arrayDateRanges = [];
  TextEditingController operadorController =
      TextEditingController(text: "TODO");

  TextEditingController fechaEntregaController =
      TextEditingController(text: "");
  TextEditingController codigoController = TextEditingController(text: "");
  TextEditingController ciudadShippingController =
      TextEditingController(text: "");
  TextEditingController nombreShippingController =
      TextEditingController(text: "");
  TextEditingController direccionShippingController =
      TextEditingController(text: "");
  TextEditingController telefonoShippingController =
      TextEditingController(text: "");
  TextEditingController cantidadTotalController =
      TextEditingController(text: "");
  TextEditingController productoPController = TextEditingController(text: "");
  TextEditingController productoExtraController =
      TextEditingController(text: "");
  TextEditingController precioTotalController = TextEditingController(text: "");
  TextEditingController comentarioController = TextEditingController(text: "");
  TextEditingController marcaTiController = TextEditingController(text: "");
  TextEditingController statusController = TextEditingController(text: "TODO");
  TextEditingController estadoInternoController =
      TextEditingController(text: "TODO");
  TextEditingController estadoLogisticoController =
      TextEditingController(text: "TODO");
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");
  TextEditingController costoEntregaController =
      TextEditingController(text: "");
  TextEditingController costoDevolucionController =
      TextEditingController(text: "");
  bool changevalue = false;

  var arrayfiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    }
  ];

  List arrayFiltersNotEq = [
    //{'status': 'PEDIDO PROGRAMADO'}
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
    'fecha_entrega',
    'numero_orden',
    'nombre_shipping',
    'ciudad_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    'precio_total',
    'observacion',
    'comentario',
    'status',
    'tipo_pago',
    'marca_t_d',
    'marca_t_d_l',
    'marca_t_d_t',
    'marca_t_i',
    'estado_pagado',
  ];

  List<String> listStatus = [
    'TODO',
    'PEDIDO PROGRAMADO',
    'NOVEDAD',
    'ENTREGADO',
    'NO ENTREGADO',
    'REAGENDADO',
    'EN OFICINA',
    'EN RUTA'
  ];

  List<String> listEstadoInterno = [
    'TODO',
    'CONFIRMADO',
    'PENDIENTE',
    'NO DESEA',
  ];

  List<String> listEstadoLogistico = [
    'TODO',
    'PENDIENTE',
    'ENVIADO',
    'IMPRESO',
  ];

  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'DEVOLUCION EN RUTA',
    'EN BODEGA',
    'ENTREGADO EN OFICINA'
  ];

  List arrayFiltersAnd = [];
  List arrayFiltersAnd2 = [];

  NumberPaginatorController paginatorController = NumberPaginatorController();

  @override
  void didChangeDependencies() {
    initializeDates();

    loadData();
    super.didChangeDependencies();
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var responseCounters = await Connections().getOrdersCountersSeller(
          populate, arrayfiltersDefaultAnd, [], arrayFiltersNotEq);

      // var responseValues = await Connections().getValuesSeller(populate, [
      //   {
      //     "transportadora": {"\$not": null}
      //   },
      //   {
      //     'IdComercial':
      //         sharedPrefs!.getString("idComercialMasterSeller").toString()
      //   }
      // ]);

      var responseValues =
          await Connections().getValuesSellerLaravel(arrayfiltersDefaultAnd);

      var responseLaravel = await Connections()
          .getOrdersForSellerStateSearchForDateSellerLaravel(
              _controllers.searchController.text,
              filtersOrCont,
              arrayfiltersDefaultAnd,
              arrayFiltersAnd,
              currentPage,
              pageSize,
              _controllers.searchController.text,
              arrayFiltersNotEq,
              sortFieldDefaultValue);

      dataCounters = responseCounters;
      valuesTransporter = responseValues['data'];
      data = responseLaravel['data'];

      // totallast = responseLaravel['total'];
      totallast = dataCounters['TOTAL'];
      pageCount = responseLaravel['last_page'];

      paginatorController.navigateToPage(0);

      updateCounters();
      calculateValues();

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      print("datos cargados correctamente");
      setState(() {
        isFirst = false;

        isLoading = false;
        if (sortFieldDefaultValue.toString() == "marca_tiempo_envio:DESC") {
          totallast = dataCounters['TOTAL'];
        }
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
    print("datos inicializados correctamente");
  }

  paginateData() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var response = await Connections()
          .getOrdersForSellerStateSearchForDateSellerLaravel(
              _controllers.searchController.text,
              filtersOrCont,
              arrayfiltersDefaultAnd,
              arrayFiltersAnd,
              currentPage,
              pageSize,
              _controllers.searchController.text,
              arrayFiltersNotEq,
              sortFieldDefaultValue.toString());

      setState(() {
        data = response['data'];
        pageCount = response['last_page'];
        //paginatorController.navigateToPage(0);
      });

      Future.delayed(Duration(milliseconds: 500), () {
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
    //unit packages
    List<Opcion> opciones = [
      Opcion(
          icono: Icon(Icons.all_inbox),
          titulo: 'Total',
          filtro: 'Total',
          valor: totallast,
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
      Opcion(
          icono: Icon(Icons.event),
          // titulo: 'Pedido Programado',
          titulo: 'Programado',
          filtro: 'PEDIDO PROGRAMADO',
          valor: programado,
          color: const Color(0xFF7E84F2)),
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
                      Container(
                        padding: EdgeInsets.all(10),
                        child: boxValues(
                            totalValoresRecibidos: totalValoresRecibidos,
                            costoDeEntregas: costoDeEntregas,
                            devoluciones: devoluciones,
                            utilidad: utilidad),
                      ),
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
              padding: EdgeInsets.all(10),
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                      SizedBox(width: 10),
                      Tooltip(
                        message: 'Limpiar filtros',
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            resetFilters();
                            paginatorController.navigateToPage(0);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_alt_outlined),
                              Icon(Icons.clear_outlined),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 245, 88, 76),
                          ),
                        ),
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
                  headingRowHeight: 63,
                  showBottomBorder: true,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 4500,
                  columns: [
                    // const DataColumn2(

                    //     label: Text(""), size: ColumnSize.S, fixedWidth: 20),
                    DataColumn2(
                      label: InputFilter(
                          'Fecha', fechaEntregaController, 'fecha_entrega'),
                      //label: Text('Fecha de Entrega'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc2("fecha_entrega", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Código', codigoController, 'numero_orden'),
                      //label: const Text('Código'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Ciudad', ciudadShippingController,
                          'ciudad_shipping'),
                      //label: const Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("CiudadShipping");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Nombre Cliente',
                          nombreShippingController, 'nombre_shipping'),
                      //label: Text('Nombre Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("NombreShipping");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Dirección',
                          direccionShippingController, 'direccion_shipping'),
                      //label: Text('Dirección'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Teléfono Cliente',
                          telefonoShippingController, 'telefono_shipping'),
                      //label: Text('Teléfono Cliente'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Cantidad', cantidadTotalController,
                          'cantidad_total'),
                      //label: Text('Cantidad'),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Cantidad_Total");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Producto', productoPController, 'producto_p'),
                      // label: Text('Producto'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("ProductoP");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Producto Extra',
                          productoExtraController, 'producto_extra'),
                      // label: Text('Producto Extra'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("ProductoExtra");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter('Precio Total', precioTotalController,
                          'precio_total'),
                      //label: Text('Precio Total'),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("PrecioTotal");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Comentario', comentarioController, 'comentario'),
                      // label: Text('Comentario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Comentario");
                      },
                    ),
                    DataColumn2(
                      label: SelectFilter2('Estado de Entrega', 'status',
                          statusController, listStatus),
                      // label: Text('Status'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: SelectFilter2('Confirmado', 'estado_interno',
                          estadoInternoController, listEstadoInterno),
                      //label: Text('Confirmado'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Estado_Interno");
                      },
                    ),
                    DataColumn2(
                      label: SelectFilter2(
                          'Estado Logístico',
                          'estado_logistico',
                          estadoLogisticoController,
                          listEstadoLogistico),
                      //label: Text('Estado Logístico'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Estado_Logistico");
                      },
                    ),
                    DataColumn2(
                      label: SelectFilter2(
                          'Estado Devolución',
                          'estado_devolucion',
                          estadoDevolucionController,
                          listEstadoDevolucion),
                      //label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Costo Entrega',
                          costoEntregaController,
                          'users.vendedores.costo_envio'),
                      // label: Text('Costo Entrega'),  //costo_envio
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFuncCost("CostoEnvio");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Costo Devolución',
                          costoDevolucionController,
                          'users.vendedores.costo_devolucion'),
                      // label: Text('Costo Devolución'), //costo_devolucion
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFuncCost("CostoDevolucion");
                      },
                    ),
                    DataColumn2(
                      label: InputFilter(
                          'Fecha Ingreso', marcaTiController, 'marca_t_i'),
                      //label: Text('Fecha Ingreso'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFuncDate("Marca_T_I");
                      },
                    ),
                    DataColumn2(
                      label: const Text('N. intentos'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {},
                    ),
                    DataColumn2(
                      label: Text('Transportadora'),
                      size: ColumnSize.M,
                    ),
                  ],
                  border: const TableBorder(
                    top: BorderSide(color: Colors.grey),
                    horizontalInside: BorderSide(color: Colors.grey),
                    verticalInside: BorderSide(color: Colors.grey),
                  ),
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            // DataCell(

                            //  Text(
                            //             style:
                            //                 const TextStyle(color: Colors.blue),
                            //             '${(index * currentPage) + 1}'),
                            //     onTap: () {
                            //   openDialog(context, index);
                            // }),
                            DataCell(
                                Row(
                                  children: [
                                    Text(data[index]['fecha_entrega']
                                        .toString()),
                                    data[index]['status'] == 'NOVEDAD' &&
                                            data[index]['estado_devolucion'] ==
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
                                        color: GetColor(
                                            data[index]['status'].toString())!),
                                    '${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}'),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['ciudad_shipping'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['nombre_shipping'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['direccion_shipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['telefono_shipping']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['cantidad_total'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(Text(data[index]['producto_p'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['producto_extra'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['precio_total'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['comentario'] == null ||
                                        data[index]['comentario'] == "null"
                                    ? ""
                                    : data[index]['comentario'].toString()),
                                // Text(data[index]['comentario'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(
                                            data[index]['status'].toString())!),
                                    data[index]['status'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['estado_interno'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(
                                    data[index]['estado_logistico'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['estado_devolucion']
                                    .toString()), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['users'] != null
                                    ? data[index]['status'].toString() ==
                                                "ENTREGADO" ||
                                            data[index]['status'].toString() ==
                                                "NO ENTREGADO"
                                        ? data[index]['users'][0]['vendedores']
                                                [0]['costo_envio']
                                            .toString()
                                        : ""
                                    : ""), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['users'] != null
                                    ? data[index]['status'].toString() ==
                                            "NOVEDAD"
                                        ? data[index]['estado_devolucion']
                                                        .toString() ==
                                                    "ENTREGADO EN OFICINA" ||
                                                data[index]['status']
                                                        .toString() ==
                                                    "EN RUTA" ||
                                                data[index]['estado_devolucion']
                                                        .toString() ==
                                                    "EN BODEGA"
                                            ? data[index]['users'][0]
                                                        ['vendedores'][0]
                                                    ['costo_devolucion']
                                                .toString()
                                            : ""
                                        : ""
                                    : ""), onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(Text(data[index]['marca_t_i'].toString()),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                getLengthArrayMap(data[index]['novedades']),
                                onTap: () {
                              openDialog(context, index);
                            }),
                            DataCell(
                                Text(data[index]['transportadora'] != null &&
                                        data[index]['transportadora'].isNotEmpty
                                    ? data[index]['transportadora'][0]['nombre']
                                        .toString()
                                    : ''), onTap: () {
                              openDialog(context, index);
                            }),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  Column InputFilter(String title, var controller, key) {
    return Column(
      children: [
        Text(title),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: TextField(
            controller: controller,
            onChanged: (value) {
              if (value == '') {
                {
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(key));
                }
              }
            },
            onSubmitted: (value) {
              if (value != '') {
                arrayFiltersAnd.add({key: value});
              }

              paginatorController.navigateToPage(0);
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            )),
          ),
        ))
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

  void resetFilters() {
    getOldValue(true);

    fechaEntregaController.clear();
    codigoController.clear();
    ciudadShippingController.clear();
    nombreShippingController.clear();
    direccionShippingController.clear();
    telefonoShippingController.clear();
    cantidadTotalController.clear();
    productoPController.clear();
    productoExtraController.clear();
    precioTotalController.clear();
    comentarioController.clear();
    costoEntregaController.clear();
    costoDevolucionController.clear();
    statusController.text = "TODO";
    estadoInternoController.text = "TODO";
    estadoLogisticoController.text = "TODO";
    estadoDevolucionController.text = "TODO";
    arrayFiltersAnd = [];
    _controllers.searchController.text = "";

    // paginatorController.navigateToPage(0);
  }

//money
  calculateValues() {
    totalValoresRecibidos = 0;
    costoDeEntregas = 0;
    devoluciones = 0;

    setState(() {
      totalValoresRecibidos =
          double.parse(valuesTransporter['totalValoresRecibidos'].toString());
      costoDeEntregas =
          double.parse(valuesTransporter['totalShippingCost'].toString());
      devoluciones =
          double.parse(valuesTransporter['totalCostoDevolucion'].toString());
      utilidad = (valuesTransporter['totalValoresRecibidos']) -
          (valuesTransporter['totalShippingCost'] +
              valuesTransporter['totalCostoDevolucion']);
      utilidad = double.parse(utilidad.toString());
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
    resetFilters();

    arrayFiltersAnd.removeWhere((element) => element.containsKey("status"));
    if (value["filtro"] != "Total") {
      arrayFiltersAnd.add({"status": value["filtro"]});
    }

    setState(() {
      currentColor = value['color'];
    });

    paginatorController.navigateToPage(0);
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
          paginatorController.navigateToPage(0);
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
    resetFilters();
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
    programado = 0;

    setState(() {
      entregados = int.parse(dataCounters['ENTREGADO'].toString()) ?? 0;
      noEntregados = int.parse(dataCounters['NO ENTREGADO'].toString()) ?? 0;
      conNovedad = int.parse(dataCounters['NOVEDAD'].toString()) ?? 0;
      reagendados = int.parse(dataCounters['REAGENDADO'].toString()) ?? 0;
      enRuta = int.parse(dataCounters['EN RUTA'].toString()) ?? 0;
      programado = int.parse(dataCounters['PEDIDO PROGRAMADO'].toString()) ?? 0;
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
        color = 0xFF66BB6A;
        break;
      case "NOVEDAD":
        color = 0xFFD6DC27;
        break;
      case "NO ENTREGADO":
        color = 0xFFF32121;
        break;
      case "REAGENDADO":
        color = 0xFFE320F1;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;
      case "PEDIDO PROGRAMADO":
        color = 0xFF7E84F2;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
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
                  // Expanded(
                  //     child: DeliveryStatusSellerInfo(
                  //   id: data[index]['id'].toString(),
                  //   function: exeReSchedule,
                  // ))
                  Expanded(
                      child: DeliveryStatusSellerInfo(
                          id: data[index]['id'].toString(),
                          function: exeReSchedule,
                          data: data))
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
                        .updateDateDeliveryAndStateLaravel(id, fecha, estado);
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
}
