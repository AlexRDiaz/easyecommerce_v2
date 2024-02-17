import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/transport/my_orders_prv/prv_info.dart';
import 'package:frontend/ui/transport/my_orders_prv/prv_info_new.dart';
import 'package:frontend/ui/transport/my_orders_prv/scanner_orders_prv.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes_new.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class MyOrdersPRVTransport extends StatefulWidget {
  const MyOrdersPRVTransport({super.key});

  @override
  State<MyOrdersPRVTransport> createState() => _MyOrdersPRVTransportState();
}

class _MyOrdersPRVTransportState extends State<MyOrdersPRVTransport> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  bool buttonLeft = false;
  bool buttonRigth = false;

  //  *laravel version
  bool isLoading = false;

  List populate = [
    "operadore.up_users",
    "users.vendedores",
    "transportadora",
    "pedidoFecha",
    "subRuta"
  ];
  //transportadora, pedido_fecha, sub_ruta, operadore, operadore.user, users.vendedores

  List filtersOrCont = [
    'marca_t_i',
    'fecha_entrega',
    'numero_orden',
    'name_comercial',
    'ciudad_shipping',
    'nombre_shipping',
    'direccion_shipping',
    //sub_ruta
    //operadore
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    'status',
    "estado_interno",
    "estado_logistico",
    // 'comentario',
  ];

  List arrayFiltersDefaultOr = [];

  var arrayfiltersDefaultAnd = [
    {
      'transportadora.transportadora_id':
          sharedPrefs!.getString("idTransportadora").toString()
    },
    {"status": "PEDIDO PROGRAMADO"},
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "ENVIADO"}
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersNotEq = [];

  int currentPage = 1;
  int pageSize = 150;
  int pageCount = 100;
  int total = 0;
  var sortFieldDefaultValue = "id:DESC";
  var sortField = "";

  bool changevalue = false;
  List dataL = [];
  List selectedCheckBox = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
          populate,
          filtersOrCont,
          arrayFiltersDefaultOr,
          arrayfiltersDefaultAnd,
          arrayFiltersAnd,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          arrayFiltersNotEq,
          sortFieldDefaultValue.toString());

      dataL = responseLaravel["data"];

      setState(() {
        selectedCheckBox = [];
        counterChecks = 0;
        total = responseLaravel['total'];
        pageCount = responseLaravel['last_page'];
      });

      optionsCheckBox = [];
      for (Map pedido in dataL) {
        var selectedItem = selectedCheckBox
            .where((elemento) => elemento["id"] == pedido["id"])
            .toList();
        if (selectedItem.isNotEmpty) {
          pedido['check'] = true;
        } else {
          pedido['check'] = false;
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });
    // var response = [];

    // response = await Connections()
    //     .getOrdersForTransportPRV(_controllers.searchController.text);

    // data = response;
    // print("data strapi: ${data.length}");
    // sortFuncDate("Marca_Tiempo_Envio");
    // for (var i = 0; i < (data.isNotEmpty ? data.length : [].length); i++) {
    //   optionsCheckBox.add({
    //     "check": false,
    //     "id": "",
    //     "numPedido": "",
    //     "date": "",
    //     "city": "",
    //     "product": "",
    //     "extraProduct": "",
    //     "quantity": "",
    //     "phone": "",
    //     "price": "",
    //     "name": "",
    //     "transport": "",
    //     "address": "",
    //     "obervation": "",
    //     "qrLink": "",
    //   });
    // }
    // Future.delayed(Duration(milliseconds: 500), () {
    //   Navigator.pop(context);
    // });
    // setState(() {});
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
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
            children: [
              const SizedBox(
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return ScannerOrdersPrv();
                              });
                          await loadData();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFF031749),
                          ),
                        ),
                        child: const Text(
                          "SCANNER",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              responsive(webMainContainer(width, heigth, context),
                  mobileMainContainer(width, heigth, context), context),
              /*
            Container(
              width: double.infinity,
              child: counterChecks != 0
                  ? _buttons()
                  : _modelTextField(
                      text: "Busqueda",
                      controller: _controllers.searchController),
            ),
            Container(
              padding: EdgeInsets.only(left: 250, right: 15),
              child: ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return ScannerOrdersPrv();
                        });
                    await loadData();
                  },
                  child: Text(
                    "SCANNER",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
            Row(
              children: [
                Text(
                  "Totales: ${data.length}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Seleccionados: $counterChecks",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
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
                  minWidth: 3000,
                  columns: [
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text('Fecha'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha Entrega'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_Tiempo_Envio");
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
                      size: ColumnSize.S,
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
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Sub Ruta'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncSubRoute();
                      },
                    ),
                    DataColumn2(
                      label: Text('Operador'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncOperator();
                      },
                    ),
                    DataColumn2(
                      label: Text('Teléfono'),
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
                      label: Text('Confirmado?'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Interno");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado Logistico'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Logistico");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            DataCell(Checkbox(
                                value: optionsCheckBox[index]['check'],
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      optionsCheckBox[index]['check'] = value;
                                      optionsCheckBox[index]['id'] =
                                          data[index]['id'].toString();

                                      counterChecks += 1;
                                    } else {
                                      optionsCheckBox[index]['check'] = value;
                                      optionsCheckBox[index]['id'] = '';
                                      counterChecks -= 1;
                                    }
                                  });
                                })),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Marca_Tiempo_Envio']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Fecha_Entrega'] ??
                                    "".toString()),
                                onTap: () {}),
                            DataCell(
                                Text(
                                    style: TextStyle(
                                        color: GetColor(data[index]
                                            ['attributes']['revisado'])!),
                                    '${data[index]['attributes']['users']['data'][0]['attributes']['vendedores']['data'][0]['attributes']['Nombre_Comercial']}-${data[index]['attributes']['NumeroOrden'].toString()}'),
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
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['sub_ruta']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']['sub_ruta']
                                        ['data']['attributes']['Titulo']
                                    : "".toString()), onTap: () {
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
                                Text(data[index]['attributes']['Status']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Interno']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Logistico']
                                    .toString()), onTap: () {
                              info(context, index);
                            }),
                          ]))),
            ),
          */
            ],
          ),
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

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      color: Colors.white,
      child: responsive(
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: _modelTextField(
                    text: "Buscar", controller: _controllers.searchController),
              ),
              const SizedBox(width: 10),
              Text(
                "Totales: $total",
              ),
              const SizedBox(width: 10),
              Text(
                "Seleccionados: $counterChecks",
              ),
              counterChecks > 0
                  ? Visibility(
                      visible: true,
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () {
                          {
                            setState(() {
                              selectedCheckBox = [];
                              counterChecks = 0;
                            });
                            loadData();
                          }
                        },
                        icon: Icon(Icons.close_rounded),
                      ),
                    )
                  : Container(),
              const SizedBox(width: 20),
              Visibility(
                visible: counterChecks != 0,
                child: _btnSubRuta(),
              ),
              // Expanded(
              //   child: Align(
              //     alignment: Alignment.centerRight,
              //     child:
              //         Container(width: width * 0.3, child: numberPaginator()),
              //   ),
              // ),
              // Container(width: width * 0.3, child: numberPaginator()),
            ],
          ),
          Column(
            children: [
              _modelTextField(
                  text: "Buscar", controller: _controllers.searchController),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Text(
                    "Totales: $total",
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Seleccionados: $counterChecks",
                  ),
                  counterChecks > 0
                      ? Visibility(
                          visible: true,
                          child: IconButton(
                            iconSize: 20,
                            onPressed: () {
                              {
                                setState(() {
                                  selectedCheckBox = [];
                                  counterChecks = 0;
                                });
                                loadData();
                              }
                            },
                            icon: Icon(Icons.close_rounded),
                          ),
                        )
                      : Container(),
                  const SizedBox(width: 20),
                  Visibility(
                    visible: counterChecks != 0,
                    child: _btnSubRuta(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          context),
    );
  }

  Container _dataTableOrders(height) {
    return Container(
      height: height * 0.70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: dataL.length > 0
          ? DataTableModelPrincipal(
              columnWidth: 200,
              columns: getColumns(),
              rows: buildDataRows(dataL))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(label: Text(''), size: ColumnSize.S, fixedWidth: 50),
      DataColumn2(
        label: Text("Fecha Envio"),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Fecha Entrega'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("fecha_entrega", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Nombre Cliente'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("nombre_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Sub Ruta'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Operador'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Teléfono Cliente'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("cantidad_total", changevalue);
        },
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
      ),
      DataColumn2(
        label: Text('Precio Total'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("precio_total", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Status'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Confirmado?'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("estado_interno", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Estado Logistico'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("estado_logistico", changevalue);
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List dataL) {
    dataL = dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Checkbox(
              value: dataL[index]['check'],
              onChanged: (value) {
                setState(() {
                  dataL[index]['check'] = value;
                });

                if (value!) {
                  selectedCheckBox.add({
                    "check": value,
                    "id": dataL[index]['id'].toString(),
                  });
                } else {
                  selectedCheckBox.removeWhere((option) =>
                      option['id'] == dataL[index]['id'].toString());
                }
                setState(() {
                  counterChecks = selectedCheckBox.length;
                });
                print(selectedCheckBox);
              },
            ),
          ),
          DataCell(
            InkWell(
              child: Text(
                dataL[index]['marca_tiempo_envio'].toString(),
              ),
              onTap: () {
                info(context, index);
              },
            ),
          ),
          DataCell(
            Text(dataL[index]['fecha_entrega'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(
                '${dataL[index]['users'] != null && dataL[index]['users'].isNotEmpty ? dataL[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${dataL[index]['numero_orden'].toString()}',
                style: TextStyle(color: GetColor(dataL[index]['revisado'])!)),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['ciudad_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['nombre_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['direccion_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          // subruta
          DataCell(
            Text(dataL[index]['sub_ruta'] != null &&
                    dataL[index]['sub_ruta'].toString() != "[]"
                ? dataL[index]['sub_ruta'][0]['titulo'].toString()
                : ""),
            onTap: () {
              info(context, index);
            },
          ),
          // oper
          DataCell(
            Text(dataL[index]['operadore'].toString() != null &&
                    dataL[index]['operadore'].toString().isNotEmpty
                ? dataL[index]['operadore'] != null &&
                        dataL[index]['operadore'].isNotEmpty &&
                        dataL[index]['operadore'][0]['up_users'] != null &&
                        dataL[index]['operadore'][0]['up_users'].isNotEmpty &&
                        dataL[index]['operadore'][0]['up_users'][0]
                                ['username'] !=
                            null
                    ? dataL[index]['operadore'][0]['up_users'][0]['username']
                    : ""
                : ""),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['telefono_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['cantidad_total'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['producto_p'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['producto_extra'] == null ||
                    dataL[index]['producto_extra'].toString() == "null"
                ? ""
                : dataL[index]['producto_extra'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text("\$ ${dataL[index]['precio_total'].toString()}"),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['status'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['estado_interno'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['estado_logistico'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
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
    return dataL.length > 0
        ? Container(
            height: height * 0.70,
            child: DataTableModelPrincipal(
                columnWidth: 400,
                columns: getColumns(),
                rows: buildDataRows(dataL)),
          )
        : const Center(
            child: Text("Sin datos"),
          );
  }

  ElevatedButton _btnSubRuta() {
    return ElevatedButton(
      onPressed: () async {
        await showDialog(
            context: context,
            builder: (context) {
              return SubRoutesModalNew(
                idOrder: selectedCheckBox,
                someOrders: true,
              );
            });

        setState(() {});
        loadData();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color(0xFF031749),
        ),
      ),
      child: const Text(
        "Asignar SubRuta",
        style: TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return SubRoutesModal(
                        idOrder: optionsCheckBox,
                        someOrders: true,
                      );
                    });

                setState(() {});
                loadData();
              },
              child: Text(
                "Asignar SubRuta",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  sortFunc3(filtro, changevalu) {
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
          loadData();
        },
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                    await loadData();
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

  sortFuncOperator() {
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

  sortFuncSubRoute() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(a['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(b['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    }
  }

  sortFuncDate(name) {
    if (!sort) {
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

  Color? GetColor(state) {
    var color;
    if (state == true) {
      color = 0xFF2991DB;
    } else {
      color = 0xFF000000;
    }
    return Color(color);
  }

  NextInfo0(index) {
    Navigator.pop(context);

    if (index + 1 < data.length) {
      info(context, index + 1);
    }
  }

  PreviusInfo0(index) {
    Navigator.pop(context);
    if (index - 1 >= 0) {
      info(context, index - 1);
    }
  }

  NextInfo(index) {
    Navigator.pop(context);

    if (index + 1 < pageSize) {
      info(context, index + 1);
    }
  }

  PreviusInfo(index) {
    Navigator.pop(context);
    if (index - 1 >= 0) {
      info(context, index - 1);
    }
  }

  Future<void> sumarNumero(BuildContext context, int numero) async {
    print('Sumando el número: $numero');
    await loadData();
    Navigator.pop(context);

    //});
    info(context, numero);
  }

  Future<dynamic> info(BuildContext context, int index) {
    if (index - 1 >= 0) {
      buttonLeft = true;
    } else {
      buttonLeft = false;
    }
    if (index + 1 < dataL.length) {
      buttonRigth = true;
    } else {
      buttonRigth = false;
    }
    return openDialog(
        context,
        MediaQuery.of(context).size.width * 0.5,
        MediaQuery.of(context).size.height,
        responsive(
            Container(
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
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                      child: MyOrdersPRVInfoNew(
                          order: dataL[index],
                          index: index,
                          sumarNumero: sumarNumero,
                          data: dataL)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: buttonLeft,
                        child: IconButton(
                          iconSize: 60,
                          onPressed: () => {PreviusInfo(index)},
                          icon: Icon(Icons.arrow_circle_left),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                      ),
                      Visibility(
                        visible: buttonRigth,
                        child: IconButton(
                          iconSize: 60,
                          onPressed: () => {NextInfo(index)},
                          icon: Icon(Icons.arrow_circle_right),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx < 0) {
                  NextInfo(index);
                } else if (details.delta.dx > 0) {
                  PreviusInfo(index);
                }
              },
              child: Container(
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
                        child: MyOrdersPRVInfoNew(
                            order: dataL[index],
                            index: index,
                            sumarNumero: sumarNumero,
                            data: dataL)),
                  ],
                ),
              ),
            ),
            context),
        () {});
  }

  Future<dynamic> info0(BuildContext context, int index) {
    if (index - 1 >= 0) {
      buttonLeft = true;
    } else {
      buttonLeft = false;
    }
    if (index + 1 < data.length) {
      buttonRigth = true;
    } else {
      buttonRigth = false;
    }
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
                      child: MyOrdersPRVInfo(
                    // id: data[index]['id'].toString(),
                    id: dataL[index]['id'].toString(),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: buttonLeft,
                        child: IconButton(
                          iconSize: 60,
                          onPressed: () => {PreviusInfo(index)},
                          icon: Icon(Icons.arrow_circle_left),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                      ),
                      Visibility(
                        visible: buttonRigth,
                        child: IconButton(
                          iconSize: 60,
                          onPressed: () => {NextInfo(index)},
                          icon: Icon(Icons.arrow_circle_right),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
