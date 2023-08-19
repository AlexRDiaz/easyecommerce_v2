import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controllers/controllers.dart';

class VendorWithDrawalRequest extends StatefulWidget {
  const VendorWithDrawalRequest({super.key});

  @override
  State<VendorWithDrawalRequest> createState() =>
      _VendorWithDrawalRequestState();
}

class _VendorWithDrawalRequestState extends State<VendorWithDrawalRequest> {
  final VendorWithDrawalRequestControllers _controllers =
      VendorWithDrawalRequestControllers();
  List optionsCheckBox = [];
  int counterChecks = 0;
  List data = [];
  String id = "";
  bool aprobado = true;
  bool realizado = false;
  bool rechazado = false;
  bool sort = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    response = await Connections()
        .getWithdrawalsSellersListWalletByCodeAndSearch(
            getStringCheck(), _controllers.searchController.text);
    setState(() {
      data = response;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _modelTextField(
                  text: "Búsqueda", controller: _controllers.searchController),
            ),
            SizedBox(
              height: 10,
            ),
            Wrap(
              children: [
                Container(
                  width: 150,
                  child: Row(
                    children: [
                      Checkbox(
                          value: aprobado,
                          onChanged: (value) async {
                            setState(() {
                              aprobado = true;
                              realizado = false;
                              rechazado = false;
                            });
                            await loadData();
                          }),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Aprobados")
                    ],
                  ),
                ),
                Container(
                  width: 150,
                  child: Row(
                    children: [
                      Checkbox(
                          value: realizado,
                          onChanged: (value) async {
                            setState(() {
                              aprobado = false;
                              realizado = true;
                              rechazado = false;
                            });
                            await loadData();
                          }),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Realizados")
                    ],
                  ),
                ),
                Container(
                  width: 150,
                  child: Row(
                    children: [
                      Checkbox(
                          value: rechazado,
                          onChanged: (value) async {
                            setState(() {
                              aprobado = false;
                              rechazado = true;
                              realizado = false;
                            });
                            await loadData();
                          }),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Rechazados")
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Fecha");
                    },
                  ),
                  DataColumn2(
                    label: Text('Vendedor'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Monto a Retirar'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Monto");
                    },
                  ),
                  DataColumn2(
                    label: Text('Código de Validación'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Código de Retiro'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Estado Pago'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Estado");
                    },
                  ),
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) {
                    return DataRow(
                      cells: [
                        DataCell(
                            Text(
                              data[index]['attributes']['Fecha'].toString(),
                            ), onTap: () {
                          Navigators().pushNamed(
                            context,
                            '/layout/logistic/withdrawal/details?id=${data[index]['id']}',
                          );
                        }),
                        DataCell(
                          Text(
                            data[index]['attributes']['users_permissions_user']
                                    ['data']['attributes']['username']
                                .toString(),
                          ),
                        ),
                        DataCell(
                          Text(
                            data[index]['attributes']['Monto'].toString(),
                          ),
                        ),
                        DataCell(
                          Text(
                            data[index]['attributes']['CodigoGenerado']
                                .toString(),
                          ),
                        ),
                        DataCell(
                          Text(
                            data[index]['attributes']['Codigo'].toString(),
                          ),
                        ),
                        DataCell(
                          Text(
                            data[index]['attributes']['Estado'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DataCell(
                          aprobado == false
                              ? Container()
                              : GestureDetector(
                                  onTap: () async {
                                    var response = await Connections()
                                        .deleteWithdrawal(data[index]['id']);
                                    await loadData();
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    size: 20,
                                  ),
                                ),
                        ),
                        DataCell(
                          const Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15,
                          ),
                        ),
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

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (v) async {
          await loadData();
          setState(() {});
        },
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: const Icon(Icons.close),
                )
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  getStringCheck() {
    if (aprobado == true) {
      return "APROBADO";
    }
    if (realizado == true) {
      return "REALIZADO";
    }
    if (rechazado == true) {
      return "RECHAZADO";
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
}
