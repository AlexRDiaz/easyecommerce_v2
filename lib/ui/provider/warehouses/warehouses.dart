import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class WarehousesView extends StatefulWidget {
  const WarehousesView({super.key});
  @override
  _WarehousesViewState createState() => _WarehousesViewState();
}

class _WarehousesViewState extends StateMVC<WarehousesView> {
  late WrehouseController _controller;
  late TextEditingController _searchController;
  late Future<List<WarehouseModel>> _futureWarehouseData;

  @override
  void initState() {
    _controller = WrehouseController();
    _searchController = TextEditingController();
    _futureWarehouseData = _loadWarehouses();
    _loadWarehouses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  flex:
                      2, // Ajusta este valor según sea necesario para cambiar el tamaño del TextField
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar bodega',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // Lógica de búsqueda
                    },
                  ),
                ),
                SizedBox(width: 8), // Espacio entre el TextField y el botón
                ElevatedButton.icon(
                  onPressed: () => openDialog(context),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Agregar Bodega",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Botón naranja
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _futureWarehouseData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar bodegas'));
                } else {
                  List<WarehouseModel> warehouses = snapshot.data ?? [];
                  return GridView.builder(
                    itemCount: warehouses.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 5 tarjetas por fila
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0, // Ajusta la relación de aspecto según necesidad
                    ),
                    itemBuilder: (context, index) {
                      WarehouseModel warehouse = warehouses[index];
                      return Card(
                        color: Color.fromARGB(255, 12, 37, 49),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store,
                                size: 50,
                                color: Colors.white), // Icono de bodega
                            SizedBox(height: 8), // Espacio entre icono y texto
                            Text(
                              warehouse.branchName ?? 'Sin nombre',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            // Agrega más detalles según sea necesario
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Column(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: TextField(
  //             controller: _searchController,
  //             decoration: InputDecoration(
  //               labelText: 'Buscar bodega',
  //               prefixIcon: Icon(Icons.search),
  //             ),
  //             onChanged: (value) {
  //               // Agrega aquí la lógica para filtrar la lista según la búsqueda
  //             },
  //           ),
  //         ),
  //         TextButton(
  //             onPressed: () {
  //               openDialog(context);
  //             },
  //             child: Text("Nuevo")),
  //         Expanded(
  //           child: FutureBuilder(
  //             future: _loadWarehouses(),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return Center(child: CircularProgressIndicator());
  //               } else if (snapshot.hasError) {
  //                 SnackBarHelper.showErrorSnackBar(context, "error");
  //                 return Center(child: Text('Error al cargar proveedores'));
  //               } else {
  //                 return _buildProviderList(_controller.warehouses);
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<List<WarehouseModel>> _loadWarehouses() async {
    await _controller.loadWarehouses();
    return _controller.warehouses;
  }

  // Widget _buildProviderList(List<WarehouseModel> providers) {
  //   return DataTableModelPrincipal(
  //       columnWidth: 1200,
  //       columns: getColumns(),
  //       rows: buildDataRows(_controller.warehouses));
  // }

  // List<DataColumn2> getColumns() {
  //   return [
  //     DataColumn2(
  //       label: // Espacio entre iconos
  //           Text('Id'),
  //       size: ColumnSize.S,
  //       onSort: (columnIndex, ascending) {
  //         // sortFunc3("marca_tiempo_envio", changevalue);
  //       },
  //     ),
  //     DataColumn2(
  //       label: Text('Nombre'),
  //       size: ColumnSize.S,
  //       onSort: (columnIndex, ascending) {
  //         // sortFunc3("fecha_entrega", changevalue);
  //       },
  //     ),
  //   ];
  // }

  // List<DataRow> buildDataRows(List<WarehouseModel> data) {
  //   List<DataRow> rows = [];
  //   for (int index = 0; index < data.length; index++) {
  //     DataRow row = DataRow(
  //       cells: [
  //         DataCell(InkWell(
  //             child: Text(data[index].id.toString()),
  //             onTap: () {
  //               // OpenShowDialog(context index);
  //             })),
  //         DataCell(InkWell(
  //             child: Text(data[index].branchName.toString()),
  //             onTap: () {
  //               // OpenShowDialog(context index);
  //             })),
  //       ],
  //     );
  //     rows.add(row);
  //   }

  //   return rows;
  // }

  Future<dynamic> openDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: AddProvider(),
            ),
          );
        }).then((value) => setState(() {
          _futureWarehouseData = _loadWarehouses(); // Actualiza el Future
        }));
  }
}
