import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/widgets/logistic/generate_logistic_balance.dart';
import 'package:intl/intl.dart';

class LogisticBalance extends StatefulWidget {
  const LogisticBalance({super.key});

  @override
  State<LogisticBalance> createState() => _LogisticBalanceState();
}

class _LogisticBalanceState extends State<LogisticBalance> {
  final IncomeAndExpensesControllers _controllers =
      IncomeAndExpensesControllers();

  List data = [];
  String dateDesde = "";
  List<DateTime?> _datesDesde = [];
  String dateHasta = "";
  List<DateTime?> _datesHasta = [];
  bool sort = false;
  bool datesSearch = false;
  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];

    response = await Connections().getLogisticBalance();
    setState(() {
      datesSearch = false;
    });

    data = response;
    sortFuncDate("Fecha");

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  sarchByDates() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];
    setState(() {
      datesSearch = true;
    });
    response =
        await Connections().getLogisticBalanceByDates(dateDesde, dateHasta);
    data = response;
    setState(() {
      sort = false;
    });
    sortFuncDate("Fecha");

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
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () async {
                            setState(() {});
                            var results = await showCalendarDatePicker2Dialog(
                              context: context,
                              config:
                                  CalendarDatePicker2WithActionButtonsConfig(
                                dayTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                yearTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                selectedYearTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                weekdayLabelTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              dialogSize: const Size(325, 400),
                              value: _datesDesde,
                              borderRadius: BorderRadius.circular(15),
                            );
                            setState(() {
                              if (results != null) {
                                String fechaOriginal = results![0]
                                    .toString()
                                    .split(" ")[0]
                                    .split('-')
                                    .reversed
                                    .join('-')
                                    .replaceAll("-", "/");
                                List<String> componentes =
                                    fechaOriginal.split('/');

                                String dia =
                                    int.parse(componentes[0]).toString();
                                String mes =
                                    int.parse(componentes[1]).toString();
                                String anio = componentes[2];

                                String nuevaFecha = "$dia/$mes/$anio";
                                setState(() {
                                  dateDesde = nuevaFecha;
                                });
                              }
                            });
                          },
                          child: Text(
                            "DESDE: $dateDesde",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () async {
                            setState(() {});
                            var results = await showCalendarDatePicker2Dialog(
                              context: context,
                              config:
                                  CalendarDatePicker2WithActionButtonsConfig(
                                dayTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                yearTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                selectedYearTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                weekdayLabelTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              dialogSize: const Size(325, 400),
                              value: _datesHasta,
                              borderRadius: BorderRadius.circular(15),
                            );
                            setState(() {
                              if (results != null) {
                                String fechaOriginal = results![0]
                                    .toString()
                                    .split(" ")[0]
                                    .split('-')
                                    .reversed
                                    .join('-')
                                    .replaceAll("-", "/");
                                List<String> componentes =
                                    fechaOriginal.split('/');

                                String dia =
                                    int.parse(componentes[0]).toString();
                                String mes =
                                    int.parse(componentes[1]).toString();
                                String anio = componentes[2];

                                String nuevaFecha = "$dia/$mes/$anio";
                                setState(() {
                                  dateHasta = nuevaFecha;
                                });
                              }
                            });
                          },
                          child: Text(
                            "HASTA: $dateHasta",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: dateDesde.isEmpty || dateHasta.isEmpty
                              ? null
                              : () async {
                                  await sarchByDates();
                                },
                          child: Text(
                            "BUSCAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              sort = false;
                            });
                            await loadData();
                            setState(() {
                              dateDesde = "";
                              dateHasta = "";
                            });
                          },
                          child: Text(
                            "REINICIAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return GenerateLogisticBalance();
                          });
                      setState(() {
                        sort = false;
                      });
                      await loadData();
                      setState(() {
                        dateDesde = "";
                        dateHasta = "";
                      });
                    },
                    child: Text(
                      "GENERAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 1000,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      sortFuncDate("Fecha");
                    },
                  ),
                  DataColumn2(
                    label: Text('Depositos Recibidos Transporte'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Depositos");
                    },
                  ),
                  DataColumn2(
                    label: Text('Retiro Vendedores'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Retiros");
                    },
                  ),
                  DataColumn2(
                    label: Text('Saldo a la fecha'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Saldo");
                    },
                  ),
                  DataColumn2(
                    label: Text('Ingresos'),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Ingresos");
                    },
                  ),
                  DataColumn2(
                    label: Text('Egresos'),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Egresos");
                    },
                  ),
                  DataColumn2(
                    label: Text('Utilidad total'),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("UtilidadTotal");
                    },
                  ),
                     DataColumn2(
                    label: Text(''),
                    
                  
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Fecha'].toString()
                            : data[index]['attributes']['Fecha'].toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Depositos'].toString()
                            : data[index]['attributes']['Depositos']
                                .toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Retiros'].toString()
                            : data[index]['attributes']['Retiros'].toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Saldo'].toString()
                            : data[index]['attributes']['Saldo'].toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Ingresos'].toString()
                            : data[index]['attributes']['Ingresos'].toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['Egresos'].toString()
                            : data[index]['attributes']['Egresos'].toString()),
                      ),
                      DataCell(
                        Text(datesSearch == true
                            ? data[index]['UtilidadTotal'].toString()
                            : data[index]['attributes']['UtilidadTotal']
                                .toString()),
                      ),
                      DataCell(Center(child: IconButton(onPressed: ()async{
                        getLoadingModal(context, false);
                        var response = await Connections().deleteReportLogistic(data[index]['id'].toString());
                        Navigator.pop(context);
                      await  loadData();
                          sortFuncDate("Fecha");

                    

                      },icon:Icon(Icons.delete_forever), color: Colors.redAccent,)))
                    ],
                  ),
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

  sortFuncDate(name) {
    if (datesSearch == true) {
      if (sort) {
        setState(() {
          sort = !true;
        });
        data.sort((a, b) {
          DateTime? dateA = a[name] != null && a[name].toString().isNotEmpty
              ? DateFormat("d/M/yyyy").parse(a[name].toString())
              : null;
          DateTime? dateB = b[name] != null && b[name].toString().isNotEmpty
              ? DateFormat("d/M/yyyy").parse(b[name].toString())
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
      } else {
        setState(() {
          sort = !false;
        });
        data.sort((a, b) {
          DateTime? dateA = a[name] != null && a[name].toString().isNotEmpty
              ? DateFormat("d/M/yyyy").parse(a[name].toString())
              : null;
          DateTime? dateB = b[name] != null && b[name].toString().isNotEmpty
              ? DateFormat("d/M/yyyy").parse(b[name].toString())
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
      }
    } else {
      if (sort) {
        setState(() {
          sort = !true;
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
      } else {
        setState(() {
          sort = !false;
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
      }
    }
  }

  sortFunc(name) {
    if (datesSearch == true) {
      if (sort) {
        setState(() {
          sort = false;
        });
        data.sort((a, b) => b[name].compareTo(a[name]));
      } else {
        setState(() {
          sort = true;
        });
        data.sort((a, b) => a[name].compareTo(b[name]));
      }
    } else {
      if (sort) {
        setState(() {
          sort = false;
        });
        data.sort(
            (a, b) => b['attributes'][name].compareTo(a['attributes'][name]));
      } else {
        setState(() {
          sort = true;
        });
        data.sort(
            (a, b) => a['attributes'][name].compareTo(b['attributes'][name]));
      }
    }
  }
}
