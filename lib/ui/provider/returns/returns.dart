import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/ui/provider/returns/scanner_service.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/scanner_printed_devoluciones.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../widgets/sellers/add_order.dart';

class Returns extends StatefulWidget {
  const Returns({super.key});

  @override
  State<Returns> createState() => _ReturnsState();
}

class _ReturnsState extends State<Returns> {
  List data = [];
  List optionsCheckBox = [];
  int counterChecks = 0;
  bool sort = false;
  List dataTemporal = [];
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  // int total = 0;
  String pedido = '';
  bool enabledBusqueda = true;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController(text: "");

  NumberPaginatorController paginatorController = NumberPaginatorController();

  TextEditingController transportadorasController =
      TextEditingController(text: "TODO");
  TextEditingController operadorController =
      TextEditingController(text: "TODO");
  TextEditingController statusController = TextEditingController(text: "TODO");
  TextEditingController estadoDevolucionController =
      TextEditingController(text: "TODO");

  String sortFieldDefaultValue = "id:DESC";
  List<String> carrierToSelect = ['TODO', 'LOGEC', 'GTM'];
  List<String> listOperators = ['TODO'];
  List<String> listStatus = [
    'TODO',
    'NOVEDAD',
    'NO ENTREGADO',
  ];

  List<String> listEstadoDevolucion = [
    'TODO',
    'PENDIENTE',
    'ENTREGADO EN OFICINA',
    'DEVOLUCION EN RUTA',
    'EN BODEGA PROVEEDOR',
    'EN BODEGA',
  ];

  bool changevalue = false;
  List populate = [
    "vendor",
    "transportadora",
    "receivedBy",
    "pedidoCarrierSimple",
    "product_s.warehouses.provider",
    // "users.vendedores",
    // "operadore.up_users",
    // "ruta",
    // "subRuta",
    // "novedades",
  ];

  List filtersOrCont = [
    'name_comercial',
    'numero_orden',
    'marca_tiempo_envio',
    'direccion_shipping',
    'cantidad_total',
    'precio_total',
    'producto_p',
    'ciudad_shipping',
    'status',
    'comentario',
    'fecha_entrega',
    'nombre_shipping',
    'telefono_shipping',
    'estado_devolucion',
    'marca_t_d',
    'marca_t_d_t',
    'marca_t_d_l'
  ];

  List arrayFiltersDefaultOr = [
    {
      "status": ["NOVEDAD", "NO ENTREGADO"]
    }
  ];
  List arrayFiltersNotEq = [];

  List arrayfiltersDefaultAnd = [
    {
      'product_s.warehouses.provider_id':
          sharedPrefs!.getString("idProvider").toString(),
    },
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "ENVIADO"},
  ];
  List arrayFiltersAnd = [];

  int provType = 0;
  String idUser = sharedPrefs!.getString("id").toString();
  String idProv = sharedPrefs!.getString("idProvider").toString();
  String idProvUser = sharedPrefs!.getString("idProviderUserMaster").toString();

  int total = 0;

  bool isFirst = true;
  List relationsToInclude = [];
  List relationsToExclude = [];

  List ordersScaned = [];

  @override
  void didChangeDependencies() {
    if (idProvUser == idUser) {
      provType = 1; //prov principal
    } else if (idProvUser != idUser) {
      provType = 2; //sub principal
    }

    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (provType == 2) {
        arrayFiltersAnd.add({"product_s.warehouses.up_users.id_user": idUser});
        print("is sub_provProv");
      }

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
        populate,
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        searchController.text,
        arrayFiltersNotEq,
        sortFieldDefaultValue.toString(),
        relationsToInclude,
        relationsToExclude,
      );

      data = responseLaravel['data'];
      // print(data[0]);

      setState(() {
        pageCount = responseLaravel['last_page'];
        // if (sortFieldDefaultValue.toString() == "id:DESC") {
        //   total = responseLaravel['total'];
        // }

        total = responseLaravel['total'];
      });

