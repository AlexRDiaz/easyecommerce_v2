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
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Color de la sombra
            spreadRadius: 5, // Radio de dispersión de la sombra
            blurRadius: 7, // Radio de desenfoque de la sombra
            offset: Offset(
                0, 3), // Desplazamiento de la sombra (horizontal, vertical)
          ),
        ],
      ),
      dividerThickness: 1,
      dataRowColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue.withOpacity(0.5); // Color para fila seleccionada
        } else if (states.contains(MaterialState.hovered)) {
          return const Color.fromARGB(255, 234, 241, 251);
        }
        return const Color.fromARGB(0, 173, 233, 231);
      }),
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      dataTextStyle: const TextStyle(color: Colors.black),
      columnSpacing: 12,
      headingRowHeight: 80,
      horizontalMargin: 32,
      minWidth: 3500,
      columns: columns,
      rows: rows,
    );
  }
}
