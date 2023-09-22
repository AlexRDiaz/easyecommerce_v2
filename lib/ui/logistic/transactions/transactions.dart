import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List data = [];

  loadData() async {
    try {
      var response = await Connections().allTransactions();

      setState(() {
        data = response;
      });

      // print(data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: DataTableModelPrincipal(
            columns: getColumns(), rows: buildDataRows(data)),
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
    ];
  }

  setColor (transaccion) {
    final color = transaccion == "credit" ? Color.fromARGB(255, 202, 236, 162) : Color.fromARGB(255, 236, 176, 175);
    return color;
  }
  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        color: MaterialStateColor.resolveWith((states) => setColor(data[index]['tipo'])!),
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
                    : "\$ ${data[index]['monto'].toString()}",
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
              child:
                  Text(data[index]['marca_de_tiempo'].toString().split(" ")[0]),
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
        ],
      );
      rows.add(row);
    }

    return rows;
  }

}
