import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
// import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/print_guides_laravel/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';

import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/report_manifiesto.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
// import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

class PrintGuidesLaravel extends StatefulWidget {
  const PrintGuidesLaravel({super.key});

  @override
  State<PrintGuidesLaravel> createState() => _PrintGuidesLaravelState();
}

class _PrintGuidesLaravelState extends State<PrintGuidesLaravel> {
  PrintGuidesLaravelControllers _controllers = PrintGuidesLaravelControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  Uint8List? _imageFile = null;
  bool sort = false;
  List dataTemporal = [];
  bool selectAll = false;
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  var idUser = sharedPrefs!.getString("id");

  int currentPage = 1;
  int pageSize = 300;
  int pageCount = 1;
  bool isFirst = true;
  bool isLoading = false;
  int total = 0;
  bool changevalue = false;

  String model = "PedidosShopify";
  var sortFieldDefaultValue = "id:DESC";
  List populate = [
    'transportadora',
    'users.vendedores',
    'ruta',
    'product_s.warehouses.provider',
    "pedidoCarrier"
  ];
  // List arrayFiltersAnd = [
  //   {"/estado_logistico": "PENDIENTE"},
  //   {"/estado_interno": "CONFIRMADO"}
  // ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "nombre_shipping",
    "numero_orden",
    "ciudad_shipping",
    "direccion_shipping",
    "telefono_shipping",
    "cantidad_total",
    "producto_p",
    "producto_extra",
    "precio_total",
    "transportadora.nombre",
    "status",
    "estado_interno",
    "estado_logistico",
    "observacion"
  ];
  List arrayFiltersNot = [];

  bool showExternalCarriers = false;
  // List relationsToInclude = ['ruta', 'transportadora'];
  // List relationsToExclude = ['pedidoCarrier'];
  List relationsToInclude = [];
  List relationsToExclude = [];

  var getReport = ReportManifiesto();

  @override
  void didChangeDependencies() {
    // if (Provider.of<FiltersOrdersProviders>(context).indexActive == 2) {
    //   setState(() {
    //     _controllers.searchController.text = "d/m/a,d/m/a";
    //     data = [];
    //   });
    // } else {
    //   setState(() {
    //     data = [];

    //     _controllers.searchController.clear();
    //   });
    // }
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      // print("loadData: $externalCarriers");
      isLoading = true;
      arrayFiltersAnd = [];
      arrayFiltersNot = [];

      if (showExternalCarriers == false) {
        arrayFiltersAnd = [
          {"/estado_logistico": "PENDIENTE"},
          {"/estado_interno": "CONFIRMADO"},
          // {"/id_externo": null}
        ];
        relationsToInclude = ['ruta', 'transportadora'];
        relationsToExclude = ['pedidoCarrier'];
      } else {
        arrayFiltersAnd = [
          {"/estado_logistico": "PENDIENTE"},
          {"/estado_interno": "CONFIRMADO"},
        ];

        arrayFiltersNot = [
          // {"id_externo": null}
        ];
        relationsToInclude = ['pedidoCarrier'];
        relationsToExclude = ['ruta', 'transportadora'];
      }
      var responseL = await Connections().generalData(
          pageSize,
          pageCount,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersOr,
          relationsToInclude,
          relationsToExclude,
          _controllers.searchController.text,
          model,
          "",
          "",
          "",
          sortFieldDefaultValue);

      data = responseL['data'];
      dataTemporal = responseL['data'];

      total = responseL['total'];

      setState(() {
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

      isLoading = false;
    } catch (e) {
      print("Error en cargar información");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        isLoading: isLoading,
        content: Scaffold(
          body: Container(
            width: double.infinity,
            child: webContainer(),
          ),
        ));
  }

  Column webContainer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: counterChecks != 0
                  ? _buttons()
                  : _modelTextField(
                      text: "Busqueda",
                      controller: _controllers.searchController),
            ),
            SizedBox(
              width: 10,
            ),
            /*
            ElevatedButton(
              onPressed: () async {
                try {
                  // var pdfContent =
                  //     await Connections().getGintraLabel("idExteralOrder");
                  // if (pdfContent is Uint8List) {
                  //   await Printing.layoutPdf(
                  //     onLayout: (format) => pdfContent!,
                  //   );
                  // } else {
                  //   print("Error: No se pudo obtener el PDF desde el backend.");
                  // }
                  Stopwatch stopwatch = Stopwatch();

                  // Iniciar el cronómetro
                  stopwatch.start();

                  var idsExternals = [
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016",
                    "EC000000010",
                    "EC000000012",
                    "EC000000013",
                    "EC000000014",
                    "EC000000015",
                    "EC000000016"
                  ];
                  print("Start get pdf");

                  var pdfContentTotal =
                      await Connections().multiExternalGuidesGTM(idsExternals);

                  if (pdfContentTotal is Uint8List) {
                    await Printing.layoutPdf(
                      onLayout: (format) => pdfContentTotal!,
                    );
                  } else {
                    print("Error: No se pudo obtener el PDF desde el backend.");
                  }

                  // Detener el cronómetro
                  stopwatch.stop();

                  // Obtener la duración transcurrida
                  Duration duration = stopwatch.elapsed;

                  // Imprimir la duración transcurrida en milisegundos
                  print(
                      'La función tardó ${duration.inMilliseconds} milisegundos en ejecutarse.');
                } catch (error) {
                  print("Error: $error");
                }
              },
              child: Text(
                "Imprimir Externos",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            */
          ],
        ),
        SizedBox(
          height: 10,
        ),
        responsive(
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Text(
                    counterChecks > 0
                        ? "Seleccionados: ${optionsCheckBox.length}"
                        : "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "Total: $total",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    "Guías externas",
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      Text(
                        counterChecks > 0
                            ? "Seleccionados: ${optionsCheckBox.length}"
                            : "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Total: $total",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
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
              ],
            ),
            context),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                  // border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0)),
              child: dataT(),
            ),
          ),
        ),
      ],
    );
  }

  //
  /*
  printOnePdfExternal() async {
    print("printOnePdfExternal");
    int total = optionsCheckBox.length;
    int step = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.0),
              Text("Cargando... $step/$total "),
            ],
          ),
        );
      },
    );

    await Future.forEach(optionsCheckBox, (checkBox) async {
      if (checkBox['id'].toString().isNotEmpty &&
          checkBox['id'].toString() != '') {
        //
        var pdfContent =
            await Connections().getGintraLabel(checkBox['idExteralOrder']);
        if (pdfContent is Uint8List) {
          Navigator.pop(context);

          await Printing.layoutPdf(
            onLayout: (format) => pdfContent,
          );
          var responseL = await Connections().updateOrderWithTime(
            checkBox['id'].toString(),
            "estado_logistico:IMPRESO",
            idUser,
            "",
            "",
          );
        } else {
          print("Error: No se pudo obtener el PDF desde el backend.");
        }
        //
      }
    });

    loadData();
  }
  */

  DataTable2 dataT() {
    return DataTable2(
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
            label: Text('Nombre Cliente'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("NombreShipping");
            },
          ),
          DataColumn2(
            label: Text('Fecha'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {
              // sortFuncFecha();
            },
          ),
          DataColumn2(
            label: Text('Código'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              sortFunc("numero_orden", changevalue);
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
            label: Text('Dirección'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("DireccionShipping");
            },
          ),
          DataColumn2(
            label: Text('Teléfono Cliente'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("TelefonoShipping");
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
            label: Text('Transportadora'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncTransporte();
            },
          ),
          DataColumn2(
            label: Text('Status'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("Status");
            },
          ),
          DataColumn2(
            label: Text('Confirmado?'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("Estado_Interno");
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
            label: Text('Observación'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFunc("Observacion");
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
                          // print(data[index]);
                          optionsCheckBox.add({
                            "check": false,
                            "id": data[index]['id'].toString(),
                            "numPedido":
                                "${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}"
                                    .toString(),
                            "date": data[index]['marca_t_i'].toString(),
                            // "city": data[index]['ciudad_shipping'].toString(),
                            "city": data[index]['ruta'] != null &&
                                    data[index]['ruta'].toString() != "[]"
                                ? data[index]['ruta'][0]['titulo'].toString()
                                : data[index]['pedido_carrier'].isNotEmpty
                                    ? data[index]['pedido_carrier'][0]
                                            ['city_external']['ciudad']
                                        .toString()
                                    : "",
                            "product": data[index]['producto_p'].toString(),
                            "extraProduct":
                                data[index]['producto_extra'] == null ||
                                        data[index]['producto_extra'] == "null"
                                    ? ""
                                    : data[index]['producto_extra'].toString(),
                            "quantity":
                                data[index]['cantidad_total'].toString(),
                            "phone":
                                data[index]['telefono_shipping'].toString(),
                            "price": data[index]['precio_total'].toString(),
                            "name": data[index]['nombre_shipping'].toString(),
                            "transport":
                                data[index]['transportadora'] != null &&
                                        data[index]['transportadora'].isNotEmpty
                                    ? data[index]['transportadora'][0]['nombre']
                                        .toString()
                                    : data[index]['pedido_carrier'].isNotEmpty
                                        ? data[index]['pedido_carrier'][0]
                                                ['carrier']['name']
                                            .toString()
                                        : "",
                            "address":
                                data[index]['direccion_shipping'].toString(),
                            "obervation": data[index]['observacion'].toString(),
                            "qrLink": data[index]['users'] != null &&
                                    data[index]['users'].toString() != "[]"
                                ? data[index]['users'][0]['vendedores'][0]
                                        ['url_tienda']
                                    .toString()
                                : "",
                            "provider": data[index]['id_product'] != null &&
                                    data[index]['id_product'] != 0
                                ? getFirstProviderName(
                                    data[index]['product_s']['warehouses'])
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
                              option['id'] == data[index]['id'].toString());
                        }
                        setState(() {
                          counterChecks = optionsCheckBox.length;
                        });
                      })),
                  DataCell(Text(data[index]['nombre_shipping'].toString()),
                      onTap: () {
                    getInfoModal(index);
                  }),
                  DataCell(
                      // Text(data[index]['attributes']['pedido_fecha']
                      //         ['data']['attributes']['Fecha']
                      //     .toString()),
                      Text(data[index]['marca_t_i'].toString()), onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(
                      "${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}"
                          .toString())),
                  DataCell(
                      Text(
                        data[index]['ciudad_shipping'].toString(),
                        // data[index]['ruta'] != null &&
                        //         data[index]['ruta'].toString() != "[]"
                        //     ? data[index]['ruta'][0]['titulo'].toString()
                        //     : data[index]['carrier_external'] != null
                        //         ? data[index]['ciudad_external']['ciudad']
                        //             .toString()
                        //         : "",
                      ), onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['direccion_shipping'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['telefono_shipping'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(
                    Center(
                      child: Text(
                        data[index]['id_product'] != null &&
                                data[index]['id_product'] != 0
                            ? data[index]['id_product'].toString()
                            : "",
                      ),
                    ),
                  ),
                  DataCell(Text(data[index]['cantidad_total'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['producto_p'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(
                      Text(data[index]['producto_extra'] == null ||
                              data[index]['producto_extra'] == "null"
                          ? ""
                          : data[index]['producto_extra'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['precio_total'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(
                      // Text(
                      //   "${data[index]['transportadora'] != null && data[index]['transportadora'].toString() != "[]" ? data[index]['transportadora'][0]['nombre'].toString() : ""}",
                      Text(
                        data[index]['transportadora'] != null &&
                                data[index]['transportadora'].isNotEmpty
                            ? data[index]['transportadora'][0]['nombre']
                                .toString()
                            : data[index]['pedido_carrier'].isNotEmpty
                                ? data[index]['pedido_carrier'][0]['carrier']
                                        ['name']
                                    .toString()
                                : "",
                      ), onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['status'].toString()), onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['estado_interno'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['estado_logistico'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                  DataCell(Text(data[index]['observacion'].toString()),
                      onTap: () {
                    // getInfoModal(index);
                  }),
                ])));
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

  Container _buttons() {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                if (!showExternalCarriers) {
                  generateDocument();
                } else {
                  // printOnePdfExternal();
                  generateDocumentExternal();
                }
              },
              child: const Text(
                "IMPRIMIR",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: !showExternalCarriers
                  ? () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return RoutesModalv2(
                              idOrder: optionsCheckBox,
                              someOrders: true,
                              phoneClient: "",
                              codigo: "",
                              origin: " ",
                            );
                          });

                      setState(() {});
                      await loadData();
                    }
                  : null,
              child: Text(
                "Asignar Ruta",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          // SizedBox(child: showProgressIndicator(context, 200, 20, 0.6)),
        ],
      ),
    );
  }

  void generateDocument() async {
    try {
      // setState(() {
      //   isLoading = true;
      // });
      const double point = 1.0;
      const double inch = 72.0;
      const double cm = inch / 2.54;
      const double mm = inch / 25.4;
      // getLoadingModal(context, false);

      int total = optionsCheckBox.length;
      int step = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20.0),
                Text("Cargando... $step/$total "),
              ],
            ),
          );
        },
      );

      // getReport.generateExcelReport(optionsCheckBox);

      final doc = pw.Document();

      await Future.forEach(optionsCheckBox, (checkBox) async {
        if (checkBox['id'].toString().isNotEmpty &&
            checkBox['id'].toString() != '') {
          final capturedImage = await screenshotController.captureFromWidget(
            Container(
              child: ModelGuide(
                address: checkBox['address'],
                city: checkBox['city'],
                date: checkBox['date'],
                extraProduct: checkBox['extraProduct'],
                idForBarcode: checkBox['id'],
                name: checkBox['name'],
                numPedido: checkBox['numPedido'],
                observation: checkBox['obervation'],
                phone: checkBox['phone'],
                price: checkBox['price'],
                product: checkBox['product'],
                qrLink: checkBox['qrLink'],
                quantity: checkBox['quantity'],
                transport: checkBox['transport'],
                provider: checkBox['provider'],
              ),
            ),
          );

          doc.addPage(
            pw.Page(
              pageFormat:
                  PdfPageFormat(21.0 * cm, 21.0 * cm, marginAll: 0.1 * cm),
              build: (pw.Context context) {
                return pw.Row(
                  children: [
                    pw.Image(pw.MemoryImage(capturedImage),
                        fit: pw.BoxFit.contain),
                  ],
                );
              },
            ),
          );

          step++;

          // Actualizar el diálogo con el progreso actual
          Navigator.pop(context); // Cerrar el diálogo actual
          if (step != total) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20.0),
                      Text("Cargando... $step/$total "),
                    ],
                  ),
                );
              },
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20.0),
                      Text("Generando Documento..."),
                    ],
                  ),
                );
              },
            );
          }
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) {
          //     return AlertDialog(
          //       content: Row(
          //         children: [
          //           CircularProgressIndicator(),
          //           SizedBox(width: 20.0),
          //           Text("Cargando... $step/$total "),
          //         ],
          //       ),
          //     );
          //   },
          // );

          var responseL = await Connections().updateOrderWithTime(
            checkBox['id'].toString(),
            "estado_logistico:IMPRESO",
            idUser,
            "",
            "",
          );
        }
      });

      // Cerrar el diálogo después de completar todas las iteraciones
      Navigator.pop(context);
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await doc.save());
      _controllers.searchController.clear();
      // setState(() {});
      // setState(() {
      //   isLoading = false;
      // });
      optionsCheckBox = [];
      loadData();
      // isLoading = false;
    } catch (e) {
      print("Error al generar el documento $e");
    }
  }

  void generateDocumentExternal() async {
    try {
      getLoadingModal(context, false);
      getReport.generateExcelReport(optionsCheckBox);

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
        await Future.forEach(optionsCheckBox, (checkBox) async {
          if (checkBox['id'].toString().isNotEmpty &&
              checkBox['id'].toString() != '') {
            //
            var responseL = await Connections().updateOrderWithTime(
              checkBox['id'].toString(),
              "estado_logistico:IMPRESO",
              idUser,
              "",
              "",
            );
          }
          //
        });
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
      loadData();
      // isLoading = false;
    } catch (e) {
      print("Error al generar el documento $e");
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.5,
      // padding: EdgeInsets.only(top: 15.0),
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // paginateData();
          loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });

                    setState(() {
                      // paginateData();
                      loadData();
                    });
                    // Navigator.pop(context);
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
                      "Código: ${data[index]['users'] != null && data[index]['users'].toString() != "[]" ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : data[index]['tienda_temporal']}-${data[index]['numero_orden']}"),
                  _model("Fecha: ${data[index]['marca_t_i'].toString()}"),
                  _model("Nombre Cliente: ${data[index]['nombre_shipping']}"),
                  _model("Teléfono: ${data[index]['telefono_shipping']}"),
                  _model("Detalle: ${data[index]['direccion_shipping']}"),
                  _model("Cantidad: ${data[index]['cantidad_total']}"),
                  _model("Precio Total: ${data[index]['precio_total']}"),
                  _model("Producto: ${data[index]['producto_p']}"),
                  _model("Producto Extra: ${data[index]['producto_extra']}"),
                  _model("Ciudad: ${data[index]['ciudad_shipping']}"),
                  _model("Status: ${data[index]['status']}"),
                  _model("Comentario: ${data[index]['comentario']}"),
                  _model("Fecha de Entrega: ${data[index]['fecha_entrega']}"),
                  _model(
                      "Marca de Tiempo Envio: ${data[index]['marca_tiempo_envio']}"),
                  _model(
                      "Estado Logistico: ${data[index]['estado_devolucion']}"),
                  _model("Observación: ${data[index]['observacion']}"),
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
    optionsCheckBox = [];
    if (selectAll) {
      //optionsCheckBox[index]['check']
      for (Map element in data) {
        setState(() {
          element['check'] = true;
        });
        optionsCheckBox.add({
          "id": element['id'].toString(),
          "numPedido":
              "${element['users'] != null && element['users'].toString() != "[]" ? element['users'][0]['vendedores'][0]['nombre_comercial'] : element['tienda_temporal']}-${element['numero_orden']}"
                  .toString(),
          "date": element['marca_t_i'].toString(),
          "city": element['ruta'] != null && element['ruta'].toString() != "[]"
              ? element['ruta'][0]['titulo'].toString()
              : element['pedido_carrier'].isNotEmpty
                  ? element['pedido_carrier'][0]['city_external']['ciudad']
                      .toString()
                  : "",
          // "city": element['ciudad_shipping'].toString(),
          "product": element['producto_p'].toString(),
          "extraProduct": element['producto_extra'].toString(),
          "quantity": element['cantidad_total'].toString(),
          "phone": element['telefono_shipping'].toString(),
          "price": element['precio_total'].toString(),
          "name": element['nombre_shipping'].toString(),
          "transport": element['transportadora'] != null &&
                  element['transportadora'].isNotEmpty
              ? element['transportadora'][0]['nombre'].toString()
              : element['pedido_carrier'].isNotEmpty
                  ? element['pedido_carrier'][0]['carrier']['name'].toString()
                  : "",
          "address": element['direccion_shipping'].toString(),
          "obervation": element['observacion'].toString(),
          "qrLink": element['users'] != null &&
                  element['users'].toString() != "[]"
              ? element['users'][0]['vendedores'][0]['url_tienda'].toString()
              : "".toString(),
          "provider":
              element['id_product'] != null && element['id_product'] != 0
                  ? getFirstProviderName(element['product_s']['warehouses'])
                  : "",
          "idExteralOrder": element['pedido_carrier'].isNotEmpty
              ? element['pedido_carrier'][0]['external_id'].toString()
              : "",
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
      counterChecks = optionsCheckBox.length;
    });
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
}
