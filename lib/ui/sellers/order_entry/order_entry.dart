import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/sellers/order_entry/calendar_modal.dart';
import 'package:frontend/ui/sellers/order_entry/confirm_carrier.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/sellers/order_entry/order_info.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
import 'package:frontend/ui/widgets/sellers/add_order.dart';
import 'package:frontend/ui/widgets/sellers/add_order_laravel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import '../../widgets/show_error_snackbar.dart';

class OrderEntry extends StatefulWidget {
  const OrderEntry({super.key});

  @override
  State<OrderEntry> createState() => _OrderEntryState();
}

enum IconAction { phone, message, check, close }

class _OrderEntryState extends State<OrderEntry> {
  OrderEntryControllers _controllers = OrderEntryControllers();
  final _startDateController = TextEditingController(text: "1/1/2023");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
  TextEditingController statusController = TextEditingController(text: "TODO");

  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 0;
  int total = 0;
  bool isSearch = false;
  bool buttonLeft = false;
  bool buttonRigth = false;
  String pedido = '';
  String confirmado = 'TODO';
  String logistico = 'TODO';
  bool enabledBusqueda = true;
  bool isLoading = false;
  bool columnChecksActive = false;
  List<DateTime?> _dates = [];

  List filtersAnd = [
    {'/estado_logistico': 'ENVIADO'}
  ];
  // List filtersDefaultAnd = [
  //   {
  //     'operator': '\$and',
  //     'filter': 'IdComercial',
  //     'operator_attr': '\$eq',
  //     'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
  //   },
  //   {
  //     'operator': '\$and',
  //     'filter': 'Estado_Interno',
  //     'operator_attr': '\$ne',
  //     'value': 'NO DESEA'
  //   },
  //   {
  //     'operator': '\$and',
  //     'filter': 'Status',
  //     'operator_attr': '\$eq',
  //     'value': 'PEDIDO PROGRAMADO'
  //   },
  // ];

  // List filtersOrCont = [
  //   {'filter': 'CiudadShipping'},
  //   {'filter': 'NumeroOrden'},
  //   {'filter': 'NombreShipping'},
  //   {'filter': 'DireccionShipping'},
  //   {'filter': 'TelefonoShipping'},
  //   {'filter': 'ProductoP'},
  //   {'filter': 'ProductoExtra'},
  //   {'filter': 'PrecioTotal'},
  // ];

