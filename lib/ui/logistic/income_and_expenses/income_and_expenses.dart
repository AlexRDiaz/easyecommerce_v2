import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';

class IncomeAndExpenses extends StatefulWidget {
  const IncomeAndExpenses({super.key});

  @override
  State<IncomeAndExpenses> createState() => _IncomeAndExpensesState();
}

class _IncomeAndExpensesState extends State<IncomeAndExpenses> {
  final IncomeAndExpensesControllers _controllers =
      IncomeAndExpensesControllers();
  List data = [];
  bool sort = false;

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    response = await Connections()
        .getIngresosEgresos(_controllers.searchController.text);

    data = response;
    setState(() {});
    print(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigators().pushNamed(
            context,
            '/layout/logistic/income-expense/details/info',
          );
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _modelTextField(
                  text: "Búsqueda", controller: _controllers.searchController),
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
                    label: Text('Marca Tiempo'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Fecha");
                    },
                  ),
                  DataColumn2(
                    label: Text('Fecha Movimiento'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Fecha");
                    },
                  ),
                  DataColumn2(
                    label: Text('Tipo Movimiento'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Tipo");
                    },
                  ),
                  DataColumn2(
                    label: Text('Persona'),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Persona");
                    },
                  ),
                  DataColumn2(
                    label: Text('Motivo'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Motivo");
                    },
                  ),
                  DataColumn2(
                    label: Text('Monto'),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortFunc("Monto");
                    },
                  ),
                  DataColumn2(
                    label: Text(''),
                    numeric: true,
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) => DataRow(
                    onSelectChanged: (bool? selected) {
                      Navigators().pushNamed(
                        context,
                        '/layout/logistic/income-expense/details/info?id=${data[index]['id'].toString()}',
                      );
                    },
                    cells: [
                      DataCell(
                        Text(data[index]['attributes']['Fecha'].toString()),
                      ),
                      DataCell(
                        Text(data[index]['attributes']['Fecha']
                            .toString()
                            .split(" ")[0]
                            .toString()),
                      ),
                      DataCell(
                        Text(data[index]['attributes']['Tipo'].toString()),
                      ),
                      DataCell(
                        Text(data[index]['attributes']['Persona'].toString()),
                      ),
                      DataCell(
                        Text(data[index]['attributes']['Motivo'].toString()),
                      ),
                      DataCell(
                        Text(
                            "\$${data[index]['attributes']['Monto'].toString()}"),
                      ),
                      DataCell(
                        const Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 15,
                        ),
                      ),
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
        onSubmitted: (value) async {
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
