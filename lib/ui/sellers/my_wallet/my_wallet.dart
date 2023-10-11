import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Transaction {
  final String title;
  final double amount;

  Transaction(this.title, this.amount);
}

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  MyWalletController walletController = MyWalletController();
  TextEditingController searchController = TextEditingController();
  String saldo = '0';
  List data = [];
  String start = "";
  String end = "";

  // Saldo inicial de cuenta
  List<Transaction> transactions = [
    Transaction('Compra 1', -50.0),
    Transaction('Compra 2', -75.0),
    Transaction('Depósito 1', 200.0),
  ];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    var res = await walletController.getSaldo();
    setState(() {
      saldo = res;
    });

    try {
      var response = await Connections().getTransactionsBySeller();

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  filterData() async {
    try {
      var response = await Connections()
          .getTransactionsByDate(start, end, searchController.text);

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Saldo de Cuenta',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '\$${saldo}',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Transacciones Recientes',
              style: TextStyle(fontSize: 24),
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
                            text: "Buscar", controller: searchController),
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
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Spacer(),
                      TextButton(
                          onPressed: () => loadData(),
                          child: Text("Actualizar")),

                      //   Expanded(child: numberPaginator()),
                    ],
                  ),
                  Container(),
                  context),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: DataTableModelPrincipal(
                    columns: getColumns(), rows: buildDataRows(data)),
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: transactions.length,
            //     itemBuilder: (ctx, index) {
            //       final transaction = transactions[index];
            //       return Card(
            //         elevation: 3,
            //         margin: EdgeInsets.all(10),
            //         child: ListTile(
            //           title: Text(transaction.title),
            //           trailing: Text(
            //             '\$${transaction.amount.toStringAsFixed(2)}',
            //             style: TextStyle(
            //               color: transaction.amount < 0
            //                   ? Colors.red
            //                   : Colors.green,
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showDatePickerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Rango de Fechas'),
          content: Container(
            width: double.maxFinite,
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
        label: Text('Valor Anterior'),
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
        label: Text('Origen'),
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
              child: Text("\$ ${data[index]['valor_anterior']}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_actual']}"),
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
