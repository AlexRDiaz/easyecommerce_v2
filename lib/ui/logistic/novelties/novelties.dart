import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/novelties/generate_report_novelties.dart';
import 'package:frontend/ui/logistic/novelties/novelties_info.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_details.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_details_data.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';
import 'package:screenshot/screenshot.dart';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/novelties/generate_report_novelties.dart';
import 'package:frontend/ui/logistic/novelties/novelties_info.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_details.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_details_data.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:lottie/lottie.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';
import 'package:screenshot/screenshot.dart';

class NoveltiesL extends StatefulWidget {
  const NoveltiesL({super.key});

  @override
  State<NoveltiesL> createState() => _NoveltiesLState();
}

class _NoveltiesLState extends State<NoveltiesL> {
  TextEditingController _search = TextEditingController();
  List allData = [];
  List data = [];
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
  int pageSize = 75;
  int pageCount = 0;
  bool isLoading = false;
  int total = 0;
  bool enabledBusqueda = true;
  int totalRegistros = 0;

  String valorSeleccionado = 'ENTREGADO';

  var getReport = CreateReportNovelties();

  var sortFieldDefaultValue = "marca_t_i:DESC";

  List<String> listvendedores = ['TODO'];
  List<String> listtransportadores = ['TODO'];

  String filterDate = "FECHA ENTREGA";

  List<String> listStatus = [
    'TODO',
    'PEDIDO PROGRAMADO',
    'NOVEDAD',
    'NOVEDAD RESUELTA',
    'NO ENTREGADO',
    'REAGENDADO',
  ];

  List populate = [
    'pedido_fecha',
    'transportadora',
    'ruta',
    'operadore',
    "operadore.user",
    "users",
    "users.vendedores"
  ];
  List defaultArrayFiltersAnd = [
    {"equals/estado_devolucion": "PENDIENTE"},
    {"/estado_interno": "CONFIRMADO"},
    {"/estado_logistico": "ENVIADO"}
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "marca_t_i",
    "numero_orden",
    "ciudad_shipping",
    "nombre_shipping",
    "telefono_shipping",
    "direccion_shipping",
    "cantidad_total",
    "producto_p",
    "producto_extra",
    "precio_total",
    "observacion",
    "comentario",
    "status",
    "estado_devolucion",
    "fecha_entrega"
  ];
  List not = [
    {"status": "ENTREGADO"},
    {"status": "EN RUTA"},
    {"status": "EN OFICINA"},
  ];

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

  TextEditingController myController = TextEditingController();

  List<String> dataListOrderStatus = [
    'Sin Asignar', // Opción predeterminada para valores null
    'ENTREGADO',
    'NO ENTREGADO',
    'NOVEDAD',
    'REAGENDADO',
    'EN RUTA',
    'EN OFICINA',
  ];

  List<String> opstionsDateFilter = [
    'Sin Asignar', // Opción predeterminada para valores null
    'FECHA ENTREGA',
  ];

  @override
  void dispose() {
    // Asegúrate de desechar el controlador cuando el widget sea descartado
    myController.dispose();
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
          populate,
          defaultArrayFiltersAnd,
          arrayFiltersAnd,
          arrayFiltersOr,
          not,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          sortFieldDefaultValue.toString(),
          sharedPrefs!.getString("dateDesdeLogistica").toString(),
          sharedPrefs!.getString("dateHastaLogistica").toString(),
          filterDate);

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
          _controllers.searchController.text,
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

