import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/audit/audit_data_info.dart';
import 'package:frontend/ui/logistic/audit/generate_report_audit_data.dart';
import 'package:frontend/ui/widgets/logistic/customwidgetvalues.dart';
import 'package:number_paginator/number_paginator.dart';
import '../../widgets/loading.dart';
import 'package:screenshot/screenshot.dart';

class Audit extends StatefulWidget {
  const Audit({super.key});

  @override
  State<Audit> createState() => _AuditState();
}

class _AuditState extends State<Audit> {
  TextEditingController _search = TextEditingController();
  List allData = [];
  List data = [];
  // var datavalue ;
  bool sort = false;
  ScreenshotController screenshotController = ScreenshotController();
  ScrollController _scrollController = ScrollController();
  bool paginate = false;
  bool search = false;
  String option = "";
  String url = "";
  int counterChecks = 0;
  List optionsCheckBox = [];
  int currentPage = 1;
  int pageSize = 80;
  int pageCount = 0;
  bool isLoading = false;
  int total = 0;
  bool enabledBusqueda = true;
  int totalRegistros = 0;
  int generalValuetotal = 0;

  String costTrans = "0.0";
  String costEnt = "0.0";
  String costDev = "0.0";
  var respvalues;

  var getReport = CreateReportAudit();

  var sortFieldDefaultValue = "marca_t_i:DESC";

  List<String> listvendedores = ['TODO'];
  List<String> listtransportadores = ['TODO'];

  List<String> listStatus = [
    'TODO',
    'PEDIDO PROGRAMADO',
    'NOVEDAD',
    'NOVEDAD RESUELTA',
    'NO ENTREGADO',
    'ENTREGADO',
    'REAGENDADO',
    'EN OFICINA',
    'EN RUTA'
  ];

  List<String> returnStates = [
    'TODO',
    'PENDIENTE',
    'EN BODEGA',
    'DEVOLUCION EN RUTA',
    'ENTREGADO EN OFICINA',
    'EN BODEGA PROVEEDOR',
  ];

  List populate = [
    'pedido_fecha',
    'transportadora',
    'ruta',
    'subRuta',
    'operadore',
    "operadore.user",
    "users",
    "users.vendedores",
    'pedidoCarrier'
  ];

  List defaultArrayFiltersAnd = [
    // {"equals/estado_devolucion": "PENDIENTE"},
    {"/estado_interno": "CONFIRMADO"},
    {"/estado_logistico": "ENVIADO"}
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "marca_t_i",
    "numero_orden",
    "ciudad_shipping",
    "nombre_shipping",
    "observacion",
    "comentario",
    "status",
    "estado_devolucion",
    "estado_logistico",
    "estado_interno",
    "fecha_entrega",
    "fecha_confirmacion",
    'marca_tiempo_envio'
  ];
  List not = [];

  NumberPaginatorController paginatorController = NumberPaginatorController();

