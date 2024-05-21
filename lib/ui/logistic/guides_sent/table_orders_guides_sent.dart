import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/logistic/guides_sent/controllers/controllers.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/filters_orders.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
import 'package:frontend/ui/widgets/sellers/scanner_sent.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TableOrdersGuidesSent extends StatefulWidget {
  const TableOrdersGuidesSent({super.key});

  @override
  State<TableOrdersGuidesSent> createState() => _TableOrdersGuidesSentState();
}

class _TableOrdersGuidesSentState extends State<TableOrdersGuidesSent> {
  GuidesSentControllers _controllers = GuidesSentControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  Uint8List? _imageFile = null;
  bool sort = false;
  List<DateTime?> _dates = [];
  List<String> carriersToSelect = [];
  String? selectedValueTransportator;
  String date =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  List dataL = [];
  int currentPage = 1;
  int pageSize = 1300;
  var filtersDefaultAnd = [
    {"/estado_logistico": "ENVIADO"}
  ];

  List filtersOrCont = [
    // 'fecha_entrega',
    "name_comercial",
    'numero_orden',
    'ciudad_shipping',
    'nombre_shipping',
    'direccion_shipping',
    // 'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    "estado_interno",
    "estado_logistico"
  ];

  List filtersAnd = [];
  List arrayFiltersNot = [];

  var sortFieldDefaultValue = "id:DESC";
  bool changevalue = false;
  bool showExternalCarriers = false;

  List populate = [
    "transportadora",
    "users",
    "users.vendedores",
    "pedidoFecha",
    "ruta",
    "sentBy",
    "printedBy",
    'product_s.warehouses.provider',
    "pedidoCarrier"
  ];
  var idUser = sharedPrefs!.getString("id");
  List relationsToInclude = [];
  List relationsToExclude = [];

