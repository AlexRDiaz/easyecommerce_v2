import 'dart:math';

import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/payment_vouchers_transport_new.dart';
import 'package:frontend/ui/transport/transportation_billing/info_transportation_billing.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class TransportationBilling extends StatefulWidget {
  const TransportationBilling({super.key});

  @override
  State<TransportationBilling> createState() => _TransportationBillingState();
}

class _TransportationBillingState extends State<TransportationBilling> {
  TextEditingController searchController = TextEditingController();
  List data = [];

  int currentPage = 1;
  int pageSize = 500;
  int pageCount = 0;
  bool isLoading = false;
  List populate = [
    "operadore.up_users",
    "transportadora",
    "users.vendedores",
    "novedades",
    // "pedidoFecha",
    "ruta",
    "subRuta",
  ];
  List arrayFiltersOr = [
    "operadore.up_users.username",
    // "operadore.up_users.email",
    'marca_tiempo_envio',
    'fecha_entrega',
    'numero_orden',
    'name_comercial',
    'nombre_shipping',
    'ciudad_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    'producto_extra',
    'precio_total',
    'status',
    'comentario',
    'tipo_pago',
    //operador,
    'estado_devolucion',
    'estado_pagado',
  ];
  String selectedDateFilter = "FECHA ENTREGA";

