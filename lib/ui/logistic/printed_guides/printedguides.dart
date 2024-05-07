import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/printed_guides/controllers/controllers.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides_info.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/scanner_printed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:js' as js;
import 'package:intl/intl.dart';

class PrintedGuides extends StatefulWidget {
  const PrintedGuides({super.key});

  @override
  State<PrintedGuides> createState() => _PrintedGuidesState();
}

class _PrintedGuidesState extends State<PrintedGuides> {
  PrintedGuidesControllers _controllers = PrintedGuidesControllers();
  ScreenshotController screenshotController = ScreenshotController();

  String? _barcode;
  late bool visible;
  List optionsCheckBox = [];
  List data = [];
  bool sort = false;
  List dataTemporal = [];
  bool selectAll = false;
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
  var arrayfiltersDefaultAnd = [];
  List arrayFiltersAnd = [];
  List arrayFiltersNot = [];

  int currentPage = 1;
  int pageSize = 1300;
  var sortFieldDefaultValue = "id:DESC";
  bool changevalue = false;

  int counterChecks = 0;
  var idUser = sharedPrefs!.getString("id");
  bool showExternalCarriers = false;

  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      data = [];
    });
    // response =
    //     await Connections().getOrdersForPrintedGuides(_controllers.search.text);
    arrayFiltersAnd = [];
    arrayFiltersNot = [];

    if (showExternalCarriers == false) {
      arrayFiltersAnd = [
        {"estado_interno": "CONFIRMADO"},
        {"estado_logistico": "IMPRESO"},
        {"status": "PEDIDO PROGRAMADO"},
        {"id_externo": null}
      ];
    } else {
      arrayFiltersAnd = [
        {"estado_interno": "CONFIRMADO"},
        {"estado_logistico": "IMPRESO"},
        {"status": "PEDIDO PROGRAMADO"},
      ];

      arrayFiltersNot = [
        {"id_externo": null}
      ];
    }
    var responseLaravel = await Connections().getOrdersForPrintGuidesLaravel(
      filtersOrCont,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      arrayFiltersNot,
      currentPage,
      pageSize,
      sortFieldDefaultValue.toString(),
      _controllers.search.text,
    );

    // data = response;
    data = responseLaravel['data'];

    // print("data logis laravel: $data");
    dataTemporal = response;

    setState(() {
      optionsCheckBox = [];
      counterChecks = 0;
    });
    for (var i = 0; i < data.length; i++) {
      optionsCheckBox.add({
        "check": false,
        "variant_details": "",
        "id": "",
        "numPedido": "",
        "date": "",
        "city": "",
        "product": "",
        "extraProduct": "",
        "quantity": "",
        "phone": "",
        "price": "",
        "name": "",
        "transport": "",
        "address": "",
        "obervation": "",
        "qrLink": "",
        "provider": "",
        "idExteralOrder": "",
      });
    }
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
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
    _controllers.search.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   enviarMensajeWhatsApp('593992107483', '¡Hola! ¿Cómo estás?');
      // }),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
                    optionsCheckBox = [];
                    _controllers.search.clear();
                    selectAll = false;
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
                height: 10,
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
                                controller: _controllers.search)),
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
                            "Contador: ${data.length}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Text(
                            "Guías Externas",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return ScannerPrinted(
                                    from: "logistic",
                                  );
                                });
                            await loadData();
                          },
                          child: const Text(
                            "SCANNER",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: DataTable2(
                    headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: TextStyle(
                        fontSize: 12,
                        // fontWeight: FontWeight.bold,
                        color: Colors.black),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 2500,
                    columns: [
                      DataColumn2(
                        label: Row(
                          children: [
                            Checkbox(
                              value: selectAll,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectAll = value ?? false;
                                  addAllValues();
                                });
                              },
                            ),
                            const Text('Todo'),
                          ],
                        ),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: const Text('Código'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("numero_orden", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Ciudad'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("ciudad_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Nombre Cliente'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          // sortFunc("NombreShipping");
                          sortFunc("nombre_shipping", changevalue);
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
                        label: const Text('Estado'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          // sortFunc("Status");
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
                        label: const Text('Transportadora'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          // sortFuncTransporte();
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
                        label: const Text('Fecha Impresion'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("printed_at", changevalue);
                        },
                      ),
                    ],
                    rows: List<DataRow>.generate(data.length, (index) {
                      Color rowColor = Colors.white;
                      if ((data[index]['printed_by'] != null &&
                          data[index]['printed_by'].isNotEmpty)) {
                        if (data[index]['printed_by']['roles_fronts'][0]
                                ['id'] !=
                            1) {
                          rowColor = Colors.lightBlue.shade50;
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
                                value: optionsCheckBox[index]['check'],
                                onChanged: (value) {
                                  setState(() {
                                    selectAll = false;
                                    if (value!) {
                                      optionsCheckBox[index]['check'] = value;
                                      optionsCheckBox[index]
                                          ['variant_details'] = data[index]
                                              ['variant_details']
                                          .toString();
                                      optionsCheckBox[index]['id'] =
                                          data[index]['id'].toString();
                                      optionsCheckBox[index]['numPedido'] =
                                          "${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'].toString()}-${data[index]['numero_orden']}"
                                              .toString();
                                      optionsCheckBox[index]['date'] =
                                          data[index]['pedido_fecha'][0]
                                                  ['fecha']
                                              .toString();
                                      // optionsCheckBox[index]['city'] =
                                      //     data[index]['ciudad_shipping']
                                      //         .toString();
                                      optionsCheckBox[index]
                                          ['city'] = data[index]['ruta'] !=
                                                  null &&
                                              data[index]['ruta'].toString() !=
                                                  "[]"
                                          ? data[index]['ruta'][0]['titulo']
                                              .toString()
                                          : data[index]['carrier_external'] !=
                                                  null
                                              ? data[index]['ciudad_external']
                                                      ['ciudad']
                                                  .toString()
                                              : "";
                                      optionsCheckBox[index]['product'] =
                                          data[index]['producto_p'].toString();
                                      optionsCheckBox[index]['extraProduct'] =
                                          data[index]['producto_extra']
                                              .toString();
                                      optionsCheckBox[index]['quantity'] =
                                          data[index]['cantidad_total']
                                              .toString();
                                      optionsCheckBox[index]['phone'] =
                                          data[index]['telefono_shipping']
                                              .toString();
                                      optionsCheckBox[index]['price'] =
                                          data[index]['precio_total']
                                              .toString();
                                      optionsCheckBox[index]['name'] =
                                          data[index]['nombre_shipping']
                                              .toString();
                                      optionsCheckBox[index]
                                          ['transport'] = data[index]
                                                      ['transportadora'] !=
                                                  null &&
                                              data[index]['transportadora']
                                                  .isNotEmpty
                                          ? data[index]['transportadora'][0]
                                                  ['nombre']
                                              .toString()
                                          : data[index]['carrier_external'] !=
                                                  null
                                              ? data[index]['carrier_external']
                                                      ['name']
                                                  .toString()
                                              : "";
                                      optionsCheckBox[index]['address'] =
                                          data[index]['direccion_shipping']
                                              .toString();
                                      optionsCheckBox[index]['obervation'] =
                                          data[index]['observacion'].toString();
                                      optionsCheckBox[index]['qrLink'] =
                                          data[index]['users'][0]['vendedores']
                                                  [0]['url_tienda']
                                              .toString();
                                      optionsCheckBox[index]['provider'] =
                                          data[index]['id_product'] != null &&
                                                  data[index]['id_product'] != 0
                                              ? getFirstProviderName(data[index]
                                                  ['product_s']['warehouses'])
                                              : "";
                                      optionsCheckBox[index]['idExteralOrder'] =
                                          data[index]['id_externo'] != null &&
                                                  data[index]['id_externo'] != 0
                                              ? data[index]['id_externo']
                                                  .toString()
                                              : "";

                                      counterChecks += 1;
                                    } else {
                                      optionsCheckBox[index]['check'] = value;
                                      optionsCheckBox[index]['id'] = '';
                                      counterChecks -= 1;
                                    }
                                  });
                                })),
                            DataCell(
                                Text(
                                    // "${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden']}"
                                    "${data[index]["users"][0]["vendedores"][0]["nombre_comercial"].toString()}-${data[index]['numero_orden']}"
                                        .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // data[index]['attributes']
                                //       ['CiudadShipping']
                                Text(
                                  data[index]['ciudad_shipping'].toString(),
                                  // data[index]['ruta'] != null &&
                                  //         data[index]['ruta'].toString() != "[]"
                                  //     ? data[index]['ruta'][0]['titulo']
                                  //         .toString()
                                  //     : data[index]['carrier_external'] != null
                                  //         ? data[index]['ciudad_external']
                                  //                 ['ciudad']
                                  //             .toString()
                                  //         : "",
                                ), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['NombreShipping']
                                Text(data[index]['nombre_shipping'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['DireccionShipping']
                                Text(data[index]['direccion_shipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['Cantidad_Total']
                                Text(data[index]['cantidad_total'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']['ProductoP']
                                Text(data[index]['producto_p'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['ProductoExtra']
                                //     .toString()),
                                Text(data[index]['producto_extra'] == null ||
                                        data[index]['producto_extra'] == "null"
                                    ? ""
                                    : data[index]['producto_extra'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']['PrecioTotal']
                                //     .toString()),
                                Text(data[index]['precio_total'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['Estado_Interno']
                                //     .toString()), onTap: () {
                                Text(data[index]['estado_interno'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(data[index]['attributes']
                                //         ['Estado_Logistico']
                                //     .toString()), onTap: () {
                                Text(
                                    data[index]['estado_logistico'].toString()),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                // Text(
                                //     "${data[index]['attributes']['transportadora']['data'] != null ? data[index]['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}"),
                                // onTap: () {
                                Text(
                                  // data[index]['transportadora'] != null &&
                                  //         data[index]['transportadora']
                                  //             .isNotEmpty
                                  //     ? data[index]['transportadora'][0]
                                  //             ['nombre']
                                  //         .toString()
                                  //     : '',
                                  data[index]['transportadora'] != null &&
                                          data[index]['transportadora']
                                              .isNotEmpty
                                      ? data[index]['transportadora'][0]
                                              ['nombre']
                                          .toString()
                                      : data[index]['carrier_external'] != null
                                          ? data[index]['carrier_external']
                                                  ['name']
                                              .toString()
                                          : "",
                                ), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['printed_by'] != null &&
                                        data[index]['printed_by'].isNotEmpty
                                    ? "${data[index]['printed_by']['username'].toString()}-${data[index]['printed_by']['id'].toString()}"
                                    : ''), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['printed_at'] != null
                                    ? "${UIUtils.formatDate(data[index]['printed_at'])}"
                                    : ''), onTap: () {
                              info(context, index);
                            }),
                          ]);
                    })),
              ),
            ],
          ),
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
          getOldValue(true);
          loadData();

          // getLoadingModal(context, false);

          // setState(() {
          //   data = dataTemporal;
          // });
          // if (value.isEmpty) {
          //   setState(() {
          //     data = dataTemporal;
          //   });
          // } else {
          //   var dataTemp = data
          //       .where((objeto) =>
          //           objeto['attributes']['NumeroOrden'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //           objeto['attributes']['CiudadShipping']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['NombreShipping']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['DireccionShipping']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['Cantidad_Total']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['ProductoP']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['ProductoExtra']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['PrecioTotal']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['Estado_Interno']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           objeto['attributes']['Estado_Logistico']
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()) ||
          //           (objeto['attributes']['transportadora']['data'] != null
          //                   ? objeto['attributes']['transportadora']['data']['attributes']['Nombre'].toString()
          //                   : '')
          //               .toString()
          //               .toLowerCase()
          //               .contains(value.toLowerCase()))
          //       .toList();
          //   setState(() {
          //     data = dataTemp;
          //   });
          // }
          // Navigator.pop(context);

          // loadData();
        },
        onChanged: (value) {},
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // getLoadingModal(context, false);
                    // setState(() {
                    //   _controllers.search.clear();
                    // });
                    // setState(() {
                    //   data = dataTemporal;
                    // });

                    // Navigator.pop(context);
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.search.clear();
                    });

                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
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
                  setState(() {});
                } else {
                  // printOnePdfExternal();
                  generateDocumentExternal();
                }
              },
              child: const Text(
                "IMPRIMIR",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),

          const SizedBox(
            width: 20,
          ),
          // ElevatedButton(
          //     onPressed: () async {
          //       getLoadingModal(context, false);

          //       for (var i = 0; i < optionsCheckBox.length; i++) {
          //         if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
          //             optionsCheckBox[i]['id'].toString() != '' &&
          //             optionsCheckBox[i]['check'] == true) {
          //           var response = await Connections()
          //               .updateOrderInteralStatusLogistic(
          //                   "NO DESEA", optionsCheckBox[i]['id'].toString());
          //         }
          //       }
          //       Navigator.pop(context);

          //       setState(() {});

          //       await loadData();
          //     },
          //     child: const Text(
          //       "NO DESEA",
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);
                var responsereduceStock;

                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    // var response = await Connections()
                    //     .updateOrderLogisticStatusPrint(
                    //         "ENVIADO", optionsCheckBox[i]['id'].toString());

                    //new
                    responsereduceStock = await Connections()
                        .updateProductVariantStock(
                            optionsCheckBox[i]['variant_details'],
                            0,
                            optionsCheckBox[i]['id_comercial']);

                    if (responsereduceStock == 0) {
                      var responseL = await Connections().updateOrderWithTime(
                          optionsCheckBox[i]['id'].toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                    }
                    if (responsereduceStock ==
                        "No Dispone de Stock en la Reserva") {
                      var emojiSaludo = "\u{1F44B}"; // 👋
                      var _url = Uri.parse(
                          "https://api.whatsapp.com/send?phone=+593${data[i]['users'][0]['vendedores'][0]['telefono_1'].toString()}&text=Hola,${emojiSaludo} ${data[i]['users'][0]['vendedores'][0]['nombre_comercial'].toString()} tu pedido con el id ${data[i]['numero_orden']} no tiene Stock en tu reserva de Producto. Deseas Recargar el Stock o Eliminar la reserva ? ");
                      if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }
                    }
                  }
                }
                Navigator.pop(context);

                setState(() {});

                await loadData();
                if (responsereduceStock ==
                    "No Dispone de Stock en la Reserva") {
                  // ignore: use_build_context_synchronously
                  SnackBarHelper.showErrorSnackBar(
                      context, "$responsereduceStock");
                }
              },
              child: const Text(
                "MARCAR ENVIADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    var response = await Connections().updatenueva(
                        optionsCheckBox[i]['id'],
                        {"estado_interno": "RECHAZADO"});
                  }
                }
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: const Text(
                "RECHAZADO",
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

      _controllers.search.clear();

      optionsCheckBox = [];
      loadData();
      // isLoading = false;
    } catch (e) {
      print("Error al generar el documento $e");
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
                      child: PrintedGuideInfo(
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
  }

  addAllValues() {
    if (selectAll == true) {
      //deleteValues();
      print("se ha seleccionado todo");
      //optionsCheckBox[index]['check']
      for (var i = 0; i < data.length; i++) {
        setState(() {
          if (optionsCheckBox[i]['check'] != true) {
            optionsCheckBox[i]['check'] = true;
            optionsCheckBox[i]['id'] = data[i]['id'].toString();
            optionsCheckBox[i]['numPedido'] =
                "${data[i]['users'] != null ? data[i]['users'][0]['vendedores'][0]['nombre_comercial'] : data[i]['tienda_temporal'].toString()}-${data[i]['numero_orden']}"
                    .toString();
            optionsCheckBox[i]['date'] =
                data[i]['pedido_fecha'][0]['fecha'].toString();
            optionsCheckBox[i]['city'] =
                data[i]['ruta'] != null && data[i]['ruta'].toString() != "[]"
                    ? data[i]['ruta'][0]['titulo'].toString()
                    : data[i]['carrier_external'] != null
                        ? data[i]['ciudad_external']['ciudad'].toString()
                        : "";
            // data[i]['ciudad_shipping'].toString();
            optionsCheckBox[i]['product'] = data[i]['producto_p'].toString();
            optionsCheckBox[i]['extraProduct'] =
                data[i]['producto_extra'].toString();
            optionsCheckBox[i]['quantity'] =
                data[i]['cantidad_total'].toString();
            optionsCheckBox[i]['phone'] =
                data[i]['telefono_shipping'].toString();
            optionsCheckBox[i]['price'] = data[i]['precio_total'].toString();
            optionsCheckBox[i]['name'] = data[i]['nombre_shipping'].toString();
            optionsCheckBox[i]['transport'] =
                data[i]['transportadora'] != null &&
                        data[i]['transportadora'].isNotEmpty
                    ? data[i]['transportadora'][0]['nombre'].toString()
                    : data[i]['carrier_external'] != null
                        ? data[i]['carrier_external']['name'].toString()
                        : "";
            optionsCheckBox[i]['address'] =
                data[i]['direccion_shipping'].toString();
            optionsCheckBox[i]['obervation'] =
                data[i]['observacion'].toString();
            optionsCheckBox[i]['qrLink'] =
                data[i]['users'][0]['vendedores'][0]['url_tienda'].toString();
            optionsCheckBox[i]['provider'] =
                data[i]['id_product'] != null && data[i]['id_product'] != 0
                    ? getFirstProviderName(data[i]['product_s']['warehouses'])
                    : "";
            optionsCheckBox[i]["idExteralOrder"] =
                data[i]['id_externo'] != null && data[i]['id_externo'] != 0
                    ? data[i]['id_externo'].toString()
                    : "";
            counterChecks += 1;
          }
          //   print("tamanio a imprimir"+optionsCheckBox.length.toString());
        });
      }
    } else {
      deleteValues();
    }
  }

  deleteValues() {
    for (var i = 0; i < optionsCheckBox.length; i++) {
      optionsCheckBox[i]['check'] = false;
      optionsCheckBox[i]['id'] = '';
      counterChecks -= 1;
    }
    // print("tamanio a imprimir"+optionsCheckBox.length.toString());
  }
}

void enviarMensajeWhatsApp(String numeroTelefono, String mensaje) {
  final url =
      'https://wa.me/$numeroTelefono?text=${Uri.encodeComponent(mensaje)}';
  js.context.callMethod('open', [url]);
}
