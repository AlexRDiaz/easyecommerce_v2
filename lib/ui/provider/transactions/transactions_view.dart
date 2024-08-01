import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_transactions_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/transactions/controllers/transactions_controller.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:get/get.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  TextEditingController _search = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 100;
  int pageCount = 0;
  bool isLoading = false;
  bool isFirst = false;
  String saldo = '0';

  List populate = ["pedido", "orden_retiro"];
  List arrayFiltersAnd = [
    {
      'equals/provider_id': sharedPrefs!.getString("idProvider"),
    }
  ];
  List arrayFiltersOr = [
    "transaction_type",
    "origin_code",
    "comment",
    "description",
    "sku_product_reference"
  ];
  var sortFieldDefaultValue = "id:DESC";

  late TransactionsController _transactionsController;
  List<ProviderTransactionsModel> transactions = [];

  List data = [];
  int total = 0;

  List<String> listOrigen = [
    'TODO',
    'PAGO PRODUCTO',
    'RETIRO',
    'RESTAURACION',
  ];

  List<String> listTipo = [
    'TODO',
    'CREDIT',
    'DEBIT',
  ];

  final _startDateController = TextEditingController(text: "2023-01-01");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");

  String? selectedValueOrigen;
  String? selectedValueTipo;

  String retiro = '0';

  @override
  void initState() {
    data = [];
    _transactionsController = TransactionsController();

    loadData();
    super.initState();
  }

  Future<List<ProviderTransactionsModel>>
      _getProviderTransactionsModelData() async {
    await _transactionsController.loadTransactionsByProvider(
        _startDateController.text,
        _endDateController.text,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text);
    return _transactionsController.transactions;
  }

  loadData() async {
    // try {
    // print("idProvider: ${sharedPrefs!.getString("idProvider")}");
    // print(
    //     "idProviderUserMaster: ${sharedPrefs!.getString("idProviderUserMaster")}");

    getSaldo();
    getTotalRetiros();
    setState(() {
      isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    transactions = await _getProviderTransactionsModelData();

    var response = await _transactionsController.loadTransactionsByProvider(
        _startDateController.text,
        _endDateController.text,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text);

    data = response['data'];
    // print(data);
    total = response['total'];
    pageCount = response['last_page'];

    paginatorController.navigateToPage(0);
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    // print("datos cargados correctamente");
    setState(() {
      isFirst = false;
      isLoading = false;
    });
  }

  paginateData() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var response = await _transactionsController.loadTransactionsByProvider(
          _startDateController.text,
          _endDateController.text,
          populate,
          pageSize,
          currentPage,
          arrayFiltersOr,
          arrayFiltersAnd,
          sortFieldDefaultValue.toString(),
          _search.text);

      setState(() {
        data = response['data'];
        pageCount = response['last_page'];
        total = response['total'];
      });

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      // print("datos paginados");
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  getSaldo() async {
    var response = await Connections().getSaldoProvider(
        sharedPrefs!.getString("idProviderUserMaster").toString());
    setState(() {
      saldo = response;
    });
  }

  getTotalRetiros() async {
    var response = await Connections()
        .getTotalRetiros(sharedPrefs!.getString("idProvider").toString());
    setState(() {
      retiro = response.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(6.0),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Container(
                  //     width: MediaQuery.of(context).size.width * 0.5,
                  //     child: numberPaginator()),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  ElevatedButton(
                    onPressed: () {
                      withdrawalInputDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF274965),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Solicitar Retiro",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              responsive(
                  webMainContainer(screenWidth, screenHeight, context),
                  mobileMainContainer(screenWidth, screenHeight, context),
                  context),
              // Container(
              //   width: double.infinity,
              //   color: Colors.white,
              //   padding: const EdgeInsets.all(5),
              //   child: Row(
              //     children: [
              //       // Expanded(
              //       //   child: _modelTextField(
              //       //       text: "Busqueda", controller: _search),
              //       // ),
              //       Expanded(
              //         child: Row(
              //           children: [
              //             const SizedBox(width: 20),
              //             const SizedBox(width: 30),
              //             Expanded(child: numberPaginator()),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              /*
              const SizedBox(height: 10),
              Expanded(
                child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.blueGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // dataRowHeight: 120,
                  dividerThickness: 1,
                  dataRowColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                    } else if (states.contains(MaterialState.hovered)) {
                      return const Color.fromARGB(255, 234, 241, 251);
                    }
                    return const Color.fromARGB(0, 255, 255, 255);
                  }),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(
                      fontSize: 12,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  columns: [
                    const DataColumn2(
                      label: Text('Id Origen'), //check
                      size: ColumnSize.S,
                    ),
                    const DataColumn2(
                      label: Text('Fecha Envio'), //check
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: const Text('Fecha Entrega'), //img
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("marca_t_i", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Tipo'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("numero_orden", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Codigo'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("ciudad_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Cantidad'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("nombre_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Producto'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("direccion_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Valor'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("telefonoS_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Descripcion'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("telefonoS_shipping", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('V. Anterior'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("cantidad_total", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('V. Actual'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("producto_p", changevalue);
                      },
                    ),
                    DataColumn2(
                      label: const Text('Estado'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        // sortFunc3("producto_extra", changevalue);
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    data.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(
                          Text(data[index]['origin_id'] == null
                              ? ""
                              : data[index]['origin_id'].toString()),
                        ),
                        // DataCell(
                        //   // data[index]['pedido'] == null ||
                        //   //         data[index]['pedido']
                        //   //                 ['marca_tiempo_envio'] ==
                        //   //             null
                        //   //     ?
                        //   // ()
                        //   Text(data[index]['pedido']
                        //               ['marca_tiempo_envio']
                        //           .toString()) ,
                        // // ),
                        DataCell(
                          data[index]['orden_retiro'] != null
                              ? Text(UIUtils.formatDate(data[index]
                                      ['orden_retiro']['createdAt']
                                  .toString())) // Si orden_retiro no es null
                              : Text(data[index]['pedido'] == null
                                  ? ""
                                  : data[index]['pedido']['marca_tiempo_envio']
                                      .toString()), // Si orden_retiro es null
                        ),
                        DataCell(
                          data[index]['orden_retiro'] != null
                              ? Text(data[index]['orden_retiro']
                                      ['fechaTransferencia']
                                  .toString()) // Si orden_retiro no es null
                              : Text(data[index]['pedido'] == null
                                  ? ""
                                  : data[index]['pedido']['fecha_entrega']
                                      .toString()), // Si orden_retiro es null
                        ),

                        // DataCell(
                        //   Text(data[index]['pedido'] == null ||
                        //           data[index]['pedido']
                        //                   ['fecha_entrega'] ==
                        //               null
                        //       ? ""
                        //       : data[index]['pedido']['fecha_entrega']
                        //           .toString()),
                        // ),
                        DataCell(
                          Text(data[index]['transaction_type'].toString()),
                          // Text("Tipo"),
                        ),
                        DataCell(
                          Text(
                              "${data[index]['origin_code']}"), // Si orden_retiro es null
                        ),
                        // DataCell(
                        //   Text(
                        //       '${data[index]['pedido'] == null ? "" : data[index]['pedido']['name_comercial'] ?? "NaN"}-${data[index]['pedido'] == null ? "" : data[index]['pedido']['numero_orden'].toString()}'),
                        // ),
                        DataCell(
                            // data[index]['originCode']
                            //             .toString()
                            //             .split("-")[0] ==
                            //         "Retiro"
                            //     ? Text("hola")
                            //     : Text(data[index]['pedido']
                            //             ['cantidad_total']
                            //         .toString()),
                            // Text(data[index]['originCode']
                            //             .toString()
                            //             .split("-")[0])
                            Text(
                                "${data[index]['origin_code'].toString().split('-')[0] == "Retiro" || data[index]['origin_code'].toString().split('-')[0] == "reembolso" ? 0 : data[index]['pedido']['cantidad_total'].toString()} ")),
                        DataCell(
                          Text(data[index]['comment'].toString()),
                        ),
                        DataCell(data[index]['transaction_type'].toString() ==
                                    "Retiro" ||
                                data[index]['transaction_type'].toString() ==
                                    "Restauracion"
                            ? Row(
                                children: [
                                  Icon(Icons.remove,
                                      color: Colors.red, size: 12),
                                  Text(data[index]['amount'].toString()),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.green, size: 12),
                                  Text(data[index]['amount'].toString()),
                                ],
                              )),
                        DataCell(
                          Text(data[index]['description'] == null
                              ? ""
                              : data[index]['description'].toString()),
                          // Text(""),
                        ),
                        DataCell(
                          Text(data[index]['previous_value'].toString()),
                        ),
                        DataCell(
                          Text(data[index]['current_value'].toString()),
                        ),
                        DataCell(
                          Text(data[index]['status'] == null
                              ? ""
                              : data[index]['status'].toString()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            */
            ],
          ),
        ),
      ),
    );
  }

  Container _leftWidgetWeb(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.17,
      padding: EdgeInsets.only(left: 5, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${formatNumber(double.parse(saldo))}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Text(
                  'Saldo de Cuenta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${formatNumber(double.parse(retiro))}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Text(
                  'Total de Retiros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _dateButtons(width, context),
        const SizedBox(height: 20),
        _optionButtons(width, heigth),
      ]),
    );
  }

  String formatNumber(double number) {
    var formatter =
        NumberFormat('###,###.##', 'es'); // 'es' para formato en español
    return formatter.format(number);
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftWidgetWeb(width, heigth, context),
        Expanded(
          child: Column(
            children: [
              _searchBar(width, heigth, context),
              SizedBox(height: 10),
              _dataTableTransactions(heigth),
            ],
          ),
        ),
      ],
    );
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
                width: MediaQuery.of(context).size.width * 0.25,
                child: _modelTextField(text: "Buscar", controller: _search),
              ),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 5),
                child: Text(
                  "Registros: $total",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Spacer(),
              Container(width: width * 0.25, child: numberPaginator()),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: _modelTextField(text: "Buscar", controller: _search),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, right: 5),
                        width: width * 0.4,
                        child: Text(
                          "Registros: $total",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                          width: width * 0.6, child: numberPaginator()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          context),
    );
  }

  mobileMainContainer(double width, double heigth, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // _leftWidgetMobile(width, heigth, context),
          Divider(),
          // _searchBar(width, heigth, context),
          // _dataTableTransactionsMobile(heigth),
        ],
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
          //  paginatorController.navigateToPage(0);
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _search.clear();
                      loadData();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Container _dataTableTransactions(height) {
    return Container(
      height: height * 0.72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: data.length > 0
          ? DataTable2(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: Colors.blueGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // dataRowHeight: 120,
              dividerThickness: 1,
              dataRowColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                } else if (states.contains(MaterialState.hovered)) {
                  return const Color.fromARGB(255, 234, 241, 251);
                }
                return const Color.fromARGB(0, 255, 255, 255);
              }),
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              dataTextStyle: const TextStyle(
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black),
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1200,
              columns: getColumns(),
              rows: buildDataRows(data))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      //
      const DataColumn2(
        label: Text('Id Origen'), //check
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Fecha Envio'), //check
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: const Text('Fecha Entrega'), //img
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("marca_t_i", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Tipo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Codigo'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Cantidad'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("nombre_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Producto'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Valor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefonoS_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Descripcion'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefonoS_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('V. Anterior'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("cantidad_total", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('V. Actual'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("producto_p", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Estado'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("producto_extra", changevalue);
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          //
          DataCell(
            Text(data[index]['origin_id'] == null
                ? ""
                : data[index]['origin_id'].toString()),
          ),
          // DataCell(
          //   // data[index]['pedido'] == null ||
          //   //         data[index]['pedido']
          //   //                 ['marca_tiempo_envio'] ==
          //   //             null
          //   //     ?
          //   // ()
          //   Text(data[index]['pedido']
          //               ['marca_tiempo_envio']
          //           .toString()) ,
          // // ),
          DataCell(
            data[index]['orden_retiro'] != null
                ? Text(UIUtils.formatDate(data[index]['orden_retiro']
                        ['createdAt']
                    .toString())) // Si orden_retiro no es null
                : Text(data[index]['pedido'] == null
                    ? ""
                    : data[index]['pedido']['marca_tiempo_envio']
                        .toString()), // Si orden_retiro es null
          ),
          DataCell(
            data[index]['orden_retiro'] != null
                ? Text(data[index]['orden_retiro']['fechaTransferencia']
                    .toString()) // Si orden_retiro no es null
                : Text(data[index]['pedido'] == null
                    ? ""
                    : data[index]['pedido']['fecha_entrega']
                        .toString()), // Si orden_retiro es null
          ),

          // DataCell(
          //   Text(data[index]['pedido'] == null ||
          //           data[index]['pedido']
          //                   ['fecha_entrega'] ==
          //               null
          //       ? ""
          //       : data[index]['pedido']['fecha_entrega']
          //           .toString()),
          // ),
          DataCell(
            Text(data[index]['transaction_type'].toString()),
            // Text("Tipo"),
          ),
          DataCell(
            Text("${data[index]['origin_code']}"), // Si orden_retiro es null
          ),
          // DataCell(
          //   Text(
          //       '${data[index]['pedido'] == null ? "" : data[index]['pedido']['name_comercial'] ?? "NaN"}-${data[index]['pedido'] == null ? "" : data[index]['pedido']['numero_orden'].toString()}'),
          // ),
          DataCell(
              // data[index]['originCode']
              //             .toString()
              //             .split("-")[0] ==
              //         "Retiro"
              //     ? Text("hola")
              //     : Text(data[index]['pedido']
              //             ['cantidad_total']
              //         .toString()),
              // Text(data[index]['originCode']
              //             .toString()
              //             .split("-")[0])
              Text(
                  "${data[index]['origin_code'].toString().split('-')[0] == "Retiro" || data[index]['origin_code'].toString().split('-')[0] == "reembolso" ? 0 : data[index]['pedido']['cantidad_total'].toString()} ")),
          DataCell(
            Text(data[index]['comment'].toString()),
          ),
          DataCell(data[index]['transaction_type'].toString() == "Retiro" ||
                  data[index]['transaction_type'].toString() == "Restauracion"
              ? Row(
                  children: [
                    Icon(Icons.remove, color: Colors.red, size: 12),
                    Text(data[index]['amount'].toString()),
                  ],
                )
              : Row(
                  children: [
                    Icon(Icons.add, color: Colors.green, size: 12),
                    Text(data[index]['amount'].toString()),
                  ],
                )),
          DataCell(
            Text(data[index]['description'] == null
                ? ""
                : data[index]['description'].toString()),
            // Text(""),
          ),
          DataCell(
            Text(data[index]['previous_value'].toString()),
          ),
          DataCell(
            Text(data[index]['current_value'].toString()),
          ),
          DataCell(
            Text(data[index]['status'] == null
                ? ""
                : data[index]['status'].toString()),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Container _dateButtons(double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 5, // Radio de dispersión de la sombra
          blurRadius: 7, // Radio de desenfoque de la sombra
          offset: Offset(
              0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.2,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: width * 0.2,
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    _showDatePickerModal(context);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Ajusta el valor según sea necesario
                      ),
                    ),
                  ),
                  label: Text('Seleccionar'),
                  icon: Icon(Icons.calendar_month_outlined),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                width: width * 0.2,
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Ajusta el valor según sea necesario
                      ),
                    ),
                  ),
                  onPressed: () {
                    loadData();
                  },
                  label: Text('Consultar'),
                  icon: Icon(Icons.search),
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            child: Column(
              children: [
                _buildDateField("Fecha Inicio", _startDateController),
                SizedBox(height: 10),
                _buildDateField("Fecha Fin", _endDateController),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _showDatePickerModal(BuildContext context) {
    return openDialog(
        context,
        400,
        400,
        SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: _onSelectionChanged,
        ),
        () {});
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              child: Text(
                label + ":",
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: "2023-01-31",
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Ajusta la altura aquí
                ),
                style: TextStyle(
                  fontSize:
                      12, // Ajusta el tamaño del texto según tus necesidades
                ),
                validator: (value) {
                  // Puedes agregar validaciones adicionales según tus necesidades
                  if (value == null || value.isEmpty) {
                    return "Este campo no puede estar vacío";
                  }
                  // Aquí podrías validar el formato de la fecha
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange dateRange = args.value;

      print('Fecha de inicio: ${dateRange.startDate}');
      print('Fecha de fin: ${dateRange.endDate}');
      _startDateController.text =
          "${dateRange.startDate!.year}-${dateRange.startDate!.month}-${dateRange.startDate!.day}";
      _endDateController.text =
          "${dateRange.endDate!.year}-${dateRange.endDate!.month}-${dateRange.endDate!.day}";

      // start = dateRange.startDate.toString();
      // end = dateRange.endDate.toString();
      // if (dateRange.endDate != null) {
      //   Navigator.of(context).pop();
      //  // filterData();
      // }
    }
  }

  Container _optionButtons(double width, double height) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.3,
      height: height * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Origen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listOrigen),
                value: selectedValueOrigen,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueOrigen = value;
                  });

                  arrayFiltersAnd.removeWhere((element) =>
                      element.containsKey("equals/transaction_type"));
                  if (value != '') {
                    if (value == 'TODO') {
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/transaction_type"));
                    } else {
                      arrayFiltersAnd.add({"equals/transaction_type": value});
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 150,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listOrigen),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          /*
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Tipo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listTipo),
                value: selectedValueTipo,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueTipo = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/state"));
                  if (value != '') {
                    if (value == 'TODO') {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/state"));
                    } else {
                      arrayFiltersAnd.add({"equals/state": value});
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listTipo),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          
          Container(
            child: FilledButton.tonalIcon(
              onPressed: () {
                _showDatePickerModal(context);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        5), // Ajusta el valor según sea necesario
                  ),
                ),
              ),
              label: Text("Generar reporte"),
              icon: Icon(Icons.calendar_month_outlined),
            ),
          ),
          */
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights(array) {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (array.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  Future<dynamic> withdrawalInputDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.30,
            height: MediaQuery.of(context).size.height * 0.50,
            child: Withdrawal(saldo: saldo),
          ),
        );
      },
    ).then((value) {
      // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
      // Por ejemplo, actualizar algún estado
      // setState(() {
      //   loadData(); // Actualiza el Future
      // });
    });
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonSelectedBackgroundColor: const Color(0xFF253e55),
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
}
