import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/ui/operator/orders_operator/info_orders_operator.dart';
import 'package:intl/intl.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersOperator extends StatefulWidget {
  const OrdersOperator({super.key});

  @override
  State<OrdersOperator> createState() => _OrdersOperatorState();
}

class _OrdersOperatorState extends State<OrdersOperator> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  bool sort = false;
  List dataTemporal = [];
  String option = "";
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
    "Status"
  ];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    response = await Connections()
        .getOrdersForOperator(_controllers.searchController.text);

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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Row(
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
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            _filters(context),
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
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Código'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.S,
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
                        label: Text('Observación'),
                        size: ColumnSize.M,
                        numeric: true),
                    DataColumn2(
                        label: Text('Comentario'),
                        size: ColumnSize.M,
                        numeric: true),
                    DataColumn2(
                      label: Text(
                        'Status',
                      ),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            DataCell(
                              onTap: () {
                                info(context, index);
                              },
                              Text(data[index]['attributes']
                                      ['Marca_Tiempo_Envio']
                                  .toString()
                                  .split(" ")[0]),
                            ),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                            ['attributes']['Status'])),
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}')),
                            DataCell(Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${data[index]['attributes']['TelefonoShipping'].toString()}&text=Buen Día, servicio de mensajeria le saluda, para informarle que tenemos una entrega para su persona de ${data[index]['attributes']['ProductoP'].toString()} y  ${data[index]['attributes']['ProductoExtra'].toString()}. Por el valor de ${data[index]['attributes']['PrecioTotal'].toString()}...... Realizado su compra en la tienta ${data[index]['attributes']['Tienda_Temporal'].toString()}. Me confirma su recepción el Día de Hoy.""");
                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  },
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      var _url = Uri(
                                          scheme: 'tel',
                                          path:
                                              '${data[index]['attributes']['TelefonoShipping'].toString()}');

                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                            'Could not launch $_url');
                                      }
                                    },
                                    child: Icon(Icons.phone))
                              ],
                            )),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['ProductoP']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['Observacion']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(data[index]['attributes']['Comentario']
                                    .toString())),
                            DataCell(onTap: () {
                              info(context, index);
                            },
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                            ['attributes']['Status'])),
                                    data[index]['attributes']['Status']
                                        .toString())),
                          ]))),
            ),
          ],
        ),
      ),
    );
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

          setState(() {
            data = dataTemporal;
          });
          if (value.isEmpty) {
            setState(() {
              data = dataTemporal;
            });
          } else {
            if (option.isEmpty) {
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
                      objeto['attributes']['Observacion'].toString().toLowerCase().contains(value.toLowerCase()) ||
                      objeto['attributes']['Comentario'].toString().toLowerCase().contains(value.toLowerCase()) ||
                      objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()))
                  .toList();
              setState(() {
                data = dataTemp;
              });
            } else {
              switch (option) {
                case "Fecha":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']
                              ['Marca_Tiempo_Envio']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Código":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['NumeroOrden']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Ciudad":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['CiudadShipping']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Nombre Cliente":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['NombreShipping']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Dirección":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']
                              ['DireccionShipping']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Teléfono Cliente":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']
                              ['TelefonoShipping']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Cantidad":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['Cantidad_Total']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Producto":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['ProductoP']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Producto Extra":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['ProductoExtra']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Precio Total":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['PrecioTotal']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Observación":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['Observacion']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Comentario":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['Comentario']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                case "Status":
                  var dataTemp = data
                      .where((objeto) => objeto['attributes']['Status']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    data = dataTemp;
                  });
                  break;
                default:
              }
            }
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

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
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
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
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
                      child: InfoOrdersOperator(
                    id: data[index]['id'].toString(),
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
}
