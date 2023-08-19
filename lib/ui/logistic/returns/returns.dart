import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/scanner_printed_devoluciones.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';

import '../../widgets/sellers/add_order.dart';
import 'controllers/controllers.dart';

class Returns extends StatefulWidget {
  const Returns({super.key});

  @override
  State<Returns> createState() => _ReturnsState();
}

class _ReturnsState extends State<Returns> {
  ReturnsControllers _controllers = ReturnsControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  List dataTemporal = [];
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  int total = 0;
  String pedido = '';
  bool enabledBusqueda = true;
  bool isLoading = false;
  NumberPaginatorController paginatorController = NumberPaginatorController();
  List filtersDefaultOr = [
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NOVEDAD'
    },
    {
      'operator': '\$or',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'NO ENTREGADO'
    },
  ];

  List filtersDefaultAnd = [
    {
      'operator': '\$and',
      'filter': 'Estado_Devolucion',
      'operator_attr': '\$ne',
      'value': 'EN BODEGA'
    },
  ];
  List populate = [
    'users',
    'pedido_fecha',
    'ruta',
    'transportadora',
    'users.vendedores',
    'operadore',
    'operadore.user'
  ];
  List filtersAnd = [];

  List filtersOrCont = [
    {'filter': 'Marca_T_I'},
    {'filter': 'CiudadShipping'},
    {'filter': 'NombreShipping'},
    {'filter': 'DireccionShipping'},
    {'filter': 'TelefonoShipping'},
    {'filter': 'NumeroOrden'},
    {'filter': 'Cantidad_Total'},
    {'filter': 'ProductoP'},
    {'filter': 'ProductoExtra'},
    {'filter': 'PrecioTotal'},
    {'filter': 'Observacion'},
    {'filter': 'Status'},
    {'filter': 'Estado_Interno'},
    {'filter': 'Estado_Logistico'},
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
    isLoading = true;
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      data.clear();
    });

    response = await Connections().getOrdersSellersFilter(
        _controllers.searchController.text,
        currentPage,
        pageSize,
        populate,
        filtersOrCont,
        filtersAnd,
        filtersDefaultOr,
        filtersDefaultAnd, []);

    data = response[0]['data'];
    setState(() {
      pageCount = response[0]['meta']['pagination']['pageCount'];
      total = response[0]['meta']['pagination']['total'];

      // print("metadatar"+pageCount.toString());
    });
    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "NumeroOrden": ""});
    }
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    paginatorController.navigateToPage(0);
    counterChecks = 0;
    setState(() {});
    isLoading = false;
  }

  paginateData() async {
    // print("Pagina Actual="+currentPage.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      data.clear();
    });

    // print("actual pagina valor" + currentPage.toString());

    response = await Connections().getOrdersSellersFilter(
        _controllers.searchController.text,
        currentPage,
        pageSize,
        populate,
        filtersOrCont,
        filtersAnd,
        [],
        filtersDefaultAnd,
        []);
    data = response[0]['data'];
    setState(() {
      pageCount = response[0]['meta']['pagination']['pageCount'];
      total = response[0]['meta']['pagination']['total'];
    });

    await Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        color: Colors.grey[100],
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    optionsCheckBox = [];
                    counterChecks = 0;
                    enabledBusqueda = true;
                  });
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
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 5),
              child: responsive(
                  Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Busqueda",
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
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Row(
                                children: [
                                  Text(
                                    counterChecks > 0
                                        ? "Seleccionados: ${counterChecks}"
                                        : "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  counterChecks > 0
                                      ? Visibility(
                                          visible: true,
                                          child: IconButton(
                                            iconSize: 20,
                                            onPressed: () => {clearSelected()},
                                            icon: Icon(Icons.close_rounded),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50.0,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ScannerPrintedDevoluciones();
                                        });
                                    await loadData();
                                  },
                                  child: Text(
                                    "SCANNER",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: NumberPaginator(
                        config: NumberPaginatorUIConfig(
                          buttonShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Customize the button shape
                          ),
                        ),
                        controller: paginatorController,
                        numberPages: pageCount > 0 ? pageCount : 1,
                        initialPage: 0,
                        onPageChange: (index) async {
                          //  print("indice="+index.toString());

                          setState(() {
                            currentPage = index + 1;
                          });
                          if (!isLoading) {
                            await paginateData();
                          }
                        },
                      )),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        child: _modelTextField(
                            text: "Busqueda",
                            controller: _controllers.searchController),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              "Registros: ${total}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              counterChecks > 0
                                  ? "Seleccionados: ${counterChecks}"
                                  : "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ScannerPrintedDevoluciones();
                                  });
                              await loadData();
                            },
                            child: Text(
                              "SCANNER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      Container(
                          child: NumberPaginator(
                        config: NumberPaginatorUIConfig(
                          buttonShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Customize the button shape
                          ),
                        ),
                        numberPages: pageCount > 0 ? pageCount : 1,
                        onPageChange: (index) async {
                          //  print("indice="+index.toString());
                          setState(() {
                            currentPage = index + 1;
                          });

                          await paginateData();
                        },
                      )),
                    ],
                  ),
                  context),
            ),
            const SizedBox(
              width: 10,
            ),
            const Row(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  headingRowHeight: 80,
                  horizontalMargin: 12,
                  minWidth: 3500,
                  columns: [
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Código'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca de Tiempo'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Detalle'),
                      size: ColumnSize.L,
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
                      label: Text('Precio Total'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoP");
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
                      label: Text('Status'),
                      size: ColumnSize.S,
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
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Fecha_Entrega");
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
                      label: Text('Teléfono'),
                      numeric: true,
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Devolución'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca. O'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca TR'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D_T");
                      },
                    ),
                    DataColumn2(
                      label: Text('Marca TL'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D_L");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(data.length, (index) {
                    Color rowColor = Colors.black;

                    return DataRow(cells: [
                      DataCell(ElevatedButton(
                          onPressed: data[index]['attributes']
                                          ['Estado_Devolucion']
                                      .toString() ==
                                  "EN BODEGA"
                              ? null
                              : () {
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.rightSlide,
                                    title:
                                        '¿Estás seguro de marcar el pedido en BODEGA?',
                                    desc: '',
                                    btnOkText: "Confirmar",
                                    btnCancelText: "Cancelar",
                                    btnOkColor: Colors.blueAccent,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () async {
                                      getLoadingModal(context, false);
                                      await Connections()
                                          .updateOrderReturnLogistic(
                                              data[index]['id']);
                                      await loadData();
                                      Navigator.pop(context);
                                    },
                                  ).show();
                                },
                          child: Text(
                            "Devolver",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10),
                          ))),
                      DataCell(
                          Text(
                            "${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}",
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_Tiempo_Envio']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_Tiempo_Envio']
                                .toString()
                                .split(" ")[0]
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['DireccionShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Cantidad_Total']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            '\$${data[index]['attributes']['PrecioTotal'].toString()}',
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            '${data[index]['attributes']['ProductoP'].toString()}',
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                              '${data[index]['attributes']['CiudadShipping'].toString()}'),
                          onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Status'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Comentario'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Fecha_Entrega']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['NombreShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['TelefonoShipping']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Estado_Devolucion']
                                .toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D_T'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                      DataCell(
                          Text(
                            data[index]['attributes']['Marca_T_D_L'].toString(),
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ), onTap: () {
                        getInfoModal(index);
                      }),
                    ]);
                  })),
            ),
          ],
        ),
      ),
    );
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
                      "Código: ${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}"),
                  _model(
                      "Marca de Tiempo: ${data[index]['attributes']['Marca_Tiempo_Envio']}"),
                  _model(
                      "Fecha: ${data[index]['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0].toString()}"),
                  _model(
                      "Detalle: ${data[index]['attributes']['DireccionShipping']}"),
                  _model(
                      "Cantidad: ${data[index]['attributes']['Cantidad_Total']}"),
                  _model(
                      "Precio Total: ${data[index]['attributes']['PrecioTotal']}"),
                  _model("Producto: ${data[index]['attributes']['ProductoP']}"),
                  _model(
                      "Producto Extra: ${data[index]['attributes']['ProductoExtra']}"),
                  _model(
                      "Ciudad: ${data[index]['attributes']['CiudadShipping']}"),
                  _model("Status: ${data[index]['attributes']['Status']}"),
                  _model(
                      "Comentario: ${data[index]['attributes']['Comentario']}"),
                  _model(
                      "Fecha de Entrega: ${data[index]['attributes']['Fecha_Entrega']}"),
                  _model(
                      "Nombre Cliente: ${data[index]['attributes']['NombreShipping']}"),
                  _model(
                      "Teléfono: ${data[index]['attributes']['TelefonoShipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['attributes']['Estado_Devolucion']}"),
                  _model("Marca. O: ${data[index]['attributes']['Marca_T_D']}"),
                  _model(
                      "Marca. TR: ${data[index]['attributes']['Marca_T_D_T']}"),
                  _model(
                      "Marca. TL: ${data[index]['attributes']['Marca_T_D_L']}")
                ],
              ),
            ),
          );
        });
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
                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    var response = await Connections().updateOrderInteralStatus(
                        "NO DESEA", optionsCheckBox[i]['id'].toString());
                  }
                }
                setState(() {});
                loadData();
              },
              child: Text(
                "No Desea",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                for (var i = 0; i < optionsCheckBox.length; i++) {
                  if (optionsCheckBox[i]['id'].toString().isNotEmpty &&
                      optionsCheckBox[i]['id'].toString() != '' &&
                      optionsCheckBox[i]['check'] == true) {
                    var response = await Connections().updateOrderInteralStatus(
                        "CONFIRMADO", optionsCheckBox[i]['id'].toString());
                  }
                }
                await showDialog(
                    context: context,
                    builder: (context) {
                      return RoutesModal(
                          idOrder: optionsCheckBox,
                          someOrders: true,
                          phoneClient: "",
                          codigo: "");
                    });

                setState(() {});
                loadData();
              },
              child: Text(
                "Confirmar",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
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
        enabled: enabledBusqueda,
        controller: controller,
        onSubmitted: (value) async {
          setState(() {
            _controllers.searchController.text = value;
            pedido = "";
          });
          loadData();
          getLoadingModal(context, false);

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                      filtersAnd = [];
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

  clearSelected() {
    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "NumeroOrden": ""});
    }
    setState(() {
      counterChecks = 0;
      enabledBusqueda = true;
    });
  }

  String listToDelete() {
    String res = "";

    for (var i = 0; i < optionsCheckBox.length; i++) {
      if (optionsCheckBox[i]['check'] == true) {
        res += sharedPrefs!.getString("NameComercialSeller").toString() +
            "-" +
            optionsCheckBox[i]['NumeroOrden'] +
            '\n';
      }
    }
    return res;
  }

  bool verificarIndice(int index) {
    try {
      dynamic elemento =
          optionsCheckBox.elementAt(index + ((currentPage - 1) * pageSize));
      // print("elemento="+elemento.toString());
      if (elemento['id'] != data[index]['id']) {
        return false;
      } else {
        return true;
      }
    } catch (error) {
      return false;
    }
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
}

// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:frontend/config/exports.dart';
// import 'package:frontend/connections/connections.dart';
// import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
// import 'package:frontend/ui/utils/utils.dart';
// import 'package:frontend/ui/widgets/loading.dart';
// import 'package:frontend/helpers/navigators.dart';
// import 'package:frontend/ui/widgets/logistic/scanner_printed_devoluciones.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

// import 'controllers/controllers.dart';

// class Returns extends StatefulWidget {
//   const Returns({super.key});

//   @override
//   State<Returns> createState() => _ReturnsState();
// }

// class _ReturnsState extends State<Returns> {
//   final ReturnsControllers _controllers = ReturnsControllers();
//   List data = [];
//   List dataTemporal = [];
//   String option = "";
//   bool sort = false;

//   List bools = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ];
//   List titlesFilters = [
//     "Fecha",
//     "Código",
//     "Ciudad",
//     "Nombre Cliente",
//     "Dirección",
//     "Teléfono Cliente",
//     "Cantidad",
//     "Producto",
//     "Producto Extra",
//     "Precio Total",
//     "Observación",
//     "Comentario",
//     "Status",
//     "Fecha Entrega",
//     "Est. Devolución"
//   ];
//   loadData() async {
//     var response = [];
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getLoadingModal(context, false);
//     });

