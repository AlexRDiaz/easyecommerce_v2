import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_provider/edit_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProviderView extends StatefulWidget {
  ProviderView({Key? key}) : super(key: key);

  @override
  _ProviderViewState createState() => _ProviderViewState();
}

class _ProviderViewState extends State<ProviderView> {
  late ProviderController _providerController;
  ProviderModel _selctedProvider = ProviderModel();
  bool edited = false;
  bool isFilterIconVisible = false;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _providerController = ProviderController();
    //  _providerController.searchController.text = "";
  }

  hasEdited(value) {
    setState(() {
      edited = value;
    });
  }

  editProviderDialog(provider) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: EditProvider(
                provider: provider,
                hasEdited: hasEdited,
              ),
            ),
          );
        }).then((value) {
      if (edited) {
        setState(() {
          //   //_futureProviderData = _loadProviders(); // Actualiza el Future
        });
      }
    });
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
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar proveedor',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  _providerController.searchController.text = value;
                  setState(() {
                    _getProviderModelData();
                  });
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
                    editProviderDialog: editProviderDialog,
                    providers: snapshot.data!,
                  );

                  return Container(
                    color: Colors.white,
                    child: SfDataGrid(
                      source: providerModelDataSource,
                      columnWidthMode: ColumnWidthMode.fill,
                      isScrollbarAlwaysShown: true,
                      showVerticalScrollbar: true,
                      showHorizontalScrollbar: true,
                      columns: <GridColumn>[
                        GridColumn(
                            autoFitPadding: EdgeInsets.all(30.0),
                            columnName: 'nombre',
                            label: FilterIcon(
                              name: "nombre",
                              onFilterPressed: () {
                                // Lógica para aplicar el filtro
                              },
                            )),
                        GridColumn(
                            autoFitPadding: EdgeInsets.all(30.0),
                            columnName: 'username',
                            label: FilterIcon(
                              name: "PROPIETARIO",
                              onFilterPressed: () {
                                // Lógica para aplicar el filtro
                              },
                            )),
                        GridColumn(
                            autoFitPadding: EdgeInsets.all(30.0),
                            columnName: 'email',
                            label: FilterIcon(
                              name: "EMAIL",
                              onFilterPressed: () {
                                // Lógica para aplicar el filtro
                              },
                            )),
                        GridColumn(
                            autoFitPadding: EdgeInsets.all(30.0),
                            columnName: 'description',
                            label: FilterIcon(
                              name: "descripción",
                              onFilterPressed: () {
                                // Lógica para aplicar el filtro
                              },
                            )),
                        GridColumn(
                          autoFitPadding: EdgeInsets.all(30.0),
                          columnName: 'Actions',
                          label: Container(
                            padding: EdgeInsets.all(50.0),
                            alignment: Alignment.center,
                            child: Text('actions'),
                          ),
                        ),
                      ],
                      onCellTap: (DataGridCellTapDetails details) {
                        if (details.rowColumnIndex.rowIndex > 0) {
                          _selctedProvider = _providerController
                              .providers[details.rowColumnIndex.rowIndex - 1];

                          _showDialog(_selctedProvider);
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
  final Function(dynamic) editProviderDialog;
  ProviderModelDataSource(
      {required List<ProviderModel> providers,
      required this.editProviderDialog}) {
    _providersData = providers
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'username', value: e.user!.username),
              DataGridCell<String>(columnName: 'email', value: e.user!.email),
              DataGridCell<String>(
                  columnName: 'description', value: e.description),
              DataGridCell<ProviderModel>(
                columnName: 'actions',
                value: e,
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
        return Row(
          children: [
            SizedBox(
              //  width: 20,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  editProviderDialog(e.value);
                },
              ),
            ),
            SizedBox(
              // width: 20,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Lógica para eliminar la fila correspondiente
                },
              ),
            )
          ],
        );
        // IconButton(
        //   icon: Icon(Icons.delete),
        //   onPressed: () {
        //     // Lógica para eliminar la fila correspondiente
        //   },
        // ),
      }
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}

class FilterIcon extends StatefulWidget {
  final VoidCallback onFilterPressed;
  final String name;
  const FilterIcon({required this.onFilterPressed, required this.name});

  @override
  State<FilterIcon> createState() => _FilterIconState();
}

class _FilterIconState extends State<FilterIcon> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        isVisible = true;
      }),
      onExit: (event) => setState(() {
        isVisible = false;
      }),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: Text(widget.name),
          ),
          Visibility(
            visible: isVisible,
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                // Aquí puedes manejar la opción seleccionada del menú emergente
                print('Selected: $value');
                // Llama a una función que aplique el filtro seleccionado
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Filter 1',
                  child: Text('Filter 1'),
                ),
                PopupMenuItem<String>(
                  value: 'Filter 2',
                  child: Text('Filter 2'),
                ),
                PopupMenuItem<String>(
                  value: 'Filter 3',
                  child: Text('Filter 3'),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'Custom Filter',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Text('Custom Filter'),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  Icon(Icons.filter_alt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
