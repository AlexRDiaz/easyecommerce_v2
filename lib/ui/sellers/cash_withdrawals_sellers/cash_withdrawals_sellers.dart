import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/controllers/controllers.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_info_new.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_seller.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/helpers/server.dart';

import '../../../helpers/navigators.dart';
import 'controllers/search_controller.dart';
import '../../widgets/show_error_snackbar.dart';

class CashWithdrawalsSellers extends StatefulWidget {
  const CashWithdrawalsSellers({super.key});

  @override
  State<CashWithdrawalsSellers> createState() => _CashWithdrawalsSellersState();
}

class _CashWithdrawalsSellersState extends State<CashWithdrawalsSellers> {
  SearchCashWithdrawalsSellersControllers _controllers =
      SearchCashWithdrawalsSellersControllers();
  List data = [];
  bool sort = false;
  int idUser = int.parse(sharedPrefs!.getString("id").toString());

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      var response;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      response = await Connections()
          .getWithdrawalSellers(_controllers.searchController.text);

      data = response;

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      //  Visibility later
      floatingActionButton: Visibility(
        visible: idUser == 2,
        child: FloatingActionButton(
          onPressed: () {
            withdrawalInputDialog(context);
          },
          backgroundColor: colors.colorGreen,
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigators().pushNamed(
          //   context,
          //   '/layout/sellers/cash-withdrawal/new',
          // );
          withdrawalInputDialog(context);
        },
        backgroundColor: colors.colorGreen,
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      */
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        loadData();
                      },
                      icon: const Icon(
                        Icons.autorenew_rounded,
                        size: 35,
                        color: Color(0xFF031749),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            /*
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
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
                ),
              ],
            ),
            */
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: heigth * 0.80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: data.length > 0
                        ? DataTable2(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            dataRowColor:
                                MaterialStateColor.resolveWith((states) {
                              return Colors.white;
                            }),
                            dividerThickness: 1,
                            headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            dataTextStyle: const TextStyle(color: Colors.black),
                            columnSpacing: 12,
                            headingRowHeight: 40,
                            horizontalMargin: 32,
                            minWidth: 900,
                            dataRowHeight: 45,
                            columns: getColumns(),
                            rows: buildDataRows(data),
                          )
                        // ? DataTableModelPrincipal(
                        //     columnWidth: 100,
                        //     columns: getColumns(),
                        //     rows: buildDataRows(data))
                        : const Center(
                            child: Text("Sin datos"),
                          ),
                  ),
                ],
              ),
            ),
            /*
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
                  minWidth: 1000,
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn2(
                      label: Text('Fecha'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Fecha");
                      },
                    ),
                    DataColumn2(
                      label: Text('Monto a Retirar'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Monto");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado del Pago'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha y Hora Transferencia'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("FechaTransferencia");
                      },
                    ),
                    DataColumn2(
                      label: Text('Comprobante'),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(
                              onSelectChanged: (bool? selected) {
                                Navigators().pushNamed(
                                  context,
                                  '/layout/sellers/cash-withdrawal/info?id=${data[index]['id']}',
                                );
                              },
                              cells: [
                                DataCell(
                                  Text(data[index]['fecha'].toString()),
                                ),
                                DataCell(Text(
                                    '\$${data[index]['monto'].toString()}')),
                                DataCell(
                                    Text(data[index]['estado'].toString())),
                                DataCell(Text(
                                    data[index]['fecha_transferencia'] == null
                                        ? ""
                                        : data[index]['fecha_transferencia']
                                            .toString())),
                                DataCell(TextButton(
                                  onPressed:
                                      data[index]['comprobante'].toString() !=
                                              "null"
                                          ? () {
                                              launchUrl(Uri.parse(
                                                  "$generalServer${data[index]['comprobante'].toString()}"));
                                            }
                                          : null,
                                  child: const Text(
                                    "VER COMPROBANTE",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )),
                              ]))),
            ),
          */
          ],
        ),
      ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text("Fecha"),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Monto a Retirar'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Estado del Pago'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Fecha y Hora Transferencia'),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Comprobante'),
        size: ColumnSize.M,
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
            Text(data[index]['fecha'].toString()),
            onTap: () {
              withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text('\$${data[index]['monto'].toString()}'),
            onTap: () {
              withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text(data[index]['estado'].toString()),
            onTap: () {
              withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text(data[index]['fecha_transferencia'] == null
                ? ""
                : data[index]['fecha_transferencia'].toString()),
            onTap: () {
              withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            TextButton(
              onPressed: data[index]['comprobante'].toString() != "null"
                  ? () {
                      launchUrl(Uri.parse(
                          "$generalServer${data[index]['comprobante'].toString()}"));
                    }
                  : null,
              child: const Text(
                "VER COMPROBANTE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
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

  Future<dynamic> withdrawalInputDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.27,
                height: MediaQuery.of(context).size.height * 0.45,
                child: WithdrawalSeller(),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pop(); // Cierra el modal al tocar el botón de cierre
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {});
  }

  Future<dynamic> withdrawalInfo(BuildContext context, data) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width > 600
                    ? MediaQuery.of(context).size.width * 0.65
                    : MediaQuery.of(context).size.width * 0.95,
                // screenWidth > 600 ? 16 : 12;
                height: MediaQuery.of(context).size.height * 0.80,
                child: SellerWithdrawalInfoNew(data: data),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {});
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
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
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
}