//     response = await Connections()
//         .getOrdersForReturnsLogistic(_controllers.searchController.text);
//     data = response;
//     dataTemporal = response;

//     Future.delayed(const Duration(milliseconds: 500), () {
//       Navigator.pop(context);
//     });
//     setState(() {});
//   }

//   @override
//   void didChangeDependencies() {
//     loadData();
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox(
//         width: double.infinity,
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               child: _modelTextField(
//                   text: "Busqueda", controller: _controllers.searchController),
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton(
//                   onPressed: () async {
//                     await showDialog(
//                         context: context,
//                         builder: (context) {
//                           return ScannerPrintedDevoluciones();
//                         });
//                     await loadData();
//                   },
//                   child: Text(
//                     "SCANNER",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   )),
//             ),
//             _filters(context),
//             Expanded(
//               child: DataTable2(
//                 headingTextStyle: const TextStyle(
//                     fontWeight: FontWeight.bold, color: Colors.black),
//                 dataTextStyle: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//                 columnSpacing: 12,
//                 horizontalMargin: 6,
//                 minWidth: 2000,
//                 showCheckboxColumn: false,
//                 columns: [
//                   DataColumn2(
//                     label: Text(''),
//                     size: ColumnSize.M,
//                   ),
//                   DataColumn2(
//                     label: Text('Código'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("NumeroOrden");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Marca de Tiempo'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Marca_Tiempo_Envio");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Fecha'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Marca_Tiempo_Envio");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Detalle'),
//                     size: ColumnSize.L,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("DireccionShipping");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Cantidad'),
//                     size: ColumnSize.M,
//                     numeric: true,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Cantidad_Total");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Precio Total'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("PrecioTotal");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Producto'),
//                     size: ColumnSize.L,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("ProductoP");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Ciudad'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("CiudadShipping");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Status'),
//                     size: ColumnSize.S,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Status");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Comentario'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Comentario");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Fecha de Entrega'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Fecha_Entrega");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Nombre Cliente'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("NombreShipping");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Teléfono'),
//                     numeric: true,
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("TelefonoShipping");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Estado Devolución'),
//                     size: ColumnSize.M,
//                     numeric: true,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Estado_Devolucion");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Marca. O'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Marca_T_D");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Marca TR'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Marca_T_D_T");
//                     },
//                   ),
//                   DataColumn2(
//                     label: Text('Marca TL'),
//                     size: ColumnSize.M,
//                     onSort: (columnIndex, ascending) {
//                       sortFunc("Marca_T_D_L");
//                     },
//                   ),
//                 ],
//                 rows: List<DataRow>.generate(
//                   data.length,
//                   (index) {
//                     Color rowColor = Colors.black;
//                     return DataRow(
//                       onSelectChanged: (bool? selected) {},
//                       cells: [
//                         DataCell(ElevatedButton(
//                             onPressed: data[index]['attributes']
//                                             ['Estado_Devolucion']
//                                         .toString() ==
//                                     "EN BODEGA"
//                                 ? null
//                                 : () {
//                                     AwesomeDialog(
//                                       width: 500,
//                                       context: context,
//                                       dialogType: DialogType.info,
//                                       animType: AnimType.rightSlide,
//                                       title:
//                                           '¿Estás seguro de marcar el pedido en BODEGA?',
//                                       desc: '',
//                                       btnOkText: "Confirmar",
//                                       btnCancelText: "Cancelar",
//                                       btnOkColor: Colors.blueAccent,
//                                       btnCancelOnPress: () {},
//                                       btnOkOnPress: () async {
//                                         getLoadingModal(context, false);
//                                         await Connections()
//                                             .updateOrderReturnLogistic(
//                                                 data[index]['id']);
//                                         await loadData();
//                                         Navigator.pop(context);
//                                       },
//                                     ).show();
//                                   },
//                             child: Text(
//                               "Devolver",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 10),
//                             ))),
//                         DataCell(
//                             Text(
//                               "${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}",
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Marca_Tiempo_Envio']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Marca_Tiempo_Envio']
//                                   .toString()
//                                   .split(" ")[0]
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['DireccionShipping']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Cantidad_Total']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               '\$${data[index]['attributes']['PrecioTotal'].toString()}',
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               '${data[index]['attributes']['ProductoP'].toString()}',
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                                 '${data[index]['attributes']['CiudadShipping'].toString()}'),
//                             onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Status'].toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Comentario']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Fecha_Entrega']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['NombreShipping']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['TelefonoShipping']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Estado_Devolucion']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Marca_T_D'].toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Marca_T_D_T']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                         DataCell(
//                             Text(
//                               data[index]['attributes']['Marca_T_D_L']
//                                   .toString(),
//                               style: TextStyle(
//                                 color: rowColor,
//                               ),
//                             ), onTap: () {
//                           getInfoModal(index);
//                         }),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _filters(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//             onPressed: () async {
//               await showDialog(
//                   context: context,
//                   builder: (context) {
//                     return StatefulBuilder(builder: (context, setState) {
//                       return AlertDialog(
//                         content: Container(
//                           width: 500,
//                           height: MediaQuery.of(context).size.height,
//                           child: Column(
//                             children: [
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: Icon(Icons.close)),
//                               ),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Text(
//                                 "Filtros:",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Expanded(
//                                 child: Center(
//                                   child: ListView(
//                                     children: [
//                                       Wrap(
//                                         children: [
//                                           ...List.generate(
//                                               titlesFilters.length,
//                                               (index) => Container(
//                                                     width: 140,
//                                                     child: Row(
//                                                       children: [
//                                                         Checkbox(
//                                                             value: bools[index],
//                                                             onChanged: (v) {
//                                                               if (bools[
//                                                                       index] ==
//                                                                   true) {
//                                                                 setState(() {
//                                                                   bools[index] =
//                                                                       false;
//                                                                   option = "";
//                                                                 });
//                                                               } else {
//                                                                 setState(() {
//                                                                   bools[index] =
//                                                                       true;
//                                                                   option =
//                                                                       titlesFilters[
//                                                                           index];
//                                                                   for (int i =
//                                                                           0;
//                                                                       i <
//                                                                           bools
//                                                                               .length;
//                                                                       i++) {
//                                                                     if (i !=
//                                                                         index) {
//                                                                       bools[i] =
//                                                                           false;
//                                                                     }
//                                                                   }
//                                                                 });
//                                                               }
//                                                               Navigator.pop(
//                                                                   context);
//                                                             }),
//                                                         SizedBox(
//                                                           width: 5,
//                                                         ),
//                                                         Text(
//                                                           titlesFilters[index],
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontSize: 12),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ))
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     });
//                   });
//               setState(() {});
//             },
//             icon: Icon(Icons.filter_alt_outlined)),
//         Flexible(
//             child: Text(
//           "Activo: $option",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
//         ))
//       ],
//     );
//   }