  @override
  void didChangeDependencies() {
    if (Provider.of<FiltersOrdersProviders>(context).indexActive == 2) {
      setState(() {
        _controllers.searchController.text = "d/m/a,d/m/a";
        data = [];
      });
    } else {
      setState(() {
        data = [];

        _controllers.searchController.clear();
      });
    }
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    try {
      var response = [];
      var responseL;

      List carriersList = [];

      setState(() {
        carriersToSelect = [];
      });

      if (_controllers.searchController.text.isEmpty) {
        if (selectedValueTransportator == null) {
          // print("case1");
          // response = await Connections().getOrdersForPrintGuidesInSendGuides(
          //     _controllers.searchController.text, date);
          //  *
          filtersAnd = [];
          arrayFiltersNot = [];
          filtersAnd.add({"/marca_tiempo_envio": date});
          if (showExternalCarriers == false) {
            // filtersAnd.add({"/id_externo": null});
            relationsToInclude = ['ruta', 'transportadora'];
            relationsToExclude = ['pedidoCarrier'];
          } else {
            // arrayFiltersNot.add({"id_externo": null});
            relationsToInclude = ['pedidoCarrier'];
            relationsToExclude = ['ruta', 'transportadora'];
          }
          responseL = await Connections()
              .getOrdersForSentGuidesPrincipalLaravel(
                  populate,
                  filtersAnd,
                  filtersDefaultAnd,
                  filtersOrCont,
                  relationsToInclude,
                  relationsToExclude,
                  currentPage,
                  pageSize,
                  "",
                  sortFieldDefaultValue,
                  arrayFiltersNot);

          //  *
        } else {
          // print("case1 else");

          // response = await Connections()
          //     .getOrdersForPrintGuidesInSendGuidesAndTransporter(
          //         _controllers.searchController.text,
          //         date,
          //         selectedValueTransportator.toString().split('-')[1]);
          //  *
          filtersAnd = [];
          arrayFiltersNot = [];

          filtersAnd.add({"/marca_tiempo_envio": date});
          filtersAnd.add({
            "equals/transportadora.transportadora_id":
                selectedValueTransportator.toString().split('-')[1]
          });
          if (showExternalCarriers == false) {
            // filtersAnd.add({"/id_externo": null});
            relationsToInclude = ['ruta', 'transportadora'];
            relationsToExclude = ['pedidoCarrier'];
          } else {
            // arrayFiltersNot.add({"id_externo": null});
            relationsToInclude = ['pedidoCarrier'];
            relationsToExclude = ['ruta', 'transportadora'];
          }
          responseL = await Connections()
              .getOrdersForSentGuidesPrincipalLaravel(
                  populate,
                  filtersAnd,
                  filtersDefaultAnd,
                  filtersOrCont,
                  relationsToInclude,
                  relationsToExclude,
                  currentPage,
                  pageSize,
                  "",
                  sortFieldDefaultValue,
                  arrayFiltersNot);
          //  *
        }
      } else {
        // print("case2");

        // response = await Connections()
        //     .getOrdersForPrintGuidesInSendGuidesOnlyCode(
        //         _controllers.searchController.text);
        //  *
        filtersAnd = [];
        arrayFiltersNot = [];

        if (showExternalCarriers == false) {
          // filtersAnd.add({"/id_externo": null});
          relationsToInclude = ['ruta', 'transportadora'];
          relationsToExclude = ['pedidoCarrier'];
        } else {
          // arrayFiltersNot.add({"id_externo": null});
          relationsToInclude = ['pedidoCarrier'];
          relationsToExclude = ['ruta', 'transportadora'];
        }
        responseL = await Connections().getOrdersForSentGuidesPrincipalLaravel(
            populate,
            filtersAnd,
            filtersDefaultAnd,
            filtersOrCont,
            relationsToInclude,
            relationsToExclude,
            currentPage,
            pageSize,
            _controllers.searchController.text,
            sortFieldDefaultValue,
            arrayFiltersNot);
        //  *
      }

      // data = response;
      data = responseL['data'];

      setState(() {
        optionsCheckBox = [];
        counterChecks = 0;
      });
      for (Map pedido in data) {
        var selectedItem = optionsCheckBox
            .where((elemento) => elemento["id"] == pedido["id"])
            .toList();
        if (selectedItem.isNotEmpty) {
          pedido['check'] = true;
        } else {
          pedido['check'] = false;
        }
      }
      // for (var i = 0; i < data.length; i++) {
      //   selectedCheckBox.add({
      //     "check": false,
      //     "id": "",
      //     "numPedido": "",
      //     "date": "",
      //     "city": "",
      //     "product": "",
      //     "extraProduct": "",
      //     "quantity": "",
      //     "phone": "",
      //     "price": "",
      //     "name": "",
      //     "transport": "",
      //     "address": "",
      //     "obervation": "",
      //     "qrLink": "",
      //   });
      // }
      // transportatorList = await Connections().getAllTransportators();
      // print(transportatorList);

      // for (var i = 0; i < transportatorList.length; i++) {
      //   setState(() {
      //     if (transportatorList != null) {
      //       transportator.add(
      //           '${transportatorList[i]['attributes']['Nombre']}-${transportatorList[i]['id']}');
      //     }
      //   });
      // }

      var getCarriersResponse = await Connections().getTransportadoras();
      carriersList = getCarriersResponse['transportadoras'];

      if (carriersList != null) {
        setState(() {
          for (var carrier in carriersList) {
            carriersToSelect.add('$carrier');
          }
        });
      }

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (e) {
      print("error!: $e");
    }
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  void resetFilters() {
    getOldValue(true);
    filtersAnd = [];
    arrayFiltersNot = [];
    showExternalCarriers = false;
    selectedValueTransportator = null;
    _controllers.searchController.text = "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(15),
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
                  // await loadData();
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
              height: 5,
            ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                      child: counterChecks != 0
                          ? _buttons()
                          : _modelTextField(
                              text: "Busqueda",
                              controller: _controllers.searchController)),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Número de Ordenes: ${data.length}",
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          "Guías Externas",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(width: 5),
                        Checkbox(
                          value: showExternalCarriers,
                          onChanged: (value) async {
                            setState(() {
                              showExternalCarriers = value!;
                            });
                            loadData();
                          },
                          activeColor: ColorsSystem().mainBlue,
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: TextStyle(
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 2500,
                columns: [
                  DataColumn2(
                    label: const Text(''),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: const Text('Id'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("id", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Nombre Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("nombre_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Fecha'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      // sortFuncFecha();
                    },
                  ),
                  DataColumn2(
                    label: const Text('Fecha entrega'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      // sortFuncFecha();
                      sortFunc("fecha_entrega", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Código'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("NumeroOrden");
                      sortFunc("numero_orden", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Ciudad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("CiudadShipping");
                      sortFunc("ciudad_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Dirección'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("DireccionShipping");
                      sortFunc("direccion_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Teléfono Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("TelefonoShipping");
                      sortFunc("telefono_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('ID Producto'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      sortFunc("id_product", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Cantidad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Cantidad_Total");
                      sortFunc("cantidad_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Producto'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("ProductoP");
                      sortFunc("producto_p", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Producto Extra'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("ProductoExtra");
                      sortFunc("producto_extra", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Precio Total'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("PrecioTotal");
                      sortFunc("precio_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Transportadora'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFuncTransporte();
                    },
                  ),
                  DataColumn2(
                    label: const Text('Status'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Status");
                      sortFunc("status", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Confirmado?'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Estado_Interno");
                      sortFunc("estado_interno", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Estado Logistico'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Estado_Logistico");
                      sortFunc("estado_logistico", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Observación'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Observacion");
                      sortFunc("observacion", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Impreso por'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("printed_by", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Marca Envio'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("Marca_Tiempo_Envio");
                      sortFunc("marca_tiempo_envio", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Enviado por'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("sent_by", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Fecha hora Envio'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("sent_at", changevalue);
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.white;
                    if ((data[index]['sent_by'] != null &&
                        data[index]['sent_by'].isNotEmpty)) {
                      if (data[index]['sent_by']['roles_fronts'][0]['id'] !=
                          1) {
                        rowColor = Colors.lightBlue.shade50;
                        //Color(0xFFD2E4EF)
                      }
                    }
                    return DataRow(
                        color: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08);
                          }
                          return rowColor;
                        }),
                        cells: [
                          DataCell(Checkbox(
                              value: data[index]['check'],
                              onChanged: (value) {
                                setState(() {
                                  data[index]['check'] = value;
                                });

                                if (value!) {
                                  // print(data[index]);
                                  optionsCheckBox.add({
                                    "check": value,
                                    "id": data[index]['id'].toString(),
                                    "numPedido":
                                        "${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'] != null ? data[index]['tienda_temporal'].toString() : "NaN"}-${data[index]['numero_orden']}"
                                            .toString(),
                                    // "date": data[index]['pedido_fecha'][0]
                                    //         ['fecha']
                                    //     .toString(),
                                    "date": data[index]['marca_t_i'].toString(),
                                    "city": data[index]['ciudad_shipping']
                                        .toString(),
                                    "product":
                                        data[index]['producto_p'].toString(),
                                    "extraProduct": data[index]
                                            ['producto_extra']
                                        .toString(),
                                    "quantity": data[index]['cantidad_total']
                                        .toString(),
                                    "phone": data[index]['telefono_shipping']
                                        .toString(),
                                    "price":
                                        data[index]['precio_total'].toString(),
                                    "name": data[index]['nombre_shipping']
                                        .toString(),
                                    "transport":
                                        data[index]['transportadora'] != null &&
                                                data[index]['transportadora']
                                                    .isNotEmpty
                                            ? data[index]['transportadora'][0]
                                                    ['nombre']
                                                .toString()
                                            : data[index]['pedido_carrier']
                                                    .isNotEmpty
                                                ? data[index]['pedido_carrier']
                                                        [0]['carrier']['name']
                                                    .toString()
                                                : "",
                                    "address": data[index]['direccion_shipping']
                                        .toString(),
                                    "obervation":
                                        data[index]['observacion'].toString(),
                                    "qrLink": data[index]['users'][0]
                                            ['vendedores'][0]['url_tienda']
                                        .toString(),
                                    "provider":
                                        data[index]['id_product'] != null &&
                                                data[index]['id_product'] != 0
                                            ? getFirstProviderName(data[index]
                                                ['product_s']['warehouses'])
                                            : "",
                                    "idExteralOrder":
                                        data[index]['pedido_carrier'].isNotEmpty
                                            ? data[index]['pedido_carrier'][0]
                                                    ['external_id']
                                                .toString()
                                            : "",
                                  });
                                } else {
                                  var m = data[index]['id'];
                                  optionsCheckBox.removeWhere((option) =>
                                      option['id'] ==
                                      data[index]['id'].toString());
                                }
                                setState(() {
                                  counterChecks = optionsCheckBox.length;
                                });
                              })),
                          DataCell(Text(data[index]['id'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['nombre_shipping'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(
                                // data[index]['pedido_fecha'][0]['fecha'] != []
                                //     ? data[index]['pedido_fecha'][0]['fecha']
                                //     : "",
                                data[index]['marca_t_i'] ?? "".toString(),
                              ), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['fecha_entrega'] ??
                                  "".toString()), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(
                                //data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"
                                "${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'] != null ? data[index]['tienda_temporal'].toString() : "NaN"}-${data[index]['numero_orden']}",
                                // "",
                                style: TextStyle(
                                    color: GetColor(
                                        (data[index]['revisado_seller']))!),
                              ), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['ciudad_shipping'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(
                                  data[index]['direccion_shipping'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['telefono_shipping'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Center(
                                child: Text(
                                  data[index]['id_product'] != null &&
                                          data[index]['id_product'] != 0
                                      ? data[index]['id_product'].toString()
                                      : "",
                                ),
                              ), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['cantidad_total'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(Text(data[index]['producto_p'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['producto_extra'] == null ||
                                      data[index]['producto_extra'] == "null"
                                  ? ""
                                  : data[index]['producto_extra'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(Text(data[index]['precio_total'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                            Text(
                              // data[index]['transportadora'] != null &&
                              //         data[index]['transportadora'].isNotEmpty
                              //     ? data[index]['transportadora'][0]['nombre']
                              //         .toString()
                              //     : '',
                              data[index]['transportadora'] != null &&
                                      data[index]['transportadora'].isNotEmpty
                                  ? data[index]['transportadora'][0]['nombre']
                                      .toString()
                                  : data[index]['pedido_carrier'].isNotEmpty
                                      ? data[index]['pedido_carrier'][0]
                                              ['carrier']['name']
                                          .toString()
                                      : "",
                            ),
                          ),
                          DataCell(Text(data[index]['status'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['estado_interno'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['estado_logistico'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['observacion'] == null ||
                                      data[index]['observacion'] == "null"
                                  ? ""
                                  : data[index]['observacion'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['printed_by'] != null &&
                                      data[index]['printed_by'].isNotEmpty
                                  ? "${data[index]['printed_by']['username'].toString()}-${data[index]['printed_by']['id'].toString()}"
                                  : ''), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(
                                  data[index]['marca_tiempo_envio'].toString()),
                              onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['sent_by'] != null &&
                                      data[index]['sent_by'].isNotEmpty
                                  ? "${data[index]['sent_by']['username'].toString()}-${data[index]['sent_by']['id'].toString()}"
                                  : ''), onTap: () {
                            getInfoModal(index);
                          }),
                          DataCell(
                              Text(data[index]['sent_at'] != null
                                  ? "${UIUtils.formatDate(data[index]['sent_at'])}"
                                  : ''), onTap: () {
                            getInfoModal(index);
                          }),
                        ]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? getFirstProviderName(List<dynamic> warehouses) {
    if (warehouses.isNotEmpty) {
      var firstWarehouse = warehouses[0];
      if (firstWarehouse['provider'] != null) {
        return firstWarehouse['provider']['name'];
      }
    }
    return "";
  }

  Color? GetColor(state) {
    var color;
    if (state == 1 || state == 2) {
      color = 0xFF26BC5F;
    } else {
      color = 0xFF000000;
    }
    return Color(color);
  }

  Container _buttons() {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                if (!showExternalCarriers) {
                  const double point = 1.0;
                  const double inch = 72.0;
                  const double cm = inch / 2.54;
                  const double mm = inch / 25.4;
                  getLoadingModal(context, false);
                  final doc = pw.Document();

                  for (var i = 0; i < optionsCheckBox.length; i++) {
                    if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                        optionsCheckBox[i]['id'].toString() != '' &&
                        optionsCheckBox[i]['check'] == true) {
                      final capturedImage = await screenshotController
                          .captureFromWidget(Container(
                              child: ModelGuide(
                        address: optionsCheckBox[i]['address'],
                        city: optionsCheckBox[i]['city'],
                        date: optionsCheckBox[i]['date'],
                        extraProduct: optionsCheckBox[i]['extraProduct'],
                        idForBarcode: optionsCheckBox[i]['id'],
                        name: optionsCheckBox[i]['name'],
                        numPedido: optionsCheckBox[i]['numPedido'],
                        observation: optionsCheckBox[i]['obervation'],
                        phone: optionsCheckBox[i]['phone'],
                        price: optionsCheckBox[i]['price'],
                        product: optionsCheckBox[i]['product'],
                        qrLink: optionsCheckBox[i]['qrLink'],
                        quantity: optionsCheckBox[i]['quantity'],
                        transport: optionsCheckBox[i]['transport'],
                        provider: optionsCheckBox[i]['provider'],
                      )));

                      doc.addPage(pw.Page(
                        pageFormat: PdfPageFormat(21.0 * cm, 21.0 * cm,
                            marginAll: 0.1 * cm),
                        build: (pw.Context context) {
                          return pw.Row(
                            children: [
                              pw.Image(pw.MemoryImage(capturedImage),
                                  fit: pw.BoxFit.contain)
                            ],
                          );
                        },
                      ));
                    }
                  }
                  Navigator.pop(context);
                  await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async =>
                          await doc.save());
                  _controllers.searchController.clear();
                  setState(() {});

                  // loadData();
                } else {
                  // printOnePdfExternal();
                  generateDocumentExternal();
                }
              },
              child: Text(
                "IMPRIMIR",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: !showExternalCarriers
                  ? () async {
                      // for (var i = 0; i < optionsCheckBox.length; i++) {
                      //   if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      //       optionsCheckBox[i]['id'].toString() != '' &&
                      //       optionsCheckBox[i]['check'] == true) {
                      //     var response = await Connections()
                      //         .updateOrderInteralStatusInOrderPrinted(
                      //             "PENDIENTE", optionsCheckBox[i]['id'].toString());
                      //   }
                      // }
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return RoutesModalv2(
                                idOrder: optionsCheckBox,
                                someOrders: true,
                                phoneClient: "",
                                codigo: "",
                                origin: "sent");
                          });

                      // setState(() {});
                      // loadData();
                      setState(() {});
                      optionsCheckBox = [];
                      getOldValue(true);
                      await loadData();
                    }
                  : null,
              child: Text(
                "Ruta",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  void generateDocumentExternal() async {
    try {
      getLoadingModal(context, false);
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();

      var idsExternals = [];

      await Future.forEach(optionsCheckBox, (checkBox) async {
        if (checkBox['id'].toString().isNotEmpty &&
            checkBox['id'].toString() != '') {
          //
          idsExternals.add(checkBox['idExteralOrder']);
        }
        //
      });

      var pdfContentTotal =
          await Connections().multiExternalGuidesGTM(idsExternals);

      if (pdfContentTotal is Uint8List) {
        Navigator.pop(context);
        await Printing.layoutPdf(
          onLayout: (format) => pdfContentTotal!,
        );
      } else {
        Navigator.pop(context);
        print("Error: No se pudo obtener el PDF desde el backend.");
        // ignore: use_build_context_synchronously
        showSuccessModal(
            context, "Error,  No se pudo obtener el PDF.", Icons8.alert);
      }
      stopwatch.stop();
      Duration duration = stopwatch.elapsed;
      print(
          'La función tardó ${duration.inMilliseconds} milisegundos en ejecutarse.');

      _controllers.searchController.clear();

      optionsCheckBox = [];
      // loadData();
      // isLoading = false;
    } catch (e) {
      print("Error al generar el documento $e");
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
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

                    String nuevaFecha = "$dia/$mes/$anio";
                    setState(() {
                      date = nuevaFecha;
                    });
                    _controllers.searchController.clear();
                  }
                });
                await loadData();
              },
              child: Text(
                "SELECCIONAR FECHA: $date",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.5
                : MediaQuery.of(context).size.width * 0.9,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'TRANSPORTADORA',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: carriersToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedValueTransportator = null;
                                    });
                                    resetFilters();
                                    await loadData();
                                  },
                                  child: Icon(Icons.close))
                            ],
                          ),
                        ))
                    .toList(),
                value: selectedValueTransportator,
                onChanged: !showExternalCarriers
                    ? (value) async {
                        filtersAnd = [];
                        _controllers.searchController.clear();
                        setState(() {
                          selectedValueTransportator = value as String;
                        });
                        await loadData();
                      }
                    : null,

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {}
                },
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      generateExcelFileWithData(data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download),
                        Text(
                          "Descargar reporte",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return ScannerSent(
                            from: "logistic",
                          );
                        },
                      );
                      await loadData();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        ColorsSystem().mainBlue,
                      ),
                    ),
                    child: const Text(
                      "SCANNER",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color.fromARGB(255, 245, 244, 244),
            ),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) async {
                await loadData();
              },
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: _controllers.searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _controllers.searchController.clear();
                          });
                          loadData();
                        },
                        child: Icon(Icons.close))
                    : null,
                hintText: text,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusColor: Colors.black,
                iconColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  sortByCarrierName(datos) {
    try {
      datos.sort((a, b) {
        String nombreTransportadoraA = a['transportadora'].isNotEmpty
            ? a['transportadora'][0]['nombre']
            : "";
        String nombreTransportadoraB = b['transportadora'].isNotEmpty
            ? b['transportadora'][0]['nombre']
            : "";
        return nombreTransportadoraA.compareTo(nombreTransportadoraB);
      });
    } catch (e) {
      print("Error-sort: $e");
    }

    return datos;
  }

  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      var sortedData = sortByCarrierName(dataOrders);
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);
      var numItem = 1;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Item';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Fecha de Entrega';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Codigo de pedido';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Nombre del cliente';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Ciudad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'Transportadora';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'Producto';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'Cantidad';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
          .value = 'Id';

      for (int rowIndex = 0; rowIndex < sortedData.length; rowIndex++) {
        final data = sortedData[rowIndex];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIndex + 1))
            .value = numItem;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: rowIndex + 1))
            .value = data["fecha_entrega"];
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 2, rowIndex: rowIndex + 1))
                .value =
            "${data['users'] != null ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal'] != null ? data['tienda_temporal'].toString() : "NaN"}-${data["numero_orden"]}";
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: rowIndex + 1))
            .value = data["nombre_shipping"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: rowIndex + 1))
            .value = data["ciudad_shipping"];
        if (data["transportadora"].isEmpty) {
          if (data['pedido_carrier'] != null) {
            sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 5, rowIndex: rowIndex + 1))
                    .value =
                data['pedido_carrier'][0]['carrier']['name'].toString();
          } else {
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 5, rowIndex: rowIndex + 1))
                .value = "";
          }
        } else {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 5, rowIndex: rowIndex + 1))
              .value = data["transportadora"][0]["nombre"];
        }
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: rowIndex + 1))
            .value = data["producto_p"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: rowIndex + 1))
            .value = data["cantidad_total"];
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: rowIndex + 1))
            .value = data["id"];

        numItem++;
        //
      }

      var nombreFile =
          // "Guias_Enviadas_$name_comercial-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
          "Guias_Enviadas-EasyEcommerce-$date";

      excel.save(fileName: '${nombreFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!");
    }
  }

  sortFunc(filtro, changeval) {
    setState(() {
      if (changeval) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
  }

  sortFunc0(name) {
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

  sortFuncFecha() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['pedido_fecha']['data']['attributes']
              ['Fecha']
          .toString()
          .compareTo(a['attributes']['pedido_fecha']['data']['attributes']
                  ['Fecha']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['pedido_fecha']['data']['attributes']
              ['Fecha']
          .toString()
          .compareTo(b['attributes']['pedido_fecha']['data']['attributes']
                  ['Fecha']
              .toString()));
    }
  }

  getInfoModal(index) {
    return showDialog(
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
                      "Código: ${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'] != null ? data[index]['tienda_temporal'].toString() : "NaN"}-${data[index]['numero_orden']}"),
                  _model(
                      "Marca de Tiempo Envio: ${data[index]['marca_tiempo_envio']}"),
                  _model(
                      "Fecha: ${data[index]['marca_tiempo_envio'].toString().split(" ")[0].toString()}"),
                  _model("Detalle: ${data[index]['direccion_shipping']}"),
                  _model("Cantidad: ${data[index]['cantidad_total']}"),
                  _model("Precio Total: ${data[index]['precio_total']}"),
                  _model("Producto: ${data[index]['producto_p']}"),
                  _model(
                      "Producto Extra: ${data[index]['producto_extra'] == null || data[index]['producto_extra'] == "null" ? "" : data[index]['producto_extra']}"),
                  _model("Ciudad: ${data[index]['ciudad_shipping']}"),
                  _model("Status: ${data[index]['status']}"),
                  _model(
                      "Comentario: ${data[index]['comentario'] == null || data[index]['comentario'] == "null" ? "" : data[index]['comentario']}"),
                  _model("Fecha de Entrega: ${data[index]['fecha_entrega']}"),
                  _model("Nombre Cliente: ${data[index]['nombre_shipping']}"),
                  _model("Teléfono: ${data[index]['telefono_shipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['estado_devolucion']}"),
                  _model(
                      "Estado Logistico: ${data[index]['estado_logistico']}"),
                  _model(
                      "Observación: ${data[index]['observacion'] == null || data[index]['observacion'] == "null" ? "" : data[index]['observacion']}"),
                  _model("Marca. O: ${data[index]['estado_logistico']}"),
                  _model(
                      "Marca. TR: ${data[index]['marca_t_d_t'] == null || data[index]['marca_t_d_t'] == "null" ? "" : data[index]['marca_t_d_t']}"),
                  _model(
                      "Marca. TL: ${data[index]['marca_t_d_l'] == null || data[index]['marca_t_d_l'] == "null" ? "" : data[index]['marca_t_d_l']}"),
                  /* strapi version
                  _model(
                      "Código: ${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}"),
                  _model(
                      "Marca de Tiempo Envio: ${data[index]['attributes']['Marca_Tiempo_Envio']}"),
                  _model(
                      "Fecha: ${data[index]['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0].toString()}"),
                  _model(
                      "Detalle: ${data[index]['attributes']['DireccionShipping']}"),
                  _model(
                      "Cantidad: ${data[index]['attributes']['Cantidad_Total']}"),
                  _model(
                      "Precio Total: ${data[index]['attributes']['PrecioTotal']}"),
                  _model("Producto: ${data[index]['attributes']['ProductoP']}"),
                  _model(
                      "Producto Extra: ${data[index]['attributes']['ProductoExtra']}"),
                  _model(
                      "Ciudad: ${data[index]['attributes']['CiudadShipping']}"),
                  _model("Status: ${data[index]['attributes']['Status']}"),
                  _model(
                      "Comentario: ${data[index]['attributes']['Comentario']}"),
                  _model(
                      "Fecha de Entrega: ${data[index]['attributes']['Fecha_Entrega']}"),
                  _model(
                      "Nombre Cliente: ${data[index]['attributes']['NombreShipping']}"),
                  _model(
                      "Teléfono: ${data[index]['attributes']['TelefonoShipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['attributes']['Estado_Devolucion']}"),
                  _model(
                      "Estado Logistico: ${data[index]['attributes']['Estado_Devolucion']}"),
                  _model(
                      "Observación: ${data[index]['attributes']['Observacion']}"),
                  _model(
                      "Marca. O: ${data[index]['attributes']['Estado_Logistico']}"),
                  _model(
                      "Marca. TR: ${data[index]['attributes']['Marca_T_D_T']}"),
                  _model(
                      "Marca. TL: ${data[index]['attributes']['Marca_T_D_L']}"),
                      */
                ],
              ),
            ),
          );
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

  sortFuncTransporte() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['transportadora']['data']
              ['attributes']['Nombre']
          .toString()
          .compareTo(a['attributes']['transportadora']['data']['attributes']
                  ['Nombre']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['transportadora']['data']
              ['attributes']['Nombre']
          .toString()
          .compareTo(b['attributes']['transportadora']['data']['attributes']
                  ['Nombre']
              .toString()));
    }
  }
}
