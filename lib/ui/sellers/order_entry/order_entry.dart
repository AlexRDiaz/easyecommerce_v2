import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/sellers/order_entry/calendar_modal.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/sellers/order_entry/order_info.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
import 'package:frontend/ui/widgets/sellers/add_order.dart';
import 'package:frontend/ui/widgets/sellers/add_order_laravel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import '../../widgets/show_error_snackbar.dart';

class OrderEntry extends StatefulWidget {
  const OrderEntry({super.key});

  @override
  State<OrderEntry> createState() => _OrderEntryState();
}

enum IconAction { phone, message, check, close }

class _OrderEntryState extends State<OrderEntry> {
  OrderEntryControllers _controllers = OrderEntryControllers();
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  int total = 0;
  bool isSearch = false;
  bool buttonLeft = false;
  bool buttonRigth = false;
  String pedido = '';
  String confirmado = 'TODO';
  String logistico = 'TODO';
  bool enabledBusqueda = true;
  bool isLoading = false;
  bool columnChecksActive = false;

  List filtersAnd = [];
  List filtersDefaultAnd = [
    {
      'operator': '\$and',
      'filter': 'IdComercial',
      'operator_attr': '\$eq',
      'value': sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
    {
      'operator': '\$and',
      'filter': 'Estado_Interno',
      'operator_attr': '\$ne',
      'value': 'NO DESEA'
    },
    {
      'operator': '\$and',
      'filter': 'Status',
      'operator_attr': '\$eq',
      'value': 'PEDIDO PROGRAMADO'
    },
  ];
  List filtersOrCont = [
    {'filter': 'CiudadShipping'},
    {'filter': 'NumeroOrden'},
    {'filter': 'NombreShipping'},
    {'filter': 'DireccionShipping'},
    {'filter': 'TelefonoShipping'},
    {'filter': 'ProductoP'},
    {'filter': 'ProductoExtra'},
    {'filter': 'PrecioTotal'},
  ];

  // ! se usa Laravel
  bool changevalue = false;
  var sortFieldDefaultValue = "id:DESC";
  List arrayFiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
    {'status': 'PEDIDO PROGRAMADO'}
  ];
  List arrayFiltersNot = [
    {'estado_interno': 'NO DESEA'},
  ];
  // List populate = ['users', 'pedido_fecha'];
  List populate = [
    // 'operadore.up_users',
    'transportadora',
    'users.vendedores',
    // 'novedades',
    // 'pedidoFecha',
    'ruta',
    // 'subRuta'
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    'ciudad_shipping',
    'numero_orden',
    'nombre_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'producto_p',
    'producto_extra',
    'precio_total',
  ];

  NumberPaginatorController paginatorController = NumberPaginatorController();

  List<String> optEstadoConfirmado = ["TODO", 'PENDIENTE', 'CONFIRMADO'];
  List<String> optEstadoLogistico = ["TODO", 'PENDIENTE', 'IMPRESO', 'ENVIADO'];
  bool noDeseaEnabled = true;

