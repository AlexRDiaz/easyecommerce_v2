import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class DataTableModelPrincipal extends StatelessWidget {
  final List<DataColumn2> columns;
  // final List data;
  final List<DataRow> rows;
  final double columnWidth;
  // List<DataCell>getRows;

  DataTableModelPrincipal(
      {super.key,
      required this.columns,
      // required this.data,
      required this.rows,
      required this.columnWidth});

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: Colors.blueGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4, // Radio de desenfoque de la sombra
            spreadRadius: 2, // Extensión de la sombra
          ),
        ],
      ),
      headingRowHeight: 63,
      showBottomBorder: true,
      dividerThickness: 1,
      dataRowColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue.withOpacity(0.5);
        } else if (states.contains(MaterialState.hovered)) {
          return const Color.fromARGB(255, 234, 241, 251);
        }
        return const Color.fromARGB(0, 173, 233, 231);
      }),
      headingTextStyle: Theme.of(context).textTheme.bodyMedium,
      dataTextStyle: Theme.of(context).textTheme.bodySmall,
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 4500,
      columns: columns,
      rows: rows,
    );
  }
}
