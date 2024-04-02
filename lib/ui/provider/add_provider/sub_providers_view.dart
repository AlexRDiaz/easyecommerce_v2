import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_provider/edit_provider.dart';
import 'package:frontend/ui/provider/add_provider/add_sub_provider.dart';
import 'package:frontend/ui/provider/add_provider/controllers/sub_provider_controller.dart';
import 'package:frontend/ui/provider/add_provider/edit_sub_provider.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SubProviderView extends StatefulWidget {
  SubProviderView({Key? key}) : super(key: key);

  @override
  _SubProviderViewState createState() => _SubProviderViewState();
}

class _SubProviderViewState extends State<SubProviderView> {
  late SubProviderController _subProviderController;
  TextEditingController _searchController = TextEditingController();
  UserModel _selctedProvider = UserModel();
  bool edited = false;
  bool isFilterIconVisible = false;
  bool selectable = false;
  List<dynamic> accessTemp = [];

  @override
  void initState() {
    super.initState();
    _subProviderController = SubProviderController();
    // List<String> userPermissionsSubProv =
    //     sharedPrefs!.getStringList("PERMISOS")!;
    List<String>? permisos = sharedPrefs!.getStringList("userpermissions");

    if (permisos != null) {
      accessTemp = permisos;
    } else {
      print("permisos is null");
    }
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
              width: MediaQuery.of(context).size.width * 0.50,
              height: MediaQuery.of(context).size.height * 0.85,
              child: EditSubProvider(
                accessTemp: accessTemp,
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
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _subProviderController.searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar proveedor',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  _subProviderController.searchController.text = value;
                  setState(() {
                    _getSubProviderModelData();
                  });

                  // Agrega aquí la lógica para filtrar la lista según la búsqueda
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => openDialog(context),
                    child: Text("Nuevo"),
                  ),
                  // SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: () => setState(() {
                  //     selectable = !selectable;
                  //   }),
                  //   child: Text("Seleccionar"),
                  // ),
                  // SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: () => setState(() {
                  //     selectable = !selectable;
                  //   }),
                  //   child: Text("Eliminar"),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FutureBuilder<List<UserModel>>(
              future: _getSubProviderModelData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final subProviderModelDataSource = SubProviderModelDataSource(
                    editProviderDialog: editProviderDialog,
                    providers: snapshot.data!,
                    deleteDialog: deleteDialog,
                  );

                  return Container(
                    color: Colors.white,
                    child: SfDataGrid(
                      source: subProviderModelDataSource,
                      columnWidthMode: ColumnWidthMode.fill,
                      isScrollbarAlwaysShown: true,
                      selectionMode: SelectionMode
                          .multiple, // Habilita la selección múltiple
                      onSelectionChanged: (addedRows, removedRows) {},
                      showCheckboxColumn: selectable,
                      showVerticalScrollbar: true,
                      showHorizontalScrollbar: true,
                      columns: <GridColumn>[
                        GridColumn(
                          autoFitPadding: EdgeInsets.all(30.0),
                          columnName: 'nombre',
                          label: Center(
                            child: Text("Nombre"),
                          ),
                        ),
                        GridColumn(
                          autoFitPadding: EdgeInsets.all(30.0),
                          columnName: 'username',
                          label: Center(
                            child: Text("Correo"),
                          ),
                          // label: FilterIcon(
                          //   name: "Correo",
                          //   onFilterPressed: () {
                          //     // Lógica para aplicar el filtro
                          //   },
                          // ),
                        ),
                        GridColumn(
                          autoFitPadding: EdgeInsets.all(30.0),
                          columnName: 'description',
                          label: Center(
                            child: Text("Bloqueado"),
                          ),
                          // label: FilterIcon(
                          //   name: "Bloqueado",
                          //   onFilterPressed: () {
                          //     // Lógica para aplicar el filtro
                          //   },
                          // ),
                        ),
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
                          _selctedProvider = _subProviderController
                              .users[details.rowColumnIndex.rowIndex - 1];

                          _showDialog(_selctedProvider);

                          if (details.rowColumnIndex.columnIndex == 0) {}
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
          title: Text('Datos del usuario'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                Container(child: Text(selectedRow.username.toString())),
                Container(child: Text(selectedRow.email.toString())),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<UserModel>> _getSubProviderModelData() async {
    await _subProviderController.loadSubProviders();
    return _subProviderController.users;
  }

  Future<dynamic> openDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.85,
              child: AddSubProvider(
                accessTemp: accessTemp,
              ),
            ),
          );
        }).then((value) => setState(() {
          _getSubProviderModelData();
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

  deleteDialog(provider) {
    ProviderModel providerM = provider;
    return AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: '¿Está seguro de eliminar el Proveedor?',
      desc:
          '${providerM.name.toString()} de ${providerM.user?.username.toString()}',
      btnOkText: "Confirmar",
      btnCancelText: "Cancelar",
      btnOkColor: Colors.blueAccent,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        getLoadingModal(context, false);

        await _subProviderController
            .upate(int.parse(providerM.id.toString()), {"active": 0});

        Navigator.pop(context);
      },
    ).show().then((value) {
      setState(() {
        _getSubProviderModelData();
      });
    });
  }
}

class SubProviderModelDataSource extends DataGridSource {
  final Function(dynamic) editProviderDialog;
  final Function(dynamic) deleteDialog;

  SubProviderModelDataSource(
      {required List<UserModel> providers,
      required this.editProviderDialog,
      required this.deleteDialog}) {
    _providersData = providers
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: e.username),
              DataGridCell<String>(columnName: 'email', value: e.email),
              DataGridCell<bool>(columnName: 'description', value: e.blocked),
              DataGridCell<UserModel>(
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
                  deleteDialog(e.value);
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
