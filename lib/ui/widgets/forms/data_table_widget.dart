import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class DataTableWidget extends StatefulWidget {
  final List<DataColumn2> dataColumns;
  final List<DataRow> dataRow;

  const DataTableWidget(
      {super.key, required this.dataColumns, required this.dataRow});
  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  @override
  Widget build(BuildContext context) {
    return DataTable2(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: Colors.blueGrey),
        ),
        headingTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dataTextStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        columnSpacing: 12,
        headingRowHeight: 80,
        horizontalMargin: 12,
        minWidth: 3500,
        columns: widget.dataColumns,
        rows: widget.dataRow);
  }
}
