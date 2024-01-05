import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/providers_view.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
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
    // getAccess();
  }

  Future<List<WarehouseModel>> _getWarehouseModelData() async {
    await _warehouseController.loadWarehouses(widget.provider.id.toString());
    return _warehouseController.warehouses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      columns: [
                        const DataColumn2(
                          label: Text(''),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: const Text(''),
                          size: ColumnSize.L,
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
                              Text(warehouses[index]
                                  .branchName
                                  .toString()), // Accede a la propiedad 'nombre'
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