//   _modelTextField({text, controller}) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Color.fromARGB(255, 245, 244, 244),
//       ),
//       child: TextField(
//         controller: controller,
//         onSubmitted: (value) {
//           getLoadingModal(context, false);

//           setState(() {
//             data = dataTemporal;
//           });
//           if (value.isEmpty) {
//             setState(() {
//               data = dataTemporal;
//             });
//           } else {
//             if (option.isEmpty) {
//               var dataTemp = data
//                   .where((objeto) =>
//                       objeto['attributes']['Marca_Tiempo_Envio']
//                           .toString()
//                           .split(" ")[0]
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['NumeroOrden']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['CiudadShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['NombreShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['DireccionShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['TelefonoShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['Cantidad_Total']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['ProductoP']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['ProductoExtra']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['PrecioTotal']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()) ||
//                       objeto['attributes']['Observacion'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Comentario'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Fecha_Entrega'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Estado_Devolucion'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Marca_T_D_T'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Marca_T_D_L'].toString().toLowerCase().contains(value.toLowerCase()) ||
//                       objeto['attributes']['Marca_T_D'].toString().toLowerCase().contains(value.toLowerCase()))
//                   .toList();
//               setState(() {
//                 data = dataTemp;
//               });
//             } else {
//               switch (option) {
//                 case "Fecha":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']
//                               ['Marca_Tiempo_Envio']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Código":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['NumeroOrden']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Ciudad":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['CiudadShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Nombre Cliente":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['NombreShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Dirección":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']
//                               ['DireccionShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Teléfono Cliente":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']
//                               ['TelefonoShipping']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Cantidad":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['Cantidad_Total']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Producto":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['ProductoP']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Producto Extra":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['ProductoExtra']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Precio Total":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['PrecioTotal']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Observación":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['Observacion']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Comentario":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['Comentario']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Status":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['Status']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 case "Fecha Entrega":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']['Fecha_Entrega']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;

//                 case "Estado Devolución":
//                   var dataTemp = data
//                       .where((objeto) => objeto['attributes']
//                               ['Estado_Devolucion']
//                           .toString()
//                           .toLowerCase()
//                           .contains(value.toLowerCase()))
//                       .toList();
//                   setState(() {
//                     data = dataTemp;
//                   });
//                   break;
//                 default:
//               }
//             }
//           }
//           Navigator.pop(context);

//           // loadData();
//         },
//         onChanged: (value) {},
//         style: TextStyle(fontWeight: FontWeight.bold),
//         decoration: InputDecoration(
//           prefixIcon: Icon(Icons.search),
//           suffixIcon: _controllers.searchController.text.isNotEmpty
//               ? GestureDetector(
//                   onTap: () {
//                     getLoadingModal(context, false);
//                     setState(() {
//                       _controllers.searchController.clear();
//                     });
//                     setState(() {
//                       data = dataTemporal;
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: Icon(Icons.close))
//               : null,
//           hintText: text,
//           enabledBorder: OutlineInputBorder(
//             borderSide:
//                 BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide:
//                 BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           focusColor: Colors.black,
//           iconColor: Colors.black,
//         ),
//       ),
//     );
//   }

