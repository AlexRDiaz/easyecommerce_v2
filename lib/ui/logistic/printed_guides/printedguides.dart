import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/printed_guides/controllers/controllers.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides_info.dart';
import 'package:frontend/ui/widgets/loading.dart';
// import 'package:frontend/ui/widgets/logistic/scanner_printed.dart';
import 'package:frontend/ui/widgets/logistic/scanner_printed_laravel.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:js' as js;

class PrintedGuides extends StatefulWidget {
  const PrintedGuides({super.key});

  @override
  State<PrintedGuides> createState() => _PrintedGuidesState();
}
class _PrintedGuidesState extends State<PrintedGuides> {
  PrintedGuidesControllers _controllers = PrintedGuidesControllers();
  ScreenshotController screenshotController = ScreenshotController();

  String? _barcode;
  List optionsCheckBox = [];
  List data = [];
  // bool sort = false;
  // List dataTemporal = [];
  bool selectAll = false;

  // ! Laravel
  bool isLoading = false;
  int pageCount = 100;
  int total = 0;
  int currentPage = 1;
  int pageSize = 70;
  bool changevalue = false;
  var sortFieldDefaultValue = "id:DESC";
  List arrayFiltersDefaultAnd = [
    {"estado_logistico": "IMPRESO"},
    {"estado_interno": "CONFIRMADO"}
  ];
  List arrayFiltersNot = [];
  List populate = [
    'users',
    'pedido_fecha',
    'ruta',
    'transportadora',
    'users.vendedores'
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "ciudad_shipping",
    "numero_orden",
    "nombre_shipping",
    "direccion_shipping",
    "telefono_shipping",
    "producto_p",
    "producto_extra",
    "precio_total",
    "cantidad_total",
    "status",
    "estado_logistico"
  ];
  NumberPaginatorController paginatorController = NumberPaginatorController();

  int counterChecks = 0;
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  deafultcheck() {
    for (Map pedido in data) {
      var selectedItem = optionsCheckBox
          .where((elemento) => elemento["id"] == pedido["id"])
          .toList();
      if (selectedItem.isNotEmpty) {
        pedido['check'] = true;  
        print(pedido);
      } else {
        pedido['check'] = false;
      }
    }
  }

