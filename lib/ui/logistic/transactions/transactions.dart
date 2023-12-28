import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/transactions/transactionRollback.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'dart:async';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List data = [];
  String start = "";
  String end = "";
  List arrayFiltersAnd = [];

  List<String> listOrigen = [
    'TODO',
    'RECAUDO',
    'ENVIO',
    'REFERENCIADO',
    'DEVOLUCION',
    'REEMBOLSO'
  ];
  List<Map> listToRollback = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController idRollbackTransaction = TextEditingController();

  TextEditingController origenController = TextEditingController(text: "TODO");

  loadData() async {
    try {
      var response = await Connections().last30rows();

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    loadData();
    super.didChangeDependencies();
  }

  filterData() async {
    try {
      var response = await Connections().getTransactionsByDate(
          start, end, searchController.text, arrayFiltersAnd);

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.3),
                  padding: EdgeInsets.all(10),
                  child: responsive(
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: _modelTextField(
                                text: "Buscar por codigo",
                                controller: searchController),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _showDatePickerModal(context);
                            },
                            child: Text('Seleccionar fechas'),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 5),
                            child: Text(
                              "Registros: ${data.length}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          TextButton(
                              onPressed: () => RollbackInputDialog(context),
                              child: Text("Restaurar")),
                          Spacer(),
                          refreshButton(),
                        ],
                      ),
                      Container(),
                      context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DataTableModelPrincipal(
                        columnWidth: 1200,
                        columns: getColumns(),
                        rows: buildDataRows(data)),
                  ),
                ),
              ]))),
    );
  }

  Align refreshButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          await loadData();
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.only(right: 10.0),
          padding: const EdgeInsets.only(bottom: 15.0),
          width: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(
                width: 1, color: const Color.fromARGB(255, 165, 173, 156)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 165, 173, 156),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          // color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.replay_outlined,
                color: Colors.green,
              ),
              SizedBox(
                width: 7,
              ),
              Row(
                children: [
                  Text(
                    "Recargar Información",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> RollbackInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
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
                  Expanded(child: TransactionRollback())
                ],
              ),
            ),
          );
        });
  }

  void _showDatePickerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Rango de Fechas'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: _onSelectionChanged,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange dateRange = args.value;
      print('Fecha de inicio: ${dateRange.startDate}');
      print('Fecha de fin: ${dateRange.endDate}');
      start = dateRange.startDate.toString();
      end = dateRange.endDate.toString();
      if (dateRange.endDate != null) {
        Navigator.of(context).pop();
        filterData();
      }
    }
  }

  Column SelectFilterNoId(String title, filter,
      TextEditingController controller, List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    arrayFiltersAnd.add({filter: newValue});
                  } else {}

                  filterData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                // var nombre = value.split('-')[0];
                // print(nombre);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split('-')[0],
                      style: const TextStyle(fontSize: 15)),
                );
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
          filterData();
          //  paginatorController.navigateToPage(0);
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchController.clear();
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

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: // Espacio entre iconos
            Text('Id'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Tipo Transacción.'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("fecha_entrega", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Monto'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Valor Actual'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Marca de Tiempo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Id Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Codigo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label:
            SelectFilterNoId('Origen', 'origen', origenController, listOrigen),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Id Vendedor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Comentario'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
    ];
  }

  setColor(transaccion) {
    final color = transaccion == "credit"
        ? Color.fromARGB(255, 202, 236, 162)
        : Color.fromARGB(255, 236, 176, 175);
    return color;
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        color: MaterialStateColor.resolveWith(
            (states) => setColor(data[index]['tipo'])!),
        cells: [
          DataCell(InkWell(
              child: Text(data[index]['id'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['tipo'].toString()),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text(
                data[index]['tipo'] == 'debit'
                    ? "\$ - ${data[index]['monto'].toString()}"
                    : "\$ + ${data[index]['monto'].toString()}",
              ),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_actual'].toString()}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(
                  "${data[index]['marca_de_tiempo'].toString().split(" ")[0]}   ${data[index]['marca_de_tiempo'].toString().split(" ")[1]}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['id_origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['codigo'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['id_vendedor'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['comentario'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
  }
}