  List arrayFiltersDefaultAnd = [
    {
      'transportadora.transportadora_id':
          sharedPrefs!.getString("idTransportadora").toString()
    },
    {'estado_logistico': "ENVIADO"},
    {'estado_interno': "CONFIRMADO"}
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersNot = [
    {'status': 'PEDIDO PROGRAMADO'},
  ];
  String sortFieldDefaultValue = "id:ASC";

  List<String> listOperators = ['TODO'];
  TextEditingController operadorController =
      TextEditingController(text: "TODO");
  TextEditingController statusController = TextEditingController(text: "TODO");
  List<String> listStatus = [
    'TODO',
    // 'PEDIDO PROGRAMADO',
    'NOVEDAD',
    'NOVEDAD RESUELTA',
    'ENTREGADO',
    'NO ENTREGADO',
    'REAGENDADO',
    'EN OFICINA',
    'EN RUTA'
  ];

  bool changevalue = false;
  int total = 0;
  int totalC = 0;
  double dailyProceedsC = 0;
  double dailyShippingCostC = 0;
  double dailyTotalC = 0;
  double totalOperatorCost = 0;
  String? date = sharedPrefs!.getString("dateOperatorState");
  List<DateTime?> _dates = [];
  String? selectedOperator;

  @override
  void initState() {
    data = [];
    loadData();
    super.initState();
  }

  loadData() async {
    currentPage = 1;
    setState(() {
      isLoading = true;
      dailyProceedsC = 0;
      dailyShippingCostC = 0;
      dailyTotalC = 0;
    });

    try {
      if (listOperators.length == 1) {
        var responsetransportadoras = await Connections()
            .getOperatoresbyTransport(
                sharedPrefs!.getString("idTransportadora").toString());
        List<dynamic> transportadorasList =
            responsetransportadoras['operadores'];
        for (var transportadora in transportadorasList) {
          listOperators.add(transportadora);
        }
      }
      //
      var response = await Connections()
          .getOrdersForSellerStateSearchForDateTransporterLaravel(
              selectedDateFilter,
              sharedPrefs!.getString("dateOperatorState"),
              sharedPrefs!.getString("dateOperatorState"),
              populate,
              arrayFiltersAnd,
              arrayFiltersDefaultAnd,
              arrayFiltersOr,
              arrayFiltersNot,
              currentPage,
              pageSize,
              searchController.text,
              sortFieldDefaultValue);

      if (response == 1) {
        setState(() {
          data = [];
          isLoading = false;
          totalOperatorCost = 0;
        });
      } else {
        data = response["data"];

        for (var i = 0; i < data.length; i++) {
          if (data[i]['status'].toString() == "ENTREGADO") {
            dailyProceedsC += double.parse(
                data[i]['precio_total'].toString().replaceAll(",", "."));
          }
        }
        for (var i = 0; i < data.length; i++) {
          if (data[i]['status'].toString() == "ENTREGADO" ||
              data[i]['status'].toString() == "NO ENTREGADO") {
            // double costOp = data[i]['operadore'].toString() != null &&
            //         data[i]['operadore'].toString().isNotEmpty
            //     ? data[i]['operadore'] != null &&
            //             data[i]['operadore'].isNotEmpty &&
            //             data[i]['operadore'][0]['up_users'] != null &&
            //             data[i]['operadore'][0]['up_users'].isNotEmpty &&
            //             data[i]['operadore'][0]['up_users'][0]
            //                     ['costo_operador'] !=
            //                 null
            //         ? double.parse(data[i]['operadore'][0]['costo_operador']
            //             .toString()
            //             .replaceAll(",", "."))
            //         : 0
            //     : 0;
            var costo = data[i]['operadore'][0]['costo_operador']
                .toString()
                .replaceAll(",", ".");
            dailyShippingCostC += double.parse(costo);
          }
        }
        dailyProceedsC = double.parse(dailyProceedsC.toStringAsFixed(2));
        dailyShippingCostC =
            double.parse(dailyShippingCostC.toStringAsFixed(2));
        dailyTotalC = double.parse(
            (dailyProceedsC - dailyShippingCostC).toStringAsFixed(2));
        setState(() {
          total = response["total"];
        });
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    setState(() {
      isLoading = true;
      data = [];
    });

    try {
      if (listOperators.length == 1) {
        var responsetransportadoras = await Connections()
            .getOperatoresbyTransport(
                sharedPrefs!.getString("idTransportadora").toString());
        List<dynamic> transportadorasList =
            responsetransportadoras['operadores'];
        for (var transportadora in transportadorasList) {
          listOperators.add(transportadora);
        }
      }
      //
      var response = await Connections()
          .getOrdersForSellerStateSearchForDateTransporterLaravel(
              selectedDateFilter,
              sharedPrefs!.getString("dateOperatorState"),
              sharedPrefs!.getString("dateOperatorState"),
              populate,
              arrayFiltersAnd,
              arrayFiltersDefaultAnd,
              arrayFiltersOr,
              arrayFiltersNot,
              currentPage,
              pageSize,
              searchController.text,
              sortFieldDefaultValue);

      setState(() {
        data = [];
        data = response['data'];
        total = response["total"];
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  getOldValue(Arrayrestoration) {
    List respaldo = [
      {
        'transportadora.transportadora_id':
            sharedPrefs!.getString("idTransportadora").toString()
      }
    ];
    if (Arrayrestoration) {
      setState(() {
        arrayFiltersAnd.clear();
        arrayFiltersAnd = respaldo;
        sortFieldDefaultValue = "id:ASC";
      });
    }
  }

  void resetFilters() {
    getOldValue(true);

    operadorController.text = 'TODO';
    statusController.text = "TODO";
    selectedOperator = null;

    arrayFiltersAnd = [];
    searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Container(
          width: double.infinity,
          child: ListView(
            children: <Widget>[
              Container(
                // color: Colors.grey[300],
                color: Colors.white,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () async {
                                    resetFilters();
                                    loadData();
                                  },
                                  icon: Icon(
                                    Icons.autorenew_rounded,
                                    // size: 35,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        responsive(
                            Row(
                              children: [
                                dateSelector(),
                                const SizedBox(width: 10),
                                Text(
                                  "Fecha: ${sharedPrefs!.getString("dateOperatorState")}",
                                ),
                                const SizedBox(width: 20),
                                operatorSelector(width),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    dateSelector(),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Fecha: ${sharedPrefs!.getString("dateOperatorState")}",
                                    ),
                                  ],
                                ),
                                operatorSelector(width),
                              ],
                            ),
                            context),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Valores Recibidos: \$$dailyProceedsC"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Costo Entrega: \$$dailyShippingCostC"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Total: \$$dailyTotalC"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              " Estado Pago Operador: ${data.isNotEmpty ? data[0]['estado_pagado'].toString() : ''}",
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: responsive(
                              webMainContainer(width, heigth, context),
                              mobileMainContainer(width, heigth, context),
                              context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextButton dateSelector() {
    return TextButton(
      onPressed: () async {
        var results = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            dayTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            yearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            selectedYearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            weekdayLabelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
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

            sharedPrefs!.setString("dateOperatorState", nuevaFecha);
          }
        });
        loadData();
      },
      child: const Text(
        "Seleccionar Fecha",
      ),
    );
  }

  SizedBox operatorSelector(double width) {
    return SizedBox(
      width: width > 600 ? width * 0.3 : width * 0.7,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Operador',
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold),
          ),
          items: listOperators
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
                        GestureDetector(
                            onTap: () async {
                              setState(() {
                                selectedOperator = null;
                                arrayFiltersAnd.removeWhere((element) =>
                                    element.containsKey(
                                        'operadore.up_users.operadore_id'));
                              });

                              // print("arrayFiltersAnd");
                              // print(arrayFiltersAnd);
                              await loadData();
                            },
                            child: Icon(Icons.close))
                      ],
                    ),
                  ))
              .toList(),
          value: selectedOperator,
          onChanged: (value) async {
            setState(() {
              selectedOperator = value as String;

              arrayFiltersAnd.removeWhere((element) =>
                  element.containsKey('operadore.up_users.operadore_id'));

              if (selectedOperator != 'TODO') {
                arrayFiltersAnd.add({
                  'operadore.up_users.operadore_id':
                      selectedOperator?.split('-')[1]
                });
              }

              // print("arrayFiltersAnd");
              // print(arrayFiltersAnd);
            });
            await loadData();
          },

          //This to clear the search value when you close the menu
          onMenuStateChange: (isOpen) {
            if (!isOpen) {}
          },
        ),
      ),
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _searchBar(width, heigth, context),
              const SizedBox(height: 10),
              _dataTableOrders(heigth),
            ],
          ),
        ),
      ],
    );
  }

  Container _dataTableOrders(height) {
    return Container(
      height: height * 0.80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: data.length > 0
          ? DataTableModelPrincipal(
              columnWidth: 200,
              columns: getColumns(),
              rows: buildDataRows(data))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  mobileMainContainer(double width, double heigth, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _searchBar(width, heigth, context),
          const SizedBox(height: 10),
          _dataTableOrdersMobile(heigth),
        ],
      ),
    );
  }

  _dataTableOrdersMobile(height) {
    return data.length > 0
        ? Container(
            height: height * 0.65,
            child: DataTableModelPrincipal(
                columnWidth: 400,
                columns: getColumns(),
                rows: buildDataRows(data)),
          )
        : const Center(
            child: Text("Sin datos"),
          );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text("Fecha Envio"),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Fecha Entrega'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Nombre Cliente'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("nombre_shipping", changevalue);
        },
      ),
      // const DataColumn2(
      //   label: Text('Ciudad'),
      //   size: ColumnSize.M,
      // ),
      DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("direccion_shipping", changevalue);
        },
      ),
      const DataColumn2(
        label: Text('Teléfono Cliente'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Producto'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc3("producto_p", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Producto Extra'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("producto_extra", changevalue);
        },
      ),
      const DataColumn2(
        label: Text('Precio Total'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: SelectFilterStatus(
            'Estado de entrega', 'status', statusController, listStatus),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc3("status", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Comentario'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("comentario", changevalue);
        },
      ),
      const DataColumn2(
        label: Text('Tipo pago'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Operador'),
        size: ColumnSize.M,
      ),
      // DataColumn2(
      //   label: SelectFilter('Operador', 'operadore.up_users.operadore_id',
      //       operadorController, listOperators),
      //   size: ColumnSize.L,
      //   // onSort: (columnIndex, ascending) {},
      // ),
      const DataColumn2(
        label: Text('Estado Devolución'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Est. Pago Operador'),
        size: ColumnSize.M,
      ),
    ];
  }

  sortFunc3(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        // changevalue = true;
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
  }

  List<DataRow> buildDataRows(List data) {
    data = data;

    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            InkWell(
              child: Text(
                data[index]['marca_tiempo_envio'] == null
                    ? ""
                    : data[index]['marca_tiempo_envio'].toString(),
              ),
            ),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['fecha_entrega'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            InkWell(
              child: Text(
                  '${data[index]['users'] != null && data[index]['users'].isNotEmpty ? data[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data[index]['numero_orden'].toString()}',
                  style: TextStyle(
                      color: GetColor(data[index]['status'].toString()))),
            ),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['nombre_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          // DataCell(
          //   Text(data[index]['ciudad_shipping'].toString()),
          //   onTap: () {
          //     info(context, index);
          //   },
          // ),
          DataCell(
            Text(data[index]['direccion_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['telefono_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['cantidad_total'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['producto_p'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['producto_extra'] == null ||
                    data[index]['producto_extra'].toString() == "null"
                ? ""
                : data[index]['producto_extra'].toString()),
          ),
          DataCell(
            Text("\$ ${data[index]['precio_total'].toString()}"),
          ),
          DataCell(
            Text(data[index]['status'].toString()),
          ),
          DataCell(
            Text(data[index]['comentario'] == null ||
                    data[index]['comentario'].toString() == "null"
                ? ""
                : data[index]['comentario'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(data[index]['tipo_pago'] == null ||
                    data[index]['tipo_pago'].toString() == "null"
                ? ""
                : data[index]['tipo_pago'].toString()),
          ),
          DataCell(
            Text(data[index]['operadore'].toString() != null &&
                    data[index]['operadore'].toString().isNotEmpty
                ? data[index]['operadore'] != null &&
                        data[index]['operadore'].isNotEmpty &&
                        data[index]['operadore'][0]['up_users'] != null &&
                        data[index]['operadore'][0]['up_users'].isNotEmpty &&
                        data[index]['operadore'][0]['up_users'][0]
                                ['username'] !=
                            null
                    ? data[index]['operadore'][0]['up_users'][0]['username']
                    : ""
                : ""),
          ),
          DataCell(
            Text(data[index]['estado_devolucion'].toString()),
          ),
          DataCell(
            Text(data[index]['estado_pagado'].toString()),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.black),
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
                    arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                    // reemplazarValor(value, newValue!);
                    //  print(value);
                  }

                  // paginateData();
                  loadData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value.split("-")[0], style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Column SelectFilterStatus(String title, filter,
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
            height: 0,
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
                      arrayFiltersAnd.add({filter: newValue});
                    } else {
                      reemplazarValor(filter, newValue!);
                      arrayFiltersAnd.add(filter);
                    }
                    print(filter);
                  } else {}

                  // loadData();
                  paginateData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> info(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width * 0.95,
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
                    child: InfoTransportationBilling(
                  // id: data[index]['id'].toString(),
                  order: data[index],
                ))
              ],
            ),
          ),
        );
      },
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

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF33FF6D;
        break;
      case "NOVEDAD":
        color = 0xFFD6DC27;
        break;
      case "NOVEDAD RESUELTA":
        color = 0xFF6A1B9A;
        break;
      case "NO ENTREGADO":
        color = 0xFFFF3333;
        break;
      case "REAGENDADO":
        color = 0xFFFA37BF;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;
      case "PEDIDO PROGRAMADO":
        color = 0xFFEF7F0E;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
  }

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: responsive(
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.4,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),
              const SizedBox(width: 20),
              const Text("Registros: "),
              const SizedBox(width: 10),
              Text(total.toString()),
            ],
          ),
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.7,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),
              const SizedBox(width: 5),
              const Text("Registros: "),
              Text(total.toString()),
            ],
          ),
          context),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // loadData();
          paginateData();
        },
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      searchController.clear();
                    });
                    await loadData();
                    // paginateData();
                  },
                  child: const Icon(Icons.close))
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
}