  TextEditingController codigoController = TextEditingController(text: "");
  TextEditingController marcaTiController = TextEditingController(text: "");
  TextEditingController fechaController = TextEditingController(text: "");
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
  TextEditingController observacionController = TextEditingController(text: "");
  TextEditingController comentarioController = TextEditingController(text: "");
  TextEditingController statusController = TextEditingController(text: "TODO");
  TextEditingController tipoPagoController = TextEditingController(text: "");
  TextEditingController rutaAsignadaController =
      TextEditingController(text: "");
  TextEditingController transportadoraController =
      TextEditingController(text: "");
  TextEditingController subRutaController = TextEditingController(text: "");
  TextEditingController operadorController = TextEditingController(text: "");
  TextEditingController fechaEntregaController =
      TextEditingController(text: "");
  TextEditingController vendedorController =
      TextEditingController(text: "TODO");
  TextEditingController returnStatesController =
      TextEditingController(text: "TODO");
  TextEditingController estadoConfirmacionController =
      TextEditingController(text: "TODO");
  TextEditingController estadoLogisticoController =
      TextEditingController(text: "TODO");
  TextEditingController costoTransController = TextEditingController(text: "");
  TextEditingController costoOperadorController =
      TextEditingController(text: "");
  TextEditingController costoEntregaController =
      TextEditingController(text: "");
  TextEditingController costoDevolucionController =
      TextEditingController(text: "");
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "");
  TextEditingController marcaTiempoDevolucionController =
      TextEditingController(text: "");
  TextEditingController estadoPagoLogisticoController =
      TextEditingController(text: "TODO");
  // ! mia
  TextEditingController transportadorasController =
      TextEditingController(text: "TODO");

  String filterDate = "FECHA ENTREGA";

  @override
  void dispose() {
    // Asegúrate de desechar el controlador cuando el widget sea descartado
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    loadData();

    super.didChangeDependencies();
  }

  Future loadData() async {
    isLoading = true;
    currentPage = 1;
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      setState(() {
        search = false;
      });
      var response = await Connections().getOrdersForNoveltiesByDatesLaravel(
          populate, //no se aplica
          defaultArrayFiltersAnd,
          arrayFiltersAnd,
          arrayFiltersOr,
          not,
          currentPage,
          pageSize,
          searchController.text.toString(),
          sortFieldDefaultValue.toString(),
          sharedPrefs!.getString("dateDesdeLogistica").toString(),
          sharedPrefs!.getString("dateHastaLogistica").toString(),
          filterDate);

      respvalues = await Connections().getByDateRangeValuesAudit(
          sharedPrefs!.getString("dateDesdeLogistica").toString(),
          sharedPrefs!.getString("dateHastaLogistica").toString(),
          arrayFiltersAnd,
          defaultArrayFiltersAnd);

      print(respvalues);

      if (listtransportadores.length == 1) {
        var responsetransportadoras = await Connections().getTransportadoras();
        List<dynamic> transportadorasList =
            responsetransportadoras['transportadoras'];
        for (var transportadora in transportadorasList) {
          listtransportadores.add(transportadora);
        }
      }

      if (listvendedores.length == 1) {
        var responsevendedores = await Connections().getVendedores();
        List<dynamic> vendedoresList = responsevendedores['vendedores'];
        for (var vendedor in vendedoresList) {
          listvendedores.add(vendedor);
        }
      }

      setState(() {
        data = [];
        data = response['data'];
        // datavalue = respvalues['Costo_Transporte'];
        total = response['total'];

        pageCount = response['last_page'];

        paginatorController.navigateToPage(0);
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);

      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      setState(() {
        search = false;
      });
      var response = await Connections().getOrdersForNoveltiesByDatesLaravel(
          populate,
          defaultArrayFiltersAnd,
          arrayFiltersAnd,
          arrayFiltersOr,
          not,
          currentPage,
          pageSize,
          searchController.text.toString(),
          sortFieldDefaultValue.toString(),
          sharedPrefs!.getString("dateDesdeLogistica").toString(),
          sharedPrefs!.getString("dateHastaLogistica").toString(),
          filterDate);

      setState(() {
        data = [];
        data = response['data'];
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      Navigator.pop(context);

      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
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

  TextEditingController searchController = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          color: Colors.grey[200],
          child: responsive(
              Column(
                children: [
                  MyCustomWidget(
                    value1: respvalues != null &&
                            respvalues['Costo_Transporte'] != null
                        ? respvalues['Costo_Transporte'].toString()
                        : "0.0",
                    value2: respvalues != null &&
                            respvalues['Costo_Entrega'] != null
                        ? respvalues['Costo_Entrega'].toString()
                        : "0.0",
                    value3: respvalues != null &&
                            respvalues['Costo_Devolución'] != null
                        ? respvalues['Costo_Devolución'].toString()
                        : "0.0",
                    filterInvoke: respvalues != null &&
                            respvalues['Filtro_Existente'] != null
                        ? respvalues['Filtro_Existente'].toString()
                        : "0",
                    entregados: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['ENTREGADO'] != null
                        ? respvalues['Estado_Pedidos']['ENTREGADO'].toString()
                        : "0",
                    noEntregados: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['NO ENTREGADO'] != null
                        ? respvalues['Estado_Pedidos']['NO ENTREGADO']
                            .toString()
                        : "0",
                    novedad: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['NOVEDAD'] != null
                        ? respvalues['Estado_Pedidos']['NOVEDAD'].toString()
                        : "0",
                  ),
                  _dates(context),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: SizedBox(
                        child: responsive(
                            Row(
                              children: [
                                Expanded(
                                  child: _modelTextField(
                                      text: "Buscar",
                                      controller: searchController),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 5),
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
                                Expanded(child: numberPaginator()),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  child: _modelTextField(
                                      text: "Buscar",
                                      controller: searchController),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 5),
                                      child: Text(
                                        "Registros: ${total}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                numberPaginator(),
                              ],
                            ),
                            context),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: DataTable2(
                          scrollController: _scrollController,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                          headingRowHeight: 63,
                          headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          dataTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          columnSpacing: 5,
                          horizontalMargin: 5,
                          minWidth: 2500,
                          columns: [
                            DataColumn2(
                              label: Text("Id Pedido"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilter(
                                  'Tienda',
                                  'equals/id_comercial',
                                  vendedorController,
                                  listvendedores),
                              size: ColumnSize.S,
                              // numeric: true,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Name_Comercial");
                              },
                            ),
                            DataColumn2(
                              label: Text("Fecha Ingreso Pedido"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Fecha de Confirmación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Marca Tiempo Envio"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Fecha Entrega"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: const Text('Código'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Nombre Cliente"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Ciudad"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Usuario de Confirmación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),

                            DataColumn2(
                              label: SelectFilterNoId('Status', 'equals/status',
                                  statusController, listStatus),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilter(
                                  'Transportadora',
                                  'equals/transportadora.transportadora_id',
                                  transportadorasController,
                                  listtransportadores),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Estado_Interno");
                              },
                            ),
                            DataColumn2(
                              label: Text("Ruta"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("SubRuta"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Operador"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Observación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Comentario"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Estado Interno"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Estado Logístico"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilterNoId(
                                  'Estado Devolución',
                                  'equals/estado_devolucion',
                                  returnStatesController,
                                  returnStates),
                              size: ColumnSize.S,
                              // numeric: true,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Name_Comercial");
                              },
                            ),

                            // data['novedades'][index]['try']
                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            final color = Colors.blue[50];

                            return DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) => color!),
                                cells: getRows(index));
                          }))),
                ],
              ),
              Column(
                children: [
                  MyCustomWidget(
                    value1: respvalues != null &&
                            respvalues['Costo_Transporte'] != null
                        ? respvalues['Costo_Transporte'].toString()
                        : "0.0",
                    value2: respvalues != null &&
                            respvalues['Costo_Entrega'] != null
                        ? respvalues['Costo_Entrega'].toString()
                        : "0.0",
                    value3: respvalues != null &&
                            respvalues['Costo_Devolución'] != null
                        ? respvalues['Costo_Devolución'].toString()
                        : "0.0",
                    filterInvoke: respvalues != null &&
                            respvalues['Filtro_Existente'] != null
                        ? respvalues['Filtro_Existente'].toString()
                        : "0",
                    entregados: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['ENTREGADO'] != null
                        ? respvalues['Estado_Pedidos']['ENTREGADO'].toString()
                        : "0",
                    noEntregados: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['NO ENTREGADO'] != null
                        ? respvalues['Estado_Pedidos']['NO ENTREGADO']
                            .toString()
                        : "0",
                    novedad: respvalues != null &&
                            respvalues['Estado_Pedidos'] != null &&
                            respvalues['Estado_Pedidos']['NOVEDAD'] != null
                        ? respvalues['Estado_Pedidos']['NOVEDAD'].toString()
                        : "0",
                  ),
                  _datesMovil(context),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: SizedBox(
                        child: responsive(
                            Row(
                              children: [
                                Expanded(
                                  child: _modelTextField(
                                      text: "Buscar",
                                      controller: searchController),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 5),
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
                                Expanded(child: numberPaginator()),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  child: _modelTextField(
                                      text: "Buscar",
                                      controller: searchController),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 5),
                                      child: Text(
                                        "Registros: ${total}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                numberPaginator(),
                              ],
                            ),
                            context),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: DataTable2(
                          scrollController: _scrollController,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                          headingRowHeight: 63,
                          headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          dataTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          columnSpacing: 5,
                          horizontalMargin: 5,
                          minWidth: 2500,
                          columns: [
                            DataColumn2(
                              label: Text("Id Pedido"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilter(
                                  'Tienda',
                                  'equals/id_comercial',
                                  vendedorController,
                                  listvendedores),
                              size: ColumnSize.S,
                              // numeric: true,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Name_Comercial");
                              },
                            ),
                            DataColumn2(
                              label: Text("Fecha Ingreso Pedido"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Fecha de Confirmación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Marca Tiempo Envio"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Fecha Entrega"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: const Text('Código'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Nombre Cliente"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Ciudad"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Usuario de Confirmación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),

                            DataColumn2(
                              label: SelectFilterNoId('Status', 'equals/status',
                                  statusController, listStatus),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilter(
                                  'Transportadora',
                                  'equals/transportadora.transportadora_id',
                                  transportadorasController,
                                  listtransportadores),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Estado_Interno");
                              },
                            ),
                            DataColumn2(
                              label: Text("Ruta"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("SubRuta"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Operador"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Observación"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Comentario"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Estado Interno"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: Text("Estado Logístico"),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {},
                            ),
                            DataColumn2(
                              label: SelectFilterNoId(
                                  'Estado Devolución',
                                  'equals/estado_devolucion',
                                  returnStatesController,
                                  returnStates),
                              size: ColumnSize.S,
                              // numeric: true,
                              onSort: (columnIndex, ascending) {
                                // sortFunc("Name_Comercial");
                              },
                            ),
                            // data['novedades'][index]['try']
                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            final color = index % 2 == 0
                                ? Colors.grey[400]
                                : Colors.white;

                            return DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) => color!),
                                cells: getRows(index));
                          }))),
                ],
              ),
              context)),
    );
  }

  Column InputFilter(String title, filter, var controller, key) {
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

              loadData();
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

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  getLengthArrayMap(List data) {
    var arraylength = data.length;
    return Text(
      arraylength.toString(),
      style: TextStyle(
          color: arraylength > 3
              ? Color.fromARGB(255, 185, 10, 10)
              : Colors.black),
    );
  }

  List<DataCell> getRows(index) {
    Color rowColor = Colors.black;
    return [
      DataCell(
          Text(
            data[index]['id'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['users'][0]['vendedores'][0]['nombre_comercial'],
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),

      DataCell(
          Text(
            data[index]['marca_t_i'].toString().split(' ')[0].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['fecha_confirmacion'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['marca_tiempo_envio'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['fecha_entrega'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            "${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}",
            style: TextStyle(
              color: GetColor(data[index]['status']!),
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['nombre_shipping'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            '${data[index]['ciudad_shipping'].toString()}',
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      // ! aqui falta el usuario que confirma
      // DataCell(
      //   FutureBuilder<String>(
      //     future: userNametotoConfirmOrder(data[index]['confirmed_by'] != null
      //         ? data[index]['confirmed_by']
      //         : 0),
      //     builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      //       return Text(snapshot.data ?? 'Desconocido');
      //     },
      //   ),
      //   onTap: () {
      //     info(context, index);
      //   },
      // ),
      DataCell(
        Text(
          data[index]['confirmed_by'] != null
              ? data[index]['confirmed_by']['username'].toString()
              : 'Desconocido',
          style: TextStyle(
            color: rowColor,
          ),
        ),
        onTap: () {
          info(context, index);
        },
      ),
      // ! **********************************
      DataCell(
          Text(
            style: TextStyle(
              color: GetColor(data[index]['status']),
              // color: Colors.blue,
            ),
            data[index]['status'].toString(),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            // data[index]['transportadora'] != null &&
            //         data[index]['transportadora'].toString() != "[]"
            //     ? data[index]['transportadora'][0]['nombre'].toString()
            //     : "",
            data[index]['transportadora'] != null &&
                    data[index]['transportadora'].isNotEmpty
                ? data[index]['transportadora'][0]['nombre'].toString()
                : data[index]['pedido_carrier'].isNotEmpty
                    ? data[index]['pedido_carrier'][0]['carrier']['name']
                        .toString()
                    : "",
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['ruta'] != null &&
                    data[index]['ruta'].toString() != "[]"
                ? data[index]['ruta'][0]['titulo'].toString()
                : "",
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['sub_ruta'] != null &&
                    data[index]['sub_ruta'].toString() != "[]"
                ? data[index]['sub_ruta'][0]['titulo'].toString()
                : "",
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['operadore'] != null &&
                    data[index]['operadore'].toString() != "[]"
                ? data[index]['operadore'][0]['up_users'][0]['username']
                    .toString()
                : "",
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['observacion'] == null
                ? ""
                : data[index]['observacion'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['comentario'] == null
                ? ""
                : data[index]['comentario'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['estado_interno'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['estado_logistico'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['estado_devolucion'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
    ];
  }

  SizedBox _dates(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () async {
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        selectedYearTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        weekdayLabelTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      dialogSize: const Size(325, 400),
                      value: [],
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

                        String nuevaFecha = "$dia/$mes/$anio";

                        sharedPrefs!
                            .setString("dateDesdeLogistica", nuevaFecha);
                      }
                    });
                  },
                  child: Text(
                    "DESDE: ${sharedPrefs!.getString("dateDesdeLogistica")}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: 10,
              ),
              TextButton(
                  onPressed: () async {
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        selectedYearTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        weekdayLabelTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      dialogSize: const Size(325, 400),
                      value: [],
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

                        String nuevaFecha = "$dia/$mes/$anio";

                        sharedPrefs!
                            .setString("dateHastaLogistica", nuevaFecha);
                      }
                    });
                  },
                  child: Text(
                    "HASTA: ${sharedPrefs!.getString("dateHastaLogistica")}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _search.clear();
                    });
                    await loadData();
                  },
                  child: Text(
                    "BUSCAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 167, 7, 7),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    limpiar();
                    loadData();
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quitar Filtros',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.green,
                  ),
                ),
                onPressed: () async {
                  if (total > 2300) {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: 'El Número de Registros debe ser menor a 2.300',
                      desc: '',
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      btnOkOnPress: () async {},
                    ).show();
                  } else {
                    getLoadingModal(context, true);

                    try {
                      var response =
                          await Connections().getByDateRangeOrdersforAudit(
                        defaultArrayFiltersAnd,
                        arrayFiltersAnd,
                        arrayFiltersOr,
                        not,
                        1,
                        searchController.text.toString(),
                        sortFieldDefaultValue,
                        sharedPrefs!.getString("dateDesdeLogistica").toString(),
                        sharedPrefs!.getString("dateHastaLogistica").toString(),
                      );
                      await getReport
                          .generateExcelFileWithDataAudit(response['data']);
                      // }

                      Navigator.of(context).pop();
                    } catch (e) {
                      Navigator.of(context).pop();

                      _showErrorSnackBar(context,
                          "Ha ocurrido un error al generar el reporte: $e");
                    }
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.filter_alt),
                    // SizedBox(width: 8),
                    Text(
                      'Reportes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> userNametotoConfirmOrder(userId) async {
    if (userId == 0) {
      return 'Desconocido';
    } else {
      var user =
          await Connections().getPersonalInfoAccountforConfirmOrderPDF(userId);
      // Verifica si user es nulo
      if (user != null && user.containsKey('username')) {
        return user['username'].toString();
      } else {
        // Maneja el caso de usuario nulo o sin 'username'
        return 'Desconocido';
      }
    }
  }

  SizedBox _datesMovil(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () async {
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        selectedYearTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        weekdayLabelTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      dialogSize: const Size(325, 400),
                      value: [],
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

                        String nuevaFecha = "$dia/$mes/$anio";

                        sharedPrefs!
                            .setString("dateDesdeLogistica", nuevaFecha);
                      }
                    });
                  },
                  child: Text(
                    "DESDE: ${sharedPrefs!.getString("dateDesdeLogistica")}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: 10,
              ),
              TextButton(
                  onPressed: () async {
                    var results = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        selectedYearTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        weekdayLabelTextStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      dialogSize: const Size(325, 400),
                      value: [],
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

                        String nuevaFecha = "$dia/$mes/$anio";

                        sharedPrefs!
                            .setString("dateHastaLogistica", nuevaFecha);
                      }
                    });
                  },
                  child: Text(
                    "HASTA: ${sharedPrefs!.getString("dateHastaLogistica")}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _search.clear();
                      });
                      await loadData();
                    },
                    child: Text(
                      "BUSCAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 167, 7, 7),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      limpiar();
                      loadData();
                    });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.filter_alt),
                      // SizedBox(width: 8),
                      Text(
                        'Quitar Filtros',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.green,
                    ),
                  ),
                  onPressed: () async {
                    if (total > 2300) {
                      AwesomeDialog(
                        width: 500,
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'El Número de Registros debe ser menor a 2.300',
                        desc: '',
                        btnOkText: "Aceptar",
                        btnOkColor: Colors.green,
                        btnOkOnPress: () async {},
                      ).show();
                    } else {
                      getLoadingModal(context, true);

                      try {
                        var response =
                            await Connections().getByDateRangeOrdersforAudit(
                          defaultArrayFiltersAnd,
                          arrayFiltersAnd,
                          arrayFiltersOr,
                          not,
                          1,
                          searchController.text.toString(),
                          sortFieldDefaultValue,
                          sharedPrefs!
                              .getString("dateDesdeLogistica")
                              .toString(),
                          sharedPrefs!
                              .getString("dateHastaLogistica")
                              .toString(),
                        );
                        await getReport
                            .generateExcelFileWithDataAudit(response['data']);
                        // }

                        Navigator.of(context).pop();
                      } catch (e) {
                        Navigator.of(context).pop();

                        _showErrorSnackBar(context,
                            "Ha ocurrido un error al generar el reporte: $e");
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.filter_alt),
                      // SizedBox(width: 8),
                      Text(
                        'Reportes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ])
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
          loadData();
        },
        onChanged: (value) {
          if (value == "") {
            {
              arrayFiltersAnd
                  .removeWhere((element) => element.containsKey('\$or'));
            }
          }
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: const Color.fromARGB(255, 28, 51, 70),
          prefixIcon: Icon(Icons.search),
          suffixIcon: searchController.text.toString().isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      searchController.clear();
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

  Column SelectFilterNoId(String title, filter,
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
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    arrayFiltersAnd.add({filter: newValue});
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

  clearSelected() {
    setState(() {
      optionsCheckBox = [];
      data = data.map((item) => {...item, 'check': false}).toList();
      counterChecks = 0;
      enabledBusqueda = true;
    });
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonSelectedBackgroundColor: Color.fromARGB(255, 71, 71, 71),
        // buttonUnselectedBackgroundColor: Color.fromARGB(255, 71, 71, 71),
        buttonSelectedForegroundColor: Colors.white,
        buttonUnselectedForegroundColor: Colors.black,
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        paginate = true;
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  void limpiar() {
    searchController.text = "";
    arrayFiltersAnd.clear();
    // sortFieldDefaultValue = "marca_t_i:DESC";
    _search.clear();
    marcaTiController.clear();
    fechaController.clear();
    codigoController.clear();
    ciudadShippingController.clear();
    nombreShippingController.clear();
    direccionShippingController.clear();
    telefonoShippingController.clear();
    cantidadTotalController.clear();
    productoPController.clear();
    productoExtraController.clear();
    precioTotalController.clear();
    observacionController.clear();
    comentarioController.clear();
    statusController.text = 'TODO';
    tipoPagoController.clear();
    rutaAsignadaController.clear();
    transportadorasController.text = 'TODO';
    subRutaController.clear();
    operadorController.clear();
    fechaEntregaController.clear();
    vendedorController.text = 'TODO';
    estadoConfirmacionController.text = 'TODO';
    estadoLogisticoController.text = 'TODO';
    costoTransController.clear();
    costoOperadorController.clear();
    costoEntregaController.clear();
    costoDevolucionController.clear();
    estadoDevolucionController.text = 'TODO';
    marcaTiempoDevolucionController.clear();
    estadoPagoLogisticoController.text = 'TODO';
  }

  Future<dynamic> info(BuildContext context, int index) {
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
                      child: AuditDataInfo(
                    id: data[index]['id'].toString(),
                    data: data,
                    function: paginateData,
                  ))
                ],
              ),
            ),
          );
        });
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
}
