import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_transactions_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/transactions/controllers/transactions_controller.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:intl/intl.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  TextEditingController _search = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;

  List populate = ["pedido"];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [];
  var sortFieldDefaultValue = "id:DESC";

  late TransactionsController _transactionsController;
  List<ProviderTransactionsModel> transactions = [];

  List data = [];
  int total = 0;

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
        sharedPrefs!.getString("idProvider"),
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
    setState(() {
      isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    transactions = await _getProviderTransactionsModelData();

    var response = await _transactionsController.loadTransactionsByProvider(
        sharedPrefs!.getString("idProvider"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      Expanded(
                        child: DataTable2(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
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
                          dataRowColor:
                              MaterialStateColor.resolveWith((states) {
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          columns: [
                            const DataColumn2(
                              label: Text('Fecha Envio'), //check
                              size: ColumnSize.S,
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
                              label: const Text('Valor Anterior'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("cantidad_total", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Valor Actual'),
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
                                  Text(data[index]['pedido']
                                                  ['marca_tiempo_envio']
                                              .toString() ==
                                          "null"
                                      ? ""
                                      : data[index]['pedido']
                                              ['marca_tiempo_envio']
                                          .toString()),
                                ),
                                DataCell(
                                  Text(
                                    (data[index]['pedido']['fecha_entrega']
                                                .toString() ==
                                            "null"
                                        ? ""
                                        : data[index]['pedido']['fecha_entrega']
                                            .toString()),
                                  ),
                                ),
                                DataCell(
                                  Text(data[index]['transaction_type']
                                      .toString()),
                                  // Text("Tipo"),
                                ),
                                DataCell(
                                  Text(
                                      '${data[index]['pedido']['name_comercial'] ?? "NaN"}-${data[index]['pedido']['numero_orden'].toString()}'),
                                ),
                                DataCell(
                                  // Text(data[index]['product_id'].toString()),
                                  Text(data[index]['pedido']['cantidad_total']),
                                ),
                                DataCell(
                                  Text(data[index]['comment'].toString()),
                                ),
                                DataCell(
                                  Text(data[index]['amount'].toString()),
                                ),
                                DataCell(
                                  // Text(data[index]['product_id'].toString()),
                                  Text(""),
                                ),
                                DataCell(
                                  Text(
                                      data[index]['previous_value'].toString()),
                                ),
                                DataCell(
                                  Text(data[index]['current_value'].toString()),
                                ),
                                DataCell(
                                  Text(data[index]['pedido']['status']
                                      .toString()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -7);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
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
            child: Withdrawal(),
          ),
        );
      },
    ).then((value) {});
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
