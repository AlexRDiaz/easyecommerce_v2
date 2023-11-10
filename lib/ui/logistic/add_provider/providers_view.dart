import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProviderView extends StatefulWidget {
  @override
  _ProviderViewState createState() => _ProviderViewState();
}

class _ProviderViewState extends StateMVC<ProviderView> {
  late ProviderController _controller;
  late TextEditingController _searchController;
  late Future<List<ProviderModel>> _futureProviderData;

  @override
  void initState() {
    _controller = ProviderController();
    _searchController = TextEditingController();
    _futureProviderData = _loadProviders();
    _loadProviders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar proveedor',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Agrega aquí la lógica para filtrar la lista según la búsqueda
              },
            ),
          ),
          TextButton(
              onPressed: () {
                openDialog(context);
              },
              child: Text("Nuevo")),
          Expanded(
            child: FutureBuilder(
              future: _loadProviders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  SnackBarHelper.showErrorSnackBar(context, "error");
                  return Center(child: Text('Error al cargar proveedores'));
                } else {
                  return _buildProviderList(_controller.providers);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ProviderModel>> _loadProviders() async {
    await _controller.loadProviders();
    return _controller.providers;
  }

  Widget _buildProviderList(List<ProviderModel> providers) {
    return DataTableModelPrincipal(
        columnWidth: 1200,
        columns: getColumns(),
        rows: buildDataRows(_controller.providers));
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
        label: Text('Nombre'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("fecha_entrega", changevalue);
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List<ProviderModel> data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(InkWell(
              child: Text(data[index].id.toString()),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text(data[index].name.toString()),
              onTap: () {
                // OpenShowDialog(context index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

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
          _futureProviderData = _loadProviders(); // Actualiza el Future
        }));
  }
}
