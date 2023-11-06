import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/logistic/print_guides/controllers/controllers.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/sellers/print_guides/controllers/controllers.dart';

import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:frontend/main.dart';

class PrintGuidesSeller extends StatefulWidget {
  const PrintGuidesSeller({super.key});

  @override
  State<PrintGuidesSeller> createState() => _PrintGuidesStateSeller();
}

class _PrintGuidesStateSeller extends State<PrintGuidesSeller> {
  PrintGuidesControllersSeller _controllers = PrintGuidesControllersSeller();
  List data = [];
  List selectedCheckBox = [];
  int counterChecks = 0;
  Uint8List? _imageFile = null;
  bool sort = false;
  List dataTemporal = [];
  bool selectAll = false;
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  int currentPage = 1;
  int pageSize = 1300;
  var idUser = sharedPrefs!.getString("id");
  var arrayfiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString(),
    },
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "PENDIENTE"}
  ];

  List filtersOrCont = [
    // 'fecha_entrega',
    'nombre_shipping',
    "name_comercial",
    'numero_orden',
    'ciudad_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    'status',
    'comentario',
    "estado_interno",
    "estado_logistico",
    "observacion"
  ];

  List arrayFiltersAnd = [];

  var sortFieldDefaultValue = "id:DESC";
  var sortField = "";

  bool changevalue = false;

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

//    *
    var responseLaravel = await Connections().getOrdersForPrintGuidesLaravel(
      filtersOrCont,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      pageSize,
      sortFieldDefaultValue.toString(),
      _controllers.searchController.text,
    );

    var dataL = responseLaravel;
    // print(dataL['total']);
    // print("id_user: $idUser");
    // ---this

    var response = [];
