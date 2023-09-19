import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';

import '../../widgets/sellers/add_order.dart';
import 'controllers/controllers.dart';

class UnwantedOrdersSellers extends StatefulWidget {
  const UnwantedOrdersSellers({super.key});

  @override
  State<UnwantedOrdersSellers> createState() => _UnwantedOrdersSellersState();
}

class _UnwantedOrdersSellersState extends State<UnwantedOrdersSellers> {
  UnwantedOrdersSellersControllers _controllers =
      UnwantedOrdersSellersControllers();

  List arrayFiltersDefaultOr = [
    // {"status": "NOVEDAD"},
    // {"status": "NO ENTREGADO"}
  ];

  var arrayfiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString(),
    },
    {'estado_interno': 'NO DESEA'}
  ];
  List arrayFiltersNotEq = [];
  var sortFieldDefaultValue = "id:DESC";
  bool isFirst = false;
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
  bool changevalue = false;

  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");

  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'ENTREGADO EN OFICINA',
    'DEVOLUCION EN RUTA',
    'EN BODEGA',
  ];
  NumberPaginatorController paginatorController = NumberPaginatorController();
  // List filtersDefaultAnd = [
  //   {
  //     'operator': '\$and',
  //     'filter': 'IdComercial',
  //     'operator_attr': '\$eq',
  //     'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
  //   },
  //   {
  //     'operator': '\$and',
  //     'filter': 'Estado_Interno',
  //     'operator_attr': '\$eq',
  //     'value': 'NO DESEA'
  // ];
  List populate = ['users', 'pedido_fecha'];
  List arrayFiltersAnd = [];

  List filtersOrCont = [
    'fecha_entrega',
    'numero_orden',
    'ciudad_shipping',
    'nombre_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    'status',
    "estado_devolucion",
    "fecha_confirmacion",
    'comentario',
  ];

  //
  //
  //                 objeto['attributes']['ProductoExtra'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                 objeto['attributes']['PrecioTotal'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                 objeto['attributes']['Observacion'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                 objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                 objeto['attributes']['Estado_Interno'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                 objeto['attributes']['Estado_Logistico'].toString().toLowerCase().contains(value.toLowerCase()))

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      data.clear();
    });
    var response = await Connections().getOrdersSellersFilterLaravel(
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        _controllers.searchController.text,
        arrayFiltersNotEq,
        sortFieldDefaultValue.toString());

    data = response['data'];
    setState(() {
      // print("metadatar"+pageCount.toString());
    });
    optionsCheckBox = [];

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    paginatorController.navigateToPage(0);
    counterChecks = 0;
    setState(() {});
    isLoading = false;
  }

  paginateData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var response = [];
      setState(() {
        isLoading = true;
        data.clear();
      });

      // response = await Connections().getOrdersSellersFilter(
      //     _controllers.searchController.text,
      //     currentPage,
      //     pageSize,
      //     populate,
      //     filtersOrCont,
      //     filtersAnd,
      //     filtersDefaultOr,
      //     filtersDefaultAnd, []);

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
          filtersOrCont,
          arrayFiltersDefaultOr,
          arrayfiltersDefaultAnd,
          arrayFiltersAnd,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          arrayFiltersNotEq,
          sortFieldDefaultValue.toString());

      // data = response[0]['data'];
      data = responseLaravel['data'];

      setState(() {
        // pageCount = response[0]['meta']['pagination']['pageCount'];
        // total = response[0]['meta']['pagination']['total'];

        pageCount = responseLaravel['last_page'];
        total = responseLaravel['total'];
      });

      await Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      print("datos paginados");
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
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
                                            onPressed: () => {},
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
                            ElevatedButton(
                                onPressed: counterChecks > 0
                                    ? () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Ateneción'),
                                              content: Column(
                                                children: [
                                                  const Text(
                                                      '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                  Text(''),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () {
                                                    // Acción al presionar el botón de cancelar
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Aceptar'),
                                                  onPressed: () async {
                                                    for (var i = 0;
                                                        i <
                                                            optionsCheckBox
                                                                .length;
                                                        i++) {
                                                      if (optionsCheckBox[i]
                                                                  ['id']
                                                              .toString()
                                                              .isNotEmpty &&
                                                          optionsCheckBox[i]
                                                                      ['id']
                                                                  .toString() !=
                                                              '' &&
                                                          optionsCheckBox[i]
                                                                  ['check'] ==
                                                              true) {
                                                        var response = await Connections()
                                                            .updateOrderInteralStatus(
                                                                "NO DESEA",
                                                                optionsCheckBox[
                                                                        i]['id']
                                                                    .toString());
                                                        counterChecks = 0;
                                                      }
                                                    }

                                                    loadData();
                                                    setState(() {});
                                                    enabledBusqueda = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: const Text(
                                  "No Desea",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
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
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50.0,
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed: counterChecks > 0
                                    ? () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Atenecion'),
                                              content: Column(
                                                children: [
                                                  const Text(
                                                      '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                  Text('lista a eliminar'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () {
                                                    // Acción al presionar el botón de cancelar
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Aceptar'),
                                                  onPressed: () async {
                                                    for (var i = 0;
                                                        i <
                                                            optionsCheckBox
                                                                .length;
                                                        i++) {
                                                      if (optionsCheckBox[i]
                                                                  ['id']
                                                              .toString()
                                                              .isNotEmpty &&
                                                          optionsCheckBox[i]
                                                                      ['id']
                                                                  .toString() !=
                                                              '' &&
                                                          optionsCheckBox[i]
                                                                  ['check'] ==
                                                              true) {
                                                        var response = await Connections()
                                                            .updateOrderInteralStatus(
                                                                "NO DESEA",
                                                                optionsCheckBox[
                                                                        i]['id']
                                                                    .toString());
                                                        counterChecks = 0;
                                                      }
                                                    }
                                                    setState(() {});
                                                    loadData();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: const Text(
                                  "No Desea",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: (context),
                                      builder: (context) {
                                        return AddOrderSellers();
                                      });
                                  await loadData();
                                },
                                child: const Text(
                                  "Nuevo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                      ),
                      Container(child: numberPaginator()),
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
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                headingRowHeight: 63,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("fecha_entrega", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Código'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("numero_orden", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Ciudad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("ciudad_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Nombre Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("nombre_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Dirección'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("direccion_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Teléfono'),
                    numeric: true,
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("telefono_shipping", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("cantidad_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("producto_p", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto Extra'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("producto_extra", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Precio Total'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("precio_total", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Status'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("status", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: SelectFilter(
                        'Estado Devolución',
                        'estado_devolucion',
                        estadoDevolucionController,
                        listEstadoDevolucion),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("estado_devolucion", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Comentario'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("comentario", changevalue);
                    },
                  ),
                  DataColumn2(
                    label: Text('Marca Fecha Confirmación'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc2("fecha_confirmacion", changevalue);
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.black;
                    return DataRow(
                      onSelectChanged: (bool? selected) {
                        showDialog(
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
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      cells: [
                        DataCell(
                            Text(
                              data[index]['fecha_entrega'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                                style: TextStyle(
                                    color: GetColor(data[index]
                                            ['estado_devolucion']
                                        .toString())!),
                                '${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}'),
                            onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              '${data[index]['ciudad_shipping'].toString()}',
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['nombre_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['direccion_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['telefono_shipping'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['cantidad_total'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['producto_p'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['producto_extra'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['precio_total'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['status'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                        DataCell(
                            Text(
                              data[index]['estado_devolucion'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
                            onTap: () {}),
                        DataCell(
                            Text(
                              data[index]['comentario'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
                            onTap: () {}),
                        DataCell(
                            Text(
                              data[index]['fecha_confirmacion'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ), onTap: () {
                          showDialogInfoData(data[index]);
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sortFunc2(filtro, changevalu) {
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

  void showDialogInfoData(data) {}

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

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "PENDIENTE":
        color = 0xFFFF0000;
        break;
      case "ENTREGADO EN OFICINA":
        color = 0xB100E1FF;
        break;
      case "DEVOLUCION EN RUTA":
        color = 0xFF0000FF;
        break;
      case "EN BODEGA":
        color = 0xFFD6DC27;
        break;
      default:
        color = 0xFF000000;
    }

    return Color(color);
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
                    //print(filter);
                  } else {}
                  getOldValue(true);
                  paginatorController.navigateToPage(0);
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

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
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

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonUnselectedForegroundColor: Color.fromARGB(255, 67, 67, 67),
        buttonSelectedBackgroundColor: Color.fromARGB(255, 67, 67, 67),
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
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
          paginatorController.navigateToPage(0);
        },
        // onSubmitted: (value) async {
        //   setState(() {
        //     _controllers.searchController.text = value;
        //   });
        //   //loadData();
        //   paginateData();
        //   getLoadingModal(context, false);

        //   Future.delayed(Duration(milliseconds: 500), () {
        //     paginatorController.navigateToPage(0);

        //     Navigator.pop(context);
        //   });
        // },
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
                    });

                    // setState(() {
                    //   // loadData();
                    //   resetFilters();
                    //   // paginateData();
                    // });
                    resetFilters();
                    paginatorController.navigateToPage(0);

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

  void resetFilters() {
    getOldValue(true);

    // estadoDevolucionController.text = "TODO";
    arrayFiltersAnd = [];
    _controllers.searchController.text = "";
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }
}