  final VendorInvoicesControllers _controllers = VendorInvoicesControllers();
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
                                      controller:
                                          _controllers.searchController),
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
                                      controller:
                                          _controllers.searchController),
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
                  Expanded(child: DataT()),
                ],
              ),
              Column(
                children: [
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
                                      controller:
                                          _controllers.searchController),
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
                                      controller:
                                          _controllers.searchController),
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
                  Expanded(child: DataT()),
                ],
              ),
              context)

          // Column(
          //   children: [
          //     _dates(context),
          //     SizedBox(
          //       height: 10,
          //     ),
          //     Container(
          //         width: double.infinity,
          //         color: Colors.white,
          //         padding: EdgeInsets.only(top: 5, bottom: 5),
          //         child: SizedBox(
          //           child: responsive(
          //               Row(
          //                 children: [
          //                   Expanded(
          //                     child: _modelTextField(
          //                         text: "Buscar",
          //                         controller: _controllers.searchController),
          //                   ),
          //                   Expanded(
          //                     child: Row(
          //                       children: [
          //                         Container(
          //                           padding:
          //                               const EdgeInsets.only(left: 15, right: 5),
          //                           child: Text(
          //                             "Registros: ${total}",
          //                             style: const TextStyle(
          //                                 fontWeight: FontWeight.bold,
          //                                 color: Colors.black),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Expanded(child: numberPaginator()),
          //                 ],
          //               ),
          //               Column(
          //                 children: [
          //                   Container(
          //                     child: _modelTextField(
          //                         text: "Buscar",
          //                         controller: _controllers.searchController),
          //                   ),
          //                   Row(
          //                     children: [
          //                       Container(
          //                         padding:
          //                             const EdgeInsets.only(left: 15, right: 5),
          //                         child: Text(
          //                           "Registros: ${total}",
          //                           style: const TextStyle(
          //                               fontWeight: FontWeight.bold,
          //                               color: Colors.black),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                   numberPaginator(),
          //                 ],
          //               ),
          //               context),
          //         )),
          //     SizedBox(
          //       height: 10,
          //     ),
          //     Expanded(
          //         child: DataTable2(
          //             scrollController: _scrollController,
          //             decoration: BoxDecoration(
          //               color: Colors.white,
          //               borderRadius: const BorderRadius.all(Radius.circular(4)),
          //               border: Border.all(color: Colors.blueGrey),
          //             ),
          //             headingRowHeight: 63,
          //             headingTextStyle: const TextStyle(
          //                 fontWeight: FontWeight.bold, color: Colors.black),
          //             dataTextStyle: const TextStyle(
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.black),
          //             columnSpacing: 5,
          //             horizontalMargin: 5,
          //             minWidth: 2500,
          //             columns: [
          //               DataColumn2(
          //                 label: Text("Fecha Entrega"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),

          //               DataColumn2(
          //                 label: const Text('Código'),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Ciudad"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Nombre Cliente"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Teléfono Cliente"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Dirección"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Cantidad"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Producto"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Producto Extra"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Precio Total"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Observación"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Comentario"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: SelectFilterNoId('Status', 'equals/status',
          //                     statusController, listStatus),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: SelectFilter('Vendedor', 'equals/id_comercial',
          //                     vendedorController, listvendedores),
          //                 size: ColumnSize.S,
          //                 // numeric: true,
          //                 onSort: (columnIndex, ascending) {
          //                   // sortFunc("Name_Comercial");
          //                 },
          //               ),
          //               DataColumn2(
          //                 label: SelectFilter(
          //                     'Transportadora',
          //                     'equals/transportadora.transportadora_id',
          //                     transportadorasController,
          //                     listtransportadores),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {
          //                   // sortFunc("Estado_Interno");
          //                 },
          //               ),
          //               DataColumn2(
          //                 label: Text("Operador"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: Text("Estado Devolución"),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {},
          //               ),
          //               DataColumn2(
          //                 label: const Text('Fecha Marcar TI'),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {
          //                   // sortFunc("Fecha");
          //                 },
          //               ),
          //               DataColumn2(
          //                 label: const Text('Numero Intentos'),
          //                 size: ColumnSize.S,
          //                 onSort: (columnIndex, ascending) {
          //                   // sortFunc("Fecha");
          //                 },
          //               ),
          //               // data['novedades'][index]['try']
          //             ],
          //             rows: List<DataRow>.generate(data.length, (index) {
          //               final color =
          //                   index % 2 == 0 ? Colors.grey[400] : Colors.white;

          //               return DataRow(
          //                   color: MaterialStateColor.resolveWith(
          //                       (states) => color!),
          //                   cells: getRows(index));
          //             }))),
          //   ],
          // ),
          ),
    );
  }

  DropdownButton crearDropdownButton(int index, List<String> dataList) {
    // Verifica si el valor actual es null y establece un valor predeterminado
    String valorActual = getStateFromJson(
        data[index]['gestioned_novelty']?.toString(), 'novelty_status');

    if (valorActual.isEmpty) {
      valorActual = 'Sin Asignar';
    }

    return DropdownButton<String>(
      dropdownColor: ColorsSystem().colorPrincipalBrand,
      value: valorActual,
      onChanged: (String? nuevoValor) async {
        if (nuevoValor != null) {
          setState(() {
            valorActual = nuevoValor;
          });
          await Connections().updateOrCreateGestionedNovelty(
              data[index]['id'].toString(), "novelty_status:$valorActual");
          await loadData();
        }
      },
      items: dataList.map<DropdownMenuItem<String>>((String valor) {
        return DropdownMenuItem<String>(
          value: valor,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              valor,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        );
      }).toList(),
    );
  }

  DropdownButton<String> crearDropdownButtonFD(String selectedValue,
      List<String> dataList, Function(String?) onSelected) {
    return DropdownButton<String>(
      value: selectedValue,
      onChanged: (String? nuevoValor) {
        onSelected(nuevoValor);
      },
      items: dataList.map<DropdownMenuItem<String>>((String valor) {
        return DropdownMenuItem<String>(
          value: valor,
          child: Container(
            // decoration: BoxDecoration(
            // Agrega estilos si es necesario
            // ),
            // padding: const EdgeInsets.all(8.0),
            child: Text(
              valor,
              style: TextStyle(color: ColorsSystem().colorPrincipalBrand),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleCheckboxChanged(bool? newValue, int index) async {
    var gestionedNovelty = data[index]['gestioned_novelty'];
    if (gestionedNovelty is String) {
      gestionedNovelty = json.decode(gestionedNovelty);
    }

    gestionedNovelty['verified'] = newValue ?? false;
    data[index]['gestioned_novelty'] = gestionedNovelty;

    await Connections().updateOrCreateGestionedNovelty(
        data[index]['id'].toString(), "verified:$newValue");

    loadData();
  }

  Checkbox checkboxPersonalizado(int index) {
    bool valorActual = false;
    String resp = getStateFromJson(
        data[index]['gestioned_novelty']?.toString(), 'verified');
    if (resp == "true") {
      valorActual = true;
    }

    String uniqueKey =
        data[index]['id'].toString(); // Asumiendo que 'id' es único

    return Checkbox(
      key: ValueKey(uniqueKey), // Utiliza el ID único como Key
      value: valorActual,
      onChanged: (newValue) {
        _handleCheckboxChanged(newValue, index);
      },
    );
  }

  DataTable2 DataT() {
    return DataTable2(
        scrollController: _scrollController,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: Colors.blueGrey),
        ),
        headingRowHeight: 63,
        headingTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black),
        columnSpacing: 5,
        horizontalMargin: 5,
        minWidth: 2500,
        columns: [
          DataColumn2(
            label: Text("Contactos Pedido"),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Fecha Entrega"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Gestión Novedades"),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: const Text('Código'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text(''),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text("Ciudad"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Nombre Cliente"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Teléfono Cliente"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Dirección"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Cantidad"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Producto"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Producto Extra"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Precio Total"),
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
            label: Text("Comentario Novedades"),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Marca Tiempo Gestión"),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Status Actual Guía"),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Pedido Verificado"),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: SelectFilterNoId(
                'Status', 'equals/status', statusController, listStatus),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: SelectFilter('Vendedor', 'equals/id_comercial',
                vendedorController, listvendedores),
            size: ColumnSize.S,
            // numeric: true,
            onSort: (columnIndex, ascending) {
              // sortFunc("Name_Comercial");
            },
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
            label: Text("Operador"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text("Estado Devolución"),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: const Text('Fecha Marcar TI'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {
              // sortFunc("Fecha");
            },
          ),
          DataColumn2(
            label: const Text('Numero Intentos'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {
              // sortFunc("Fecha");
            },
          ),
          // data['novedades'][index]['try']
        ],
        rows: List<DataRow>.generate(data.length, (index) {
          final color = index % 2 == 0 ? Colors.grey[400] : Colors.white;

          return DataRow(
              color: MaterialStateColor.resolveWith((states) => color!),
              cells: getRows(index));
        }));
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

  String getStateFromJson(String? jsonString, String claveAbuscar) {
    // Verificar si jsonString es null
    if (jsonString == null || jsonString.isEmpty) {
      return ''; // Retorna una cadena vacía si el valor es null o está vacío
    }

    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap[claveAbuscar]?.toString() ?? '';
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return ''; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
  }

  int gettryFromJson(String? jsonString, String claveAbuscar) {
    // Verificar si jsonString es null
    if (jsonString == null || jsonString.isEmpty) {
      return 0; // Retorna una cadena vacía si el valor es null o está vacío
    }

    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return int.parse(jsonMap[claveAbuscar]!.toString()) ?? 0;
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return 0; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
  }

  List<DataCell> getRows(index) {
    Color rowColor = Colors.black;
    return [
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Tooltip(
            message: 'Transporte',
            child: InkWell(
              onTap: () {
                sendWhatsAppMessage(
                    context,
                    data[index]['transportadora'] != null &&
                            data[index]['transportadora'].toString() != "[]"
                        ? data[index]['transportadora'][0]['telefono_1']
                            .toString()
                        : "",
                    index);
              },
              child: Icon(Icons.local_shipping,
                  color: ColorsSystem().colorPrincipalBrand),
            ),
          ),
          Tooltip(
            message: 'Tienda',
            child: InkWell(
              onTap: () {
                sendWhatsAppMessage(
                    context,
                    data[index]['users'] != null &&
                            data[index]['users'].isNotEmpty
                        ? data[index]['users'][0]['vendedores'][0]['telefono_2']
                        : "NaN",
                    index);
              },
              child: Icon(Icons.shopping_bag,
                  color: ColorsSystem().colorPrincipalBrand),
            ),
          ),
          Tooltip(
            message: 'Operador',
            child: InkWell(
              onTap: () {
                sendWhatsAppMessage(
                    context,
                    data[index]['operadore'] != null &&
                            data[index]['operadore'].toString() != "[]"
                        ? data[index]['operadore'][0]['telefono'].toString()
                        : "",
                    index);
              },
              child: Icon(Icons.motorcycle,
                  color: ColorsSystem().colorPrincipalBrand),
            ),
          ),
        ],
      )),
      DataCell(
          Text(
            data[index]['fecha_entrega'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1.0, color: ColorsSystem().colorPrincipalBrand),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Tooltip(
              message: 'Gestionar Novedad',
              child: gettryFromJson(
                          data[index]['gestioned_novelty']?.toString(),
                          'try') ==
                      5
                  ? Icon(
                      Icons.warning,
                      color: Colors.grey, // Color para estado deshabilitado
                    )
                  : InkWell(
                      onTap: () {
                        _mostrarVentanaEmergenteGuiasImpresas(
                            context, index, 1, "Novedad Gestionada");
                      },
                      child: Icon(
                        Icons.warning,
                        color: Colors.yellow,
                      ),
                    ),
            ),
            Tooltip(
              message: 'Resolver Novedad',
              child: InkWell(
                onTap: () {
                  _mostrarVentanaEmergenteGuiasImpresas(
                      context, index, 2, "Novedad Resuelta");
                },
                child: Icon(Icons.timelapse_rounded, color: Colors.orange),
              ),
            ),
            Tooltip(
              message: 'OK Novedad',
              child: InkWell(
                onTap: () async {
                  await updateGestionedNovelty(
                      context, index, 3, "Ok Novedad", "");
                  await loadData();
                },
                child: Icon(Icons.check_circle_rounded, color: Colors.green),
              ),
            ),
          ],
        ),
      )),

      DataCell(
          Text(
            "${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}",
            style: TextStyle(
              color: GetColor(data[index]['status']!),
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(Row(
        children: [
          GestureDetector(
            onTap: () async {
              var emojiSaludo = "\u{1F44B}"; // 👋
              var emojiCheck = "\u{2705}"; // ✅
              var emojiCruz = "\u{274C}"; // ❌
              var shoppingBagsEmoji = "\u{1F6CD}";
              var personComputerEmoji = "\u{1F4BB}";

              var cliente = data[index]['nombre_shipping'].toString();
              var codigo = data[index]['users'] != null &&
                      data[index]['users'].toString() != "[]"
                  ? "${data[index]['users'][0]['vendedores'][0]['nombre_comercial']}-${data[index]['numero_orden']}"
                  : "${data[index]['tienda_temporal']}-${data[index]['numero_orden']}";

              var producto = data[index]['producto_p'].toString();
              var productoExtra = data[index]['producto_extra'] != null &&
                      data[index]['producto_extra'].toString() != 'null' &&
                      data[index]['producto_extra'].toString() != ''
                  ? ' ${data[index]['producto_extra'].toString()}'
                  : '';
              var tienda = data[index]['users'] != null &&
                      data[index]['users'].isNotEmpty
                  ? data[index]['users'][0]['vendedores'][0]['nombre_comercial']
                  : "NaN";
              var telefono = data[index]['telefono_shipping'].toString();

              var mensaje = """
$emojiSaludo Un gusto Saludarle Estimad@ "$cliente"
Lo Estamos saludando de la Tienda Virtual "$tienda" $shoppingBagsEmoji $personComputerEmoji
Me confirma si recibió su pedido.

*Con los siguientes datos:* 
*N° Guía:* $codigo
*Producto:* $producto
*Producto Extra:* $productoExtra

Responda SI para registrar su recepción $emojiCheck.
Responda NO para coordinar su entrega $emojiCruz.

Quedamos atentos a su respuesta Muchas gracias.
              
*Saludos*
*Tienda Virtual "$tienda"*
""";
              var encodedMessage = Uri.encodeFull(mensaje);
              var whatsappUrl =
                  "https://api.whatsapp.com/send?phone=$telefono&text=$encodedMessage";

              if (!await launchUrl(Uri.parse(whatsappUrl))) {
                throw 'Could not launch $whatsappUrl';
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.green,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
              onTap: () async {
                var _url = Uri(
                    scheme: 'tel',
                    path: '${data[index]['telefono_shipping'].toString()}');

                if (!await launchUrl(_url)) {
                  throw Exception('Could not launch $_url');
                }
              },
              child: Icon(Icons.phone))
        ],
      )),
      DataCell(
          Text(
            '${data[index]['ciudad_shipping'].toString()}',
            style: TextStyle(
              color: rowColor,
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
            data[index]['telefono_shipping'].toString(),
            style: TextStyle(
                color: GetColorofStateNovelti(getStateFromJson(
                    data[index]['gestioned_novelty']?.toString(), 'state')),
                fontWeight: FontWeight.bold),
          ), onTap: () {
        // print(data[index]['gestioned_novelty']);
      }),
      DataCell(
          Text(
            '${data[index]['direccion_shipping'].toString()}',
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['cantidad_total'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['producto_p'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['producto_extra'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['precio_total'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['observacion'].toString(),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            '${data[index]['comentario'].toString()}',
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            getStateFromJson(
                data[index]['gestioned_novelty']?.toString(), 'comment'),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            getStateFromJson(
                data[index]['gestioned_novelty']?.toString(), 'm_t_g'),
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Container(
            decoration: BoxDecoration(
                color: ColorsSystem().colorPrincipalBrand,
                border: Border.all(width: 2, color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0)),
            width: 130,
            child: crearDropdownButton(index, dataListOrderStatus),
          ), onTap: () {
        // info(context, index);
      }),
      DataCell(checkboxPersonalizado(index), onTap: () {
        // info(context, index);
      }),
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
            // data[index]['tienda_temporal'].toString(),
            data[index]['users'] != null && data[index]['users'].isNotEmpty
                ? data[index]['users'][0]['vendedores'][0]['nombre_comercial']
                : "NaN",
            style: TextStyle(
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
      }),
      DataCell(
          Text(
            data[index]['transportadora'] != null &&
                    data[index]['transportadora'].toString() != "[]"
                ? data[index]['transportadora'][0]['nombre'].toString()
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
            data[index]['estado_devolucion'].toString(),
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
      DataCell(getLengthArrayMap(data[index]['novedades']), onTap: () {
        info(context, index);
      }),
      // DataCell(
      //   Text(
      //     data[index]['novedades'] != null &&
      //             data[index]['novedades'].isNotEmpty
      //         ? data[index]['novedades'][0]['try'].toString()
      //         : '',
      //     style: TextStyle(
      //       color: GetColor(data[index]['status']!),
      //     ),
      //   ),
      //   onTap: () {
      //     info(context, index);
      //   },
      // ),

      // data['novedades'][index]['try']
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
              crearDropdownButtonFD(
                filterDate,
                ['FECHA ENTREGA', 'MARCA TIEMPO ENVIO'], // Tu lista de opciones
                (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      filterDate = newValue;
                      // Realiza la lógica que necesitas cuando el valor cambia
                    });
                  }
                },
              ),
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
                    filterDate = "FECHA ENTREGA";
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
                  // Mostrar indicador de carga antes de iniciar la descarga
                  getLoadingModal(context,
                      true); // Asumiendo que esta función muestra un modal de carga.

                  try {
                    // Suponiendo que tu función necesita parámetros como 'populate', 'defaultArrayFiltersAnd', etc.
                    var response = await Connections()
                        .getOrdersForNoveltiesByDatesLaravel(
                            populate,
                            defaultArrayFiltersAnd,
                            arrayFiltersAnd,
                            arrayFiltersOr,
                            not,
                            1,
                            100000,
                            _controllers.searchController.text,
                            sortFieldDefaultValue,
                            sharedPrefs!
                                .getString("dateDesdeLogistica")
                                .toString(),
                            sharedPrefs!
                                .getString("dateHastaLogistica")
                                .toString(),
                            filterDate);

                    // Suponiendo que 'generateExcelFileWithData' toma la lista de datos como parámetro
                    await getReport.generateExcelFileWithData(response['data']);

                    // Si llegamos aquí, la operación fue exitosa y cerramos el modal de carga
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Cerrar el modal de carga si hay un error
                    Navigator.of(context).pop();

                    // Mostrar un mensaje de error
                    _showErrorSnackBar(context,
                        "Ha ocurrido un error al generar el reporte: $e");
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
              crearDropdownButtonFD(
                filterDate,
                ['FECHA ENTREGA', 'MARCA TIEMPO ENVIO'], // Tu lista de opciones
                (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      filterDate = newValue;
                      // Realiza la lógica que necesitas cuando el valor cambia
                    });
                  }
                },
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
                      filterDate = "FECHA ENTREGA";
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
                    // Mostrar indicador de carga antes de iniciar la descarga
                    getLoadingModal(context,
                        true); // Asumiendo que esta función muestra un modal de carga.

                    try {
                      // Suponiendo que tu función necesita parámetros como 'populate', 'defaultArrayFiltersAnd', etc.
                      var response = await Connections()
                          .getOrdersForNoveltiesByDatesLaravel(
                              populate,
                              defaultArrayFiltersAnd,
                              arrayFiltersAnd,
                              arrayFiltersOr,
                              not,
                              1,
                              100000,
                              _controllers.searchController.text,
                              sortFieldDefaultValue,
                              sharedPrefs!
                                  .getString("dateDesdeLogistica")
                                  .toString(),
                              sharedPrefs!
                                  .getString("dateHastaLogistica")
                                  .toString(),
                              filterDate);

                      // Suponiendo que 'generateExcelFileWithData' toma la lista de datos como parámetro
                      await getReport
                          .generateExcelFileWithData(response['data']);

                      // Si llegamos aquí, la operación fue exitosa y cerramos el modal de carga
                      Navigator.of(context).pop();
                    } catch (e) {
                      // Cerrar el modal de carga si hay un error
                      Navigator.of(context).pop();

                      // Mostrar un mensaje de error
                      _showErrorSnackBar(context,
                          "Ha ocurrido un error al generar el reporte: $e");
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

  void _mostrarVentanaEmergenteGuiasImpresas(
      BuildContext context, index, noveltyState, title) {
    double width =
        MediaQuery.of(context).size.width * 0.3; // Ajustar según necesidad
    double height =
        MediaQuery.of(context).size.height * 0.15; // Ajustar según necesidad

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Bordes redondeados
          ),
          title: Row(
            // Título más llamativo
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_note,
                  color:
                      Theme.of(context).primaryColor), // Ícono representativo
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
            ],
          ),
          content: Container(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Añade espacio entre los elementos
              children: [
                TextField(
                  controller: myController,
                  minLines: 1, // Reduce el número de líneas
                  maxLines: 3, // Permite expandirse hasta 3 líneas
                  decoration: InputDecoration(
                    labelText: 'Escribe tu comentario aquí',
                    hintText: 'Ingresa detalles relevantes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment, color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.check_circle),
                      label: Text("Aceptar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Color verde para aceptar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        updateGestionedNovelty(context, index, noveltyState,
                            title, myController.text);
                        myController.clear();
                        Navigator.pop(context);
                        // Navigator.pop(context);
                        await loadData();
                        // Navigator.pop(context); // Cierra el modal después de la acción
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.cancel),
                      label: Text("Cancelar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Color rojo para cancelar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el modal
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  updateGestionedNovelty(context, index, noveltyState, title, comment) async {
    // getLoadingModal(context, false);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d/M/yyyy HH:mm:ss').format(now);

    print(formattedDate);

    if (noveltyState == 3) {
      comment =
          "Novedad Gestionada con exito UID: ${sharedPrefs!.getString("id")}";
    } else {
      comment = "$comment UID: ${sharedPrefs!.getString("id")}";
    }
    var resp = await Connections().postGestinodNovelty(
      data[index]['id'],
      comment,
      sharedPrefs!.getString("id"),
      noveltyState,
      formattedDate,
    );

    // if (resp['response'].toString() == "Novelty updated successfully") {
    //   AwesomeDialog(
    //     width: 500,
    //     context: context,
    //     dialogType: DialogType.success,
    //     animType: AnimType.rightSlide,
    //     title: title,
    //     desc: 'Estado de Novedad actualizado a $title',
    //     btnCancel: Container(),
    //     btnOkText: "Aceptar",
    //     btnOkColor: Colors.green,
    //     btnCancelOnPress: () {},
    //     btnOkOnPress: () {},
    //   ).show();
    // }
    // Navigator.pop(context);

    // await loadData();
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
    _controllers.searchController.text = "";
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
                      child: NoveltiesInfo(
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

  Color? GetColorofStateNovelti(stateNovelti) {
    int color = 0xFF000000;

    switch (stateNovelti) {
      case "ok":
        color = 0xFF66BB6A;
        break;
      case "gestioned":
        color = 0xFFD6DC27;
        break;
      case "resolved":
        color = 0xFFFF5722;
        break;
      default:
        color = 0xFF000000;
    }
    return Color(color);
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

  Future<void> sendWhatsAppMessage(
      BuildContext context, String cellphone, int index) async {
    String codigo =
        "${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}";

    if (cellphone != "" && cellphone.isNotEmpty) {
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$cellphone&text=$codigo";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      _showErrorSnackBar(context, "El pedido no tiene un número asignado.");
    }
  }
}