/*
    response = await Connections()
        .getOrdersForPrintGuides(_controllers.searchController.text);

    data = response;
    dataTemporal = response;
*/
    data = responseLaravel['data'];
    // dataTemporal = data;
    setState(() {
      counterChecks = 0;
    });
    for (Map pedido in data) {
      var selectedItem = selectedCheckBox
          .where((elemento) => elemento["id"] == pedido["id"])
          .toList();
      if (selectedItem.isNotEmpty) {
        pedido['check'] = true;
      } else {
        pedido['check'] = false;
      }
    }
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
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
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
              children: [
                Text(
                  counterChecks > 0
                      ? "Seleccionados: ${selectedCheckBox.length}"
                      : "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "Contador: ${data.length}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
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
                      label: const Text('Dirección'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("direccion_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("telefono_shipping", changevalue);
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
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
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
                        sortFunc("status", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Confirmado?'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("estado_interno", changevalue);
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
                      label: const Text('Observación'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("observacion", changevalue);
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(cells: [
                            DataCell(Checkbox(
                                value: data[index]['check'],
                                onChanged: (value) {
                                  setState(() {
                                    data[index]['check'] = value;
                                  });

                                  if (value!) {
                                    selectedCheckBox.add({
                                      "check": false,
                                      "id": data[index]['id'].toString(),
                                      "numPedido":
                                          "${data[index]['users'] != null ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal'].toString()}-${data[index]['numero_orden']}"
                                              .toString(),
                                      "date": data[index]['pedido_fecha'][0]
                                              ['fecha']
                                          .toString(),
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
                                      "price": data[index]['precio_total']
                                          .toString(),
                                      "name": data[index]['nombre_shipping']
                                          .toString(),
                                      "transport":
                                          data[index]['transportadora'] != null
                                              ? data[index]['transportadora'][0]
                                                      ['nombre']
                                                  .toString()
                                              : '',
                                      "address": data[index]
                                              ['direccion_shipping']
                                          .toString(),
                                      "obervation":
                                          data[index]['observacion'].toString(),
                                      "qrLink": data[index]['users'][0]
                                              ['vendedores'][0]['url_tienda']
                                          .toString(),
                                    });
                                  } else {
                                    var m = data[index]['id'];
                                    selectedCheckBox.removeWhere((option) =>
                                        option['id'] ==
                                        data[index]['id'].toString());
                                  }
                                  setState(() {
                                    counterChecks = selectedCheckBox.length;
                                  });
                                })),
                            DataCell(
                                Text(data[index]['nombre_shipping'].toString()),
                                onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['pedido_fecha'][0]['fecha']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(Text(
                                "${data[index]['name_comercial'].toString()}-${data[index]['numero_orden']}"
                                    .toString())),
                            DataCell(
                                Text(data[index]['ciudad_shipping'].toString()),
                                onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['direccion_shipping']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['telefono_shipping']
                                    .toString()), onTap: () {
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
                            DataCell(
                                Text(data[index]['precio_total'].toString()),
                                onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['transportadora'] != null &&
                                        data[index]['transportadora'].isNotEmpty
                                    ? data[index]['transportadora'][0]['nombre']
                                        .toString()
                                    : ''), onTap: () {
                              getInfoModal(index);
                            }),
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
                                Text(
                                    data[index]['estado_logistico'].toString()),
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
                            /*
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['pedido_fecha']
                                        ['data']['attributes']['Fecha']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(Text(
                                "${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden']}"
                                    .toString())),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoP']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(
                                    "${data[index]['attributes']['transportadora']['data'] != null ? data[index]['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}"),
                                onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Status']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Interno']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Logistico']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Observacion']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            */
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  Widget showProgressIndicator(BuildContext context, width, height, progress) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Container(
            width: width * progress,
            height: height,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
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

                for (var i = 0; i < selectedCheckBox.length; i++) {
                  // print(optionsCheckBox[i]);
                  if (selectedCheckBox[i]['id'].toString().isNotEmpty &&
                      selectedCheckBox[i]['id'].toString() != '') {
                    final capturedImage =
                        await screenshotController.captureFromWidget(Container(
                            child: ModelGuide(
                      address: selectedCheckBox[i]['address'],
                      city: selectedCheckBox[i]['city'],
                      date: selectedCheckBox[i]['date'],
                      extraProduct: selectedCheckBox[i]['extraProduct'],
                      idForBarcode: selectedCheckBox[i]['id'],
                      name: selectedCheckBox[i]['name'],
                      numPedido: selectedCheckBox[i]['numPedido'],
                      observation: selectedCheckBox[i]['obervation'],
                      phone: selectedCheckBox[i]['phone'],
                      price: selectedCheckBox[i]['price'],
                      product: selectedCheckBox[i]['product'],
                      qrLink: selectedCheckBox[i]['qrLink'],
                      quantity: selectedCheckBox[i]['quantity'],
                      transport: selectedCheckBox[i]['transport'],
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

                    // var responseL = await Connections().updatenueva(
                    //     selectedCheckBox[i]['id'].toString(),
                    //     {"estado_logistico": "IMPRESO", "printed_by": idUser});

                    //new
                    var responseL = await Connections().updateOrderWithTime(
                        selectedCheckBox[i]['id'].toString(),
                        "estado_logistico:IMPRESO",
                        idUser,
                        "",
                        "");
                  }
                }
                Navigator.pop(context);
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => await doc.save());
                _controllers.searchController.clear();
                setState(() {});
                selectedCheckBox = [];
                selectAll = false;
                getOldValue(true);
                loadData();
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
                await showDialog(
                    context: context,
                    builder: (context) {
                      return RoutesModalv2(
                          idOrder: selectedCheckBox,
                          someOrders: true,
                          phoneClient: "",
                          codigo: "",
                          origin: "print");
                    });

                setState(() {});
                selectedCheckBox = [];
                selectAll = false;
                getOldValue(true);
                await loadData();
              },
              child: const Text(
                "Asignar Ruta",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
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
          getOldValue(true);
          loadData();
        },
        // onSubmitted: (value) {
        //   getLoadingModal(context, false);

        //   setState(() {
        //     data = dataTemporal;
        //   });
        //   if (value.isEmpty) {
        //     setState(() {
        //       data = dataTemporal;
        //     });
        //   } else {
        //     var dataTemp = data
        //         .where((objeto) =>
        //             objeto['attributes']['NumeroOrden'].toString().toLowerCase().contains(value.toLowerCase()) ||
        //             objeto['attributes']['CiudadShipping']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['NombreShipping']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['DireccionShipping']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['Cantidad_Total']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['ProductoP']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['ProductoExtra']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['PrecioTotal']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['Estado_Interno']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['Status']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['Observacion']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             objeto['attributes']['Estado_Logistico']
        //                 .toString()
        //                 .toLowerCase()
        //                 .contains(value.toLowerCase()) ||
        //             (objeto['attributes']['transportadora']['data'] != null ? objeto['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : '').toString().toLowerCase().contains(value.toLowerCase()))
        //         .toList();
        //     setState(() {
        //       data = dataTemp;
        //     });
        //   }
        //   Navigator.pop(context);

        //   // loadData();
        // },
        onChanged: (value) {},
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // getLoadingModal(context, false);
                    // setState(() {
                    //   _controllers.searchController.clear();
                    // });
                    // setState(() {
                    //   data = dataTemporal;
                    // });
                    // Navigator.pop(context);

                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
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

  sortFunc(filtro, changevalu) {
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

  sortFuncTransporte() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['transportadora'][0]['nombre']
          .toString()
          .compareTo(a['transportadora'][0]['nombre'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['transportadora'][0]['nombre']
          .toString()
          .compareTo(b['transportadora'][0]['nombre'].toString()));
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
                      "Código: ${data[index]['name_comercial']}-${data[index]['numero_orden']}"),
                  _model(
                      "Fecha: ${data[index]['pedido_fecha'][0]['fecha'].toString()}"),
                  _model("Nombre Cliente: ${data[index]['nombre_shipping']}"),
                  _model("Teléfono: ${data[index]['telefono_shipping']}"),
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
                  _model(
                      "Fecha de Entrega: ${data[index]['fecha_entrega'] == null || data[index]['fecha_entrega'] == "null" ? "" : data[index]['fecha_entrega']}"),
                  _model(
                      "Marca de Tiempo Envio: ${data[index]['marca_tiempo_envio'] == null || data[index]['marca_tiempo_envio'] == "null" ? "" : data[index]['marca_tiempo_envio']}"),
                  _model(
                      "Estado Logistico: ${data[index]['estado_devolucion']}"),
                  _model(
                      "Observación: ${data[index]['observacion'] == null || data[index]['observacion'] == "null" ? "" : data[index]['observacion']}"),
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

  addAllValues() {
    selectedCheckBox = [];
    if (selectAll) {
      //optionsCheckBox[index]['check']
      for (Map element in data) {
        setState(() {
          element['check'] = true;
        });
        selectedCheckBox.add({
          "id": element['id'].toString(),
          "numPedido":
              "${element['users'] != null ? element['users'][0]['vendedores'][0]['nombre_comercial'] : element['tienda_temporal'].toString()}-${element['numero_orden']}"
                  .toString(),
          "date": element['pedido_fecha'][0]['fecha'].toString(),
          "city": element['ciudad_shipping'].toString(),
          "product": element['producto_p'].toString(),
          "extraProduct": element['producto_extra'].toString(),
          "quantity": element['cantidad_total'].toString(),
          "phone": element['telefono_shipping'].toString(),
          "price": element['precio_total'].toString(),
          "name": element['nombre_shipping'].toString(),
          "transport": element['transportadora'] != null
              ? element['transportadora'][0]['nombre'].toString()
              : '',
          "address": element['direccion_shipping'].toString(),
          "obervation": element['observacion'].toString(),
          "qrLink":
              element['users'][0]['vendedores'][0]['url_tienda'].toString(),
        });
      }
    } else {
      setState(() {
        for (Map element in data) {
          element['check'] = false;
        }
      });
    }
    setState(() {
      counterChecks = selectedCheckBox.length;
    });
  }
}