  // ! se usa Laravel
  bool changevalue = false;
  var sortFieldDefaultValue = "id:DESC";
  List arrayFiltersDefaultAnd = [
    {
      'equals/id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
    {'equals/status': 'PEDIDO PROGRAMADO'}
  ];
  // List arrayFiltersDefaultAnd = [
  //   {
  //     'id_comercial':
  //         sharedPrefs!.getString("idComercialMasterSeller").toString()
  //   },
  //   {'status': 'PEDIDO PROGRAMADO'}
  // ];
  List arrayFiltersNot = [
    {'estado_interno': 'NO DESEA'},
  ];
  // List populate = ['users', 'pedido_fecha'];
  List populate = [
    // 'operadore.up_users',
    'transportadora',
    'users.vendedores',
    // 'novedades',
    // 'pedidoFecha',
    'ruta',
    // 'subRuta'
    // 'carrierExternal',
    'product.warehouses',
    'pedidoCarrier',
    "products.product",
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    'ciudad_shipping',
    'numero_orden',
    'nombre_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'producto_p',
    'producto_extra',
    'precio_total',
  ];

  String from = '0.0';
  String to = '0.0';

  NumberPaginatorController paginatorController = NumberPaginatorController();

  List<String> listStatus = [
    'TODO',
    'PENDIENTE POR CONFIRMAR',
    'CONFIRMADO',
    'IMPRESO',
    'ENVIADO',
  ];

  List<String> optEstadoConfirmado = ["TODO", 'PENDIENTE', 'CONFIRMADO'];
  List<String> optEstadoLogistico = ["TODO", 'PENDIENTE', 'IMPRESO', 'ENVIADO'];
  bool noDeseaEnabled = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    currentPage = 1;

    setState(() {
      isLoading = true;
      // data.clear();
    });

    try {
      var response = await Connections().generalDataOptimized(
          pageSize,
          currentPage,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          [],
          [],
          _controllers.searchController.text,
          "PedidosShopify",
          "MARCA INGRESO",
          _startDateController.text,
          _endDateController.text,
          sortFieldDefaultValue);

      // paginatorController.navigateToPage(0);

      optionsCheckBox = [];
      for (var i = 0; i < total; i++) {
        optionsCheckBox.add({"check": false, "id": "", "numero_orden": ""});
      }
      // paginatorController.navigateToPage(0);

      counterChecks = 0;
      setState(() {
        data = [];
        data = response['data'];
        pageCount = response['last_page'];
        total = response['total'];
        from = response['from'].toString();
        to = response['to'].toString();

        paginatorController.navigateToPage(0);
        isLoading = false;
      });
    } catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
      print(e);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    // print("Pagina Actual="+currentPage.toString());
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });
    // // var response = [];
    // setState(() {
    //   data.clear();
    // });
    // setState(() {
    //     // search = false;
    //   });

    try {
      // setState(() {
      //   isLoading = true;
      //   // data.clear();
      // });
      var response = await Connections().generalDataOptimized(
          pageSize,
          currentPage,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          [],
          [],
          _controllers.searchController.text,
          "PedidosShopify",
          "MARCA INGRESO",
          // "FECHA ENTREGA",
          _startDateController.text,
          _endDateController.text,
          sortFieldDefaultValue);

      // var response = await Connections().getPrincipalOrdersSellersFilterLaravel(
      //     populate,
      //     arrayFiltersAnd,
      //     arrayFiltersDefaultAnd,
      //     arrayFiltersOr,
      //     currentPage,
      //     pageSize,
      //     _controllers.searchController.text,
      //     sortFieldDefaultValue.toString(),
      //     arrayFiltersNot);

      setState(() {
        data = [];
        from = response['from'].toString();
        to = response['to'].toString();
        data = response['data'];
        pageCount = response['last_page'];
        total = response['total'];
        // pageCount = response[0]['meta']['pagination']['pageCount'];
        // total = response[0]['meta']['pagination']['total'];
      });
      // print("paginadoo");
      // await Future.delayed(Duration(milliseconds: 500), () {
      //   Navigator.pop(context);
      // });
      // setState(() {});
      // setState(() {
      //   isLoading = false;
      // });
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    String logisticoVal = logistico;
    String confirmadoVal = confirmado;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        key: _scaffoldKey,
        body: Container(
            // padding: EdgeInsets.all(15),
            // color: Colors.grey[100],
            width: double.infinity,
            height: double.infinity,
            child: responsive(
                webMainContainer(context, confirmadoVal, logisticoVal),
                mobileMainContainer(context, confirmadoVal, logisticoVal),
                context)),
      ),
    );
  }

  Container searchBarOnly(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.30,
      child: _modelTextField(
        text: "Buscar",
        controller: _controllers.searchController,
      ),
    );
  }

  Container searchBarOnlyMobile(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.85,
      child: _modelTextFieldMobile(
        text: "Buscar",
        controller: _controllers.searchController,
      ),
    );
  }

  Container dropdownStatus(BuildContext context, isMobile) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listStatus
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorLabels),
                  ),
                ),
              )
              .toList(),
          value: statusController.text,
          onChanged: (String? value) {
            setState(() {
              statusController.text = value ?? "";

              // Limpia filtros relacionados antes de agregar nuevos
              arrayFiltersAnd.removeWhere(
                  (element) => element.containsKey("equals/estado_logistico"));
              arrayFiltersAnd.removeWhere(
                  (element) => element.containsKey("equals/estado_interno"));

              if (value != null) {
                if (value == "TODO") {
                  // Si selecciona TODO, no aplica ningún filtro
                  arrayFiltersAnd.clear();
                } else if (value == "IMPRESO" || value == "ENVIADO") {
                  // Filtro solo por estado logístico
                  arrayFiltersAnd.add({"equals/estado_logistico": value});
                } else if (value == "PENDIENTE POR CONFIRMAR") {
                  // Filtro para pendiente por confirmar
                  arrayFiltersAnd.add({"equals/estado_interno": "PENDIENTE"});
                  arrayFiltersAnd.add({"equals/estado_logistico": "PENDIENTE"});
                } else {
                  // Filtros generales
                  arrayFiltersAnd.add({"equals/estado_interno": value});
                  arrayFiltersAnd.add({"equals/estado_logistico": "PENDIENTE"});
                }
              }
            });

            loadData(); // Recarga los datos con los filtros actualizados
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Container dropdownStatusMobile(BuildContext context, isMobile, setState) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listStatus
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorLabels),
                  ),
                ),
              )
              .toList(),
          value: statusController.text,
          onChanged: (String? value) {
            setState(() {
              statusController.text = value ?? "";

              // Limpia filtros relacionados antes de agregar nuevos
              arrayFiltersAnd.removeWhere(
                  (element) => element.containsKey("equals/estado_logistico"));
              arrayFiltersAnd.removeWhere(
                  (element) => element.containsKey("equals/estado_interno"));

              if (value != null) {
                if (value == "TODO") {
                  // Si selecciona TODO, no aplica ningún filtro
                  arrayFiltersAnd.clear();
                } else if (value == "IMPRESO" || value == "ENVIADO") {
                  // Filtro solo por estado logístico
                  arrayFiltersAnd.add({"equals/estado_logistico": value});
                } else if (value == "PENDIENTE POR CONFIRMAR") {
                  // Filtro para pendiente por confirmar
                  arrayFiltersAnd.add({"equals/estado_interno": "PENDIENTE"});
                  arrayFiltersAnd.add({"equals/estado_logistico": "PENDIENTE"});
                } else {
                  // Filtros generales
                  arrayFiltersAnd.add({"equals/estado_interno": value});
                  arrayFiltersAnd.add({"equals/estado_logistico": "PENDIENTE"});
                }
              }
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 30 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Stack webMainContainer(
      BuildContext context, String confirmadoVal, String logisticoVal) {
    return Stack(children: [
      Column(
        children: [
          Container(
            height: 230,
            color: ColorsSystem()
                .colorInitialContainer, // Cambia a tu color deseado
          ),
        ],
      ),
      Positioned(
          top: 20,
          left: 20,
          right: 20,
          height: MediaQuery.of(context).size.height * 0.95,
          child:
              // LayoutBuilder(builder: ((context, constraints) {
              // return
              Container(
                  height: 100,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        // color: Colors.orange,
                        // height: 100,
                        child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Ingreso de Pedidos',
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: ColorsSystem().colorStore,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.replay_outlined,
                                            color: ColorsSystem().colorSelected,
                                          ),
                                          onPressed: () {
                                            loadData();
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("Registros: ",
                                            style: TextStylesSystem()
                                                .ralewayStyle(
                                                    18,
                                                    FontWeight.w700,
                                                    ColorsSystem().colorStore)),
                                        SizedBox(width: 5),
                                        Text(
                                          "$total",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: ColorsSystem().colorStore,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                        // const SizedBox(
                        //   height: 5,
                        // ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "",
                                    style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels),
                                  ),
                                  SizedBox(height: 10),
                                  searchBarOnly(context, 40),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Status",
                                    style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels),
                                  ),
                                  SizedBox(
                                      height:
                                          10), // Espacio entre el texto y el campo de búsqueda
                                  // searchBarOnly(context),
                                  dropdownStatus(context, 0),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fecha",
                                    style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          startDateContainer(0),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        children: [
                                          endDateContainer(0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "",
                                        style: TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.w700,
                                            ColorsSystem().colorLabels),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Tooltip(
                                              message: 'Aplicar Filtros',
                                              child: filterButton()),
                                          const SizedBox(width: 10),
                                          Tooltip(
                                              message: 'Quitar Filtros',
                                              child: resetFilterButton())
                                        ],
                                      ),
                                    ])),
                            SizedBox(width: 10),
                            Flexible(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "",
                                        style: TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.w700,
                                            ColorsSystem().colorLabels),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            // padding: EdgeInsets.only(left: 10, right: 10),
                                            // height: 50.0,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  child: ElevatedButton(
                                                      onPressed:
                                                          counterChecks > 0 &&
                                                                  noDeseaEnabled
                                                              ? () async {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            'Atención'),
                                                                        content:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              const Text('¿Estás seguro de eliminar los siguientes pedidos?'),
                                                                              Text('' + listToDelete()),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            child:
                                                                                const Text('Cancelar'),
                                                                            onPressed:
                                                                                () {
                                                                              // Acción al presionar el botón de cancelar
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                Text('Aceptar'),
                                                                            onPressed:
                                                                                () async {
                                                                              for (var i = 0; i < optionsCheckBox.length; i++) {
                                                                                if (optionsCheckBox[i]['id'].toString().isNotEmpty && optionsCheckBox[i]['id'].toString() != '' && optionsCheckBox[i]['check'] == true) {
                                                                                  // var response = await Connections()
                                                                                  //     .updateOrderInteralStatusLaravel(
                                                                                  //         "NO DESEA",
                                                                                  //         optionsCheckBox[
                                                                                  //                     i]
                                                                                  //                 ['id']
                                                                                  //             .toString());

                                                                                  //
                                                                                  var response3 = await Connections().updateOrderWithTime(optionsCheckBox[i]['id'].toString(), "estado_interno:NO DESEA", sharedPrefs!.getString("id"), "", "");
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
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                // ElevatedButton(
                                                //     onPressed: () async {
                                                //       await showDialog(
                                                //           context: (context),
                                                //           builder: (context) {
                                                //             // return const AddOrderSellers();
                                                //             return const AddOrderSellersLaravel();
                                                //           });
                                                //       await loadData();

                                                //       // showNuevo(context);
                                                //     },
                                                //     child: const Row(
                                                //       children: [Text(" Nuevo"), Icon(Icons.add)],
                                                //     )),
                                              ],
                                            ),
                                          ),
                                          // SizedBox(width: 10,),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: Row(
                                              children: [
                                                Text(
                                                  counterChecks > 0
                                                      ? "Seleccionados: ${counterChecks}"
                                                      : "",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                counterChecks > 0
                                                    ? Visibility(
                                                        visible: true,
                                                        child: IconButton(
                                                          iconSize: 20,
                                                          onPressed: () =>
                                                              {clearSelected()},
                                                          icon: Icon(Icons
                                                              .close_rounded),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ])),
                          ],
                        ),
                      ],
                    )),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child:
                          // ExpandableTable(data: data,)
                          buildDataTable(confirmadoVal, logisticoVal, context),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                        child: data.isNotEmpty
                            ? Container(
                                height: 30,
                                child: paginationComplete(),
                              )
                            : Container()),
                  ]))
          // })
          // )
          )
    ]);
  }

  Stack mobileMainContainer(
      BuildContext context, String confirmadoVal, String logisticoVal) {
    return Stack(children: [
      Column(
        children: [
          Container(
            height: 140,
            color: ColorsSystem()
                .colorInitialContainer, // Cambia a tu color deseado
          ),
        ],
      ),
      Positioned(
          top: 8,
          left: 20,
          right: 20,
          height: MediaQuery.of(context).size.height,
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ingreso de Pedidos',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColorsSystem().colorStore,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.replay_outlined,
                              color: ColorsSystem().colorSelected,
                              size: 14,
                            ),
                            onPressed: () {
                              loadData();
                            },
                          ),
                          // filterButtonMobile()
                          SizedBox(
                            width: 30,
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blue, // Color de fondo azul
                                padding: EdgeInsets
                                    .zero, // Eliminar el relleno para reducir el tamaño del botón
                              ),
                              onPressed: () {
                                // Acción al presionar el botón
                                // print("Botón presionado");
                                setState(() {
                                  columnChecksActive = !columnChecksActive;
                                });
                              },
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              ), // Icono blanco
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 30,
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsSystem().colorStore,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                filtersDialog(context);
                              },
                              child: Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.white,
                                size: 10,
                              ), // Icono blanco
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 30,
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsSystem().colorStore,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                clearSelected();
                                resetFilters();
                                loadData();
                              },
                              child: Icon(
                                Icons.filter_alt_off_outlined,
                                color: Colors.white,
                                size: 10,
                              ), // Icono blanco
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]),
            Row(
              children: [
                // SizedBox(
                //   width: 30,
                //   height: 20,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue, // Color de fondo azul
                //       padding: EdgeInsets
                //           .zero, // Eliminar el relleno para reducir el tamaño del botón
                //     ),
                //     onPressed: () {
                //       // Acción al presionar el botón
                //       // print("Botón presionado");
                //       setState(() {
                //         columnChecksActive = !columnChecksActive;
                //       });
                //     },
                //     child: Icon(Icons.check, color: Colors.white,size: 10,), // Icono blanco
                //   ),
                // ),
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                searchBarOnlyMobile(context, 30),
                // SizedBox(width: 10),
                // Flexible(
                //   flex: 2,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // Text(
                //       //   "Fecha",
                //       //   style: TextStylesSystem().ralewayStyle(
                //       //       18,
                //       //       FontWeight.w700,
                //       //       ColorsSystem().colorLabels),
                //       // ),
                //       // SizedBox(height: 10),
                //       Row(
                //         // mainAxisAlignment: MainAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           Column(
                //             children: [
                //               startDateContainer(0),
                //             ],
                //           ),
                //           SizedBox(
                //             width: 10,
                //           ),
                //           Column(
                //             children: [
                //               endDateContainer(0),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // Flexible(
                //     flex: 1,
                //     child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             "",
                //             style: TextStylesSystem().ralewayStyle(18,
                //                 FontWeight.w700, ColorsSystem().colorLabels),
                //           ),
                //           SizedBox(height: 10),
                //           filterButton()
                //         ])),
                // SizedBox(width: 10),
                // Flexible(
                //     flex: 1,
                //     child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             "",
                //             style: TextStylesSystem().ralewayStyle(18,
                //                 FontWeight.w700, ColorsSystem().colorLabels),
                //           ),
                //           SizedBox(height: 10),
                //           Row(
                //             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Container(
                //                 // padding: EdgeInsets.only(left: 10, right: 10),
                //                 // height: 50.0,
                //                 child: Row(
                //                   children: [
                //                     SizedBox(
                //                       height: 40,
                //                       child: ElevatedButton(
                //                           onPressed:
                //                               counterChecks > 0 &&
                //                                       noDeseaEnabled
                //                                   ? () async {
                //                                       showDialog(
                //                                         context: context,
                //                                         builder: (BuildContext
                //                                             context) {
                //                                           return AlertDialog(
                //                                             title: Text(
                //                                                 'Atención'),
                //                                             content:
                //                                                 SingleChildScrollView(
                //                                               child: Column(
                //                                                 children: [
                //                                                   const Text(
                //                                                       '¿Estás seguro de eliminar los siguientes pedidos?'),
                //                                                   Text('' +
                //                                                       listToDelete()),
                //                                                 ],
                //                                               ),
                //                                             ),
                //                                             actions: [
                //                                               TextButton(
                //                                                 child: const Text(
                //                                                     'Cancelar'),
                //                                                 onPressed: () {
                //                                                   // Acción al presionar el botón de cancelar
                //                                                   Navigator.of(
                //                                                           context)
                //                                                       .pop();
                //                                                 },
                //                                               ),
                //                                               TextButton(
                //                                                 child: Text(
                //                                                     'Aceptar'),
                //                                                 onPressed:
                //                                                     () async {
                //                                                   for (var i =
                //                                                           0;
                //                                                       i <
                //                                                           optionsCheckBox
                //                                                               .length;
                //                                                       i++) {
                //                                                     if (optionsCheckBox[i]['id']
                //                                                             .toString()
                //                                                             .isNotEmpty &&
                //                                                         optionsCheckBox[i]['id'].toString() !=
                //                                                             '' &&
                //                                                         optionsCheckBox[i]['check'] ==
                //                                                             true) {
                //                                                       // var response = await Connections()
                //                                                       //     .updateOrderInteralStatusLaravel(
                //                                                       //         "NO DESEA",
                //                                                       //         optionsCheckBox[
                //                                                       //                     i]
                //                                                       //                 ['id']
                //                                                       //             .toString());

                //                                                       //
                //                                                       var response3 = await Connections().updateOrderWithTime(
                //                                                           optionsCheckBox[i]['id']
                //                                                               .toString(),
                //                                                           "estado_interno:NO DESEA",
                //                                                           sharedPrefs!
                //                                                               .getString("id"),
                //                                                           "",
                //                                                           "");
                //                                                       counterChecks =
                //                                                           0;
                //                                                     }
                //                                                   }

                //                                                   loadData();
                //                                                   setState(
                //                                                       () {});
                //                                                   enabledBusqueda =
                //                                                       true;
                //                                                   Navigator.of(
                //                                                           context)
                //                                                       .pop();
                //                                                 },
                //                                               ),
                //                                             ],
                //                                           );
                //                                         },
                //                                       );
                //                                     }
                //                                   : null,
                //                           child: const Text(
                //                             "No Desea",
                //                             style: TextStyle(
                //                                 fontWeight: FontWeight.bold),
                //                           )),
                //                     ),
                //                     const SizedBox(
                //                       width: 10,
                //                     ),
                //                     // ElevatedButton(
                //                     //     onPressed: () async {
                //                     //       await showDialog(
                //                     //           context: (context),
                //                     //           builder: (context) {
                //                     //             // return const AddOrderSellers();
                //                     //             return const AddOrderSellersLaravel();
                //                     //           });
                //                     //       await loadData();

                //                     //       // showNuevo(context);
                //                     //     },
                //                     //     child: const Row(
                //                     //       children: [Text(" Nuevo"), Icon(Icons.add)],
                //                     //     )),
                //                   ],
                //                 ),
                //               ),
                //               // SizedBox(width: 10,),
                //               Container(
                //                 margin: EdgeInsets.only(left: 10.0),
                //                 padding:
                //                     const EdgeInsets.only(left: 5, right: 5),
                //                 child: Row(
                //                   children: [
                //                     Text(
                //                       counterChecks > 0
                //                           ? "Seleccionados: ${counterChecks}"
                //                           : "",
                //                       style: const TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           color: Colors.black),
                //                     ),
                //                     counterChecks > 0
                //                         ? Visibility(
                //                             visible: true,
                //                             child: IconButton(
                //                               iconSize: 20,
                //                               onPressed: () =>
                //                                   {clearSelected()},
                //                               icon: Icon(Icons.close_rounded),
                //                             ),
                //                           )
                //                         : Container(),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           )
                //         ])),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        dropdownPagination(),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: 20,
                          child: ElevatedButton(
                              onPressed: counterChecks > 0 && noDeseaEnabled
                                  ? () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Atención'),
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
                                                    if (optionsCheckBox[i]['id']
                                                            .toString()
                                                            .isNotEmpty &&
                                                        optionsCheckBox[i]['id']
                                                                .toString() !=
                                                            '' &&
                                                        optionsCheckBox[i]
                                                                ['check'] ==
                                                            true) {
                                                      // var response = await Connections()
                                                      //     .updateOrderInteralStatusLaravel(
                                                      //         "NO DESEA",
                                                      //         optionsCheckBox[
                                                      //                     i]
                                                      //                 ['id']
                                                      //             .toString());

                                                      //
                                                      var response3 = await Connections()
                                                          .updateOrderWithTime(
                                                              optionsCheckBox[i]
                                                                      ['id']
                                                                  .toString(),
                                                              "estado_interno:NO DESEA",
                                                              sharedPrefs!
                                                                  .getString(
                                                                      "id"),
                                                              "",
                                                              "");
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      counterChecks > 0 ? "Seleccionados: $counterChecks" : "",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorsSystem().colorLabels,
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            Expanded(
              flex: MediaQuery.of(context).size.height <= 640 ? 4 : 5,
              child: data.length > 0
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];

                          return InkWell(
                            onTap: () {
                              // Mostrar el diálogo OrderInfo
                              var order = data[index];
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return OrderInfo(
                                    order: order,
                                    index: index,
                                    sumarNumero: sumarNumero,
                                    codigo:
                                        "${sharedPrefs!.getString("NameComercialSeller")}-${order['numero_orden']}",
                                    data: data,
                                  );
                                },
                              );
                            },
                            child: cardOrder(item, index),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text("Sin datos")),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height <= 640
                    ? MediaQuery.of(context).size.height * 0.01
                    : MediaQuery.of(context).size.height * 0.03),
            Flexible(
                child: data.isNotEmpty
                    ? Container(
                        height: 30,
                        child: paginationPhoneComplete(),
                      )
                    : Container()),
          ]))
    ]);
  }

  Future<dynamic> filtersDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.50,
                child:
                    // Container()
                    _leftWidgetMobile(
                        context, setState), // Pasamos setState aquí
              );
            },
          ),
        );
      },
    );
  }

  Scaffold _leftWidgetMobile(BuildContext context, setState) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Filtros",
          style: TextStylesSystem().ralewayStyle(
            14,
            FontWeight.bold,
            ColorsSystem().colorLabels,
          ),
        ),
        iconTheme: IconThemeData(
          color: ColorsSystem().colorLabels,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: ColorsSystem().colorInitialContainer,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: ColorsSystem().colorSection,
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              left: 8,
              right: 8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: SingleChildScrollView(
                                  child: Container(
                                    // padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Fecha Inicio",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w500,
                                                  ColorsSystem().colorLabels),
                                        ),
                                        startDateContainerMobile(setState, 1),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Fecha Fin",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w500,
                                                  ColorsSystem().colorLabels),
                                        ),
                                        endDateContainerMobile(setState, 1),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        dropdownStatusMobile(
                                            context, 1, setState),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        filterButtonFiltersModal()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card cardOrder(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                columnChecksActive == true
                    ? Container(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: verificarIndice(index),
                          onChanged: (value) {
                            setState(() {
                              int calculatedIndex =
                                  index + ((currentPage - 1) * pageSize);

                              // Asegúrate de que optionsCheckBox tenga suficientes elementos.
                              if (optionsCheckBox.length <= calculatedIndex) {
                                optionsCheckBox.addAll(List.generate(
                                  calculatedIndex - optionsCheckBox.length + 1,
                                  (i) => {
                                    'check': false,
                                    'id': '',
                                    'numero_orden': ''
                                  },
                                ));
                              }

                              if (value!) {
                                optionsCheckBox[calculatedIndex]['check'] =
                                    value;
                                optionsCheckBox[calculatedIndex]['id'] =
                                    item['id'];
                                optionsCheckBox[calculatedIndex]
                                    ['numero_orden'] = item['numero_orden'];

                                if (item['estado_logistico'].toString() ==
                                        "IMPRESO" ||
                                    item['estado_logistico'].toString() ==
                                        "ENVIADO") {
                                  noDeseaEnabled = false;
                                }

                                counterChecks += 1;
                              } else {
                                optionsCheckBox[calculatedIndex]['check'] =
                                    value;
                                optionsCheckBox[calculatedIndex]['id'] = '';
                                counterChecks -= 1;
                              }

                              enabledBusqueda = counterChecks <= 0;
                            });
                          },
                        ),
                      )
                    : Container(width: 1),

                // columnChecksActive == true
                //     ? Container(
                //         height: 20,
                //         width: 20,
                //         child: Checkbox(
                //           value: verificarIndice(index),
                //           onChanged: (value) {
                //             // ! esto se comento por el momento
                //             setState(() {
                //               int calculatedIndex =
                //                   index + ((currentPage - 1) * pageSize);
                //               // Asegúrate de que optionsCheckBox sea lo suficientemente grande.
                //               if (optionsCheckBox.length <= calculatedIndex) {
                //                 optionsCheckBox.addAll(List.generate(
                //                   calculatedIndex - optionsCheckBox.length + 1,
                //                   (i) => {
                //                     'check': false,
                //                     'id': '',
                //                     'numero_orden': ''
                //                   },
                //                 ));
                //               }

                //               if (value!) {
                //                 optionsCheckBox[calculatedIndex]['check'] =
                //                     value;
                //                 optionsCheckBox[calculatedIndex]['id'] =
                //                     item['id'];
                //                 optionsCheckBox[calculatedIndex]
                //                     ['numero_orden'] = item['numero_orden'];
                //                 if (item['estado_logistico'].toString() ==
                //                         "IMPRESO" ||
                //                     item['estado_logistico'].toString() ==
                //                         "ENVIADO") {
                //                   noDeseaEnabled = false;
                //                 }
                //                 counterChecks += 1;
                //               } else {
                //                 optionsCheckBox[calculatedIndex]['check'] =
                //                     value;
                //                 optionsCheckBox[calculatedIndex]['id'] = '';
                //                 counterChecks -= 1;
                //               }

                //               enabledBusqueda = counterChecks <= 0;
                //             });
                //           },
                //         ),
                //       )
                //     : Container(width: 1),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['users'] != null && item['users'].isNotEmpty ? item['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${item['numero_orden'].toString()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: UIUtils.getColorStateArea(
                      item['status_history'].toString() == "null" ||
                              item['status_history'].toString() == "[]"
                          ? (item['status'].toString() == "NOVEDAD" ||
                                      item['status'].toString() ==
                                          "NO ENTREGADO") &&
                                  item['estado_devolucion'].toString() !=
                                      "PENDIENTE"
                              ? "estado_devolucion:${item['estado_devolucion'].toString()}"
                              : "status:${item['status'].toString()}"
                          : getLastStatusFromJson(
                              item['status_history'].toString(),
                            ).toString(),
                    ).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 2.0, top: 2.0),
                  child: Text(
                    (item['estado_interno'].toString() == "PENDIENTE") &&
                            (item['estado_logistico'].toString() == "PENDIENTE")
                        ? "PENDIENTE POR CONFIRMAR"
                        : (item['estado_interno'].toString() == "CONFIRMADO") &&
                                (item['estado_logistico'].toString() ==
                                    "PENDIENTE")
                            ? item['estado_interno'].toString()
                            : (() {
                                String? lastStatus = getLastStatusFromJson(
                                    item['status_history']?.toString());
                                if (lastStatus != null) {
                                  List<String> parts = lastStatus.split(":");
                                  return parts.length > 1
                                      ? parts[1]
                                      : lastStatus;
                                }
                                // Valor predeterminado si todo lo demás falla
                                return item['estado_logistico']?.toString() ??
                                    "SIN ESTADO";
                              })(),
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ],
            ),
            // ${data[index]['pedido_carrier_simple'][0]['external_id'].toString()}
            // ! nueva fila
            item['pedido_carrier'].isNotEmpty
                ?

                // pedidoCarrier
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['pedido_carrier'][0]['external_id'].toString()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['nombre_shipping']}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorStore,
                  ),
                ),
                Text(
                  item['marca_t_i'] ?? 'Fecha no disponible',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['ciudad_shipping']}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorStore,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: (data[index]['estado_logistico'].toString() !=
                              "PENDIENTE")
                          ? Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor:
                                        Color.fromARGB(255, 80, 78, 78),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // print('Phone selected');
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '${data[index]['telefono_shipping'].toString()}');

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.phone,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor:
                                        Color.fromARGB(255, 80, 78, 78),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // print('Message selected');
                                    var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.message,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor:
                                        Color.fromARGB(255, 80, 78, 78),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // print('Phone selected');
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '${data[index]['telefono_shipping'].toString()}');

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.phone,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor:
                                          Color.fromARGB(255, 80, 78, 78),
                                      shape: RoundedRectangleBorder()),
                                  onPressed: () async {
                                    // print('Message selected');
                                    var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.message,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor:
                                        Color.fromARGB(255, 80, 78, 78),
                                    shape: RoundedRectangleBorder(),
                                  ),
                                  onPressed: () async {
                                    /*
                                          setState(() {});
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return RoutesModalv2(
                                                idOrder: data[index]['id']
                                                    .toString(),
                                                someOrders: false,
                                                phoneClient: "",
                                                codigo:
                                                    "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                                                origin: "",
                                              );
                                            },
                                          );
                                          loadData();
                                          */
                                    showConfirmar(context, data[index], 1);
                                  },
                                  child: Icon(
                                    Icons.check,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor:
                                        Color.fromARGB(255, 80, 78, 78),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // var response = await Connections()
                                    //     .updateOrderInteralStatusLaravel(
                                    //         "NO DESEA",
                                    //         data[index]['id']
                                    //             .toString());

                                    //
                                    var response3 = await Connections()
                                        .updateOrderWithTime(
                                            data[index]['id'],
                                            "estado_interno:NO DESEA",
                                            sharedPrefs!.getString("id"),
                                            "",
                                            "");
                                    setState(() {});
                                    loadData();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: ColorsSystem().colorStore,
                                    size: 14,
                                  ),
                                ),
                              ],
                            )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  bool shouldShowApplyFilters() {
    // Comprobar si arrayFiltersAnd está vacío y las fechas coinciden
    bool isArrayEmpty = arrayFiltersAnd.isEmpty;
    // bool isStartDateDefault = _startDateController.text == "1/1/2023";
    // bool isEndDateDefault = _endDateController.text ==
    //     "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    // return isArrayEmpty && isStartDateDefault && isEndDateDefault;
    return isArrayEmpty;
  }

