import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/printed_guides/controllers/controllers.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides_info.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/sellers/printed_guides/controllers/controllers.dart';
import 'package:frontend/ui/sellers/printed_guides/printedguides_info.dart';
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

class PrintedGuidesSeller extends StatefulWidget {
  const PrintedGuidesSeller({super.key});

  @override
  State<PrintedGuidesSeller> createState() => _PrintedGuidesStateSeller();
}

class _PrintedGuidesStateSeller extends State<PrintedGuidesSeller> {
  PrintedGuidesControllersSeller _controllers =
      PrintedGuidesControllersSeller();
  ScreenshotController screenshotController = ScreenshotController();

  String? _barcode;
  late bool visible;
  List optionsCheckBox = [];
  List data = [];
  bool sort = false;
  List dataTemporal = [];
  bool selectAll = false;

  int currentPage = 1;
  int pageSize = 1300;
  var arrayfiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString(),
    },
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "IMPRESO"}
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

  List arrayFiltersAnd = [];

  var sortFieldDefaultValue = "id:DESC";
  var sortField = "";

  bool changevalue = false;

  int counterChecks = 0;
  var idUser = sharedPrefs!.getString("id");

  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    counterChecks = 0;

    setState(() {
      data = [];
    });

//    *
    var responseLaravel = await Connections().getOrdersForPrintGuidesLaravel(
      filtersOrCont,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      pageSize,
      sortFieldDefaultValue.toString(),
      _controllers.search.text,
    );

    var dataL = responseLaravel;
    // print(dataL['total']);
//--
/*
    response =
        await Connections().getOrdersForPrintedGuides(_controllers.search.text);

    data = response;
    dataTemporal = response;
*/
    data = responseLaravel['data'];
    dataTemporal = response;

    setState(() {
      optionsCheckBox = [];
      counterChecks = 0;
    });
    for (var i = 0; i < data.length; i++) {
      optionsCheckBox.add({
        "check": false,
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
      });
    }
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
                    _controllers.search.clear();
                    getOldValue(true);
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
                  Text(
                    "Contador: ${data.length}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return ScannerPrinted();
                              });
                          counterChecks = 0;
                          getOldValue(true);
                          await loadData();
                        },
                        child: const Text(
                          "SCANNER",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
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
                          sortFunc("nombre_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Dirección'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("direccion_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Cantidad'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          sortFunc("cantidad_total", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Producto'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("producto_p", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Producto Extra'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("producto_extra", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Precio Total'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("precio_total", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Estado'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("status", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Estado Logistico'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
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
                    rows: List<DataRow>.generate(
                        data.length,
                        (index) => DataRow(cells: [
                              DataCell(Checkbox(
                                  value: optionsCheckBox[index]['check'],
                                  onChanged: (value) {
                                    setState(() {
                                      selectAll = false;
                                      if (value!) {
                                        optionsCheckBox[index]['check'] = value;
                                        optionsCheckBox[index]['id'] =
                                            data[index]['id'].toString();
                                        optionsCheckBox[index]['numPedido'] =
                                            "${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'].toString()}-${data[index]['numero_orden']}"
                                                .toString();
                                        optionsCheckBox[index]['date'] =
                                            data[index]
                                                            ['pedido_fecha'] !=
                                                        null &&
                                                    data[index]['pedido_fecha']
                                                        .isNotEmpty
                                                ? data[index]['pedido_fecha'][0]
                                                        ['fecha']
                                                    .toString()
                                                : "";
                                        optionsCheckBox[index]['city'] =
                                            data[index]['ciudad_shipping']
                                                .toString();
                                        optionsCheckBox[index]['product'] =
                                            data[index]['producto_p']
                                                .toString();
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
                                        optionsCheckBox[index]['transport'] =
                                            "${data[index]['transportadora'] != null ? data[index]['transportadora'][0]['nombre'].toString() : ''}";
                                        optionsCheckBox[index]['address'] =
                                            data[index]['direccion_shipping']
                                                .toString();
                                        optionsCheckBox[index]['obervation'] =
                                            data[index]['observacion']
                                                .toString();
                                        optionsCheckBox[index]
                                            ['qrLink'] = data[index]['users'][0]
                                                ['vendedores'][0]['url_tienda']
                                            .toString();

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
                                      "${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden']}"
                                          .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['ciudad_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['nombre_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['direccion_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['cantidad_total'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['producto_p'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['producto_extra'] == null ||
                                          data[index]['producto_extra'] ==
                                              "null"
                                      ? ""
                                      : data[index]['producto_extra']
                                          .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['precio_total'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['estado_interno'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['estado_logistico']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['transportadora'] != null &&
                                          data[index]['transportadora']
                                              .isNotEmpty
                                      ? data[index]['transportadora'][0]
                                              ['nombre']
                                          .toString()
                                      : ''), onTap: () {
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
                                      ? formatDate(data[index]['printed_at'])
                                      : ''), onTap: () {
                                info(context, index);
                              }),
                            ]))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -7);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
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
          getLoadingModal(context, false);
          getOldValue(true);
          loadData();
          Navigator.pop(context);
        },
        onChanged: (value) {},
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.search.clear();
                    });
                    // setState(() {
                    //   data = dataTemporal;
                    // });

                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
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
                    final capturedImage =
                        await screenshotController.captureFromWidget(Container(
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
                    onLayout: (PdfPageFormat format) async => await doc.save());
                setState(() {});
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
          const SizedBox(
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
                    // responsereduceStock = await Connections()
                    //     .updateProductVariantStock(
                    //         data[i]['sku'],
                    //         data[i]['cantidad_total'],
                    //         0,
                    //         data[i]['id_comercial']);

                    // if (responsereduceStock == 0) {
                      var responseL = await Connections().updateOrderWithTime(
                          optionsCheckBox[i]['id'].toString(),
                          "estado_logistico:ENVIADO",
                          idUser,
                          "",
                          "");
                    }
                  }
                // }
                Navigator.pop(context);

                setState(() {});
                selectAll = false;
                getOldValue(true);
                await loadData();
                // if (responsereduceStock ==
                //     "No Dispone de Stock en la Reserva Comuniquese con el Proveedor") {
                //   // ignore: use_build_context_synchronously
                //   SnackBarHelper.showErrorSnackBar(
                //       context, "$responsereduceStock");
                // }
              },
              child: const Text(
                "MARCAR ENVIADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(
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

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
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
                      child: PrintedGuideInfoSeller(
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
            optionsCheckBox[i]['date'] = data[i]['pedido_fecha'] != null &&
                    data[i]['pedido_fecha'].isNotEmpty
                ? data[i]['pedido_fecha'][0]['fecha'].toString()
                : "";
            optionsCheckBox[i]['city'] = data[i]['ciudad_shipping'].toString();
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
                "${data[i]['transportadora'] != null ? data[i]['transportadora'][0]['nombre'].toString() : ''}";
            optionsCheckBox[i]['address'] =
                data[i]['direccion_shipping'].toString();
            optionsCheckBox[i]['obervation'] =
                data[i]['observacion'].toString();
            optionsCheckBox[i]['qrLink'] =
                data[i]['users'][0]['vendedores'][0]['url_tienda'].toString();

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
