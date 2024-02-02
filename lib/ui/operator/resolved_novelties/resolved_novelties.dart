import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:frontend/ui/operator/resolved_novelties/resolved_novelties_info.dart';
import 'package:number_paginator/number_paginator.dart';
import '../../widgets/loading.dart';
import 'package:screenshot/screenshot.dart';

class ResolvedNovelties extends StatefulWidget {
  final int? idRolInvokeClass;

  const ResolvedNovelties({super.key, this.idRolInvokeClass});

  @override
  State<ResolvedNovelties> createState() => _ResolvedNoveltiesState();
}

class _ResolvedNoveltiesState extends State<ResolvedNovelties> {
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
  String filterDate = "FECHA ENTREGA";

  var sortFieldDefaultValue = "marca_t_i:DESC";

  List<String> listvendedores = ['TODO'];
  List<String> listtransportadores = ['TODO'];

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
  // List defaultArrayFiltersAnd = [
  //   {"equals/estado_devolucion": "PENDIENTE"}
  // ];

  // List defaultArrayFiltersAnd = [
  //       {"equals/estado_devolucion": "PENDIENTE"},
  //       {
  //         "equals/transportadora.transportadora_id":
  //             sharedPrefs!.getString("idTransportadora")
  //       }
  //     ];
  List defaultArrayFiltersAnd = [];
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
    {"status": "NO ENTREGADO"},
    {"status": "NOVEDAD"},
    {"status": "EN RUTA"},
    {"status": "EN OFICINA"},
    {"status": "REAGENDADO"},
    {"status": "PEDIDO PROGRAMADO"},
  ];

  String dateStart = "";
  String dateEnd = "";

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

      identifiedRolInvoke();

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
          dateStart,
          dateEnd,
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

  identifiedRolInvoke() {
    if (widget.idRolInvokeClass == 3) {
      defaultArrayFiltersAnd = [
        {"equals/estado_devolucion": "PENDIENTE"},
        {
          "equals/transportadora.transportadora_id":
              sharedPrefs!.getString("idTransportadora")
        }
      ];

      dateStart = "1/1/2010";
      dateEnd = "1/1/2200";
    } else if (widget.idRolInvokeClass == 4) {
      defaultArrayFiltersAnd = [
        {"equals/estado_devolucion": "PENDIENTE"},
        {"equals/operadore.operadore_id": sharedPrefs!.getString("idOperadore")}
      ];
      dateStart = "1/1/2010";
      dateEnd = "1/1/2200";
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
          dateStart,
          dateEnd,
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
        child: Column(
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
                                controller: _controllers.searchController),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 15, right: 5),
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
                                controller: _controllers.searchController),
                          ),
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 5),
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
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                        label: const Text('Fecha Entrega'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          // sortFunc("Fecha");
                        },
                      ),
                      DataColumn2(
                        label: const Text('Código'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {},
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
                        // label: SelectFilterNoId('Status', 'equals/status',
                        //     statusController, listStatus),
                        label: Text("Status"),
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
                        // label: SelectFilter(
                        //     'Transportadora',
                        //     'equals/transportadora.transportadora_id',
                        //     transportadorasController,
                        //     listtransportadores),
                        label: Text("Transportadora"),
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
                    ],
                    rows: List<DataRow>.generate(data.length, (index) {
                      final color =
                          index % 2 == 0 ? Colors.grey[400] : Colors.white;

                      return DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => color!),
                          cells: getRows(index));
                    }))),
          ],
        ),
      ),
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

  List<DataCell> getRows(index) {
    Color rowColor = Colors.black;

    return [
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
              color: rowColor,
            ),
          ), onTap: () {
        info(context, index);
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
    ];
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

  SizedBox _dates(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TextButton(
              //     onPressed: () async {
              //       var results = await showCalendarDatePicker2Dialog(
              //         context: context,
              //         config: CalendarDatePicker2WithActionButtonsConfig(
              //           dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
              //           yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
              //           selectedYearTextStyle:
              //               TextStyle(fontWeight: FontWeight.bold),
              //           weekdayLabelTextStyle:
              //               TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         dialogSize: const Size(325, 400),
              //         value: [],
              //         borderRadius: BorderRadius.circular(15),
              //       );
              //       setState(() {
              //         if (results != null) {
              //           String fechaOriginal = results![0]
              //               .toString()
              //               .split(" ")[0]
              //               .split('-')
              //               .reversed
              //               .join('-')
              //               .replaceAll("-", "/");
              //           List<String> componentes = fechaOriginal.split('/');

              //           String dia = int.parse(componentes[0]).toString();
              //           String mes = int.parse(componentes[1]).toString();
              //           String anio = componentes[2];

              //           String nuevaFecha = "$dia/$mes/$anio";

              //           if (widget.idRolInvokeClass! == 4) {
              //             sharedPrefs!
              //                 .setString("dateDesdeOperador", nuevaFecha);
              //           } else if (widget.idRolInvokeClass! == 3) {
              //             sharedPrefs!
              //                 .setString("dateDesdeTransportadora", nuevaFecha);
              //           }
              //         }
              //       });
              //     },
              //     child: widget.idRolInvokeClass == 4
              //         ? Text(
              //             "DESDE: ${sharedPrefs!.getString("dateDesdeOperador")}",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           )
              //         : Text(
              //             "DESDE: ${sharedPrefs!.getString("dateDesdeTransportadora")}",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           )),
              // SizedBox(
              //   width: 10,
              // ),
              // TextButton(
              //     onPressed: () async {
              //       var results = await showCalendarDatePicker2Dialog(
              //         context: context,
              //         config: CalendarDatePicker2WithActionButtonsConfig(
              //           dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
              //           yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
              //           selectedYearTextStyle:
              //               TextStyle(fontWeight: FontWeight.bold),
              //           weekdayLabelTextStyle:
              //               TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         dialogSize: const Size(325, 400),
              //         value: [],
              //         borderRadius: BorderRadius.circular(15),
              //       );
              //       setState(() {
              //         if (results != null) {
              //           String fechaOriginal = results![0]
              //               .toString()
              //               .split(" ")[0]
              //               .split('-')
              //               .reversed
              //               .join('-')
              //               .replaceAll("-", "/");
              //           List<String> componentes = fechaOriginal.split('/');

              //           String dia = int.parse(componentes[0]).toString();
              //           String mes = int.parse(componentes[1]).toString();
              //           String anio = componentes[2];

              //           String nuevaFecha = "$dia/$mes/$anio";

              //           if (widget.idRolInvokeClass! == 4) {
              //             sharedPrefs!
              //                 .setString("dateHastaOperador", nuevaFecha);
              //           } else if (widget.idRolInvokeClass! == 3) {
              //             sharedPrefs!
              //                 .setString("dateHastaTransportadora", nuevaFecha);
              //           }
              //         }
              //       });
              //     },
              //     child: widget.idRolInvokeClass == 4
              //         ? Text(
              //             "HASTA: ${sharedPrefs!.getString("dateHastaOperador")}",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           )
              //         : Text(
              //             "HASTA: ${sharedPrefs!.getString("dateHastaTransportadora")}",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           )),
              // SizedBox(
              //   width: 10,
              // ),
              // ElevatedButton(
              //     onPressed: () async {
              //       setState(() {
              //         _search.clear();
              //       });
              //       await loadData();
              //     },
              //     child: Text(
              //       "BUSCAR",
              //       style: TextStyle(fontWeight: FontWeight.bold),
              //     )),
              // SizedBox(
              //   width: 10,
              // ),
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
            ],
          ),
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
                      child: ResolvedNoveltiesInfo(
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
      case "NOVEDAD RESUELTA":
        color = 0xFF2E7D32;
        break;
      case "NOVEDAD":
        color = 0xFFF57F17;
        break;
      case "NO ENTREGADO":
        color = 0xFFE61414;
        break;
      case "REAGENDADO":
        color = 0xFFAB47BC;
        break;
      case "PEDIDO PROGRAMADO":
        color = 0xFF3341FF;
        break;
      default:
    }

    return Color(color);
  }
}
