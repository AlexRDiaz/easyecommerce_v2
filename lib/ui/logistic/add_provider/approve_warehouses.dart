import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/layout_approve.dart';
import 'package:frontend/ui/logistic/add_provider/providers_view.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ApproveWarehouse extends StatefulWidget {
  final ProviderModel provider;

  const ApproveWarehouse({super.key, required this.provider});

  @override
  State<ApproveWarehouse> createState() => _ApproveWarehouseState();
}

class _ApproveWarehouseState extends State<ApproveWarehouse> {
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];

  @override
  void initState() {
    _warehouseController = WrehouseController();

    super.initState();
  }

  Future<List<WarehouseModel>> _getWarehouseModelData() async {
    await _warehouseController.loadWarehouses(widget.provider.id.toString());
    // return _warehouseController.warehouses;
    List<WarehouseModel> filteredWarehouses = _warehouseController.warehouses
        .where((warehouse) => warehouse.active == 1 && warehouse.approved == 2)
        .toList();

    return filteredWarehouses;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider.name.toString(),
                  style: customTextStyleTitle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bodegas:",
                  style: customTextStyleTitle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: _getWarehouseModelData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar bodegas'));
                  } else {
                    List<WarehouseModel> warehouses = snapshot.data ?? [];
                    return DataTable2(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: Colors.blueGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        return Colors.white;
                      }),
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      dataTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      columnSpacing: 12,
                      columns: [
                        const DataColumn2(
                          label: Text('Creado'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: const Text('ID'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Nombre'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Ciudad'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Telefono'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Aprobado'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text(''), //btn
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        warehouses.length,
                        (index) => DataRow(
                          cells: [
                            DataCell(
                              Text(UIUtils.formatDate(
                                  warehouses[index].createdAt.toString())),
                            ),
                            DataCell(
                              Text(warehouses[index].id.toString()),
                            ),
                            DataCell(
                              Text(warehouses[index].branchName.toString()),
                            ),
                            DataCell(
                              Text(warehouses[index].city.toString()),
                            ),
                            DataCell(
                              Text(warehouses[index]
                                  .customerphoneNumber
                                  .toString()),
                            ),
                            DataCell(warehouses[index].approved == 1
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.green)
                                : warehouses[index].approved == 2
                                    ? const Icon(Icons.hourglass_bottom_sharp,
                                        color: Colors.indigo)
                                    : const Icon(Icons.cancel_rounded,
                                        color: Colors.red)),
                            DataCell(
                              ElevatedButton(
                                onPressed: () async {
                                  //
                                  _warehouseController.upate(
                                      int.parse(
                                          warehouses[index].id.toString()),
                                      {
                                        "approved":
                                            warehouses[index].approved != 1
                                                ? 1
                                                : 0
                                      });

                                  Navigator.pop(context);

                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                0.0), // Establece el radio del borde a 0
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.95,
                                            child: LayoutApprovePage(
                                                provider: widget.provider,
                                                currentV: "Bodegas"),
                                          ),
                                        );
                                      }).then((value) {});

                                  //
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      warehouses[index].approved != 1
                                          ? Colors.green
                                          : Colors.red[400],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      warehouses[index].approved != 1
                                          ? "Aprobar"
                                          : "Rechazar",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