//   getInfoModal(index) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             content: Container(
//               width: 500,
//               height: MediaQuery.of(context).size.height,
//               child: ListView(
//                 children: [
//                   Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Icon(Icons.close)),
//                       )
//                     ],
//                   ),
//                   _model(
//                       "Código: ${data[index]['attributes']['Name_Comercial']}-${data[index]['attributes']['NumeroOrden']}"),
//                   _model(
//                       "Marca de Tiempo: ${data[index]['attributes']['Marca_Tiempo_Envio']}"),
//                   _model(
//                       "Fecha: ${data[index]['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0].toString()}"),
//                   _model(
//                       "Detalle: ${data[index]['attributes']['DireccionShipping']}"),
//                   _model(
//                       "Cantidad: ${data[index]['attributes']['Cantidad_Total']}"),
//                   _model(
//                       "Precio Total: ${data[index]['attributes']['PrecioTotal']}"),
//                   _model("Producto: ${data[index]['attributes']['ProductoP']}"),
//                   _model(
//                       "Producto Extra: ${data[index]['attributes']['ProductoExtra']}"),
//                   _model(
//                       "Ciudad: ${data[index]['attributes']['CiudadShipping']}"),
//                   _model("Status: ${data[index]['attributes']['Status']}"),
//                   _model(
//                       "Comentario: ${data[index]['attributes']['Comentario']}"),
//                   _model(
//                       "Fecha de Entrega: ${data[index]['attributes']['Fecha_Entrega']}"),
//                   _model(
//                       "Nombre Cliente: ${data[index]['attributes']['NombreShipping']}"),
//                   _model(
//                       "Teléfono: ${data[index]['attributes']['TelefonoShipping']}"),
//                   _model(
//                       "Estado Devolución: ${data[index]['attributes']['Estado_Devolucion']}"),
//                   _model("Marca. O: ${data[index]['attributes']['Marca_T_D']}"),
//                   _model(
//                       "Marca. TR: ${data[index]['attributes']['Marca_T_D_T']}"),
//                   _model(
//                       "Marca. TL: ${data[index]['attributes']['Marca_T_D_L']}")
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   Padding _model(text) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Text(
//         text,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   sortFunc(name) {
//     if (sort) {
//       setState(() {
//         sort = false;
//       });
//       data.sort((a, b) => b['attributes'][name]
//           .toString()
//           .compareTo(a['attributes'][name].toString()));
//     } else {
//       setState(() {
//         sort = true;
//       });
//       data.sort((a, b) => a['attributes'][name]
//           .toString()
//           .compareTo(b['attributes'][name].toString()));
//     }
//   }
// }