  loadData() async {
    isLoading = true;
    currentPage = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = [];
    setState(() {
      data.clear();
    });
    var response = await Connections().getOrdersForPrintedGuidesLaravel(
        populate,
        arrayFiltersAnd,
        arrayFiltersDefaultAnd,
        arrayFiltersOr,
        currentPage,
        pageSize,
        _controllers.search.text,
        sortFieldDefaultValue.toString(),
        arrayFiltersNot);

    setState(() {
      // data = [];
      data = response['data'];
      pageCount = response['last_page'];
      total = response['total'];
      paginatorController.navigateToPage(0);

      counterChecks = 0;
    });
      deafultcheck();

      // print(data);

    // for (var i = 0; i < data.length; i++) {
    //   optionsCheckBox.add({
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

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {
      isLoading = false;
    });
    // optionsCheckBoxs=[];
  }

  paginateData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var response = await Connections().getOrdersForPrintedGuidesLaravel(
          populate,
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          currentPage,
          pageSize,
          _controllers.search.text,
          sortFieldDefaultValue.toString(),
          arrayFiltersNot); 

      setState(() {
        // data = [];
        data = response['data'];
        total = response['total'];
        pageCount = response['last_page'];

      });

        deafultcheck();

      // print(data);



      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      Navigator.pop(context);
    }
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
                    width: 200,
                    padding: EdgeInsets.all(10.0),
                    // color: ColorsSystem().colorBlack,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent),
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
                    // SizedBox(
                    //   width: 10,
                    // ),
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
                    "Contador: $total",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  // return ScannerPrinted();
                                  return ScannerPrintedLaravel();
                                });
                            await loadData();
                          },
                          child: const Text(
                            "SCANNER",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  Expanded(child: numberPaginator()),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0)),
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
                              // Checkbox(
                              //   value: selectAll,
                              //   onChanged: (bool? value) {
                              //     setState(() {
                              //       selectAll = value ?? false;
                              //       // addAllValues();
                              //     });
                              //   },
                              // ),
                              const Text('Todo'),
                            ],
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Text('Código'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("NumeroOrden");
                          },
                        ),
                        DataColumn2(
                          label: Text('Ciudad'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("CiudadShipping");
                          },
                        ),
                        DataColumn2(
                          label: Text('Nombre Cliente'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("NombreShipping");
                          },
                        ),
                        DataColumn2(
                          label: Text('Dirección'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("DireccionShipping");
                          },
                        ),
                        DataColumn2(
                          label: Text('Cantidad'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("Cantidad_Total");
                          },
                        ),
                        DataColumn2(
                          label: Text('Producto'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("ProductoP");
                          },
                        ),
                        DataColumn2(
                          label: Text('Producto Extra'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("ProductoExtra");
                          },
                        ),
                        DataColumn2(
                          label: Text('Precio Total'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("PrecioTotal");
                          },
                        ),
                        DataColumn2(
                          label: Text('Estado'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("Status");
                          },
                        ),
                        DataColumn2(
                          label: Text('Estado Logistico'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFunc("Estado_Logistico");
                          },
                        ),
                        DataColumn2(
                          label: Text('Transportadora'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // sortFuncTransporte();
                          },
                        ),
                      ],
                      rows: List<DataRow>.generate(
                          data.length,
                          (index) => DataRow(cells: [
                                DataCell(Checkbox(
                                    // value: optionsCheckBox[index]['check'],
                                    value: data[index]['check'],
                                    onChanged: (value) {
                                      setState(() {
                                        data[index]['check'] = value;
                                        // print(data[index]);
                                      });
                                        // selectAll = false;
                                        if (value!) {
                                          optionsCheckBox.add({
                                            "id": data[index]['id'].toString(),
                                            "numPedido": "${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'].toString()}-${data[index]['numero_orden']}",
                                            "date": data[index]['pedido_fecha'][0]['fecha'].toString(),
                                            "city":data[index]['ciudad_shipping'].toString(),
                                            "product": data[index]['producto_p'].toString(),
                                            "extraProduct": data[index]['producto_extra'].toString(),
                                            "quantity": data[index]['cantidad_total'].toString(),
                                            "phone": data[index]['telefono_shipping'].toString(),
                                            "price":data[index]['precio_total'].toString(),
                                            "name": data[index]['nombre_shipping'].toString(),
                                            "transport": data[index]['transportadora']!= null  ? data[index]['transportadora'][0]['nombre'].toString() : '',
                                            "address":   data[index]['direccion_shipping'].toString(),
                                            "obervation":data[index]['observacion'].toString(),
                                            "qrLink": data[index]['users'][0]['vendedores'][0]['url_tienda'].toString(),
                                          });                                              
                                          counterChecks += 1;
                                        } else {
                                          optionsCheckBox.removeWhere((element) => element['id']==data[index]['id']);
                                          counterChecks -= 1;
                                        }
                                        // print(optionsCheckBox[index]);
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
                                    Text(data[index]['cantidad_total']
                                        .toString()), onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(data[index]['producto_p'].toString()),
                                    onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(data[index]['producto_extra']
                                        .toString()), onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(
                                        data[index]['precio_total'].toString()),
                                    onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(data[index]['estado_interno']
                                        .toString()), onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(data[index]['estado_logistico']
                                        .toString()), onTap: () {
                                  info(context, index);
                                }),
                                DataCell(
                                    Text(data[index]['transportadora'] != null
                                        ? data[index]['transportadora'][0]
                                                ['nombre']
                                            .toString()
                                        : ''), onTap: () {
                                  info(context, index);
                                }),
                              ]))),
                ),
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
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // loadData();
          paginateData();

          // getLoadingModal(context, false);

          // setState(() {
          //   data = dataTemporal;
          // });
          // if (value.isEmpty) {
          //   setState(() {
          //     data = dataTemporal;
          //   });
          // } else {

          // var dataTemp = data
          //     .where((objeto) =>
          //         objeto['attributes']['NumeroOrden'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //         objeto['attributes']['CiudadShipping']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['NombreShipping']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['DireccionShipping']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['Cantidad_Total']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['ProductoP']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['ProductoExtra']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['PrecioTotal']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['Estado_Interno']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         objeto['attributes']['Estado_Logistico']
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()) ||
          //         (objeto['attributes']['transportadora']['data'] != null
          //                 ? objeto['attributes']['transportadora']['data']['attributes']['Nombre'].toString()
          //                 : '')
          //             .toString()
          //             .toLowerCase()
          //             .contains(value.toLowerCase()))
          //     .toList();
          // setState(() {
          //   data = dataTemp;
          // });
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
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.search.clear();
                    });

                    setState(() {
                      paginateData();
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
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 244, 244),
          borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.all(10.0),
      // margin: EdgeInsets.all(5.0),
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
                      optionsCheckBox[i]['id'].toString() != '' 
                      ) {
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
                setState(() {
                  optionsCheckBox =[];
                });
              },
              child: const Text(
                "IMPRIMIR",
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
                    var response = await Connections()
                        .updateOrderInteralStatusLogisticLaravel(
                            "NO DESEA", optionsCheckBox[i]['id'].toString());
                  }
                }
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: const Text(
                "NO DESEA",
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
                    var response = await Connections()
                        .updateOrderLogisticStatusPrintLaravel(
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

  // sortFunc(name) {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) => b['attributes'][name]
  //         .toString()
  //         .compareTo(a['attributes'][name].toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) => a['attributes'][name]
  //         .toString()
  //         .compareTo(b['attributes'][name].toString()));
  //   }
  // }

  // sortFuncTransporte() {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) => b['attributes']['transportadora']['data']
  //             ['attributes']['Nombre']
  //         .toString()
  //         .compareTo(a['attributes']['transportadora']['data']['attributes']
  //                 ['Nombre']
  //             .toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) => a['attributes']['transportadora']['data']
  //             ['attributes']['Nombre']
  //         .toString()
  //         .compareTo(b['attributes']['transportadora']['data']['attributes']
  //                 ['Nombre']
  //             .toString()));
  //   }
  // }

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
                          id: data[index]['id'].toString(), data: data))
                ],
              ),
            ),
          );
        });
  }

  // addAllValues() {
  //   if (selectAll == true) {
  //     //deleteValues();
  //     // print("se ha seleccionado todo");
  //     //optionsCheckBox[index]['check']
  //     for (var i = 0; i < data.length; i++) {
  //       setState(() {
  //         if (optionsCheckBox[i]['check'] != true) {
  //           optionsCheckBox[i]['check'] = true;
  //           optionsCheckBox[i]['id'] = data[i]['id'].toString();
  //           optionsCheckBox[i]['numPedido'] =
  //               "${data[i]['users'] != null ? data[i]['users'][0]['vendedores'][0]['nombre_comercial'] : data[i]['tienda_temporal'].toString()}-${data[i]['numero_orden']}"
  //                   .toString();
  //           optionsCheckBox[i]['date'] =
  //               data[i]['pedido_fecha'][0]['fecha'].toString();
  //           optionsCheckBox[i]['city'] = data[i]['ciudad_shipping'].toString();
  //           optionsCheckBox[i]['product'] = data[i]['producto_p'].toString();
  //           optionsCheckBox[i]['extraProduct'] =
  //               data[i]['producto_Extra'].toString();
  //           optionsCheckBox[i]['quantity'] =
  //               data[i]['cantidad_total'].toString();
  //           optionsCheckBox[i]['phone'] =
  //               data[i]['telefono_shipping'].toString();
  //           optionsCheckBox[i]['price'] = data[i]['precio_total'].toString();
  //           optionsCheckBox[i]['name'] = data[i]['nombre_shipping'].toString();
  //           optionsCheckBox[i]['transport'] = data[i]['transportadora'] != null
  //               ? data[i]['transportadora'][0]['nombre'].toString()
  //               : '';
  //           optionsCheckBox[i]['address'] =
  //               data[i]['direccion_shipping'].toString();
  //           optionsCheckBox[i]['obervation'] =
  //               data[i]['observacion'].toString();
  //           optionsCheckBox[i]['qrLink'] =
  //               data[i]['users'][0]['vendedores'][0]['url_tienda'].toString();

  //           counterChecks += 1;
  //         }
  //         //   print("tamanio a imprimir"+optionsCheckBox.length.toString());
  //       });
  //     }
  //   } else {
  //     deleteValues();
  //   }
  // }

  // deleteValues() {
  //   for (var i = 0; i < optionsCheckBox.length; i++) {
  //     optionsCheckBox[i]['check'] = false;
  //     optionsCheckBox[i]['id'] = '';
  //     counterChecks -= 1;
  //   }
  //   // print("tamanio a imprimir"+optionsCheckBox.length.toString());
  // }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonUnselectedForegroundColor: const Color.fromARGB(255, 67, 67, 67),
        buttonSelectedBackgroundColor: const Color.fromARGB(255, 67, 67, 67),
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

void enviarMensajeWhatsApp(String numeroTelefono, String mensaje) {
  final url =
      'https://wa.me/$numeroTelefono?text=${Uri.encodeComponent(mensaje)}';
  js.context.callMethod('open', [url]);
}