/*
    if (listTransportadoras.length == 1) {
      var responseTransportadoras = await Connections().getTransportadoras();
      List<dynamic> transportadorasList =
          responseTransportadoras['transportadoras'];
      for (var transportadora in transportadorasList) {
        listTransportadoras.add(transportadora);
      }
    }

    if (listOperators.length == 1) {
      var responseOpertators = await Connections().getOperatorsAvailables();
      List<dynamic> operadoresList = responseOpertators;
      for (var operador in operadoresList) {
        listOperators.add(operador);
      }
    }
*/
      paginatorController.navigateToPage(0);

      isFirst = false;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  paginateData() async {
    var response = [];
    setState(() {
      isLoading = true;
      data.clear();
    });

    if (provType == 2) {
      arrayFiltersAnd.add({"product_s.warehouses.up_users.id_user": idUser});
      print("is sub_provProv");
    }

    var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
      populate,
      filtersOrCont,
      arrayFiltersDefaultOr,
      arrayfiltersDefaultAnd,
      arrayFiltersAnd,
      currentPage,
      pageSize,
      searchController.text,
      arrayFiltersNotEq,
      sortFieldDefaultValue.toString(),
      relationsToInclude,
      relationsToExclude,
    );
    data = responseLaravel['data'];

    pageCount = responseLaravel['last_page'];
    total = responseLaravel['total'];

    setState(() {
      isLoading = false;
    });

    setState(() {});
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  void resetFilters() {
    getOldValue(true);

    transportadorasController.text = 'TODO';
    operadorController.text = 'TODO';
    statusController.text = "TODO";
    estadoDevolucionController.text = "TODO";
    arrayFiltersAnd = [];
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        isLoading: isLoading,
        content: Scaffold(
          body: Container(
              width: double.infinity,
              height: double.infinity,
              child: responsive(
                  webContainer(context), phoneContainer(context), context)),
        ));
  }

  Stack webContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: ColorsSystem().colorInitialContainer,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: ColorsSystem().colorSection,
              ),
            ),
          ],
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devoluciones',
                              style: TextStylesSystem().ralewayStyle(28,
                                  FontWeight.w700, ColorsSystem().colorStore),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: Row(
                          children: [
                            Expanded(
                              child: _modelTextField(
                                  text: "Busqueda",
                                  controller: searchController),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: idUser == "431" || idUser == "350",
                        child: ElevatedButton(
                          onPressed: () async {
                            // await showDialog(
                            //   context: context,
                            //   builder: (context) {
                            //     return const ScannerPrintedDevoluciones();
                            //   },
                            // );
                            // await loadData();
                            // showInfoScan(context);

                            await showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Evita que se cierre al hacer clic fuera
                              builder: (context) {
                                return const ScannerService(
                                  from: "provider",
                                  // onClose: loadData(),
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              ColorsSystem().colorStore,
                            ),
                          ),
                          child: const Text(
                            "SCANNER",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: Text(
                          "Registros: \n${total.toString()}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsSystem().colorStore,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: NumberPaginator(
                      config: NumberPaginatorUIConfig(
                        buttonShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      controller: paginatorController,
                      numberPages: pageCount > 0 ? pageCount : 1,
                      initialPage: 0,
                      onPageChange: (index) async {
                        setState(() {
                          currentPage = index + 1;
                        });
                        if (!isLoading) {
                          await paginateData();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: DataTable2(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  dataRowColor: MaterialStateColor.resolveWith((states) {
                    return Colors.white;
                  }),
                  dividerThickness: 1,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(color: Colors.black),
                  columnSpacing: 12,
                  headingRowHeight: 80,
                  horizontalMargin: 32,
                  minWidth: 2600,
                  dataRowHeight: 70,
                  columns: getColumns(),
                  rows: buildDataRows(data),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Stack phoneContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: ColorsSystem().colorInitialContainer,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: ColorsSystem().colorSection,
            ),
          ),
        ],
      ),
      Positioned(
        top: 8,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            //
          ],
        ),
      )
    ]);
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text(''),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text(
          'Código',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Nombre Cliente',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc("nombre_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Cantidad',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc("cantidad_total", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Producto',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("producto_p", changevalue);
        },
      ),
      /*
      DataColumn2(
        label: Text(
          'Producto Extra',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("producto_extra", changevalue);
        },
      ),
      */
      DataColumn2(
        label: SelectFilter(
          'Transportadora',
          'carrier',
          transportadorasController,
          carrierToSelect,
        ),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'Ciudad',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: SelectFilterStatus(
            'Estado de entrega', 'status', statusController, listStatus),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("status", changevalue);
        },
      ),
      DataColumn2(
        label: SelectFilterStatus('Estado Devolución', 'estado_devolucion',
            estadoDevolucionController, listEstadoDevolucion),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("estado_devolucion", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Dev. Oficina',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("marca_t_d", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Dev. En Ruta',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("marca_t_d_t", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Dev. Bodega',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc("marca_t_d_l", changevalue);
        },
      ),
      DataColumn2(
        label: Text(
          'Recibido por',
          style: TextStylesSystem()
              .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels),
        ),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          // sortFunc("received_by");
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    data;

    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            ElevatedButton(
              onPressed: data[index]['estado_devolucion'].toString() ==
                      "EN BODEGA"
                  ? null
                  : () {
                      AwesomeDialog(
                        width: 500,
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: '¿Estás seguro de marcar el pedido en BODEGA?',
                        desc: '',
                        btnOkText: "Confirmar",
                        btnCancelText: "Cancelar",
                        btnOkColor: Colors.blueAccent,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          getLoadingModal(context, false);

                          bool ready = true;
                          String message = "";
                          var productS = data[index]['product_s'];

                          var warehouses = productS['warehouses'];
                          // print(warehouses);
                          var ultimoWarehouse =
                              warehouses.last; // Obtener el último almacén
                          var branchName = ultimoWarehouse['branch_name'];

                          var providerId = ultimoWarehouse['provider_id'];

                          List<dynamic> upUsers = ultimoWarehouse['up_users'];

                          List<int> userIds = [];

                          for (var user in upUsers) {
                            userIds.add(user['id_user']);
                          }

                          // print('providerId: $providerId');
                          // print('User IDs: $userIds');

                          //control de que si pertenezca al provider principal
                          if (int.parse(idProv.toString()) !=
                              int.parse(providerId.toString())) {
                            //
                            ready = false;
                            message =
                                "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                          } else {
                            if (provType == 2) {
                              // print("is sub_provProv");

                              if (userIds
                                  .contains(int.parse(idUser.toString()))) {
                                // print("realizar transaccion");
                                //
                              } else {
                                ready = false;
                                // print("NOOO tiene permitido admin el producto");
                                message =
                                    "Error, Este producto no se encuentra en esta bodega. Ubicación actual: $branchName";
                              }
                            }
                          }

                          if (ready) {
                            // print("realizar transaccion");
                            paymentLogisticInWarehouse(
                                data[index]['id'].toString());
                          } else {
                            Navigator.pop(context);

                            showSuccessModal(
                                context, message, Icons8.warning_1);
                          }
                        },
                      ).show();
                    },
              style: ButtonStyle(
                backgroundColor:
                    data[index]['estado_devolucion'].toString() == "EN BODEGA"
                        ? MaterialStateProperty.all(
                            Colors.grey[100],
                          )
                        : MaterialStateProperty.all(
                            ColorsSystem().colorStore,
                          ),
              ),
              child: const Text(
                "Devolver",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              "${data[index]['vendor']['nombre_comercial']}-${data[index]['numero_orden']}\n${data[index]["pedido_carrier_simple"].isNotEmpty ? data[index]["pedido_carrier_simple"][0]["external_id"].toString() : ""}",
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['nombre_shipping'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Center(
              child: Text(
                data[index]['cantidad_total'].toString(),
              ),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['producto_p'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          /*
          DataCell(
            Text(
              data[index]['producto_extra'] == null ||
                      data[index]['producto_extra'].toString() == "null"
                  ? ""
                  : data[index]['producto_extra'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          */
          DataCell(
            Text(
              data[index]['transportadora'] != null &&
                      data[index]['transportadora'].isNotEmpty
                  // ? data[index]['transportadora'][0]['nombre'].toString()
                  ? "Logec"
                  : data[index]['pedido_carrier_simple'].isNotEmpty
                      ? data[index]['pedido_carrier_simple'][0]
                              ['carrier_simple']['name']
                          .toString()
                      : "",
            ),
          ),
          DataCell(
            Text(
              data[index]['ciudad_shipping'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['status'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['estado_devolucion'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['marca_t_d'] == null
                  ? ""
                  : data[index]['marca_t_d'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['marca_t_d_t'] == null
                  ? ""
                  : data[index]['marca_t_d_t'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['marca_t_d_l'] == null
                  ? ""
                  : data[index]['marca_t_d_l'].toString(),
            ),
            onTap: () {
              getInfoModal(index);
            },
          ),
          DataCell(
            Text(
              data[index]['received_by'] != null &&
                      data[index]['received_by'].isNotEmpty
                  ? "${data[index]['received_by']['username'].toString()}-${data[index]['received_by']['id'].toString()}"
                  : '',
            ),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Future<void> paymentLogisticInWarehouse(
    id,
  ) async {
    var resNovelty = await Connections().paymentLogisticInWarehouse(id, "", "");

    dialogNovedad(resNovelty);
  }

  Future<void> dialogNovedad(resNovelty) async {
    if (resNovelty == 1 || resNovelty == 2) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error al modificar estado',
        desc: 'No se pudo cambiar a EN BODEGA',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 255, 59, 59)),
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          // Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Se ha modificado exitosamente',
        desc: resNovelty['res'],
        descTextStyle:
            const TextStyle(color: Color.fromARGB(255, 255, 235, 59)),
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          Navigator.pop(context);

          await loadData();
        },
      ).show();
    }
  }

  getInfoModal(index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
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
                            child: const Icon(Icons.close)),
                      )
                    ],
                  ),
                  _model(
                      "Código: ${data[index]['vendor']['nombre_comercial']}-${data[index]['numero_orden']}\n${data[index]["pedido_carrier_simple"].isNotEmpty ? data[index]["pedido_carrier_simple"][0]["external_id"].toString() : ""}"),
                  _model("Fecha de Entrega: ${data[index]['fecha_entrega']}"),
                  _model(
                      "Marca de Tiempo Envio: ${data[index]['marca_tiempo_envio']}"),
                  _model("Dirección: ${data[index]['direccion_shipping']}"),
                  _model("Cantidad: ${data[index]['cantidad_total']}"),
                  _model("Precio Total: ${data[index]['precio_total']}"),
                  _model("Producto: ${data[index]['producto_p']}"),
                  _model(
                      "Producto Extra: ${data[index]['producto_extra'] == null || data[index]['producto_extra'].toString() == "null" ? "" : data[index]['producto_extra'].toString()}"),
                  _model("Ciudad: ${data[index]['ciudad_shipping']}"),
                  _model("Status: ${data[index]['status']}"),
                  _model(
                      "Comentario: ${data[index]['comentario'] == null || data[index]['comentario'] == "null" ? "" : data[index]['comentario'].toString()}"),
                  _model("Nombre Cliente: ${data[index]['nombre_shipping']}"),
                  _model("Teléfono: ${data[index]['telefono_shipping']}"),
                  _model(
                      "Estado Devolución: ${data[index]['estado_devolucion']}"),
                  _model(
                      "Marca. O: ${data[index]['marca_t_d'] == null ? "" : data[index]['marca_t_d'].toString()}"),
                  _model(
                      "Marca. TR: ${data[index]['marca_t_d_t'] == null ? "" : data[index]['marca_t_d_t'].toString()}"),
                  _model(
                      "Marca. TL: ${data[index]['marca_t_d_l'] == null ? "" : data[index]['marca_t_d_l'].toString()}")
                ],
              ),
            ),
          );
        });
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

                  if (filter != "carrier") {
                    arrayFiltersAnd
                        .removeWhere((element) => element.containsKey(filter));

                    if (newValue != 'TODO') {
                      arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                    }
                  } else {
                    // print(newValue);
                    arrayFiltersAnd.removeWhere((element) =>
                        element.containsKey('pedido_carrier.carrier_id'));
                    relationsToInclude = [];
                    relationsToExclude = [];

                    if (newValue != 'TODO') {
                      if (newValue == "LOGEC") {
                        relationsToInclude = ['transportadora'];
                        relationsToExclude = ['pedidoCarrier'];
                        //
                      } else if (newValue == "GTM") {
                        arrayFiltersAnd.add(
                          {
                            "pedidoCarrierSimple.carrier_id": "1",
                          },
                        );
                      }
                    }
                  }

                  paginateData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split("-")[0],
                      style: const TextStyle(fontSize: 15)),
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

  Column SelectFilterStatus(String title, filter,
      TextEditingController controller, List<String> listOptions) {
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

                  paginateData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Container _buttons() {
    return Container(
      margin: const EdgeInsets.all(5.0),
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
              child: const Text(
                "No Desea",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(width: 20),
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

                if (mounted) {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return RoutesModal(
                            idOrder: optionsCheckBox,
                            someOrders: true,
                            phoneClient: "",
                            codigo: "");
                      });
                }
                setState(() {});
                loadData();
              },
              child: const Text(
                "Confirmar",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(width: 20),
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
            searchController.text = value;
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
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      searchController.clear();
                      arrayFiltersAnd = [];
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

  sortFunc(filtro, changevalu) {
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
/*
  Future<dynamic> showInfoScan(BuildContext context) {
    ordersScaned = [];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(3),
          content: SizedBox(
            width: MediaQuery.of(context).size.width > 930
                ? MediaQuery.of(context).size.width * 0.7
                : MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.70,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return _scanOrders(setState);
              },
            ),
          ),
        );
      },
    );
  }

  Container _scanOrders(StateSetter setState) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.6,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, color: Colors.red),
              )
            ],
          ),
          const Center(
            child: Text(
              "Pedidos Scaneados",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _btnScanner(context, setState),
            ],
          ),
          const SizedBox(height: 20.0),
          Container(
            height: height * 0.45,
            width: width * 0.65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.deepPurple[100],
            ),
            child: DataTable2(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              dataRowColor: MaterialStateColor.resolveWith((states) {
                return Colors.white;
              }),
              dividerThickness: 1,
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              dataTextStyle: const TextStyle(color: Colors.black),
              columnSpacing: 12,
              headingRowHeight: 40,
              horizontalMargin: 32,
              minWidth: 100,
              dataRowHeight: 70,
              columns: const [
                DataColumn2(label: Text(""), fixedWidth: 40),
                // DataColumn2(label: Text("ID"), fixedWidth: 100),
                DataColumn2(
                  label: Text("Código"),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text("Producto"),
                  size: ColumnSize.M,
                ),
                DataColumn2(label: Text("Cantidad"), fixedWidth: 60),
                DataColumn2(
                  label: Text("Estado Dev."),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text("Recibido por"),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text("Observación"),
                  size: ColumnSize.L,
                ),
              ],
              rows: List<DataRow>.generate(
                ordersScaned.length,
                (index) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (index + 1).toString(),
                        ),
                      ),
                      // DataCell(
                      //   Text(
                      //     ordersScaned[index]['id'].toString(),
                      //     style: TextStyle(
                      //       color: !ordersScaned[index]['status']
                      //           ? Colors.red
                      //           : Colors.black,
                      //     ),
                      //   ),
                      // ),
                      DataCell(
                        Text(
                          ordersScaned[index]['code'].toString(),
                          style: TextStyle(
                            color: !ordersScaned[index]['status']
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(Text(ordersScaned[index]['product'].toString())),
                      DataCell(
                          Text(ordersScaned[index]['quantity'].toString())),
                      DataCell(Text(
                          ordersScaned[index]['status_return'].toString())),
                      DataCell(
                          Text(ordersScaned[index]['received_by'].toString())),
                      DataCell(Text(ordersScaned[index]['detail'].toString())),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  getLoadingModal(context, false);

                  List<Map<String, dynamic>> ordersRespuestas = [];

                  for (var order in ordersScaned) {
                    if (order['status'] == true) {
                      print("Actualizar estado");

                      var resNovelty = await Connections()
                          .paymentLogisticInWarehouse(order['id'], "", "");

                      if (resNovelty == 1 || resNovelty == 2) {
                        ordersRespuestas.add({
                          "id": order['id'],
                          "code": order['code'],
                          "status": "Error al cambiar estado a EN BODEGA"
                        });
                      } else {
                        ordersRespuestas.add({
                          "id": order['id'],
                          "code": order['code'],
                          "status": resNovelty["res"],
                        });
                      }
                    }
                  }

                  if (ordersRespuestas.isEmpty) {
                    Navigator.pop(context);
                  }

                  if (ordersRespuestas.isNotEmpty) {
                    print(ordersRespuestas);

                    List<String> descriptions = [];
                    for (var order in ordersRespuestas) {
                      descriptions.add("${order['code']}: ${order['status']}");
                    }
                    String desc = descriptions.join('\n');

                    if (mounted) {
                      AwesomeDialog(
                        width: 650,
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Estado de solicitudes',
                        desc: desc,
                        btnOkText: "Aceptar",
                        btnOkColor: Colors.green,
                        // btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          //
                          Navigator.pop(context);

                          Navigator.pop(context);
                          loadData();
                        },
                      ).show();
                    }
                  }
                  //
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.green,
                  ),
                ),
                child: const Text(
                  "Cambiar a EN BODEGA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ElevatedButton _btnScanner(BuildContext context, StateSetter setState) {
    return ElevatedButton(
      onPressed: () async {
        final scanResult = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (_) => const ScannerService(
            from: "provider",
          ),
        );

        if (scanResult != null) {
          bool exists =
              ordersScaned.any((order) => order['id'] == scanResult['id']);

          setState(() {
            ordersScaned.add(scanResult);
          });

          // if (!exists) {
          //   setState(() {
          //     ordersScaned.add(scanResult);
          //   });
          // } else {
          //   print("El ID ya existe en la lista.");
          // }
        }

        // print(ordersScaned.toString());
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          ColorsSystem().colorStore,
        ),
      ),
      child: const Text(
        "SCANNER",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
*/
  //
}
