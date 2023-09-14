import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/delivery_status/delivery_status_info.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:get/route_manager.dart';

class DeliveryStatus extends StatefulWidget {
  const DeliveryStatus({super.key});

  @override
  State<DeliveryStatus> createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  List<DateTime?> _dates = [];
  bool sort = false;
  List dataTemporal = [];
  String option = "";
  String url = "";

  List bools = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List titlesFilters = [
    "Fecha",
    "Código",
    "Ciudad",
    "Nombre Cliente",
    "Dirección",
    "Teléfono Cliente",
    "Cantidad",
    "Producto",
    "Producto Extra",
    "Precio Total",
    "Observación",
    "Comentario",
    "Status",
    "Fecha Entrega",
    "Est. Devolución",
    "Vendedor",
    "Transportadora",
    "Operador",
    "Estado Pago"
  ];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];

    if (_controllers.searchController.text.isEmpty) {
      response = await Connections().getOrdersForTransportStateLogistic(
          _controllers.searchController.text);
    } else {
      response = await Connections().getOrdersForTransportStateLogisticForCode(
          _controllers.searchController.text, url);
    }

    data = response;
    dataTemporal = response;

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
        child: Column(
          children: [
            _modelTextField(
                text: "Buscar", controller: _controllers.searchController),
            _filters(context),
            Container(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            _controllers.searchController.clear();
                          });
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
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_Tiempo_Envio");
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
                      label: Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
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
                      label: Text('Observación'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Observacion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Comentario'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Comentario");
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
                      label: Text('Vendedor'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Tienda_Temporal");
                      },
                    ),
                    DataColumn2(
                      label: Text('Transportadora'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncTransportadora();
                      },
                    ),
                    DataColumn2(
                      label: Text('Operador'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncOperador();
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Costo Devolución'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncCostoDevo();
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Fecha_Entrega");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Pago'),
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
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                            ['attributes']['Status'])!),
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}'),
                                onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
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
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
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
                                Text(data[index]['attributes']['Observacion']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Comentario']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                            ['attributes']['Status'])!),
                                    data[index]['attributes']['Status']
                                        .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Tienda_Temporal']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['transportadora']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']
                                                ['transportadora']['data']
                                            ['attributes']['Nombre']
                                        .toString()
                                    : ""), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['operadore']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']['operadore']
                                                ['data']['attributes']['user']
                                            ['data']['attributes']['username']
                                        .toString()
                                    : ""), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Devolucion']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['users'] != null
                                    ? data[index]['attributes']['users']['data']
                                                    [0]['attributes']
                                                ['vendedores']['data'][0]
                                            ['attributes']['CostoDevolucion']
                                        .toString()
                                    : ""), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Fecha_Entrega']
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
                      child: DeliveryStatusInfo(
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
  }

  _filters(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        content: Container(
                          width: 500,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.close)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Filtros:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    children: [
                                      Wrap(
                                        children: [
                                          ...List.generate(
                                              titlesFilters.length,
                                              (index) => Container(
                                                    width: 140,
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                            value: bools[index],
                                                            onChanged: (v) {
                                                              if (bools[
                                                                      index] ==
                                                                  true) {
                                                                setState(() {
                                                                  bools[index] =
                                                                      false;
                                                                  option = "";
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  bools[index] =
                                                                      true;
                                                                  option =
                                                                      titlesFilters[
                                                                          index];
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          bools
                                                                              .length;
                                                                      i++) {
                                                                    if (i !=
                                                                        index) {
                                                                      bools[i] =
                                                                          false;
                                                                    }
                                                                  }
                                                                });
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          titlesFilters[index],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  });
              setState(() {});
            },
            icon: Icon(Icons.filter_alt_outlined)),
        Flexible(
            child: Text(
          "Activo: $option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ))
      ],
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
          getLoadingModal(context, false);

          switch (option) {
            case "Fecha":
              setState(() {
                url =
                    "&filters[\$or][1][Marca_Tiempo_Envio][\$contains]=${_controllers.searchController.text}";
              });
              break;
            case "Código":
              setState(() {
                url =
                    "&filters[\$or][1][NumeroOrden][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Ciudad":
              setState(() {
                url =
                    "&filters[\$or][1][CiudadShipping][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Nombre Cliente":
              setState(() {
                url =
                    "&filters[\$or][1][NombreShipping][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Dirección":
              setState(() {
                url =
                    "&filters[\$or][1][DireccionShipping][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Teléfono Cliente":
              setState(() {
                url =
                    "&filters[\$or][1][TelefonoShipping][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Cantidad":
              setState(() {
                url =
                    "&filters[\$or][1][Cantidad_Total][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Producto":
              setState(() {
                url =
                    "&filters[\$or][1][ProductoP][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Producto Extra":
              setState(() {
                url =
                    "&filters[\$or][1][ProductoExtra][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Precio Total":
              setState(() {
                url =
                    "&filters[\$or][1][PrecioTotal][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Observación":
              setState(() {
                url =
                    "&filters[\$or][1][Observacion][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Comentario":
              setState(() {
                url =
                    "&filters[\$or][1][Comentario][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Status":
              setState(() {
                url =
                    "&filters[\$or][1][Status][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Fecha Entrega":
              setState(() {
                url =
                    "&filters[\$or][1][Fecha_Entrega][\$contains]=${_controllers.searchController.text}";
              });

              break;

            case "Devolución":
              setState(() {
                url =
                    "&filters[\$or][1][Estado_Devolucion][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Vendedor":
              setState(() {
                url =
                    "&filters[\$or][1][Tienda_Temporal][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Transportadora":
              setState(() {
                url =
                    "&filters[\$or][1][transportadora][Nombre][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Operador":
              setState(() {
                url =
                    "&filters[\$or][1][operadore][user][username][\$contains]=${_controllers.searchController.text}";
              });

              break;
            case "Estado Pago":
              setState(() {
                url =
                    "&filters[\$or][1][Estado_Pagado][\$contains]=${_controllers.searchController.text}";
              });

              break;
            default:
              setState(() {
                url =
                    "&filters[\$or][0][NumeroOrden][\$contains]=${_controllers.searchController.text}&filters[\$or][1][Marca_Tiempo_Envio][\$contains]=${_controllers.searchController.text}&filters[\$or][2][NumeroOrden][\$contains]=${_controllers.searchController.text}&filters[\$or][3][CiudadShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][4][NombreShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][5][DireccionShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][6][TelefonoShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][7][Cantidad_Total][\$contains]=${_controllers.searchController.text}&filters[\$or][8][ProductoP][\$contains]=${_controllers.searchController.text}&filters[\$or][9][ProductoExtra][\$contains]=${_controllers.searchController.text}&filters[\$or][10][PrecioTotal][\$contains]=${_controllers.searchController.text}&filters[\$or][11][Observacion][\$contains]=${_controllers.searchController.text}&filters[\$or][12][Comentario][\$contains]=${_controllers.searchController.text}&filters[\$or][13][Status][\$contains]=${_controllers.searchController.text}&filters[\$or][14][Fecha_Entrega][\$contains]=${_controllers.searchController.text}&filters[\$or][15][Estado_Devolucion][\$contains]=${_controllers.searchController.text}&filters[\$or][16][Tienda_Temporal][\$contains]=${_controllers.searchController.text}&filters[\$or][17][transportadora][Nombre][\$contains]=${_controllers.searchController.text}&filters[\$or][18][operadore][user][username][\$contains]=${_controllers.searchController.text}&filters[\$or][19][Estado_Pagado][\$contains]=${_controllers.searchController.text}";
              });
              break;
          }

          Navigator.pop(context);

          loadData();
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
                    loadData();
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

  sortFuncCostoDevo() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['users']['data'][0]['attributes']
              ['vendedores']['data'][0]['attributes']['CostoDevolucion']
          .toString()
          .compareTo(a['attributes']['users']['data'][0]['attributes']
                  ['vendedores']['data'][0]['attributes']['CostoDevolucion']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['users']['data'][0]['attributes']
              ['vendedores']['data'][0]['attributes']['CostoDevolucion']
          .toString()
          .compareTo(b['attributes']['users']['data'][0]['attributes']
                  ['vendedores']['data'][0]['attributes']['CostoDevolucion']
              .toString()));
    }
  }

  sortFuncTransportadora() {
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

  sortFuncOperador() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(a['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(b['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    }
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
        color = 0xFFE61414;
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
    }

    // if (state == "ENTREGADO") {
    //   return Color(0xFF33FF6D);
    // } else if (state == "NOVEDAD") {
    //   return Color(0xFF3366FF);
    // } else if (state == "NO ENTREGADO") {
    //   return Color(0xFFE61414);
    // } else if (state == "REAGENDADO") {
    //   return Color(0xFFD6FA37);
    // } else if (state == "EN RUTA") {
    //   return Color(0xFF4733FF);
    // } else if (state == "EN OFICINA") {
    //   return Color(0xFF63615F);
    // } else {
    //   return Color(0xFFFFFFF);
    // }

    return Color(color);
  }
}
