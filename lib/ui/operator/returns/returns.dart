import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/returns/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

class ReturnsOperator extends StatefulWidget {
  const ReturnsOperator({super.key});

  @override
  State<ReturnsOperator> createState() => _ReturnsOperatorState();
}

class _ReturnsOperatorState extends State<ReturnsOperator> {
  final ReturnsControllers _controllers = ReturnsControllers();
  // List data = [];
  // bool sort = false;
  // List dataTemporal = [];
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
    "Devolución"
  ];
  // ! esto uso
  List data = [];
  bool search = false;
  bool sort = false;
  String currentValue = "";
  int total = 0;
  bool isFirst = true;
  int currentPage = 1;
  int pageSize = 75;
  int pageCount = 100;
  bool isLoading = false;
  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController estadodevController =
      TextEditingController(text: "TODO");
  List populate = [
    'transportadora.operadores.user',
    'pedido_fecha',
    'sub_ruta',
    'operadore',
    'operadore.user',
    'users',
    'users.vendedores',
    'novedades'
  ];
  List arrayFiltersOr = [
    'marca_tiempo_envio',
    'numero_orden',
    'nombre_shipping',
    'ciudad_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    'producto_extra',
    'precio_total',
    'observacion',
    'comentario',
    'status',
    'fecha_entrega',
    'estado_devolucion',
    'tipo_Pago',
    'marca_t_d',
    'marca_t_d_l',
    'marca_t_d_t',
  ];
  List arrayFiltersAnd = [];
  //  List arrayFiltersDefaultAnd = [
  // {
  // '"operadore.up_users.operadore_id':
  // sharedPrefs!.getString("idOperadore").toString()
  List arrayFiltersDefaultAnd = [
    // {'operadore.up_users.username': 'Omar'},
    {'operadore.operadore_id': sharedPrefs!.getString("idOperadore").toString()}
    // {'estado_logistico': "ENVIADO"},
    // {'estado_interno': "CONFIRMADO"}
  ];

  List multifilter = [
    {"status": "NO ENTREGADO"},
    {"status": "NOVEDAD"}
  ];

  List<String> listestadosdev = [
    'TODO',
    'PENDIENTE',
    'ENTREGADO EN OFICINA',
    'DEVOLUCION EN RUTA',
    'EN BODEGA',
  ];

  @override
  Future<void> didChangeDependencies() async {
    loadData(context);
    super.didChangeDependencies();
  }

  loadData(context) async {
    // print("aqui ↓");
    // print(sharedPrefs!.getString("idOperadore").toString());

    isLoading = true;
    currentPage = 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      search = false;
    });
    var response = await Connections().getOrdersOper(
        populate,
        arrayFiltersAnd,
        arrayFiltersDefaultAnd,
        arrayFiltersOr,
        currentPage,
        pageSize,
        _controllers.searchController.text,
        multifilter);

    setState(() {
      data = [];
      data = response['data'];
      pageCount = response['last_page'];
      total = response['total'];
      paginatorController.navigateToPage(0);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {
      isFirst = false;
      isLoading = false;
    });
    // print(data);
  }

  paginateData() async {
    // paginatorController.navigateToPage(0);
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      setState(() {
        search = false;
      });

      var response = await Connections().getOrdersOper(
          populate,
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          currentPage,
          pageSize,
          _controllers.searchController.text,
          multifilter);

      setState(() {
        data = [];
        data = response['data'];

        pageCount = response['last_page'];
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      // setState(() {
      //   isFirst = false;

      //   // isLoading = false;
      // });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // Expanded(child: numberPaginator()),
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),

            Row(
              children: [
                Expanded(
                  child: _filters(context),
                ),
                Expanded(
                  child: paginatorContainer(),
                ),
              ],
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
                dataTextStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                showCheckboxColumn: false,
                headingRowColor: MaterialStateColor.resolveWith((states) {
                  return Colors
                      .blueGrey; // Color de fondo de las celdas de encabezado
                }),
                columns: [
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("marca_tiempo_envio");
                    },
                  ),
                  DataColumn2(
                    label: Text('Código'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("numero_orden");
                    },
                  ),
                  DataColumn2(
                    label: Text('Ciudad'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("ciudad_shipping");
                    },
                  ),
                  DataColumn2(
                    label: Text('Nombre Cliente'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("nombre_shipping");
                    },
                  ),
                  DataColumn2(
                    label: Text('Detalle'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("direccion_shipping");
                    },
                  ),
                  DataColumn2(
                    label: Text('Teléfono'),
                    numeric: true,
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("telefono_shipping");
                    },
                  ),
                  DataColumn2(
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("cantidad_total");
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("producto_p");
                    },
                  ),
                  DataColumn2(
                    label: Text('Producto Ex'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("producto_extra");
                    },
                  ),
                  DataColumn2(
                    label: Text('Precio Total'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("precio_total");
                    },
                  ),
                  DataColumn2(
                    label: Text('Observación'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("observacion");
                    },
                  ),
                  DataColumn2(
                    label: Text('Comentario'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("comentario");
                    },
                  ),
                  DataColumn2(
                    label: Text('Status'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Status");
                    },
                  ),
                  DataColumn2(
                    label: Text('Fecha de Entrega'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("fecha_entrega");
                    },
                  ),
                  // ! ************
                  DataColumn2(
                    // label: Text('Devolución'),
                    label: SelectFilter('Devolución', 'estado_devolucion',
                        estadodevController, listestadosdev),
                    size: ColumnSize.L,
                    // numeric: true,
                    onSort: (columnIndex, ascending) {
                      // sortFunc("estado_devolucion");
                    },
                  ),
                  // DataColumn2(
                  //   label: Text('Devolución'),
                  //   size: ColumnSize.M,
                  //   numeric: true,
                  //   onSort: (columnIndex, ascending) {
                  //     sortFunc("estado_devolucion");
                  //   },
                  // ),
                  // ! ************
                  DataColumn2(
                    label: Text('MDT.OF'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("marca_t_d");
                    },
                  ),
                  DataColumn2(
                    label: Text('MDT.RUTA'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("marca_t_d_t");
                    },
                  ),
                  DataColumn2(
                    label: Text('MDT. BOD'),
                    size: ColumnSize.M,
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("marca_t_d_l");
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    Color rowColor = Colors.black;
                    return DataRow(
                      onSelectChanged: (bool? selected) {},
                      cells: [
                        DataCell(ElevatedButton(
                            onPressed: data[index]['estado_devolucion']
                                        .toString() !=
                                    "PENDIENTE"
                                ? null
                                : () {
                                    AwesomeDialog(
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.info,
                                      animType: AnimType.rightSlide,
                                      title:
                                          '¿Estás seguro de marcar el pedido en Oficina?',
                                      desc: '',
                                      btnOkText: "Confirmar",
                                      btnCancelText: "Cancelar",
                                      btnOkColor: Colors.blueAccent,
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () async {
                                        getLoadingModal(context, false);
                                        await Connections()
                                            .updateOrderReturnOperator(
                                                data[index]['id']);

                                        var datane = await Connections()
                                            .getOrderByIDHistoryLaravel(
                                                data[index]['id']);

                                        print("costos-> $datane");

                                        if (datane['estado_devolucion'] ==
                                            "ENTREGADO EN OFICINA") {
                                          if (((datane['status'] ==
                                                  "NO ENTREGADO") ||
                                              datane['status'] == "NOVEDAD")) {
                                            await Connections().postDebit(
                                                "${datane['users'][0]['vendedores'][0]['id_master']}",
                                                "${datane['users'][0]['vendedores'][0]['costo_devolucion']}",
                                                "${datane['id']}",
                                                "${datane['name_comercial']}-${datane['numero_orden']}",
                                                "devolucion",
                                                "costo de devolucion por ${datane['estado_devolucion']}");

                                            Connections().updatenueva(
                                                data[index]['id'], {
                                              "costo_envio": datane['users'][0]
                                                      ['vendedores'][0]
                                                  ['costo_devolucion'],
                                            });
                                          }
                                        }
                                        await loadData(context);
                                        Navigator.pop(context);
                                      },
                                    ).show();
                                  },
                            child: const Text(
                              "Devolver",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ))),
                        DataCell(
                          Text(
                            data[index]['marca_tiempo_envio']
                                .toString()
                                .split(" ")[0],
                            style: TextStyle(
                              color: rowColor,
                            ),
                          ),
                        ),
                        DataCell(
                            Text(
                              '${data[index]['name_comercial'].toString()}-${data[index]['numero_orden'].toString()}',
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
                            onTap: () {}),
                        DataCell(
                          Text(data[index]['ciudad_shipping'] != null &&
                                  data[index]['ciudad_shipping'].isNotEmpty
                              ? data[index]['ciudad_shipping'].toString()
                              : ""),
                        ),
                        DataCell(Text(
                          data[index]['nombre_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['direccion_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['telefono_shipping'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['cantidad_total'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['producto_p'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['producto_extra'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['precio_total'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['observacion'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['comentario'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['status'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['fecha_entrega'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['estado_devolucion'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d_t'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          data[index]['marca_t_d_l'].toString(),
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                      ],
                      color: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.blueAccent.withOpacity(
                              0.5); // Color de fondo cuando la fila está seleccionada
                        }
                        return Colors
                            .white; // Color de fondo predeterminado de la fila
                      }),
                    );
                  },
                ),
                dataRowHeight: 50, // Altura de las filas de datos
                headingRowHeight: 60,

                // Altura de la fila de encabezado
              ),
            ),
          ],
        ),
      ),
    );
  }

// ! ***********************
  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 4.0),
            width: 160,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color.fromARGB(255, 49, 48, 48)),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.blueGrey,
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              iconDisabledColor: Colors.white,
              iconEnabledColor: Colors.amber[900],
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
                      //print(filter);

                      arrayFiltersAnd.add(filter);
                    }
                  } else {}

                  loadData(context);
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.only(
                          bottom: 5.5), // Adjust the top padding as needed
                      child: Text(
                        value.split("-")[0],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          paginateData();
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
                      paginateData();
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

  Container paginatorContainer() {
    return Container(
      // color: Colors.white, // Cambia este color al color de fondo que desees
      child: NumberPaginator(
        config: NumberPaginatorUIConfig(
          buttonUnselectedForegroundColor: Color.fromARGB(255, 71, 67, 67),
          buttonSelectedBackgroundColor: ColorsSystem().colorBlack,
          buttonShape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(5), // Customize the button shape
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
      ),
    );
  }

// ! ***********************
  // _modelTextField({text, controller}) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10.0),
  //       color: Color.fromARGB(255, 245, 244, 244),
  //     ),
  //     child: TextField(
  //       controller: controller,
  //       onSubmitted: (value) {
  //         getLoadingModal(context, false);

  //         setState(() {
  //           data = dataTemporal;
  //         });
  //         if (value.isEmpty) {
  //           setState(() {
  //             data = dataTemporal;
  //           });
  //         } else {
  //           if (option.isEmpty) {
  //             var dataTemp = data
  //                 .where((objeto) =>
  //                     objeto['attributes']['Marca_Tiempo_Envio']
  //                         .toString()
  //                         .split(" ")[0]
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['NumeroOrden']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['CiudadShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['NombreShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['DireccionShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['TelefonoShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Cantidad_Total']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['ProductoP']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['ProductoExtra']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['PrecioTotal']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Observacion'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Comentario'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Fecha_Entrega'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Marca_T_D'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Marca_T_D_T'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Estado_Devolucion'].toString().toLowerCase().contains(value.toLowerCase()) ||
  //                     objeto['attributes']['Marca_T_D_L'].toString().toLowerCase().contains(value.toLowerCase()))
  //                 .toList();
  //             setState(() {
  //               data = dataTemp;
  //             });
  //           } else {
  //             switch (option) {
  //               case "Fecha":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']
  //                             ['Marca_Tiempo_Envio']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Código":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['NumeroOrden']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Ciudad":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['CiudadShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Nombre Cliente":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['NombreShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Dirección":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']
  //                             ['DireccionShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Teléfono Cliente":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']
  //                             ['TelefonoShipping']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Cantidad":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['Cantidad_Total']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Producto":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['ProductoP']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Producto Extra":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['ProductoExtra']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Precio Total":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['PrecioTotal']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Observación":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['Observacion']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Comentario":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['Comentario']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Status":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['Status']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               case "Fecha Entrega":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']['Fecha_Entrega']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;

  //               case "Devolución":
  //                 var dataTemp = data
  //                     .where((objeto) => objeto['attributes']
  //                             ['Estado_Devolucion']
  //                         .toString()
  //                         .toLowerCase()
  //                         .contains(value.toLowerCase()))
  //                     .toList();
  //                 setState(() {
  //                   data = dataTemp;
  //                 });
  //                 break;
  //               default:
  //             }
  //           }
  //         }
  //         Navigator.pop(context);

  //         // loadData();
  //       },
  //       onChanged: (value) {},
  //       style: TextStyle(fontWeight: FontWeight.bold),
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(Icons.search),
  //         suffixIcon: _controllers.searchController.text.isNotEmpty
  //             ? GestureDetector(
  //                 onTap: () {
  //                   getLoadingModal(context, false);
  //                   setState(() {
  //                     _controllers.searchController.clear();
  //                   });
  //                   setState(() {
  //                     data = dataTemporal;
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //                 child: Icon(Icons.close))
  //             : null,
  //         hintText: text,
  //         enabledBorder: OutlineInputBorder(
  //           borderSide:
  //               BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide:
  //               BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         focusColor: Colors.black,
  //         iconColor: Colors.black,
  //       ),
  //     ),
  //   );
  // }

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
}
