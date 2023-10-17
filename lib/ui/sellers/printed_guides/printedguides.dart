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
import 'package:frontend/ui/sellers/printed_guides/controllers/controllers.dart';
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

  //"Estado_Logistico" sea igual a "IMPRESO" y el "Estado_Interno" sea igual a "CONFIRMADO."

  int counterChecks = 0;
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
    print(dataL['total']);
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
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   enviarMensajeWhatsApp('593992107483', '¡Hola! ¿Cómo estás?');
      // }),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
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
              SizedBox(
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
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Contador: ${data.length}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
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
                          await loadData();
                        },
                        child: Text(
                          "SCANNER",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: DataTable2(
                    headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: TextStyle(
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
                        label: Text('Código'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("NumeroOrden");
                        },
                      ),
                      DataColumn2(
                        label: Text('Ciudad'),
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
                        label: Text('Cantidad'),
                        size: ColumnSize.S,
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
                        onSort: (columnIndex, ascending) {
                          sortFunc("PrecioTotal");
                        },
                      ),
                      DataColumn2(
                        label: Text('Estado'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Status");
                        },
                      ),
                      DataColumn2(
                        label: Text('Estado Logistico'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Estado_Logistico");
                        },
                      ),
                      DataColumn2(
                        label: Text('Transportadora'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFuncTransporte();
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
                                            data[index]['pedido_fecha'][0]
                                                    ['fecha']
                                                .toString();
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
                                      "${data[index]['name_comercial'].toString()}-${data[index]['numero_orden']}"
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
                            ]))),
              ),
            ],
          ),
        ),
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
        onSubmitted: (value) async {
          getLoadingModal(context, false);

          setState(() {
            data = dataTemporal;
          });
          if (value.isEmpty) {
            setState(() {
              data = dataTemporal;
            });
          } else {
            var dataTemp = data
                .where((objeto) =>
                    objeto['attributes']['NumeroOrden'].toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['CiudadShipping']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['NombreShipping']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['DireccionShipping']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['Cantidad_Total']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['ProductoP']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['ProductoExtra']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['PrecioTotal']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['Estado_Interno']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['Estado_Logistico']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    (objeto['attributes']['transportadora']['data'] != null
                            ? objeto['attributes']['transportadora']['data']['attributes']['Nombre'].toString()
                            : '')
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                .toList();
            setState(() {
              data = dataTemp;
            });
          }
          Navigator.pop(context);

          // loadData();
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
                    setState(() {
                      data = dataTemporal;
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
                    var response = await Connections()
                        .updateOrderLogisticStatusPrint(
                            "ENVIADO", optionsCheckBox[i]['id'].toString());
                  }
                }
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: const Text(
                "MARCAR ENVIADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
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
                "${data[i]['attributes']['users']['data'] != null ? data[i]['attributes']['users']['data'][0]['attributes']['vendedores']['data'][0]['attributes']['Nombre_Comercial'] : data[i]['attributes']['Tienda_Temporal'].toString()}-${data[i]['attributes']['NumeroOrden']}"
                    .toString();
            optionsCheckBox[i]['date'] = data[i]['attributes']['pedido_fecha']
                    ['data']['attributes']['Fecha']
                .toString();
            optionsCheckBox[i]['city'] =
                data[i]['attributes']['CiudadShipping'].toString();
            optionsCheckBox[i]['product'] =
                data[i]['attributes']['ProductoP'].toString();
            optionsCheckBox[i]['extraProduct'] =
                data[i]['attributes']['ProductoExtra'].toString();
            optionsCheckBox[i]['quantity'] =
                data[i]['attributes']['Cantidad_Total'].toString();
            optionsCheckBox[i]['phone'] =
                data[i]['attributes']['TelefonoShipping'].toString();
            optionsCheckBox[i]['price'] =
                data[i]['attributes']['PrecioTotal'].toString();
            optionsCheckBox[i]['name'] =
                data[i]['attributes']['NombreShipping'].toString();
            optionsCheckBox[i]['transport'] =
                "${data[i]['attributes']['transportadora']['data'] != null ? data[i]['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}";
            optionsCheckBox[i]['address'] =
                data[i]['attributes']['DireccionShipping'].toString();
            optionsCheckBox[i]['obervation'] =
                data[i]['attributes']['Observacion'].toString();
            optionsCheckBox[i]['qrLink'] = data[i]['attributes']['users']
                        ['data'][0]['attributes']['vendedores']['data'][0]
                    ['attributes']['Url_Tienda']
                .toString();

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