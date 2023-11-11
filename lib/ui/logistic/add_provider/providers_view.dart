import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProviderView extends StatefulWidget {
  ProviderView({Key? key}) : super(key: key);

  @override
  _ProviderViewState createState() => _ProviderViewState();
}

class _ProviderViewState extends State<ProviderView> {
  late ProviderController _providerController;
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _providerController = ProviderController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 590, right: 590),
        child: Column(
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
            FutureBuilder<List<ProviderModel>>(
              future: _getProviderModelData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final providerModelDataSource = ProviderModelDataSource(
                    providers: snapshot.data!,
                  );

                  return SingleChildScrollView(
                    child: SfDataGrid(
                      source: providerModelDataSource,
                      columnWidthMode: ColumnWidthMode.auto,
                      allowSorting: true,
                      isScrollbarAlwaysShown: true,
                      showVerticalScrollbar: true,
                      showHorizontalScrollbar: true,
                      swipeMaxOffset: 50,
                      showCheckboxColumn: true,
                      columns: <GridColumn>[
                        GridColumn(
                          columnName: 'id',
                          label: Container(
                            padding: EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text('ID'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'name',
                          label: Container(
                            padding: EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text('name'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'description',
                          label: Container(
                            padding: EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text('descripción'),
                          ),
                        ),
                        GridColumn(
                          columnName: '',
                          label: Container(
                            padding: EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text(''),
                          ),
                        ),
                      ],
                      onCellTap: (DataGridCellTapDetails details) {
                        if (details.rowColumnIndex.rowIndex > 0) {
                          _showDialog(_providerController
                              .providers[details.rowColumnIndex.rowIndex - 1]);
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(selectedRow) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información de la fila seleccionada'),
          content: Column(
            children: [
              Container(child: Text(selectedRow.name.toString())),
              Container(child: Text(selectedRow.phone.toString())),
              Container(child: Text(selectedRow.description.toString())),
              Container(child: Text(selectedRow.user!.username.toString())),
              Container(child: Text(selectedRow.user!.email.toString())),
              Container(child: Text(selectedRow.user!.username.toString())),
            ],
          ),
        );
      },
    );
  }

  Future<List<ProviderModel>> _getProviderModelData() async {
    await _providerController.loadProviders();
    return _providerController.providers;
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
          //_futureProviderData = _loadProviders(); // Actualiza el Future
        }));
  }

  void _showProviderInfoModal(ProviderModel provider) {
    // Aquí deberías abrir un modal con la información del proveedor
    // Utiliza showDialog() o algún widget modal como AlertDialog o BottomSheet
    // Puedes crear un widget personalizado que muestre la información del proveedor
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Información del Proveedor'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${provider.id}'),
              Text('Nombre: ${provider.name}'),
              // Agrega más información del proveedor según tus campos
            ],
          ),
        );
      },
    );
  }
}

class ProviderModelDataSource extends DataGridSource {
  ProviderModelDataSource({required List<ProviderModel> providers}) {
    _providersData = providers
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'designation', value: e.phone),
              DataGridCell<int>(
                columnName: 'actions',
                value: e.userId,
              ),
            ]))
        .toList();
  }

  late List<DataGridRow> _providersData;

  @override
  List<DataGridRow> get rows => _providersData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'actions') {
        return Container(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Lógica para editar la fila correspondiente
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Lógica para eliminar la fila correspondiente
                },
              ),
            ],
          ),
        );
      }
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
