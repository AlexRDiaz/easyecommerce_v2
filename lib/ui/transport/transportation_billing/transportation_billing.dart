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
