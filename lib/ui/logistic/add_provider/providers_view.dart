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
  int _selectedRowIndex =
      -1; // Variable para almacenar el índice de la fila seleccionada

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
      appBar: AppBar(
        title: Text('Proveedores'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 90, right: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar proveedor',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => openDialog(context),
                  child: Text("Nuevo Proveedor"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: _loadProviders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar proveedores'),
                    );
                  } else {
                    return _buildProviderList(_controller.providers);
                  }
                },
              ),
            ),
          ],
        ),
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
      rows: buildDataRows(_controller.providers),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Nombre'),
        ),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // Lógica de ordenamiento
        },
      ),
      DataColumn2(
        label: Text('Propietario'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // Lógica de ordenamiento
        },
      ),
      DataColumn2(
        label: Text('Descripción'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // Lógica de ordenamiento
        },
      ),
      DataColumn2(
        label: Text(''),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // Lógica de ordenamiento
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List<ProviderModel> data) {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      ProviderModel provider = entry.value;

      return DataRow(
        onSelectChanged: (isSelected) {
          // setState(() {
          //   _selectedRowIndex = isSelected! ? index : -1;
          // });

          // if (isSelected!) {
          //   // Lógica para mostrar un diálogo con la información completa
          //   _showInfoDialog(context, provider);
          // }
        },
        cells: [
          DataCell(InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(provider.name.toString()),
            ),
            onTap: () {
              _showInfoDialog(context, provider);
            },
          )),
          DataCell(GestureDetector(
            child: Text(provider.user!.username.toString()),
            onTap: () {
              _showInfoDialog(context, provider);
            },
          )),
          DataCell(InkWell(
            child: Text(provider.description.toString()),
            onTap: () {
              _showInfoDialog(context, provider);
            },
          )),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {},
              ),
            ],
          )),
        ],
      );
    }).toList();
  }

  Future<void> openDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: AddProvider(),
          ),
        );
      },
    ).then((value) => setState(() {
          _futureProviderData = _loadProviders(); // Actualiza el Future
        }));
  }

  Future<void> _showInfoDialog(
      BuildContext context, ProviderModel provider) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Información completa'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${provider.id}'),
              Text('Nombre: ${provider.name}'),
              Text('Propietario: ${provider.user!.username}'),
              Text('Descripción: ${provider.description}'),
              // Agrega más información según los campos de ProviderModel
            ],
          ),
        );
      },
    );
  }
}
