import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/controllers/controllers.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_seller.dart';
import 'package:frontend/ui/widgets/loading.dart';
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigators().pushNamed(
            context,
            '/layout/sellers/cash-withdrawal/new',
          );
        },
        backgroundColor: colors.colorGreen,
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
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
                                DataCell(Text(data[index]['fecha_transferencia']
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
                                  child: Text(
                                    "VER COMPROBANTE",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )),
                              ]))),
            ),
          ],
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

  Future<dynamic> withdrawalInputDialog(BuildContext context) {
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
                width: MediaQuery.of(context).size.width * 0.27,
                height: MediaQuery.of(context).size.height * 0.60,
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