  @override
  void didChangeDependencies() {
    if (Provider.of<FiltersOrdersProviders>(context).indexActive == 2) {
      setState(() {
        // _controllers.searchController.text = "d/m/a,d/m/a";
        _controllers.searchController.text = "";
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
    try {
      setState(() {
        isLoading = true;
        data.clear();
      });

      currentPage = 1;
      var response = await Connections().getPrincipalOrdersSellersFilterLaravel(
          populate,
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          sortFieldDefaultValue.toString(),
          arrayFiltersNot);

      data = [];
      data = response['data'];
      pageCount = response['last_page'];
      total = response['total'];
      paginatorController.navigateToPage(0);

      optionsCheckBox = [];
      for (var i = 0; i < total; i++) {
        optionsCheckBox.add({"check": false, "id": "", "numero_orden": ""});
      }
      paginatorController.navigateToPage(0);

      counterChecks = 0;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    // print("Pagina Actual="+currentPage.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = [];
    setState(() {
      data.clear();
    });
    var response = await Connections().getPrincipalOrdersSellersFilterLaravel(
        populate,
        arrayFiltersAnd,
        arrayFiltersDefaultAnd,
        arrayFiltersOr,
        currentPage,
        pageSize,
        _controllers.searchController.text,
        sortFieldDefaultValue.toString(),
        arrayFiltersNot);

    setState(() {
      data = [];
      data = response['data'];
      pageCount = response['last_page'];
      total = response['total'];
      // pageCount = response[0]['meta']['pagination']['pageCount'];
      // total = response[0]['meta']['pagination']['total'];
    });
    print("paginadoo");
    await Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String logisticoVal = logistico;
    String confirmadoVal = confirmado;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
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
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
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
                                              onPressed: () =>
                                                  {clearSelected()},
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
                                  onPressed: counterChecks > 0 && noDeseaEnabled
                                      ? () async {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Atención'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                          '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                      Text('' + listToDelete()),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child:
                                                        const Text('Cancelar'),
                                                    onPressed: () {
                                                      // Acción al presionar el botón de cancelar
                                                      Navigator.of(context)
                                                          .pop();
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
                                                              .updateOrderInteralStatusLaravel(
                                                                  "NO DESEA",
                                                                  optionsCheckBox[
                                                                              i]
                                                                          ['id']
                                                                      .toString());
                                                          counterChecks = 0;
                                                        }
                                                      }

                                                      loadData();
                                                      setState(() {});
                                                      enabledBusqueda = true;
                                                      Navigator.of(context)
                                                          .pop();
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: (context),
                                        builder: (context) {
                                          // return const AddOrderSellers();
                                          return const AddOrderSellersLaravel();
                                        });
                                    await loadData();
                                  },
                                  child: const Row(
                                    children: [Text(" Nuevo"), Icon(Icons.add)],
                                  )),
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
                                                title: Text('Atención'),
                                                content: Column(
                                                  children: [
                                                    const Text(
                                                        '¿Estás seguro de eliminar los siguientes pedidos?'),
                                                    Text('' + listToDelete()),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child:
                                                        const Text('Cancelar'),
                                                    onPressed: () {
                                                      // Acción al presionar el botón de cancelar
                                                      Navigator.of(context)
                                                          .pop();
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
                                                              .updateOrderInteralStatusLaravel(
                                                                  "NO DESEA",
                                                                  optionsCheckBox[
                                                                              i]
                                                                          ['id']
                                                                      .toString());
                                                          counterChecks = 0;
                                                        }
                                                      }
                                                      setState(() {});
                                                      loadData();
                                                      Navigator.of(context)
                                                          .pop();
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: (context),
                                        builder: (context) {
                                          return AddOrderSellersLaravel();
                                        });
                                    await loadData();
                                  },
                                  child: const Text(
                                    "Nuevo",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Colors.blueGrey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    dividerThickness: 1,
                    dataRowColor: MaterialStateColor.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue
                            .withOpacity(0.5); // Color para fila seleccionada
                      } else if (states.contains(MaterialState.hovered)) {
                        return const Color.fromARGB(255, 234, 241, 251);
                      }
                      return const Color.fromARGB(0, 173, 233, 231);
                    }),
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: const TextStyle(color: Colors.black),
                    columnSpacing: 12,
                    headingRowHeight: 80,
                    horizontalMargin: 12,
                    minWidth: 3500,
                    columns: [
                      DataColumn2(
                        label: Container(
                          width: 40, // Ancho fijo para la columna
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // Color de fondo azul
                              padding: EdgeInsets
                                  .zero, // Eliminar el relleno para reducir el tamaño del botón
                            ),
                            onPressed: () {
                              // Acción al presionar el botón
                              // print("Botón presionado");
                              setState(() {
                                columnChecksActive = !columnChecksActive;
                              });
                            },
                            child: Icon(Icons.check,
                                color: Colors.white), // Icono blanco
                          ),
                        ),
                        size: ColumnSize.S,
                        fixedWidth:
                            40, // Asegúrate de que el ancho fijo coincida con el ancho del contenedor
                      ),
                      const DataColumn2(
                        label: Text(''),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: const Text('Marca de Tiempo'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          // sortFuncDate("Marca_T_I");
                          sortFunc3("marca_t_i", changevalue);
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
                        label: Text('Teléfono Cliente'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc3("telefonoS_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: Text('Cantidad'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc3("cantidad_total", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: Text('Producto'),
                        size: ColumnSize.M,
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
                      DataColumn2(
                        label: Text('Precio Total'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc3("precio_total", changevalue);
                        },
                      ),
                      const DataColumn2(
                        label: Text('Observación'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: const Text('Estado Pedido'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc3("status", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Estado Confirmado'),
                            DropdownButton<String>(
                              value: confirmadoVal,
                              elevation: 16,
                              onChanged: (String? value) {
                                if (value == "TODO") {
                                  arrayFiltersAnd.clear();
                                } else {
                                  arrayFiltersAnd
                                      .add({"estado_interno": "$value"});
                                }
                                confirmado = value!;
                                loadData();
                              },
                              items: optEstadoConfirmado
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Estado_Interno");
                        },
                      ),
                      DataColumn2(
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Estado Logistico'),
                            DropdownButton<String>(
                              value: logisticoVal,
                              elevation: 16,
                              onChanged: (String? value) {
                                if (value == "TODO") {
                                  arrayFiltersAnd.clear();
                                } else {
                                  arrayFiltersAnd
                                      .add({"estado_logistico": "$value"});
                                }
                                logistico = value!;
                                loadData();
                              },
                              items: optEstadoLogistico
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Estado_Logistico");
                        },
                      ),
                      DataColumn2(
                        label: Text('Marca Fecha Confirmación'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc3("fecha_confirmacion", changevalue);
                        },
                      ),
                      const DataColumn2(
                        label: Text('Transportadora'),
                        size: ColumnSize.M,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                        data.length,
                        (index) => DataRow(cells: [
                              DataCell(columnChecksActive == true
                                  ? Checkbox(
                                      //  verificarIndice
                                      value: verificarIndice(index),
                                      // value: optionsCheckBox[index]['check'],
                                      onChanged: (value) {
                                        setState(() {
                                          if (value!) {
                                            optionsCheckBox[index +
                                                ((currentPage - 1) *
                                                    pageSize)]['check'] = value;
                                            optionsCheckBox[index +
                                                    ((currentPage - 1) *
                                                        pageSize)]['id'] =
                                                data[index]['id'];
                                            optionsCheckBox[index +
                                                        ((currentPage - 1) *
                                                            pageSize)]
                                                    ['numero_orden'] =
                                                data[index]['numero_orden'];
                                            // print(data[index]
                                            //         ['estado_logistico']
                                            //     .toString());
                                            if (data[index]['estado_logistico']
                                                        .toString() ==
                                                    "IMPRESO" ||
                                                data[index]['estado_logistico']
                                                        .toString() ==
                                                    "ENVIADO") {
                                              noDeseaEnabled = false;
                                            }

                                            counterChecks += 1;
                                          } else {
                                            optionsCheckBox[index +
                                                ((currentPage - 1) *
                                                    pageSize)]['check'] = value;

                                            optionsCheckBox[index +
                                                (currentPage - 1) *
                                                    pageSize]['id'] = '';
                                            counterChecks -= 1;
                                          }
                                          counterChecks > 0
                                              ? enabledBusqueda = false
                                              : enabledBusqueda = true;
                                        });
                                      })
                                  : Container(
                                      width: 1,
                                    )),
                              DataCell(
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: (data[index]['estado_logistico']
                                                      .toString() ==
                                                  "IMPRESO" &&
                                              data[index]['estado_interno']
                                                      .toString() ==
                                                  "CONFIRMADO")
                                          ? Row(
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        ColorsSystem()
                                                            .colorBlack,
                                                    shadowColor: Color.fromARGB(
                                                        255, 80, 78, 78),
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .horizontal(
                                                        left: Radius.circular(
                                                            10.0),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    // print('Phone selected');
                                                    var _url = Uri(
                                                        scheme: 'tel',
                                                        path:
                                                            '${data[index]['telefono_shipping'].toString()}');

                                                    if (!await launchUrl(
                                                        _url)) {
                                                      throw Exception(
                                                          'Could not launch $_url');
                                                    }
                                                  },
                                                  child: Icon(Icons.phone,
                                                      color: Colors.white),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          ColorsSystem()
                                                              .colorBlack,
                                                      shadowColor:
                                                          Color.fromARGB(
                                                              255, 80, 78, 78),
                                                      shape:
                                                          RoundedRectangleBorder()),
                                                  onPressed: () async {
                                                    // print('Message selected');
                                                    var _url = Uri.parse(
                                                        """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
                                                    if (!await launchUrl(
                                                        _url)) {
                                                      throw Exception(
                                                          'Could not launch $_url');
                                                    }
                                                  },
                                                  child: Icon(Icons.message,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        ColorsSystem()
                                                            .colorBlack,
                                                    shadowColor: Color.fromARGB(
                                                        255, 80, 78, 78),
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .horizontal(
                                                        left: Radius.circular(
                                                            10.0),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    // print('Phone selected');
                                                    var _url = Uri(
                                                        scheme: 'tel',
                                                        path:
                                                            '${data[index]['telefono_shipping'].toString()}');

                                                    if (!await launchUrl(
                                                        _url)) {
                                                      throw Exception(
                                                          'Could not launch $_url');
                                                    }
                                                  },
                                                  child: Icon(Icons.phone,
                                                      color: Colors.white),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          ColorsSystem()
                                                              .colorBlack,
                                                      shadowColor:
                                                          Color.fromARGB(
                                                              255, 80, 78, 78),
                                                      shape:
                                                          RoundedRectangleBorder()),
                                                  onPressed: () async {
                                                    // print('Message selected');
                                                    var _url = Uri.parse(
                                                        """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Hola ${data[index]['nombre_shipping'].toString()}, te saludo de la tienda ${data[index]['tienda_temporal'].toString()}, Me comunico con usted para confirmar su pedido de compra de: ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor total de: ${data[index]['precio_total'].toString()}. Su dirección de entrega será: ${data[index]['direccion_shipping'].toString()} Es correcto...? Desea mas información del producto?""");
                                                    if (!await launchUrl(
                                                        _url)) {
                                                      throw Exception(
                                                          'Could not launch $_url');
                                                    }
                                                  },
                                                  child: Icon(Icons.message,
                                                      color: Colors.white),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        ColorsSystem()
                                                            .colorBlack,
                                                    shadowColor: Color.fromARGB(
                                                        255, 80, 78, 78),
                                                    shape:
                                                        RoundedRectangleBorder(),
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {});
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return RoutesModalv2(
                                                          idOrder: data[index]
                                                                  ['id']
                                                              .toString(),
                                                          someOrders: false,
                                                          phoneClient: "",
                                                          codigo:
                                                              "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                                                          origin: "",
                                                        );
                                                      },
                                                    );
                                                    loadData();
                                                  },
                                                  child: Icon(Icons.check,
                                                      color: Colors.white),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        ColorsSystem()
                                                            .colorBlack,
                                                    shadowColor: Color.fromARGB(
                                                        255, 80, 78, 78),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .horizontal(
                                                        right: Radius.circular(
                                                            10.0),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    var response =
                                                        await Connections()
                                                            .updateOrderInteralStatusLaravel(
                                                                "NO DESEA",
                                                                data[index]
                                                                        ['id']
                                                                    .toString());
                                                    setState(() {});
                                                    loadData();
                                                  },
                                                  child: Icon(Icons.close,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                ),
                              ),
                              DataCell(
                                  Text(
                                      '${data[index]['marca_t_i'].toString()}'),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(
                                      "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}"
                                          .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['ciudad_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['nombre_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['direccion_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['telefono_shipping']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['cantidad_total'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['producto_p'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                Text(data[index]['producto_extra'] == null ||
                                        data[index]['producto_extra'] == "null"
                                    ? ""
                                    : data[index]['producto_extra'].toString()),
                                onTap: () {
                                  info(context, index);
                                },
                              ),
                              DataCell(
                                  Text(
                                      '\$${data[index]['precio_total'].toString()}'),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                //   Text(data[index]['observacion'].toString()),
                                //   onTap: () {
                                // info(context, index);
                                Text(data[index]['observacion'] == null ||
                                        data[index]['observacion'] == "null"
                                    ? ""
                                    : data[index]['observacion'].toString()),
                                onTap: () {
                                  info(context, index);
                                },
                              ),
                              DataCell(Text(data[index]['status'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(
                                      data[index]['estado_interno'].toString()),
                                  onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['estado_logistico']
                                      .toString()), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        child: Text(data[index][
                                                        'fecha_confirmacion'] ==
                                                    null ||
                                                data[index][
                                                        'fecha_confirmacion'] ==
                                                    "null"
                                            ? ""
                                            : data[index]['fecha_confirmacion']
                                                .toString()),
                                        /*Text(data[index]
                                                ['fecha_confirmacion']
                                            .toString()),
                                            */
                                      ),
                                      data[index]['estado_interno'] ==
                                              "PENDIENTE"
                                          ? TextButton(
                                              onPressed: () {
                                                Calendar(data[index]['id']
                                                        .toString())
                                                    .then((value) =>
                                                        paginateData());
                                              },
                                              child: Icon(Icons.calendar_today),
                                            )
                                          : Container(),
                                    ],
                                  ), onTap: () {
                                info(context, index);
                              }),
                              DataCell(
                                  Text(data[index]['transportadora'] != null &&
                                          data[index]['transportadora']
                                              .isNotEmpty
                                      ? data[index]['transportadora'][0]
                                              ['nombre']
                                          .toString()
                                      : ''), onTap: () {
                                info(context, index);
                              }),
                            ]))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      // initialPage: 0,
      onPageChange: (index) async {
        //  print("indice="+index.toString());
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  String listToDelete() {
    String res = "";

    for (var i = 0; i < optionsCheckBox.length; i++) {
      if (optionsCheckBox[i]['check'] == true) {
        res += sharedPrefs!.getString("NameComercialSeller").toString() +
            "-" +
            optionsCheckBox[i]['numero_orden'] +
            '\n';
      }
    }
    return res;
  }

  AddFilterAndEq(value, filtro) {
    setState(() {
      if (value != 'TODO') {
        bool contains = false;

        for (var filter in filtersAnd) {
          if (filter['filter'] == filtro) {
            contains = true;
            break;
          }
        }
        if (contains == false) {
          filtersAnd
              .add({'filter': filtro, 'operator_attr': '\$eq', 'value': value});
        } else {
          for (var filter in filtersAnd) {
            if (filter['filter'] == filtro) {
              filter['value'] = value;
              break;
            }
          }
        }
      } else {
        for (var filter in filtersAnd) {
          if (filter['filter'] == filtro) {
            filtersAnd.remove(filter);
            break;
          }
        }
      }

      currentPage = 1;
    });
    loadData();
  }

  Future<dynamic> Calendar(String id) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(child: CalendarModal(id: id)),
                ],
              ),
            ),
          );
        });
  }

  Future<void> sumarNumero(BuildContext context, int numero) async {
    print('Sumando el número: $numero');
    await paginateData();
    // await Future.delayed(Duration(milliseconds: 1000), () {
    Navigator.pop(context);

    //});
    info(context, numero);
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

  Future<dynamic> info(BuildContext context, int index) {
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
    return openDialog(
        context,
        MediaQuery.of(context).size.width * 0.6,
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
                      child: OrderInfo(
                          order: data[index],
                          index: index,
                          sumarNumero: sumarNumero,
                          codigo:
                              "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                          data: data)),
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
                        child: OrderInfo(
                            order: data[index],
                            index: index,
                            sumarNumero: sumarNumero,
                            codigo:
                                "${sharedPrefs!.getString("NameComercialSeller").toString()}-${data[index]['numero_orden']}",
                            data: data)),
                  ],
                ),
              ),
            ),
            context),
        () {});
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

  clearSelected() {
    optionsCheckBox = [];
    for (var i = 0; i < total; i++) {
      optionsCheckBox.add({"check": false, "id": "", "numero_orden": ""});
    }
    setState(() {
      counterChecks = 0;
      enabledBusqueda = true;
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
        enabled: enabledBusqueda,
        controller: controller,
        onSubmitted: (value) async {
          setState(() {
            _controllers.searchController.text = value;
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
                      confirmado = "TODO";
                      logistico = "TODO";
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
}
