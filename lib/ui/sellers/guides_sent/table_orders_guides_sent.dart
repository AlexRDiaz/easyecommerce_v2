import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/logistic/guides_sent/controllers/controllers.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/sellers/guides_sent/controllers/controllers.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/transport/my_orders_prv/scanner_orders_prv.dart';
import 'package:frontend/ui/widgets/filters_orders.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/scanner_printed.dart';
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

class TableOrdersGuidesSentSeller extends StatefulWidget {
  const TableOrdersGuidesSentSeller({super.key});

  @override
  State<TableOrdersGuidesSentSeller> createState() =>
      _TableOrdersGuidesSentStateSeller();
}

class _TableOrdersGuidesSentStateSeller
    extends State<TableOrdersGuidesSentSeller> {
  GuidesSentControllersSeller _controllers = GuidesSentControllersSeller();
  List data = [];

  List optionsCheckBox = [];
  int counterChecks = 0;
  Uint8List? _imageFile = null;
  bool sort = false;
  List<DateTime?> _dates = [];
  List<String> transportator = [];
  String? selectedValueTransportator;
  String date =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  int currentPage = 1;
  int pageSize = 1300;
  var filtersDefaultAnd = [
    {
      '/id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString(),
    },
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
  var sortFieldDefaultValue = "id:DESC";

  List populate = [
    "transportadora",
    "users",
    "users.vendedores",
    "pedidoFecha",
    "ruta"
  ];

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

    var responseL;

    List transportatorList = [];

    setState(() {
      transportator = [];
    });

    if (_controllers.searchController.text.isEmpty) {
      print("case1");
      if (selectedValueTransportator == null) {
        print("case1-1");

        responseL = await Connections()
            .getOrdersForPrintGuidesInSendGuidesPrincipalLaravel(
                date,
                populate,
                filtersAnd,
                filtersDefaultAnd,
                filtersOrCont,
                currentPage,
                pageSize,
                _controllers.searchController.text,
                sortFieldDefaultValue, []);
      } else {
        print("case1-2");

        filtersAnd.add({
          "equals/transportadora.transportadora_id":
              selectedValueTransportator.toString().split('-')[1]
        });
        responseL = await Connections()
            .getOrdersForPrintGuidesInSendGuidesPrincipalLaravel(
                date,
                populate,
                filtersAnd,
                filtersDefaultAnd,
                filtersOrCont,
                currentPage,
                pageSize,
                _controllers.searchController.text,
                sortFieldDefaultValue, []);
      }
    } else {
      print("case2");
      responseL = await Connections()
          .getOrdersForPrintGuidesInSendGuidesPrincipalLaravel(
              date,
              populate,
              filtersAnd,
              filtersDefaultAnd,
              filtersOrCont,
              currentPage,
              pageSize,
              _controllers.searchController.text,
              sortFieldDefaultValue, []);
    }

    data = responseL['data'];
    print("total: ${responseL['total']}");
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
    var responsetransportadoras = await Connections().getTransportadoras();
    transportatorList = responsetransportadoras['transportadoras'];
    for (var i = 0; i < transportatorList.length; i++) {
      setState(() {
        if (transportatorList != null) {
          transportator.add('${transportatorList[i]}');
        }
      });
    }
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  void resetFilters() {
    // getOldValue(true);

    filtersAnd = [];
    _controllers.searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
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
            SizedBox(
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
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Número de Ordenes: ${data.length}")),
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
                    const DataColumn2(
                      label: Text(''),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: const Text('Nombre Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("NombreShipping");
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
                      },
                    ),
                    DataColumn2(
                      label: const Text('Código'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("CiudadShipping");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Dirección'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Cantidad'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Cantidad_Total");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Producto'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("ProductoP");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Producto Extra'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("ProductoExtra");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Precio Total'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("PrecioTotal");
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
                      },
                    ),
                    DataColumn2(
                      label: const Text('Confirmado?'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Estado_Interno");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Estado Logistico'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Estado_Logistico");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Observación'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Observacion");
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marca Envio'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc("Marca_Tiempo_Envio");
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
                                    if (value!) {
                                      optionsCheckBox[index]['check'] = value;
                                      optionsCheckBox[index]['id'] =
                                          data[index]['id'].toString();
                                      optionsCheckBox[index]['numPedido'] =
                                          "${data[index]['tienda_temporal'].toString()}-${data[index]['numero_orden']}"
                                              .toString();
                                      optionsCheckBox[index]['date'] =
                                          data[index]['pedido_fecha'][0]
                                                  ['fecha']
                                              .toString();
                                      optionsCheckBox[index]['city'] =
                                          data[index]['ciudad_shipping']
                                              .toString();
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
                                      optionsCheckBox[index]['transport'] =
                                          "${data[index]['transportadora'] != null ? data[index]['transportadora'][0]['nombre'].toString() : ''}";
                                      optionsCheckBox[index]['address'] =
                                          data[index]['direccion_shipping']
                                              .toString();
                                      optionsCheckBox[index]['obervation'] =
                                          data[index]['observacion'].toString();
                                      optionsCheckBox[index]['qrLink'] =
                                          data[index]['users'][0]['vendedores']
                                                  [0]['Url_Tienda']
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
                                Text(data[index]['nombre_shipping'].toString()),
                                onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['pedido_fecha'][0]['fecha']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(data[index]['fecha_entrega'] ??
                                    "".toString()), onTap: () {
                              getInfoModal(index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color:
                                            GetColor(data[index]['revisado'])!),
                                    '${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}'),
                                onTap: () {
                              getInfoModal(index);
                            }),
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
                                  : ''),
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
                            DataCell(
                                Text(data[index]['marca_tiempo_envio']
                                    .toString()), onTap: () {
                              getInfoModal(index);
                            }),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  Container _buttons() {
    return Container(
      margin: EdgeInsets.all(3.0),
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
                _controllers.searchController.clear();
                setState(() {});

                // loadData();
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
                //no deberia ser aqui, deberia ser despues de asignar la ruta
                //???
                // for (var i = 0; i < optionsCheckBox.length; i++) {
                //   if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                //       optionsCheckBox[i]['id'].toString() != '' &&
                //       optionsCheckBox[i]['check'] == true) {
                //     // var response = await Connections()
                //     //     .updateOrderInteralStatusInOrderPrinted(
                //     //         "PENDIENTE", optionsCheckBox[i]['id'].toString());
                //     var response3 = await Connections().updateOrderLaravel(
                //         optionsCheckBox[i]['id'].toString(),
                //         {"estado_logistico": "PENDIENTE"});
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

                setState(() {});
                loadData();
              },
              child: const Text(
                "Ruta",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () async {
                var results = await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    dayTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                    yearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                    selectedYearTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    weekdayLabelTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
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
                  }
                });
                await loadData();
              },
              child: Text(
                "SELECCIONAR FECHA: $date",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 10,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'TRANSPORTADORA',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold),
              ),
              items: transportator
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.split('-')[0],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
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
              onChanged: (value) async {
                setState(() {
                  selectedValueTransportator = value as String;
                });
                await loadData();
              },

              //This to clear the search value when you close the menu
              onMenuStateChange: (isOpen) {
                if (!isOpen) {}
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  generatePDFFileWithData1(data);
                  print("general");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 163, 81),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconData(0xf6df, fontFamily: 'MaterialIcons'),
                      size: 24,
                      color: Colors.white,
                    ),
                    Text(
                      "Descargar reporte",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return ScannerSent();
                        });
                    await loadData();
                  },
                  child: const Text(
                    "SCANNER",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
          ),
        ],
      ),
    );
  }

  Color? GetColor(state) {
    var color;
    if (state == true) {
      color = 0xFF26BC5F;
    } else {
      color = 0xFF000000;
    }
    return Color(color);
  }

  Future<void> generatePDFFileWithData(dataOrders) async {
    try {
      //add ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    "${sharedPrefs!.getString("NameComercialSeller").toString()} Informe Guías Enviadas",
                    style: const pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>[
                      'Fecha de Entrega',
                      'Código del pedido',
                      'Nombre del cliente',
                      'Ciudad',
                      'Transportadora',
                      'Producto',
                      'Cantidad',
                    ],
                    for (var data in dataOrders)
                      <String>[
                        data["fecha_entrega"],
                        "${data["name_comercial"]}-${data["numero_orden"]}",
                        data["nombre_shipping"],
                        data["ciudad_shipping"],
                        data['transportadora'] != null &&
                                data['transportadora'].isNotEmpty
                            ? data['transportadora'][0]['nombre'].toString()
                            : '',
                        data["producto_p"],
                        data["cantidad_total"].toString(),
                      ]
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await pdf.save());
    } catch (e) {
      print("Error en Generar el reporte: $e");
    }
  }

  Future<void> generatePDFFileWithData1(dataOrders) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          // margin: const pw.EdgeInsets.only(top: 100),
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            int rowNumber = 1;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "${sharedPrefs!.getString("NameComercialSeller").toString()} Informe Guías Enviadas",
                  style: const pw.TextStyle(
                    // font: pw.Font.courier(),
                    fontSize: 13,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FractionColumnWidth(0.03), //  #
                    1: pw.FractionColumnWidth(
                        0.1), // Ancho de la columna 1 Fecha de Entrega
                    2: pw.FractionColumnWidth(
                        0.15), // Ancho de la columna 2 Código
                    3: pw.FractionColumnWidth(
                        0.2), // Ancho de la columna 3  Nombre
                    4: pw.FractionColumnWidth(
                        0.15), // Ancho de la columna 4  Ciudad
                    5: pw.FractionColumnWidth(
                        0.17), // Ancho de la columna 5 Transportadora
                    6: pw.FractionColumnWidth(0.25), // Producto
                    7: pw.FractionColumnWidth(0.1), //  Cantidad
                  },
                  children: <pw.TableRow>[
                    pw.TableRow(
                      children: <pw.Widget>[
                        _buildTableCell(' # ', header: true),
                        _buildTableCell('Fecha de\n Entrega', header: true),
                        _buildTableCell('Código', header: true),
                        _buildTableCell('Nombre del\n cliente', header: true),
                        _buildTableCell('Ciudad', header: true),
                        _buildTableCell('Transportadora', header: true),
                        _buildTableCell('Producto', header: true),
                        _buildTableCell('Cantidad', header: true),
                      ],
                    ),
                    for (var data in dataOrders)
                      pw.TableRow(
                        children: <pw.Widget>[
                          _buildTableCell(" ${(rowNumber++).toString()} "),
                          _buildTableCell(data["fecha_entrega"]),
                          _buildTableCell(
                              "${data["name_comercial"]}-\n${data["numero_orden"]}"),
                          _buildTableCell(data["nombre_shipping"]),
                          _buildTableCell(data["ciudad_shipping"]),
                          _buildTableCell(
                            data['transportadora'] != null &&
                                    data['transportadora'].isNotEmpty
                                ? data['transportadora'][0]['nombre'].toString()
                                : '',
                          ),
                          _buildTableCell(data["producto_p"]),
                          _buildTableCell(data["cantidad_total"].toString()),
                        ],
                      )
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await pdf.save());
    } catch (e) {
      print("Error en Generar el reporte: $e");
    }
  }

  pw.Widget _buildTableCell(String text, {bool header = false}) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding:
          header ? const pw.EdgeInsets.all(3.0) : const pw.EdgeInsets.all(3.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: header ? 9 : 8,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Easy ',
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }

  Future<void> generatePDFFileWithData2(dataOrders) async {
    try {
      //add ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    "${sharedPrefs!.getString("NameComercialSeller").toString()} Informe Guías Enviadas",
                    style: const pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  context: context,
                  // headerStyle: TextStyle(fontWeight: FontWeight.bold),
                  // headerDecoration: BoxDecoration(color: PdfColors.grey300),
                  data: <List<String>>[
                    <String>[
                      'Fecha de Entrega',
                      'Código del pedido',
                      'Nombre del cliente',
                      'Ciudad',
                      'Transportadora',
                      'Producto',
                      'Cantidad',
                    ],
                    for (var data in dataOrders)
                      <String>[
                        data["fecha_entrega"],
                        "${data["name_comercial"]}-${data["numero_orden"]}",
                        data["nombre_shipping"],
                        data["ciudad_shipping"],
                        data["producto_p"],
                        data["cantidad_total"].toString(),
                        data['transportadora'] != null &&
                                data['transportadora'].isNotEmpty
                            ? data['transportadora'][0]['nombre'].toString()
                            : '',
                      ]
                  ],
                ),
              ],
            );
          },
        ),
      );

      // final tempDir = await getTemporaryDirectory();
      // final pdfFile = File('${tempDir.path}/reporte_pedidos.pdf');
      // await pdfFile.writeAsBytes(await pdf.save());

      //  var nombreFile =
      //     "$name_transportadora-EasyEcommerce-${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      // excel.save(fileName: '${nombreFile}.xlsx');

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await pdf.save());
    } catch (e) {
      print("Error en Generar el reporte: $e");
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
