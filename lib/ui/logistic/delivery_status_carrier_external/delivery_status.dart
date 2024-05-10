import 'dart:convert';
import 'dart:js_util';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/delivery_status_provider/DeliveryStatusSellerInfo.dart';
import 'package:frontend/ui/provider/delivery_status_provider/create_report.dart';
// import 'package:frontend/ui/sellers/delivery_status/DeliveryStatusSellerInfo.dart';
import 'package:frontend/ui/sellers/delivery_status/create_report.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/OptionsWidget.dart';
import 'package:frontend/ui/transport/delivery_status_transport/delivery_details.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/box_values.dart';
import 'package:frontend/ui/widgets/box_values_external_carrier.dart';
import 'package:frontend/ui/widgets/box_values_provider.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/show_error_snackbar.dart';

class DeliveryStatusExternalCarrier extends StatefulWidget {
  const DeliveryStatusExternalCarrier({super.key});

  @override
  State<DeliveryStatusExternalCarrier> createState() =>
      _DeliveryStatusExternalCarrierState();
}

class _DeliveryStatusExternalCarrierState
    extends State<DeliveryStatusExternalCarrier> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();

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
  int novedadResuelta = 0;
  int reagendados = 0;
  int enRuta = 0;
  int programado = 0;
  int enOficina = 0;
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
  TextEditingController carrierExternalController =
      TextEditingController(text: "TODO");
  TextEditingController costoEntregaController =
      TextEditingController(text: "");
  TextEditingController costoDevolucionController =
      TextEditingController(text: "");
  bool changevalue = false;

  String selectedDateFilter = "FECHA ENTREGA";
  String selectedExt = "Gintracom-1";
  // ! estos 3 se usan para el dorpdown de transportadoras externas
  List<String> transportator = ["TODO"];
  // String? selectedValueTransportator;
  List transportatorList = [];
  // ! ************************************************************

  var arrayfiltersDefaultAnd = [
    // {
    //   'product.warehouse.provider.id':
    //       sharedPrefs!.getString("idProvider").toString(),
    // },
    {'estado_interno': "CONFIRMADO"},
    {'estado_logistico': "ENVIADO"}
  ];

  List arrayFiltersNotEq = [
    //{'status': 'PEDIDO PROGRAMADO'}
    {'carrier_external_id': ""}
  ];
  List populateC = [
    'transportadora',
    'users',
    'users.vendedores',
    'pedido_fecha',
    'sub_ruta',
    'operadore',
    'operadore.user',
    'novedades',
    'product.warehouse.provider',
    'carrierExternal'
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
    'value_product_warehouse',
    'carrier_external_id'
  ];

  List<String> listStatus = [
    'TODO',
    'PEDIDO PROGRAMADO',
    'NOVEDAD',
    'NOVEDAD RESUELTA',
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

  List<String> listDateFilter = [
    'FECHA ENVIO',
    'FECHA ENTREGA',
    'FECHA DEVOLUCION'
  ];

  List<String> listExt = ['Gintracom-1'];

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
    'ENTREGADO EN OFICINA',
    'EN BODEGA PROVEEDOR',
  ];

  List arrayFiltersAnd = [];
  List arrayFiltersAnd2 = [];

  NumberPaginatorController paginatorController = NumberPaginatorController();
  var getReport = CreateReportProvider();
  List selectedStatus = [];
  List selectedInternal = [];
  List<String> selectedChips = [];
  List populate = [
    'operadore.up_users',
    'transportadora',
    'users.vendedores',
    'novedades',
    'pedidoFecha',
    'ruta',
    'subRuta',
    'product.warehouse.provider',
    'carrierExternal'
  ];
  //        $pedidos = PedidosShopify::with(['operadore.up_users', 'transportadora', 'users.vendedores', 'novedades', 'pedidoFecha', 'ruta', 'subRuta'])

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
    try {
      setState(() {
        isLoading = true;
      });

      var responseCounters = await Connections().getOrdersCountersSeller(
          populateC,
          arrayfiltersDefaultAnd,
          [],
          arrayFiltersNotEq,
          selectedDateFilter);

      // var responseValues = await Connections()
      //     .getValuesProviderLaravel(arrayfiltersDefaultAnd, selectedDateFilter);

      var responseValues = await Connections().getValuesExternalCarrierLaravel(
          arrayfiltersDefaultAnd,
          selectedDateFilter,
          selectedExt.split('-')[1]);

      print("ak-> $responseValues");
      var responsetransportadoras =
          await Connections().getCarrierExternalActive();
      // ! *********************************
      transportatorList = responsetransportadoras['transportadoras'];
      if (transportator.length == 1) {
        for (var i = 0; i < transportatorList.length; i++) {
          setState(() {
            if (transportatorList != []) {
              transportator.add('${transportatorList[i]}');
            }
          });
        }
      }

      // ! *********************************

      var responseLaravel = await Connections()
          .getOrdersForSellerStateSearchForDateSellerLaravel(
              populate,
              selectedDateFilter,
              _controllers.searchController.text,
              filtersOrCont,
              arrayfiltersDefaultAnd,
              arrayFiltersAnd,
              currentPage,
              pageSize,
              _controllers.searchController.text,
              arrayFiltersNotEq,
              sortFieldDefaultValue);
      // print("data> $responseLaravel");
      dataCounters = responseCounters;
      valuesTransporter = responseValues['data'];
      data = responseLaravel['data'];

      // totallast = responseLaravel['total'];
      totallast = dataCounters['TOTAL'];
      pageCount = responseLaravel['last_page'];

      paginatorController.navigateToPage(0);

      updateCounters();
      calculateValues();

      print("datos cargados correctamente");

      isFirst = false;

      if (sortFieldDefaultValue.toString() == "marca_tiempo_envio:DESC") {
        totallast = dataCounters['TOTAL'];
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
    try {
      setState(() {
        isLoading = true;
      });
      var response = await Connections()
          .getOrdersForSellerStateSearchForDateSellerLaravel(
              populate,
              selectedDateFilter,
              _controllers.searchController.text,
              filtersOrCont,
              arrayfiltersDefaultAnd,
              arrayFiltersAnd,
              currentPage,
              pageSize,
              _controllers.searchController.text,
              arrayFiltersNotEq,
              sortFieldDefaultValue.toString());

      data = response['data'];
      pageCount = response['last_page'];
      //paginatorController.navigateToPage(0);
      // print("T -> ${response['total']}");

      setState(() {
        isFirst = false;
        isLoading = false;
      });
      print("datos paginados");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  void generateReport(status, internal) async {
    List allData = [];

    if (!isLoading) {
      await applyDateFilter();
    }

    List DefaultAnd = [
      // {
      //   'id_comercial':
      //       sharedPrefs!.getString("idComercialMasterSeller").toString()
      // },
      // {
      //   'product.warehouse.provider.id':
      //       sharedPrefs!.getString("idProvider").toString(),
      // },
      {'estado_interno': "CONFIRMADO"},
      {'estado_logistico': "ENVIADO"}
    ];
    var responseAll = await Connections()
        .getAllOrdersByDateRangeLaravel(DefaultAnd, status, internal);

    allData = responseAll;

    if (allData.isNotEmpty) {
      getReport.generateExcelFileWithDataProvider(allData);
    } else {
      print("No existen datos con este filtro");
      showSuccessModal(context,
          "No existen datos con los filtros seleccionados.", Icons8.warning_1);
    }

    //
  }

  List<int> selectedIds = [];

  void toggleSelection(int id, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedIds.add(id);
      } else {
        selectedIds.remove(id);
      }
    });
  }

  Future<void> sendSelectedIds() async {
    await Connections().updatePaymentCostDelivery(selectedIds, true);
    selectedIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    //unit packages
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
          icono: Icon(Icons.done_all),
          titulo: 'Novedad Resuelta',
          filtro: 'Novedad Resuelta',
          valor: novedadResuelta,
          color: Color.fromARGB(255, 244, 132, 57)),
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
      Opcion(
          icono: Icon(Icons.warehouse),
          // titulo: 'Pedido Programado',
          titulo: 'En oficina',
          filtro: 'EN OFICINA',
          valor: enOficina,
          color: const Color(0xFF4B4C4B)),
    ];

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            color: Colors.grey[100],
            child:
                ListView(padding: const EdgeInsets.all(8), children: <Widget>[
              Container(
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 5),
                                      child: responsive(
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: fechaFinFechaIni(),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: fechaFinFechaIni(),
                                          ),
                                          context),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: boxValuesExternalCarrier(
                                    totalValoresRecibidos:
                                        totalValoresRecibidos,
                                    costoEntrega: costoDeEntregas,
                                    costoDevolucion: devoluciones),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 5),
                                    child: responsive(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: fechaFinFechaIni(),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: fechaFinFechaIni(),
                                      ),
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: boxValuesExternalCarrier(
                                    totalValoresRecibidos:
                                        totalValoresRecibidos,
                                    costoEntrega: costoDeEntregas,
                                    costoDevolucion: devoluciones),
                              ),
                            ],
                          ),
                          context),
                    ),
                    //
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
                    // Row(children: [Text("Marcar como pagado: XXX ")]),
                    Container(
                      width: double.infinity,
                      color: currentColor.withOpacity(0.3),
                      padding: EdgeInsets.all(2),
                      child: responsive(
                          Row(
                            children: [
                              Container(
                                width: 300,
                                child: _modelTextField(
                                    text: "Buscar",
                                    controller: _controllers.searchController),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (selectedIds.isNotEmpty) {
                                    sendSelectedIds();
                                    loadData();
                                  } else {
                                    AwesomeDialog(
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Error',
                                      desc:
                                          'Debe seleccionar Pedidos Previamente',
                                      btnOkText: "Aceptar",
                                      btnOkColor: colors.colorGreen,
                                      btnOkOnPress: () {},
                                    ).show();
                                  }

                                  // resetFilters();
                                  // paginatorController.navigateToPage(0);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorsSystem().colorSelectMenu,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Marcar como Pagado ',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(' : (${selectedIds.length})'),
                              const SizedBox(width: 20),
                              Tooltip(
                                message: 'Limpiar filtros',
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    resetFilters();
                                    paginatorController.navigateToPage(0);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.filter_list_off),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50),
                              Expanded(child: numberPaginator()),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        _modelTextField(
                                            text: "Buscar",
                                            controller:
                                                _controllers.searchController),
                                      ]))
                                ]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message: 'Limpiar filtros',
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                resetFilters();
                                                paginatorController
                                                    .navigateToPage(0);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.filter_list_off),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              numberPaginator()
                            ],
                          ),
                          context),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height * 0.58,
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
                            return Colors.blue.withOpacity(
                                0.5); // Color para fila seleccionada
                          } else if (states.contains(MaterialState.hovered)) {
                            return const Color.fromARGB(255, 234, 241, 251);
                          }
                          return const Color.fromARGB(0, 173, 233, 231);
                        }),
                        headingTextStyle:
                            Theme.of(context).textTheme.bodyMedium,
                        dataTextStyle: Theme.of(context).textTheme.bodySmall,
                        columnSpacing: 12,
                        headingRowHeight: 80,
                        horizontalMargin: 12,
                        minWidth: 4500,
                        columns: [
                          DataColumn2(
                            label: InputFilter('Fecha Entrega',
                                fechaEntregaController, 'fecha_entrega'),
                            //label: Text('Fecha de Entrega'),
                            size: ColumnSize.S,
                            onSort: (columnIndex, ascending) {
                              sortFunc2("fecha_entrega", changevalue);
                            },
                          ),
                          DataColumn2(
                            label: Text('Pago Costo Entrega'),
                            //label: Text('Fecha de Entrega'),
                            size: ColumnSize.S,
                            onSort: (columnIndex, ascending) {
                              // sortFunc2("fecha_entrega", changevalue);
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
                            label: InputFilter('Ciudad',
                                ciudadShippingController, 'ciudad_shipping'),
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
                            label: InputFilter('Cantidad',
                                cantidadTotalController, 'cantidad_total'),
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
                            label: InputFilter('Precio Total',
                                precioTotalController, 'precio_total'),
                            //label: Text('Precio Total'),
                            size: ColumnSize.S,
                            numeric: true,
                            onSort: (columnIndex, ascending) {
                              // sortFunc("PrecioTotal");
                            },
                          ),
                          DataColumn2(
                            label: InputFilter('Comentario',
                                comentarioController, 'comentario'),
                            // label: Text('Comentario'),
                            size: ColumnSize.M,
                            onSort: (columnIndex, ascending) {
                              // sortFunc("Comentario");
                            },
                          ),
                          DataColumn2(
                            // label: InputFilter('Comentario Novedad',
                            //     comentarioController, 'comentario'),
                            label: Text('Comentario Novedad'),
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
                            label: InputFilter('Costo Proveedor',
                                marcaTiController, 'value_product_warehouse'),
                            //label: Text('Fecha Ingreso'),
                            size: ColumnSize.M,
                            onSort: (columnIndex, ascending) {
                              // sortFuncDate("Marca_T_I");
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
                                'Fecha Envío', marcaTiController, 'sent_at'),
                            //label: Text('Fecha Ingreso'),
                            size: ColumnSize.S,
                            onSort: (columnIndex, ascending) {
                              // sortFuncDate("Marca_T_I");
                            },
                          ),
                          // const DataColumn2(
                          //   label: Text('Transportadora'),
                          //   size: ColumnSize.M,
                          // ),
                          DataColumn2(
                            label: SelectFilter(
                                'Transportadora Externa',
                                'carrier_external_id',
                                carrierExternalController,
                                transportator),
                            // label: Text('Status'),
                            size: ColumnSize.M,
                            onSort: (columnIndex, ascending) {
                              // sortFunc("Status");
                            },
                          ),

                          const DataColumn2(
                            label: Text('Costo Envío'),
                            size: ColumnSize.M,
                          ),
                          const DataColumn2(
                            label: Text('Costo Devolución'),
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
                          (index) => DataRow(
                            cells: [
                              DataCell(
                                  Text(data[index]['fecha_entrega'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                data[index]['payment_cost_delivery'] == 0
                                    ? Checkbox(
                                        value: selectedIds
                                            .contains(data[index]['id']),
                                        onChanged: (bool? newValue) {
                                          toggleSelection(data[index]['id'],
                                              newValue ?? false);
                                        },
                                      )
                                    : GestureDetector(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('OK'),
                                            SizedBox(width: 8),
                                            Icon(Icons.sync,
                                                color: Colors.blue),
                                          ],
                                        ),
                                        onTap: () async {
                                          // print(
                                          // 'Cambiar estado para ID: ${data[index]['id']}');
                                          await Connections()
                                              .updatePaymentCostDeliveryInd(
                                                  data[index]['id']);
                                          loadData();
                                        },
                                      ),
                              ),
                              DataCell(
                                  Text(
                                      style: TextStyle(
                                          color: GetColor(data[index]['status']
                                              .toString())!),
                                      '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}'),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['ciudad_shipping']
                                      .toString()), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['nombre_shipping']
                                      .toString()), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['cantidad_total'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['producto_p'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['producto_extra'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['precio_total'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['comentario'] == null ||
                                          data[index]['comentario'] == "null"
                                      ? ""
                                      : data[index]['comentario'].toString()),
                                  // Text(data[index]['comentario'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(
                                    getStateFromJson(
                                        data[index]['gestioned_novelty']
                                            ?.toString(),
                                        'comment'),
                                  ), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(
                                      style: TextStyle(
                                          color: GetColor(data[index]['status']
                                              .toString())!),
                                      data[index]['status'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['estado_interno'].toString()),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['estado_logistico']
                                      .toString()), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['value_product_warehouse'] !=
                                          null
                                      ? data[index]['value_product_warehouse']
                                          .toString()
                                      : ""), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['estado_devolucion']
                                      .toString()), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['sent_at'] == null
                                      ? ""
                                      : UIUtils.formatDate(
                                          data[index]['sent_at'].toString())),
                                  onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  // Text(data[index]['transportadora'] != null &&
                                  //         data[index]['transportadora']
                                  //             .isNotEmpty
                                  //     ? data[index]['transportadora'][0]
                                  //             ['nombre']
                                  //         .toString()
                                  //     : '')
                                  Text(data[index]["carrier_external"] != null
                                      ? data[index]["carrier_external"]["name"]
                                          .toString()
                                      : ""), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['costo_transportadora'] !=
                                          null
                                      ? data[index]['costo_transportadora']
                                          .toString()
                                      : ""), onTap: () {
                                showInfo(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['cost_refound_external'] !=
                                          null
                                      ? data[index]['cost_refound_external']
                                          .toString()
                                      : ""), onTap: () {
                                showInfo(context, index);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //
                  ],
                ),
              )
            ])),
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

  Column SelectFilter2(
      String title,
      filter,
      TextEditingController controller,
      // List<String> listOptions) {
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
          double.parse(valuesTransporter['totalCostoEntrega'].toString());
      devoluciones =
          double.parse(valuesTransporter['totalCostoDevolucion'].toString());
      // utilidad = (valuesTransporter['totalValoresRecibidos'] -
      //     valuesTransporter['totalRetirosEfectivo']);
      // utilidad = double.parse(utilidad.toString());
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

  String getStateFromJson(String? jsonString, String claveAbuscar) {
    // Verificar si jsonString es null
    if (jsonString == null || jsonString.isEmpty) {
      return ''; // Retorna una cadena vacía si el valor es null o está vacío
    }

    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap[claveAbuscar]?.toString() ?? '';
    } catch (e) {
      // print('Error al decodificar JSON: $e');
      return ''; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
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
                    order: data[index],
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> OpenScannerShowDialog(BuildContext context, Map order) {
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
                    id: order["id"],
                    order: order,
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
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_controllers.startDateController.text),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      _controllers.startDateController.text =
                          await OpenCalendar();
                    },
                  ),
                  const Text(' - '),
                  Text(_controllers.endDateController.text),
                  IconButton(
                    icon: Icon(Icons.calendar_month),
                    onPressed: () async {
                      _controllers.endDateController.text =
                          await OpenCalendar();
                    },
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 67, 67, 67))),
                    onPressed: () async {
                      await applyDateFilter();
                    },
                    child: Text('Filtrar'),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 230,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedDateFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDateFilter = newValue ?? "";
                        });
                      },
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      items: listDateFilter
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 15)),
                        );
                      }).toList(),
                    ),
                  ),
                  // ! *****************
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 230,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedExt,
                      onChanged: (String? newValue) async {
                        // String filter = "carrier_external_id";
                        setState(() {
                          selectedExt = newValue ?? "";
                        });
                      },
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      items:
                          listExt.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 15)),
                        );
                      }).toList(),
                    ),
                  ),
                  // SelectFilter('test', 'carrier_external_id',
                  //     externalCarrierController, listExt),
                  // ! *****************
                  // Container(
                  //   padding: EdgeInsets.only(left: 10),
                  //   width: 230,
                  //   decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       border: Border.all(width: 1.0),
                  //       borderRadius: BorderRadius.circular(5.0)),
                  //   child: DropdownButtonHideUnderline(
                  //     child: DropdownButton2<String>(
                  //       isExpanded: true,
                  //       hint: Text(
                  //         'TRANSPORTADORA',
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             color: Theme.of(context).hintColor,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       items: transportator
                  //           .map((item) => DropdownMenuItem(
                  //                 value: item,
                  //                 child: Text(
                  //                   item.split('-')[0],
                  //                   style: const TextStyle(
                  //                       fontSize: 14,
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ))
                  //           .toList(),
                  //       value: selectedValueTransportator,
                  //       onChanged: (value) async {
                  //         setState(() {
                  //           selectedValueTransportator = value as String;
                  //         });
                  //          arrayFiltersAndEq = arrayFiltersAndEq
                  //     .where((element) => element['carrier_external_id'] !=  value?.split('-')[1],)
                  //     .toList();

                  // // for (Map element in arrayFiltersAndEq) {
                  // //   if (element['filter'] == filter) {
                  // //     arrayFiltersAndEq.remove(element);
                  // //   }
                  // // }
                  // if (value != 'TRANSPORTADORA') {
                  //   // reemplazarValor(arrayFiltersAndEq, newValue!);
                  //   //  print(value);
                  //   // ! pendiente funcionalidad
                  //   arrayFiltersAndEq.add({'filter': 'carrier_external_id', 'value':  value?.split('-')[1]});
                  // }

                  // loadData();

                  //       },
                  //       //This to clear the search value when you close the menu
                  //       onMenuStateChange: (isOpen) {
                  //         if (!isOpen) {}
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // ! *****************
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showSelectFilterReportDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 163, 81),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          IconData(0xf6df, fontFamily: 'MaterialIcons'),
                          size: 24,
                          color: Colors.white,
                        ),
                        Text(
                          "Descargar reporte",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
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

  Future<void> showSelectFilterReportDialog(BuildContext context) async {
    StateSetter dialogStateSetter;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            dialogStateSetter = setState;

            return AlertDialog(
              title: const Text(
                'Fitros para el reporte',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              content: responsive(
                  Row(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.vertical,
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: [
                          Row(
                            children: [
                              Text(_controllers.startDateController.text),
                              const Text(' - '),
                              Text(_controllers.endDateController.text),
                              const SizedBox(width: 10),
                              const Text("Marca T.I.")
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("Status"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip('ENTREGADO', 'status', setState,
                                  const Color.fromARGB(128, 102, 187, 106)),
                              const SizedBox(width: 20),
                              buildFilterChip('EN RUTA', 'status', setState,
                                  const Color.fromARGB(128, 51, 170, 255)),
                              const SizedBox(width: 20),
                              buildFilterChip('EN OFICINA', 'status', setState,
                                  const Color.fromARGB(128, 165, 144, 111)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip(
                                  'NO ENTREGADO',
                                  'status',
                                  setState,
                                  const Color.fromARGB(128, 230, 44, 51)),
                              const SizedBox(width: 20),
                              buildFilterChip('NOVEDAD', 'status', setState,
                                  const Color.fromARGB(128, 214, 220, 39)),
                              const SizedBox(width: 20),
                              buildFilterChip('REAGENDADO', 'status', setState,
                                  const Color.fromARGB(128, 227, 32, 241)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip(
                                  'PEDIDO PROGRAMADO',
                                  'status',
                                  setState,
                                  const Color.fromARGB(128, 165, 165, 249)),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ], //
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.vertical,
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: [
                          const SizedBox(height: 10),
                          const Text("Status"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip('ENTREGADO', 'status', setState,
                                  const Color.fromARGB(128, 102, 187, 106)),
                              const SizedBox(width: 10),
                              buildFilterChip('EN RUTA', 'status', setState,
                                  const Color.fromARGB(128, 51, 170, 255)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip('EN OFICINA', 'status', setState,
                                  const Color.fromARGB(128, 165, 144, 111)),
                              const SizedBox(width: 10),
                              buildFilterChip('NOVEDAD', 'status', setState,
                                  const Color.fromARGB(128, 214, 220, 39)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip(
                                  'NO ENTREGADO',
                                  'status',
                                  setState,
                                  const Color.fromARGB(128, 230, 44, 51)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip('REAGENDADO', 'status', setState,
                                  const Color.fromARGB(128, 227, 32, 241)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildFilterChip(
                                  'PEDIDO PROGRAMADO',
                                  'status',
                                  setState,
                                  const Color.fromARGB(128, 165, 165, 249)),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ], //
                      ),
                    ],
                  ),
                  context),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    selectedChips = [];
                    selectedStatus = [];
                    selectedInternal = [];
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0079FF),
                  ),
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    generateReport(selectedStatus, selectedInternal);
                    Navigator.of(context).pop();
                    selectedChips = [];
                    selectedStatus = [];
                    selectedInternal = [];
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00DFA2),
                  ),
                  child: const Text("Generar Reporte"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildFilterChip(
      String label, String key, StateSetter setState, Color color) {
    return FilterChip(
      label: Text(label),
      selected: selectedChips.contains(label),
      backgroundColor: const Color(0xFFF2F6FC),
      selectedColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          // color: Colors.black,
          color: color,
          width: 1.0,
        ),
      ),
      onSelected: (isSelected) {
        setState(() {
          if (isSelected) {
            selectedChips.add(label);
            if (key == "status") {
              selectedStatus.add({key: label});
            } else if (key == "estado_interno") {
              selectedInternal.add({key: label});
            }
          } else {
            selectedChips.remove(label);
            if (key == "status") {
              selectedStatus.removeWhere((map) => map['label'] == label);
            } else if (key == "estado_interno") {
              selectedInternal.removeWhere((map) => map['label'] == label);
            }
          }
          // print("act. Status: $selectedStatus");
          // print("act. estado_interno: $selectedInternal");
        });
      },
    );
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
    novedadResuelta = 0;
    reagendados = 0;
    enRuta = 0;
    programado = 0;
    enOficina = 0;

    setState(() {
      entregados = int.parse(dataCounters['ENTREGADO'].toString()) ?? 0;
      noEntregados = int.parse(dataCounters['NO ENTREGADO'].toString()) ?? 0;
      conNovedad = int.parse(dataCounters['NOVEDAD'].toString()) ?? 0;
      novedadResuelta =
          int.parse(dataCounters['NOVEDAD RESUELTA'].toString()) ?? 0;
      reagendados = int.parse(dataCounters['REAGENDADO'].toString()) ?? 0;
      enRuta = int.parse(dataCounters['EN RUTA'].toString()) ?? 0;
      programado = int.parse(dataCounters['PEDIDO PROGRAMADO'].toString()) ?? 0;
      enOficina = int.parse(dataCounters['EN OFICINA'].toString()) ?? 0;
    });
  }

  Future<void> sendWhatsAppMessageConfirm(
      BuildContext context, Map<dynamic, dynamic> data) async {
    var client = data['nombre_shipping'].toString();
    var code = data['users'] != null && data['users'].toString() != "[]"
        ? "${data['users'][0]['vendedores'][0]['nombre_comercial']}-${data['numero_orden']}"
        : "${data['tienda_temporal']}-${data['numero_orden']}";

    var product = data['producto_p'].toString();
    var extraProduct = data['producto_extra'] != null &&
            data['producto_extra'].toString() != 'null' &&
            data['producto_extra'].toString() != ''
        ? ' ${data['producto_extra'].toString()}'
        : '';
    var store = data['users'] != null && data['users'].isNotEmpty
        ? data['users'][0]['vendedores'][0]['nombre_comercial']
        : "NaN";
    var telefono = data['telefono_shipping'].toString();

    // String? phoneNumber = data['operadore']?.isNotEmpty == true
    //     ? data['operadore'][0]['telefono']
    //     : null;

    if (telefono != null && telefono.isNotEmpty) {
      var message =
          messageConfirmedDelivery(client, store, code, product, extraProduct);
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$telefono&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      _showErrorSnackBar(context, "El pedido no tiene un operador asignado.");
    }
  }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
        ),
        backgroundColor: Color.fromARGB(255, 253, 101, 90),
        duration: Duration(seconds: 4),
      ),
    );
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
      case "NOVEDAD RESUELTA":
        color = 0xFFFF5722;
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

  Future<dynamic> showInfo(BuildContext context, int index) {
    if (MediaQuery.of(context).size.width > 930) {
      return openDialog(
          context,
          MediaQuery.of(context).size.width * 0.4,
          MediaQuery.of(context).size.height * 0.9,
          DeliveryStatusSellerInfo2(
              order: data[index], function: exeReSchedule, data: data),
          () {});
    } else {
      return openDialog(
          context,
          MediaQuery.of(context).size.width * 0.8,
          MediaQuery.of(context).size.height * 0.9,
          DeliveryStatusSellerInfo2(
              order: data[index], function: exeReSchedule, data: data),
          () {});
    }
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
              title: Text('Atención'),
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
                    if (filter is String) {
                      arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                    } else {
                      reemplazarValor(filter, newValue!);
                      //print(filter);

                      arrayFiltersAnd.add(filter);
                    }
                  } else {}

                  loadData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                // var nombre = value.split('-')[0];
                // print(nombre);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split('-')[0],
                      style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Column SelectFilter(String title, filter, value,
  //     TextEditingController controller, List<String> listOptions) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title),
  //       Expanded(
  //         child: Container(
  //           margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(5.0),
  //             border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
  //           ),
  //           height: 50,
  //           child: DropdownButtonFormField<String>(
  //             isExpanded: true,
  //             value: controller.text,
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 controller.text = newValue ?? "";

  //                 arrayFiltersAndEq = arrayFiltersAndEq
  //                     .where((element) => element['filter'] != filter)
  //                     .toList();

  //                 // for (Map element in arrayFiltersAndEq) {
  //                 //   if (element['filter'] == filter) {
  //                 //     arrayFiltersAndEq.remove(element);
  //                 //   }
  //                 // }
  //                 if (newValue != 'TODO') {
  //                   reemplazarValor(value, newValue!);
  //                   //  print(value);

  //                   arrayFiltersAndEq.add({'filter': filter, 'value': value});
  //                 }

  //                 loadData();
  //               });
  //             },
  //             decoration: InputDecoration(
  //                 border: UnderlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10))),
  //             items: listOptions.map<DropdownMenuItem<String>>((String value) {
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: Text(value, style: TextStyle(fontSize: 15)),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
        // buttonUnselectedForegroundColor: Color.fromARGB(255, 67, 67, 67),
        // buttonSelectedBackgroundColor: Color.fromARGB(255, 67, 67, 67),
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