// Método para restablecer filtros
  void resetFilters() {
    arrayFiltersAnd.clear();
    _startDateController.text = "1/1/2023";
    _endDateController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    statusController.text = "TODO";
    setState(() {}); // Actualizar el estado
    // columnChecksActive = false;
    // optionsCheckBox.clear();
  }

  SizedBox resetFilterButton() {
    return SizedBox(
        height: 40,
        // width: 45,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(Colors.red),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
            onPressed: () {
              resetFilters();
              loadData();
            },
            child: const Row(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  color: Colors.white,
                )
              ],
            )));
  }

  SizedBox filterButton() {
    return SizedBox(
      height: 40,
      // width: 200, // Ancho de 200
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStatePropertyAll(ColorsSystem().colorSelected),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Borde redondeado de 5
            ),
          ),
        ),
        onPressed: () {
          loadData();
        },
        child: const Row(
          children: [
            Icon(
              Icons.search_outlined,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  SizedBox filterButtonFiltersModal() {
    return SizedBox(
      height: 40,
      width: 200, // Ancho de 200
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStatePropertyAll(ColorsSystem().colorSelected),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Borde redondeado de 5
            ),
          ),
        ),
        onPressed: () {
          loadData();
          Navigator.pop(context);
        },
        child: Text(
          "Filtrar",
          style: TextStylesSystem().ralewayStyle(
            11,
            FontWeight.w600,
            Colors.white,
          ),
        ),
      ),
    );
  }

  SizedBox filterButtonMobile() {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.3,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(shouldShowApplyFilters()
              ? ColorsSystem().colorSelected
              : Colors.red),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Borde redondeado de 5
            ),
          ),
        ),
        onPressed: () {
          // Navigator.pop(context);
          if (shouldShowApplyFilters()) {
            // Cambiar a "Aplicar Filtros"
            loadData();
          } else {
            resetFilters(); // Llamar a resetFilters si se cumplen las condiciones
            loadData();
          }
        },
        child: Text(
          shouldShowApplyFilters() ? "Aplicar Filtros" : "Quitar Filtros",
          style: TextStylesSystem().ralewayStyle(
            12,
            FontWeight.w500,
            Colors.white,
          ),
        ),
      ),
    );
  }

  Container startDateContainer(isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 190,
      height: isMobile == 1 ? 20 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _startDateController.text = await OpenCalendar();
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _startDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Container startDateContainerMobile(setState, isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 190,
      height: isMobile == 1 ? 40 : 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _startDateController.text = await OpenCalendar();
              setState(() {});
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _startDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Container endDateContainer(isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 190,
      height: isMobile == 1 ? 20 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _endDateController.text = await OpenCalendar();
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _endDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Container endDateContainerMobile(setState, isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 190,
      height: isMobile == 1 ? 40 : 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _endDateController.text = await OpenCalendar();
              setState(() {}); // Actualiza el estado del diálogo
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _endDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
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

  //   Container dropdownStatus(BuildContext context, isMobile) {
  //   return Container(
  //     width: 200,
  //     decoration: BoxDecoration(
  //       color: Colors.white, // Fondo blanco para el botón
  //       borderRadius:
  //           BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton2<String>(
  //         isExpanded: true,
  //         hint: Text(
  //           'Seleccionar',
  //           style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
  //               FontWeight.w500, ColorsSystem().colorSection2),
  //         ),
  //         items: listStatus
  //             .map(
  //               (item) => DropdownMenuItem<String>(
  //                 value: item,
  //                 child: Text(
  //                   item,
  //                   style: TextStylesSystem().ralewayStyle(
  //                       isMobile == 1 ? 11 : 14,
  //                       FontWeight.w500,
  //                       ColorsSystem().colorStore),
  //                 ),
  //               ),
  //             )
  //             .toList(),
  //         value: statusController.text,
  //         onChanged: (String? value) {
  //           setState(() {
  //             statusController.text = value ?? "";
  //           });

  //           arrayFiltersAnd
  //               .removeWhere((element) => element.containsKey("equals/status"));
  //           if (value != '') {
  //             if (value == "TODO") {
  //               arrayFiltersAnd.removeWhere(
  //                   (element) => element.containsKey("equals/status"));
  //             } else {
  //               arrayFiltersAnd.add({"equals/status": value});
  //             }
  //           }
  //         },
  //         buttonStyleData: ButtonStyleData(
  //           padding: EdgeInsets.symmetric(horizontal: 16),
  //           height: isMobile == 1 ? 20 : 40,
  //           width: 140,
  //           decoration: BoxDecoration(
  //             color: Colors.white, // Fondo blanco del botón
  //             borderRadius: BorderRadius.circular(
  //                 isMobile == 1 ? 5 : 10), // Bordes redondeados
  //           ),
  //         ),
  //         dropdownStyleData: DropdownStyleData(
  //           maxHeight: 200,
  //           decoration: BoxDecoration(
  //             color: Colors.white, // Fondo blanco del menú desplegable
  //             borderRadius: BorderRadius.circular(
  //                 isMobile == 1 ? 5 : 10), // Bordes redondeados
  //           ),
  //         ),
  //         menuItemStyleData: MenuItemStyleData(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //         ),
  //         iconStyleData: const IconStyleData(
  //           openMenuIcon: Icon(Icons.arrow_drop_up),
  //           icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
  //         ),
  //       ),
  //     ),
  //   );
  // }

  DataTable2 buildDataTable(
      String confirmadoVal, String logisticoVal, BuildContext context) {
    return DataTable2(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      dataRowColor: MaterialStateColor.resolveWith((states) {
        return Colors.white;
      }),
      dividerThickness: 1,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      dataTextStyle: const TextStyle(color: Colors.black),
      columnSpacing: 2,
      headingRowHeight: 50,
      horizontalMargin: 32,
      minWidth: 2700,
      dataRowHeight: 70,
      columns: columnsTable,
      rows: List<DataRow>.generate(
        data.length,
        (index) => DataRow(
          cells: cellsTable(index, context),
        ),
      ),
    );
  }

  List<DataCell> cellsTable(int index, BuildContext context) {
    return [
      DataCell(
        columnChecksActive == true
            ? Transform.scale(
                scale:
                    0.8, // Ajusta el valor para cambiar el tamaño (1.0 es el tamaño original)
                child: Checkbox(
                  value: verificarIndice(index),
                  onChanged: (value) {
                    setState(() {
                      int calculatedIndex =
                          index + ((currentPage - 1) * pageSize);

                      // Asegúrate de que optionsCheckBox tenga suficientes elementos.
                      if (optionsCheckBox.length <= calculatedIndex) {
                        optionsCheckBox.addAll(List.generate(
                          calculatedIndex - optionsCheckBox.length + 1,
                          (i) => {'check': false, 'id': '', 'numero_orden': ''},
                        ));
                      }

                      if (value!) {
                        optionsCheckBox[calculatedIndex]['check'] = value;
                        optionsCheckBox[calculatedIndex]['id'] =
                            data[index]['id'];
                        optionsCheckBox[calculatedIndex]['numero_orden'] =
                            data[index]['numero_orden'];

                        if (data[index]['estado_logistico'].toString() ==
                                "IMPRESO" ||
                            data[index]['estado_logistico'].toString() ==
                                "ENVIADO") {
                          noDeseaEnabled = false;
                        }

                        counterChecks += 1;
                      } else {
                        optionsCheckBox[calculatedIndex]['check'] = value;
                        optionsCheckBox[calculatedIndex]['id'] = '';
                        counterChecks -= 1;
                      }

                      enabledBusqueda = counterChecks <= 0;
                    });
                  },
                ),
              )
            : Container(width: 1),
      ),

      // DataCell(
      //   SingleChildScrollView(
      //     scrollDirection: Axis.horizontal,
      //     child: (data[index]['estado_logistico'].toString() != "PENDIENTE")
      //         ? Row(
      //             children: [
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                   backgroundColor: Colors.transparent,
      //                   shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                   shape: const RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.horizontal(
      //                       left: Radius.circular(10.0),
      //                     ),
      //                   ),
      //                 ),
      //                 onPressed: () async {
      //                   // print('Phone selected');
      //                   var _url = Uri(
      //                       scheme: 'tel',
      //                       path:
      //                           '${data[index]['telefono_shipping'].toString()}');

      //                   if (!await launchUrl(_url)) {
      //                     throw Exception('Could not launch $_url');
      //                   }
      //                 },
      //                 child: Icon(
      //                   Icons.phone,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                     backgroundColor: Colors.transparent,
      //                     shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                     shape: RoundedRectangleBorder()),
      //                 onPressed: () async {
      //                   // print('Message selected');
      //                   var _url = Uri.parse(
      //                       """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
      //                   if (!await launchUrl(_url)) {
      //                     throw Exception('Could not launch $_url');
      //                   }
      //                 },
      //                 child: Icon(
      //                   Icons.message,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //             ],
      //           )
      //         : Row(
      //             children: [
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                   backgroundColor: Colors.transparent,
      //                   shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                   shape: const RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.horizontal(
      //                       left: Radius.circular(10.0),
      //                     ),
      //                   ),
      //                 ),
      //                 onPressed: () async {
      //                   // print('Phone selected');
      //                   var _url = Uri(
      //                       scheme: 'tel',
      //                       path:
      //                           '${data[index]['telefono_shipping'].toString()}');

      //                   if (!await launchUrl(_url)) {
      //                     throw Exception('Could not launch $_url');
      //                   }
      //                 },
      //                 child: Icon(
      //                   Icons.phone,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                     backgroundColor: Colors.transparent,
      //                     shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                     shape: RoundedRectangleBorder()),
      //                 onPressed: () async {
      //                   // print('Message selected');
      //                   var _url = Uri.parse(
      //                       """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
      //                   if (!await launchUrl(_url)) {
      //                     throw Exception('Could not launch $_url');
      //                   }
      //                 },
      //                 child: Icon(
      //                   Icons.message,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                   backgroundColor: Colors.transparent,
      //                   shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                   shape: RoundedRectangleBorder(),
      //                 ),
      //                 onPressed: () async {
      //                   /*
      //                               setState(() {});
      //                               await showDialog(
      //                                 context: context,
      //                                 builder: (context) {
      //                                   return RoutesModalv2(
      //                                     idOrder: data[index]['id']
      //                                         .toString(),
      //                                     someOrders: false,
      //                                     phoneClient: "",
      //                                     codigo:
      //                                         "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
      //                                     origin: "",
      //                                   );
      //                                 },
      //                               );
      //                               loadData();
      //                               */
      //                   showConfirmar(context, data[index], 0);
      //                 },
      //                 child: Icon(
      //                   Icons.check,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //               TextButton(
      //                 style: TextButton.styleFrom(
      //                   backgroundColor: Colors.transparent,
      //                   shadowColor: Color.fromARGB(255, 80, 78, 78),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.horizontal(
      //                       right: Radius.circular(10.0),
      //                     ),
      //                   ),
      //                 ),
      //                 onPressed: () async {
      //                   // var response = await Connections()
      //                   //     .updateOrderInteralStatusLaravel(
      //                   //         "NO DESEA",
      //                   //         data[index]['id']
      //                   //             .toString());

      //                   //
      //                   var response3 = await Connections().updateOrderWithTime(
      //                       data[index]['id'],
      //                       "estado_interno:NO DESEA",
      //                       sharedPrefs!.getString("id"),
      //                       "",
      //                       "");
      //                   setState(() {});
      //                   loadData();
      //                 },
      //                 child: Icon(
      //                   Icons.close,
      //                   color: ColorsSystem().colorStore,
      //                   size: 14,
      //                 ),
      //               ),
      //             ],
      //           ),
      //   ),
      // ),
      
DataCell(
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white, // Cambia esto al color de fondo deseado
          // textStyle: TextStyle(color: Colors.white), // Cambia el color del texto
        ),
      ),
      child: PopupMenuButton(
        tooltip: 'Opciones', // Cambia este texto o déjalo vacío
        icon: Icon(Icons.more_vert, color: ColorsSystem().colorStore, size: 16),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'phone',
            child: Row(
              children: [
                Icon(Icons.phone, color: ColorsSystem().colorStore, size: 16),
                SizedBox(width: 5),
                Text("Llamar"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'whatsapp',
            child: Row(
              children: [
                Icon(Icons.message, color: ColorsSystem().colorStore, size: 16),
                SizedBox(width: 5),
                Text("WhatsApp"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'confirm',
            child: Row(
              children: [
                Icon(Icons.check, color: ColorsSystem().colorStore, size: 16),
                SizedBox(width: 5),
                Text("Confirmar"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.close, color: ColorsSystem().colorStore, size: 16),
                SizedBox(width: 5),
                Text("Cancelar"),
              ],
            ),
          ),
        ],
        onSelected: (value) async {
          if (value == 'phone') {
            var _url = Uri(scheme: 'tel', path: data[index]['telefono_shipping'].toString());
            if (!await launchUrl(_url)) {
              throw Exception('Could not launch $_url');
            }
          } else if (value == 'whatsapp') {
            var _url = Uri.parse(
              """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido..."""
            );
            if (!await launchUrl(_url)) {
              throw Exception('Could not launch $_url');
            }
          } else if (value == 'confirm') {
            showConfirmar(context, data[index], 0);
          } else if (value == 'cancel') {
            await Connections().updateOrderWithTime(
              data[index]['id'],
              "estado_interno:NO DESEA",
              sharedPrefs!.getString("id"),
              "",
              "",
            );
            setState(() {});
            loadData();
          }
        },
      ),
    ),
  ),
),


      DataCell(
          Text(
            '${data[index]['marca_t_i'].toString()}',
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}"
                .toString(),
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ), onTap: () {
        info(context, index);
      }),
      // DataCell(Text(data[index]['ciudad_shipping'].toString()), onTap: () {
      //   info(context, index);
      // }),
      DataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centra el contenido
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
          children: [
            Container(
              alignment: Alignment.center, // Centra el texto
              width: 450, // Ancho fijo para uniformidad
              child: Text(
                data[index]['nombre_shipping'] != null
                    ? data[index]['nombre_shipping'].toString()
                    : "sin registro",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // Alineación interna
                style: TextStylesSystem()
                    .montserratStyle(13, FontWeight.w500, Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 450,
              child: Text(
                data[index]['direccion_shipping'] != null
                    ? data[index]['direccion_shipping'].toString()
                    : "sin registro",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStylesSystem()
                    .montserratStyle(13, FontWeight.w500, Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 450,
              child: Text(
                data[index]['telefono_shipping'] != null
                    ? data[index]['telefono_shipping'].toString()
                    : "sin registro",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStylesSystem()
                    .montserratStyle(13, FontWeight.w500, Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 450,
              child: Text(
                data[index]['ciudad_shipping'] != null
                    ? data[index]['ciudad_shipping'].toString()
                    : "sin registro",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStylesSystem()
                    .montserratStyle(13, FontWeight.w500, Colors.black),
              ),
            ),
          ],
        ),
        onTap: () {
          info(context, index);
        },
      ),
      DataCell(
          Text(
            data[index]['cantidad_total'].toString(),
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['producto_p'].toString(),
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
        Text(
          data[index]['producto_extra'] == null ||
                  data[index]['producto_extra'] == "null"
              ? ""
              : data[index]['producto_extra'].toString(),
          style: TextStylesSystem()
              .montserratStyle(13, FontWeight.w500, Colors.black),
        ),
        onTap: () {
          info(context, index);
        },
      ),
      DataCell(
          Text(
            '\$${data[index]['precio_total'].toString()}',
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
        Text(
          data[index]['observacion'] == null ||
                  data[index]['observacion'] == "null"
              ? ""
              : data[index]['observacion'].toString(),
          style: TextStylesSystem()
              .montserratStyle(13, FontWeight.w500, Colors.black),
        ),
        onTap: () {
          info(context, index);
        },
      ),
      DataCell(
        Container(
          decoration: BoxDecoration(
            color: UIUtils.getColorStateArea(
              data[index]['status_history'].toString() == "null" ||
                      data[index]['status_history'].toString() == "[]"
                  ? (data[index]['status'].toString() == "NOVEDAD" ||
                              data[index]['status'].toString() ==
                                  "NO ENTREGADO") &&
                          data[index]['estado_devolucion'].toString() !=
                              "PENDIENTE"
                      ? "estado_devolucion:${data[index]['estado_devolucion'].toString()}"
                      : "status:${data[index]['status'].toString()}"
                  : getLastStatusFromJson(
                      data[index]['status_history'].toString(),
                    ).toString(),
            ).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            (data[index]['estado_interno'].toString() == "PENDIENTE") &&
                    (data[index]['estado_logistico'].toString() == "PENDIENTE")
                ? "PENDIENTE POR CONFIRMAR"
                : (data[index]['estado_interno'].toString() == "CONFIRMADO") &&
                        (data[index]['estado_logistico'].toString() ==
                            "PENDIENTE")
                    ? data[index]['estado_interno'].toString()
                    : (() {
                        String? lastStatus = getLastStatusFromJson(
                            data[index]['status_history']?.toString());
                        if (lastStatus != null) {
                          List<String> parts = lastStatus.split(":");
                          return parts.length > 1 ? parts[1] : lastStatus;
                        }
                        // Valor predeterminado si todo lo demás falla
                        return data[index]['estado_logistico']?.toString() ??
                            "SIN ESTADO";
                      })(),
            style: TextStylesSystem()
                .montserratStyle(13, FontWeight.w500, Colors.black),
          ),
        ),
      ),
      DataCell(
          Row(
            children: [
              Container(
                width: 80,
                child: Text(
                  data[index]['fecha_confirmacion'] == null ||
                          data[index]['fecha_confirmacion'] == "null"
                      ? ""
                      : data[index]['fecha_confirmacion'].toString(),
                  style: TextStylesSystem()
                      .montserratStyle(13, FontWeight.w500, Colors.black),
                ),
                /*Text(data[index]
                                          ['fecha_confirmacion']
                                      .toString()),
                                      */
              ),
              data[index]['estado_interno'] == "PENDIENTE"
                  ? TextButton(
                      onPressed: () {
                        Calendar(data[index]['id'].toString())
                            .then((value) => paginateData());
                      },
                      child: Icon(Icons.calendar_today),
                    )
                  : Container(),
            ],
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
        Text(
          data[index]['transportadora'] != null &&
                  data[index]['transportadora'].isNotEmpty
              // ? data[index]['transportadora'][0]['nombre'].toString()
              ? "Logec"
              : data[index]['pedido_carrier'].isNotEmpty
                  ? data[index]['pedido_carrier'][0]['carrier']['name']
                      .toString()
                  : "",
          style: TextStylesSystem()
              .montserratStyle(13, FontWeight.w500, Colors.black),
        ),
        onTap: () {
          info(context, index);
        },
      ),
    ];
  }

  List<DataColumn> get columnsTable {
    return [
      DataColumn2(
        label: Container(
          width: 20, // Ancho fijo para la columna
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Color de fondo azul
              padding: EdgeInsets
                  .zero, // Eliminar el relleno para reducir el tamaño del botón
            ),
            onPressed: () {
              // Acción al presionar el botón
              // print("Botón presionado");
              setState(() {
                columnChecksActive = !columnChecksActive;
              });
            },
            child: Icon(Icons.check, color: Colors.white), // Icono blanco
          ),
        ),
        size: ColumnSize.S,
        fixedWidth:
            40, // Asegúrate de que el ancho fijo coincida con el ancho del contenedor
      ),
      const DataColumn2(
        fixedWidth: 50,
        label: Text(''),
        size: ColumnSize.L,
      ),
      DataColumn2(
        fixedWidth: 130,
        label: Text(
          'Fecha Ingreso',
          style: TextStylesSystem()
              .montserratStyle(14, FontWeight.w600, Colors.black),
        ),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFuncDate("Marca_T_I");
          sortFunc3("marca_t_i", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 120,
        label: Text('Código',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("numero_orden", changevalue);
        },
      ),
      // DataColumn2(
      //   label: Text('Ciudad'),
      //   size: ColumnSize.M,
      //   onSort: (columnIndex, ascending) {
      //     sortFunc3("ciudad_shipping", changevalue);
      //   },
      // ),
      DataColumn2(
        label: Center(
            child: Text('Datos Cliente',
                style: TextStylesSystem()
                    .montserratStyle(14, FontWeight.w600, Colors.black))),
        size: ColumnSize.L,
        fixedWidth: 450,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 100,
        label: Text('Cantidad',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("cantidad_total", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Producto',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("producto_p", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Producto Extra',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("producto_extra", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 100,
        label: Text('Precio T.',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("precio_total", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Observación',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        fixedWidth: 150,
        label: Text('Estado',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.S,
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Marca Fecha Confirmación',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("fecha_confirmacion", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 120,
        label: Text('Transportadora',
            style: TextStylesSystem()
                .montserratStyle(14, FontWeight.w600, Colors.black)),
        size: ColumnSize.M,
      ),
    ];
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          // buttonSize: Size(30, 30), // Ajusta el tamaño del botón
          // buttonSelectedForegroundColor: Colors.white,
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          // height: 100,
          // contentPadding: EdgeInsets.only(bottom: 10),
          mainAxisAlignment: MainAxisAlignment.center,
          mode: ContentDisplayMode.numbers),
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

  void modalInfoNewVersionWithSections(BuildContext context, item) {
    // Control de estado para las secciones colapsables (declarado fuera del StatefulBuilder)
    final Map<String, bool> secciones = {
      'Información': false,
      'Datos Cliente': false,
      'Producto': false,
      'Transportadora': false,
    };

    final Map<String, List<Widget>> contenidoSecciones = {
      'Información': [
        Text(
          "${item['marca_t_i'].toString()}",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorsSystem().colorLabels,
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Botón de la Sección 1'),
        ),
      ],
      'Datos Cliente': [
        const Icon(Icons.star, size: 40),
        const Text('Descripción de la Sección 2'),
      ],
      'Producto': [
        const TextField(
          decoration: InputDecoration(labelText: 'Campo de texto'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Botón de la Sección 3'),
        ),
      ],
      'Transportadora': [
        const TextField(
          decoration: InputDecoration(labelText: 'Campo de texto'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Botón de la Sección 4'),
        ),
      ]
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['pedido_carrier'].isNotEmpty
                              ? '${sharedPrefs!.getString("NameComercialSeller").toString()}-${item['numero_orden'].toString()} / ${item['pedido_carrier'][0]['external_id'].toString()}'
                              : '${sharedPrefs!.getString("NameComercialSeller").toString()}-${item['numero_orden'].toString()}',

                          // item["id"].toString(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorsSystem().colorLabels),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: UIUtils.getColorStateArea(
                              item['status_history'].toString() == "null" ||
                                      item['status_history'].toString() == "[]"
                                  ? (item['status'].toString() == "NOVEDAD" ||
                                              item['status'].toString() ==
                                                  "NO ENTREGADO") &&
                                          item['estado_devolucion']
                                                  .toString() !=
                                              "PENDIENTE"
                                      ? "estado_devolucion:${item['estado_devolucion'].toString()}"
                                      : "status:${item['status'].toString()}"
                                  : getLastStatusFromJson(
                                      item['status_history'].toString(),
                                    ).toString(),
                            ).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['estado_interno'].toString() == "PENDIENTE"
                                ? "PENDIENTE POR CONFIRMAR"
                                : (item['estado_interno'].toString() ==
                                            "CONFIRMADO") &&
                                        (item['estado_logistico'].toString() ==
                                            "PENDIENTE")
                                    ? item['estado_interno'].toString()
                                    : getLastStatusFromJson(
                                        item['status_history'].toString(),
                                      ).toString().split(":")[1],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: secciones.keys.map((seccion) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título de la sección con un icono desplegable
                              ListTile(
                                title: Text(
                                  seccion,
                                  style: TextStylesSystem().ralewayStyle(
                                      12,
                                      FontWeight.w600,
                                      ColorsSystem().colorLabels),
                                ),
                                trailing: Icon(
                                  secciones[seccion]!
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () {
                                  setState(() {
                                    secciones[seccion] = !secciones[seccion]!;
                                  });
                                },
                              ),
                              // Contenido de la sección (desplegable)
                              if (secciones[seccion]!)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: contenidoSecciones[seccion]!,
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Row paginationComplete() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Distribuir los elementos
      children: [
        // Sección de resultados a la izquierda
        Text(
          '$from - $to de $total resultados',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Center(child: Container(width: 400, child: numberPaginator())),
        // Text("aqui va el dropdown"),
        // Dropdown a la derecha
        dropdownPagination()
      ],
    );
  }

  Row paginationPhoneComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Distribuir los elementos
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: numberPaginator()),
      ],
    );
  }

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value:
          pageSize, // Valor actual seleccionado (cantidad de registros por página)
      items: [
        DropdownMenuItem<int>(value: 70, child: Text('70')),
        DropdownMenuItem<int>(value: 100, child: Text('100')),
        DropdownMenuItem<int>(value: 200, child: Text('200')),
        DropdownMenuItem<int>(value: 1000, child: Text('1000')),
      ],
      onChanged: (newValue) {
        setState(() {
          pageSize = newValue!;
          paginateData(); // Llama a la función de paginación con la nueva cantidad
        });
      },
      style: TextStyle(fontSize: 12, color: Colors.black),
      dropdownColor: Colors.white,
    );
  }

  String listToDelete() {
    String res = "";

    for (var i = 0; i < optionsCheckBox.length; i++) {
      if (optionsCheckBox[i]['check'] == true) {
        res += sharedPrefs!.getString("NameComercialSeller").toString() +
            "-" +
            optionsCheckBox[i]['numero_orden'] +
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

  Future<dynamic> openDialog(
      BuildContext context, width, height, content, onDispose) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(width: width, height: height, child: content),
          );
        }).then((value) {
      onDispose;
    });
  }

  String? getLastStatusFromJson(String? statusHistoryJson) {
    if (statusHistoryJson == null || statusHistoryJson.isEmpty) {
      return null;
    }

    try {
      // Decodifica el JSON
      List<dynamic>? statusHistory = jsonDecode(statusHistoryJson);

      // Verifica si la lista es null o está vacía
      if (statusHistory == null || statusHistory.isEmpty) {
        return null;
      }

      // Invierte la lista para obtener el último estado
      statusHistory = statusHistory.reversed.toList();

      // Obtiene la última entrada
      var lastEntry = statusHistory.first;
      String? status = lastEntry['status'] as String?;
      String? area = lastEntry['area'] as String?;

      // Devuelve el resultado combinado
      return '$area:$status';
    } catch (e) {
      print('Error al procesar el JSON: $e');
      return null;
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
    return openDialog(
        context,
        data[index]["estado_logistico"].toString() != "PENDIENTE"
            ? MediaQuery.of(context).size.width * 0.34
            : MediaQuery.of(context).size.width * 0.7,
        // MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height,
        responsive(
            Container(
              // color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        data[index]['pedido_carrier'].isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden'].toString()}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsSystem().colorLabels),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        data[index]['pedido_carrier'][0]
                                                ['external_id']
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsSystem().colorLabels),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    // data[index]['pedido_carrier'].isNotEmpty
                                    // ? '${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden'].toString()} / ${data[index]['pedido_carrier'][0]['external_id'].toString()}'

                                    "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden'].toString()}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: ColorsSystem().colorLabels),
                                  ),
                                ],
                              ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: UIUtils.getColorStateArea(
                                data[index]['status_history'].toString() ==
                                            "null" ||
                                        data[index]['status_history']
                                                .toString() ==
                                            "[]"
                                    ? (data[index]['status'].toString() ==
                                                    "NOVEDAD" ||
                                                data[index]['status']
                                                        .toString() ==
                                                    "NO ENTREGADO") &&
                                            data[index]['estado_devolucion']
                                                    .toString() !=
                                                "PENDIENTE"
                                        ? "estado_devolucion:${data[index]['estado_devolucion'].toString()}"
                                        : "status:${data[index]['status'].toString()}"
                                    : getLastStatusFromJson(
                                        data[index]['status_history']
                                            .toString(),
                                      ).toString(),
                              ).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data[index]['estado_interno'].toString() ==
                                      "PENDIENTE"
                                  ? "PENDIENTE POR CONFIRMAR"
                                  : (data[index]['estado_interno'].toString() ==
                                              "CONFIRMADO") &&
                                          (data[index]['estado_logistico']
                                                  .toString() ==
                                              "PENDIENTE")
                                      ? data[index]['estado_interno'].toString()
                                      : getLastStatusFromJson(
                                          data[index]['status_history']
                                              .toString(),
                                        ).toString().split(":")[1],

                              // data[index]['status_history'].toString() ==
                              //             "null" ||
                              //         data[index]['status_history']
                              //                 .toString() ==
                              //             "[]"
                              //     ? (data[index]['status'].toString() ==
                              //                     "NOVEDAD" ||
                              //                 data[index]['status']
                              //                         .toString() ==
                              //                     "NO ENTREGADO") &&
                              //             data[index]['estado_devolucion']
                              //                     .toString() !=
                              //                 "PENDIENTE"
                              //         ? data[index]['estado_devolucion']
                              //             .toString()
                              //         : data[index]['status'].toString()
                              //     : getLastStatusFromJson(
                              //         data[index]['status_history'].toString(),
                              //       ).toString().split(":")[1],
                              style: TextStylesSystem().ralewayStyle(
                                14, // Tamaño de la fuente
                                FontWeight.w500, // Peso de la fuente medio
                                ColorsSystem().colorLabels, // Color del label
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "${data[index]['marca_t_i'].toString()}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorsSystem().colorLabels,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       loadData();
                  //       Navigator.pop(context);
                  //     },
                  //     child: const Icon(Icons.close),
                  //   ),
                  // ),
                  Expanded(
                      child: OrderInfo(
                          order: data[index],
                          index: index,
                          sumarNumero: sumarNumero,
                          codigo:
                              "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                          data: data)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: buttonLeft,
                        child: IconButton(
                          iconSize: 60,
                          onPressed: () => {PreviusInfo(index)},
                          icon: Icon(Icons.arrow_circle_left_outlined,
                              color: ColorsSystem().colorInitialContainer),
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
                          icon: Icon(
                            Icons.arrow_circle_right_outlined,
                            color: ColorsSystem().colorInitialContainer,
                          ),
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
                          loadData();
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                    Expanded(
                        child: OrderInfo(
                            order: data[index],
                            index: index,
                            sumarNumero: sumarNumero,
                            codigo:
                                "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                            data: data)),
                  ],
                ),
              ),
            ),
            context),
        () {});
  }

  // bool verificarIndice(int index) {
  //   try {
  //     dynamic elemento =
  //         optionsCheckBox.elementAt(index + ((currentPage - 1) * pageSize));
  //     // print("elemento="+elemento.toString());
  //     if (elemento['id'] != data[index]['id']) {
  //       return false;
  //     } else {
  //       return true;
  //     }
  //   } catch (error) {
  //     return false;
  //   }
  // }

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
      optionsCheckBox.add({"check": false, "id": "", "numero_orden": ""});
    }
    setState(() {
      counterChecks = 0;
      enabledBusqueda = true;
    });
  }

  _modelTextField({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      width: double.infinity,
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
        style: TextStylesSystem()
            .ralewayStyle(14, FontWeight.w500, ColorsSystem().colorSection2),
        decoration: InputDecoration(
          fillColor: Colors.white,
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
          iconColor: ColorsSystem().colorSection2,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
            borderSide: BorderSide.none, // Elimina los bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
        ),
      ),
    );
  }

  _modelTextFieldMobile({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      width: double.infinity,
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
        style: TextStylesSystem()
            .ralewayStyle(12, FontWeight.w500, ColorsSystem().colorSection2),
        decoration: InputDecoration(
          fillColor: Colors.white,
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
          iconColor: ColorsSystem().colorSection2,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
            borderSide: BorderSide.none, // Elimina los bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
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

  sortFunc3(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        // changevalue = true;
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
  }

  Future<dynamic> showNuevo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return const AlertDialog(
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: AddOrderSellersLaravel(),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showConfirmar(BuildContext context, order, isMobile) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: ConfirmCarrier(
                order: order,
                isMobile: isMobile,
              ),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }
}
