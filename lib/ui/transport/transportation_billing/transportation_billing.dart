/*
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/transport/transportation_billing/info_transportation_billing.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TransportationBilling extends StatefulWidget {
  const TransportationBilling({super.key});

  @override
  State<TransportationBilling> createState() => _TransportationBillingState();
}

class _TransportationBillingState extends State<TransportationBilling> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  List<DateTime?> _dates = [];
  double suma = 0.0;
  double sumaCosto = 0.0;
  String statusPagado = 'PENDIENTE';
  List<String> operator = [];
  String? selectedValueOperator;
  bool sort = false;
  List dataTemporal = [];
  ScrollController _scrolController = ScrollController();
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    print("thissss");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    if (sharedPrefs!.getString("operatorFacturacion") != null) {
      selectedValueOperator = sharedPrefs!.getString("operatorFacturacion");
    }
    var operatorsList = [];
    setState(() {
      operator = [];
    });

    var response = [];
    setState(() {
      suma = 0.0;
      sumaCosto = 0.0;
    });

    if (selectedValueOperator == null) {
      response = await Connections().getOrdersForTransportFiltersState(
          _controllers.searchController.text);
      data = response;
      dataTemporal = response;
    } else {
      response = await Connections().getOrdersForTransportOperatorFiltersState(
          selectedValueOperator.toString().split('-')[1]);
      data = response;
      dataTemporal = response;
    }

    setState(() {});
    for (var i = 0; i < response.length; i++) {
      if (response[i]['attributes']['Status'].toString() == "ENTREGADO") {
        suma += double.parse(response[i]['attributes']['PrecioTotal']
            .toString()
            .replaceAll(",", "."));
      }
    }
    for (var i = 0; i < response.length; i++) {
      if (response[i]['attributes']['Status'].toString() == "ENTREGADO" ||
          response[i]['attributes']['Status'].toString() == "NO ENTREGADO") {
        sumaCosto += double.parse(response[i]['attributes']['operadore']['data']
                ['attributes']['Costo_Operador']
            .toString()
            .replaceAll(",", "."));
      }
    }
    operatorsList = await Connections().getOperatorByTransport();
    for (var i = 0; i < operatorsList.length; i++) {
      setState(() {
        if (operatorsList[i]['attributes']['user']['data'] != null) {
          operator.add(
              '${operatorsList[i]['attributes']['user']['data']['attributes']['username']}-${operatorsList[i]['id']}');
        }
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
      body: Container(
        width: double.infinity,
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            Container(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () async {
                          var results = await showCalendarDatePicker2Dialog(
                            context: context,
                            config: CalendarDatePicker2WithActionButtonsConfig(
                              dayTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              yearTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
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
                              List<String> componentes =
                                  fechaOriginal.split('/');

                              String dia = int.parse(componentes[0]).toString();
                              String mes = int.parse(componentes[1]).toString();
                              String anio = componentes[2];

                              String nuevaFecha = "$dia/$mes/$anio";

                              sharedPrefs!
                                  .setString("dateOperatorState", nuevaFecha);
                            }
                          });
                          loadData();
                        },
                        child: Text(
                          "Seleccionar Fecha",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Fecha: ${sharedPrefs!.getString("dateOperatorState")}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                )),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Operador',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: operator
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
                              GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedValueOperator = null;
                                      sharedPrefs!
                                          .remove("operatorFacturacion");
                                    });
                                    await loadData();
                                  },
                                  child: Icon(Icons.close))
                            ],
                          ),
                        ))
                    .toList(),
                value: selectedValueOperator,
                onChanged: (value) async {
                  setState(() {
                    sharedPrefs!
                        .setString("operatorFacturacion", value.toString());
                    selectedValueOperator = value as String;
                  });
                  await loadData();
                },

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {}
                },
              ),
            ),
            Text(
              " Valores Recibidos: \$${suma.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Costo Entrega: \$${sumaCosto}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Total: \$${(suma - sumaCosto).toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Estado Pago Operador: ${data.isNotEmpty ? data[0]['attributes']['Estado_Pagado'].toString() : ''}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            data.isNotEmpty
                ? data[0]['attributes']['Estado_Pagado'].toString() ==
                        "PENDIENTE"
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "$generalServer${data.isNotEmpty ? data[0]['attributes']['Url_Pagado_Foto'].toString() : ''}"));
                              },
                              child: Text(
                                "VER COMPROBANTE",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                        ],
                      )
                : Container(),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 800,
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
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Fecha_Entrega");
                      },
                    ),
                    DataColumn2(
                      label: Text('Código'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NumeroOrden");
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
                      label: Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("CiudadShipping");
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
                      label: Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Cantidad'),
                      size: ColumnSize.M,
                      numeric: true,
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
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
                      },
                    ),
                    DataColumn2(
                      label: Text('Status'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: Text('Comentario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Comentario");
                      },
                    ),
                    DataColumn2(
                      label: Text('Tipo de Pago'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TipoPago");
                      },
                    ),
                    DataColumn2(
                        label: Text('Operador'),
                        size: ColumnSize.M,
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          if (sort) {
                            setState(() {
                              sort = false;
                            });
                            data.sort((a, b) => b['attributes']['operadore']
                                        ['data']['attributes']['user']['data']
                                    ['attributes']['username']
                                .toString()
                                .compareTo(a['attributes']['operadore']['data']
                                            ['attributes']['user']['data']
                                        ['attributes']['username']
                                    .toString()));
                          } else {
                            setState(() {
                              sort = true;
                            });
                            data.sort((a, b) => a['attributes']['operadore']
                                        ['data']['attributes']['user']['data']
                                    ['attributes']['username']
                                .toString()
                                .compareTo(b['attributes']['operadore']['data']
                                            ['attributes']['user']['data']
                                        ['attributes']['username']
                                    .toString()));
                          }
                        }),
                    DataColumn2(
                      label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado de Pago'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Pagado");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Marca_Tiempo_Envio']
                                    .toString()
                                    .split(" ")[0]), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Fecha_Entrega']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                                ['attributes']['Status']
                                            .toString())!),
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}'),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoP']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                                ['attributes']['Status']
                                            .toString())!),
                                    data[index]['attributes']['Status']
                                        .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Comentario']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['TipoPago']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['operadore']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']['operadore']
                                            ['data']['attributes']['user']
                                        ['data']['attributes']['username']
                                    : "".toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Devolucion']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Pagado']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return 1;
        } else if (dateB == null) {
          return -1;
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return -1;
        } else if (dateB == null) {
          return 1;
        } else {
          return dateA.compareTo(dateB);
        }
      });
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
                      child: InfoTransportationBilling(
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
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
                    objeto['attributes']['Marca_Tiempo_Envio']
                        .toString()
                        .split(" ")[0]
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['attributes']['NumeroOrden']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
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
                    objeto['attributes']['TelefonoShipping']
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
                    (objeto['attributes']['operadore']['data'] != null ? objeto['attributes']['operadore']['data']['attributes']['user']['data']['attributes']['username'] : "").toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['Estado_Devolucion'].toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['Fecha_Entrega'].toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['TipoPago'].toString().toLowerCase().contains(value.toLowerCase()) ||
                    objeto['attributes']['Estado_Pagado'].toString().toLowerCase().contains(value.toLowerCase()))
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
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
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

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF33FF6D;
        break;
      case "NOVEDAD":
        color = 0xFFD6DC27;
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

      default:
        color = 0xFF000000;
    }

    return Color(color);
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
}
*/
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

  void resetFilters() {
    // getOldValue(true);

    operadorController.text = 'TODO';
    statusController.text = "TODO";
    selectedOperator = null;

    arrayFiltersAnd = [];
    // _controllers.searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                // color: Colors.grey[300],
                color: Colors.white,
                child: Center(
                  child: Container(
                    // margin: const EdgeInsets.all(6.0),
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
                        responsive(
                            webMainContainer(width, heigth, context),
                            mobileMainContainer(width, heigth, context),
                            context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      height: height * 0.58,
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
            height: height * 0.58,
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
      const DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Nombre Cliente'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Teléfono Cliente'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Producto'),
        size: ColumnSize.L,
      ),
      const DataColumn2(
        label: Text('Producto Extra'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Precio Total'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: SelectFilterStatus(
            'Estado de entrega', 'status', statusController, listStatus),
        size: ColumnSize.L,
      ),
      const DataColumn2(
        label: Text('Comentario'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Tipo pago'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: SelectFilter('Operador', 'operadore.up_users.operadore_id',
            operadorController, listOperators),
        size: ColumnSize.L,
        // onSort: (columnIndex, ascending) {},
      ),
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
          DataCell(
            Text(data[index]['ciudad_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
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
            width: MediaQuery.of(context).size.width * 0.6,
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
