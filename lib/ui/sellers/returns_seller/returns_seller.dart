// import 'dart:html';
// import 'dart:js_util';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/returns/controllers/controllers.dart';
// import 'package:frontend/ui/sellers/returns_seller/expandable_data_table.dart';
import 'package:frontend/ui/sellers/returns_seller/return_details_data.dart';
import 'package:frontend/ui/sellers/returns_seller/scanner_return.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
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
  String from = '0.0';
  String to = '0.0';

  bool isFirst = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    "receivedBy",
    "pedidoCarrierSimple",
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
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    currentPage = 1;
    try {
      setState(() {
        isLoading = true;
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
        arrayFiltersNotEq,
        sortFieldDefaultValue.toString(),
        [],
        [],
      );
      setState(() {
        data = responseLaravel['data'];
        from = responseLaravel['from'].toString();
        to = responseLaravel['to'].toString();
        pageCount = responseLaravel['last_page'];
        if (sortFieldDefaultValue.toString() == "id:DESC") {
          total = responseLaravel['total'];
        }
        paginatorController.navigateToPage(0);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  paginateData() async {
    try {
      // setState(() {
      isLoading = true;
      // });

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
        sortFieldDefaultValue.toString(),
        [],
        [],
      );

      data = responseLaravel['data'];

      setState(() {
        from = responseLaravel['from'].toString();
        to = responseLaravel['to'].toString();
        pageCount = responseLaravel['last_page'];
        total = responseLaravel['total'];
      });

      // setState(() {
      isLoading = false;
      // });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        content: Scaffold(
          key: _scaffoldKey,
          body: Container(
              height: double.infinity,
              width: double.infinity,
              child: responsive(webMainContainer(context),
                  mobileMainContainer(context), context)),
        ),
        isLoading: isLoading);
  }

  Container searchBarOnly(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.20,
      child: _modelTextField(
        text: "Buscar",
        controller: _controllers.searchController,
      ),
    );
  }

  Container searchBarOnlyM(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.9,
      child: _modelTextFieldMobile(
        text: "Buscar",
        controller: _controllers.searchController,
      ),
    );
  }

  Stack webMainContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 230,
              color: ColorsSystem().colorInitialContainer,
            )
          ],
        ),
        contentPrintipal(context)
      ],
    );
  }

  Stack mobileMainContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 230,
              color: ColorsSystem().colorInitialContainer,
            )
          ],
        ),
        contentMobilePrincipal(context)
      ],
    );
  }

  Positioned contentPrintipal(BuildContext context) {
    return Positioned(
        top: 20,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height * 0.95,
        child: LayoutBuilder(
          builder: ((context, constraints) {
            return Container(
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fistWidgetRow(),
                  customSizedBox(10),
                  secondWidgetRow(context),
                  containerTable(context),
                  customSizedBox(5),
                  data.isNotEmpty ? paginationComplete() : Container()
                ],
              ),
            );
          }),
        ));
  }

  Positioned contentMobilePrincipal(BuildContext context) {
    return Positioned(
        top: 8,
        left: 15,
        right: 15,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Devoluciones",
                                    style: TextStylesSystem().ralewayStyle(
                                        16,
                                        FontWeight.w700,
                                        ColorsSystem().colorStore),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Registros: $total",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsSystem().colorStore,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          searchBarOnlyM(context, 30),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                dropdownPagination(),
              ],
            ),
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
                              // Método que se llama al dar clic en la tarjeta completa
                              // withdrawalInfo(context, item);
                              showDialogInfoData(item);
                            },
                            child: cardReturn(item),
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
          ],
        ));
  }

  Card cardReturn(Map<String, dynamic> item) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['users'] != null && item['users'].isNotEmpty ? item['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${item['numero_orden'].toString()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GetColor(item['estado_devolucion']),
                  ),
                ),
                Text(
                  item['fecha_entrega'] ?? 'Fecha no disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estado del pedido con color dinámico
                Text(
                  "${item['estado_devolucion']}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorLabels,
                  ),
                ),
                Icon(
                  Icons.shopping_bag_outlined,
                  color: ColorsSystem().colorSelected,
                  size: 22,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['transportadora'] != null &&
                          item['transportadora'].isNotEmpty
                      ? "Transportadora: ${item['transportadora'][0]['nombre'].toString()}"
                      : 'Transportadora: No Disponible',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorLabels,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['received_by'] != null && item['received_by'].isNotEmpty
                      ? "Recibido por: ${item['received_by']['username'].toString()}-${item['received_by']['id'].toString()}"
                      : 'Recibido por: No Disponible',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorLabels,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row paginationPhoneComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Distribuir los elementos
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: numberPaginatorMobile()),
      ],
    );
  }

  SizedBox customSizedBox(height) {
    return SizedBox(
      height: height,
    );
  }

  Container containerTable(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: buildDataTable(context),
      // child: ExpandableDataTable(data:data),
    );
  }

  Row secondWidgetRow(BuildContext context) {
    return Row(
      children: [
        // Contenedor para los dos primeros widgets alineados a la izquierda
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                    height:
                        10), // Espacio entre el texto y el campo de búsqueda
                searchBarOnly(context, 40),
              ],
            ),
            const SizedBox(
                width: 10), // Espacio entre el campo de búsqueda y el botón
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10), // Espacio entre el texto y el botón
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return ScannerReturn();
                        },
                      );
                      await loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          ColorsSystem().colorStore, // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Bordes redondeados
                      ),
                    ),
                    child: Text(
                      "SCANNER",
                      style: TextStylesSystem()
                          .ralewayStyle(16, FontWeight.w600, Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Spacer(), // Empuja el último widget hacia la derecha
        // Widget de la derecha
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Registros: ",
                style: TextStylesSystem().ralewayStyle(
                    18, FontWeight.w700, ColorsSystem().colorStore)),
            SizedBox(height: 5),
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
    );
  }

  Row fistWidgetRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Devoluciones',
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
            ),
          ],
        ),
      ),
    ]);
  }

  Row paginationComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value:
          pageSize, // Valor actual seleccionado (cantidad de registros por página)
      items: [
        // DropdownMenuItem<int>(value: 10, child: Text('10')),
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

  DataTable2 buildDataTable(BuildContext context) {
    return DataTable2(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      dataRowColor: MaterialStateColor.resolveWith((states) {
        return Colors.white;
      }),
      headingTextStyle: TextStylesSystem()
          .ralewayStyle(14, FontWeight.bold, ColorsSystem().colorLabels),
      dataTextStyle: const TextStyle(color: Colors.black),
      columnSpacing: 12,
      horizontalMargin: 6,
      minWidth: 2000,
      headingRowHeight: 70,
      showCheckboxColumn: false,
      columns: columns,
      rows: rows(context),
    );
  }

  String? getLastStatusFromJson(String statusHistoryJson) {
    try {
      List<dynamic> statusHistory = jsonDecode(statusHistoryJson);

      statusHistory = statusHistory.reversed.toList();

      var lastEntry = statusHistory.first;
      String? status = lastEntry['status'] as String?;
      String? area = lastEntry['area'] as String?;

      return '$area:$status';
    } catch (e) {
      print('Error al procesar el JSON: $e');
      return null;
    }
  }

  List<DataRow> rows(BuildContext context) {
    return List<DataRow>.generate(
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
                        color: GetColor(
                            data[index]['estado_devolucion'].toString())!),
                    data[index]['pedido_carrier_simple'].isNotEmpty
                        ? '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()} / ${data[index]['pedido_carrier_simple'][0]['external_id'].toString()}'
                        : '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}'),
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
              Container(
                decoration: BoxDecoration(
                  color: UIUtils.getColorStateArea(
                    data[index]['status_history'].toString() == "null" || data[index]['status_history'].toString() == "[]"
                        ? (data[index]['status'].toString() == "NOVEDAD" ||data[index]['status'].toString() == "NO ENTREGADO") &&
                                data[index]['estado_devolucion'].toString() != "PENDIENTE"
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
                  data[index]['status_history'].toString() == "null" || data[index]['status_history'].toString() == "[]"
                      ? (data[index]['status'].toString() == "NOVEDAD" || data[index]['status'].toString() == "NO ENTREGADO") && data[index]['estado_devolucion'].toString() != "PENDIENTE"
                          ? data[index]['estado_devolucion'].toString()
                          : data[index]['status'].toString()
                      : getLastStatusFromJson(
                          data[index]['status_history'].toString(),
                        ).toString().split(":")[1],
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              onTap: () {
                // if (data[index]['status_history'].toString() != "null" &&
                //     data[index]['status_history'].toString() != "[]") {
                //   String code =
                //       '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}';
                //   showInfoStatusHistory(
                //     context,
                //     data[index]['status_history'].toString(),
                //     code,
                //   );
                // }
                showDialogInfoData(data[index]);
              },
            ),
            // DataCell(
            //     Text(
            //       data[index]['status'].toString(),
            //       style: TextStyle(
            //         color: rowColor,
            //       ),
            //     ), onTap: () {
            //   showDialogInfoData(data[index]);
            // }),
            // DataCell(
            //     Text(
            //       data[index]['estado_devolucion'] == null ||
            //               data[index]['estado_devolucion'] == "null"
            //           ? ""
            //           : data[index]['estado_devolucion'].toString(),
            //       style: TextStyle(
            //         color: rowColor,
            //       ),
            //     ), onTap: () {
            //   showDialogInfoData(data[index]);
            // }),
            DataCell(
                Text(
                  data[index]['transportadora'] != null &&
                          data[index]['transportadora'].isNotEmpty
                      // ? data[index]['transportadora'][0]['nombre'].toString()
                      ? "Logec"
                      : data[index]['pedido_carrier_simple'].isNotEmpty
                          ? data[index]['pedido_carrier_simple'][0]
                                  ['carrier_simple']['name']
                              .toString()
                          : "",
                ), onTap: () {
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
    );
  }

  List<DataColumn> get columns {
    return [
      DataColumn2(
        label: Text('Fecha Entrega'),
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
      DataColumn2(
        label: Text('Estado de Entrega'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          // sortFunc2("precio_total", changevalue);
        },
      ),
      // DataColumn2(
      //   label: SelectFilter('Status', 'status', statusController, listStatus),
      //   size: ColumnSize.L,
      //   numeric: true,
      //   onSort: (columnIndex, ascending) {
      //     sortFunc2("status", changevalue);
      //   },
      // ),
      // DataColumn2(
      //   label: SelectFilter('Estado Devolución', 'estado_devolucion',
      //       estadoDevolucionController, listEstadoDevolucion),
      //   size: ColumnSize.L,
      //   numeric: true,
      //   onSort: (columnIndex, ascending) {
      //     sortFunc2("estado_devolucion", changevalue);
      //   },
      // ),
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
    ];
  }

  Future<dynamic> showDialogInfoData(data) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.3,
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
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(14, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left, // Centra el texto
        decoration: InputDecoration(
          fillColor: Colors.white, // Color de fondo del campo
          // filled: true, // Asegura que el color de fondo se aplique
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      loadData();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          // focusColor: Color(0xFFE8DEF8),
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
        color: Colors.white, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(11, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left, // Centra el texto
        decoration: InputDecoration(
          fillColor: Colors.white, // Color de fondo del campo
          // filled: true, // Asegura que el color de fondo se aplique
          prefixIcon: const Icon(
            Icons.search,
            size: 11,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      loadData();
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 11,
                  ))
              : null,
          hintText: text,
          // focusColor: Color(0xFFE8DEF8),
          iconColor: ColorsSystem().colorSection2,
          contentPadding: const EdgeInsets.only(bottom: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5), // Esquinas redondeadas
            borderSide: BorderSide.none, // Elimina los bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
        ),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
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

  NumberPaginator numberPaginatorMobile() {
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
}
