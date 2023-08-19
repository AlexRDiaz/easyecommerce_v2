import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/add_operators_transport/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';

class AddOperatorsTransport extends StatefulWidget {
  const AddOperatorsTransport({super.key});

  @override
  State<AddOperatorsTransport> createState() => _AddOperatorsTransportState();
}

class _AddOperatorsTransportState extends State<AddOperatorsTransport> {
  AddOperatorsTransportControllers _controllers =
      AddOperatorsTransportControllers();
  List<String> subRoutes = [];
  String? selectedValueRoute;
  List data = [];
  bool sort = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var routesList = [];
    setState(() {
      subRoutes = [];
      data = [];
    });
    routesList = await Connections().getSubRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        subRoutes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
      });
    }
    var response = await Connections()
        .getOperatorsTransport(_controllers.searchController.text);
    data = response;

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalAddOperator(context);
        },
        backgroundColor: colors.colorGreen,
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            Expanded(
              child: DataTable2(
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  columns: [
                    DataColumn2(
                      label: Text('Usuario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncUser("username");
                      },
                    ),
                    DataColumn2(
                      label: Text('Sub Ruta'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncSubRoute();
                      },
                    ),
                    DataColumn2(
                      label: Text('Costo Operador'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFuncCostOperator();
                      },
                    ),
                    DataColumn2(
                      label: Text('Transportadora'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Bloquear'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Desbloquear'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Bloqueado'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(cells: [
                            DataCell(Text(data[index]['username'].toString()),
                                onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                            }),
                            DataCell(
                                Text(data[index]['operadore']['sub_ruta']
                                        ['Titulo']
                                    .toString()), onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                            }),
                            DataCell(
                                Text(data[index]['operadore']['Costo_Operador']
                                    .toString()), onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                            }),
                            DataCell(
                                Text(data[index]['operadore']['transportadora']
                                        ['Nombre']
                                    .toString()), onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                            }),
                            DataCell(GestureDetector(
                              onTap: () async {
                                AwesomeDialog(
                                  width: 500,
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title: 'Seguro de Bloquear Usuario?',
                                  desc: '',
                                  btnOkText: "Aceptar",
                                  btnOkColor: colors.colorGreen,
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .updateAccountBlock(
                                            data[index]['id'].toString());

                                    Navigator.pop(context);
                                    await loadData();
                                  },
                                ).show();
                              },
                              child: Icon(
                                Icons.block,
                                color: Colors.redAccent,
                              ),
                            )),
                            DataCell(GestureDetector(
                              onTap: () async {
                                AwesomeDialog(
                                  width: 500,
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title: 'Seguro de Desbloquear Usuario?',
                                  desc: '',
                                  btnOkText: "Aceptar",
                                  btnOkColor: colors.colorGreen,
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .updateAccountDisBlock(
                                            data[index]['id'].toString());

                                    Navigator.pop(context);
                                    await loadData();
                                  },
                                ).show();
                              },
                              child: Icon(
                                Icons.lock_open_rounded,
                                color: Colors.greenAccent,
                              ),
                            )),
                            DataCell(
                              Text("${data[index]['blocked']}"),
                            ),
                            DataCell(GestureDetector(
                              onTap: () async {
                                AwesomeDialog(
                                  width: 500,
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title: 'Seguro de Eliminar Usuario?',
                                  desc:
                                      'Si tiene asignado algun pedido en el sistema puede causar conflictos internos.',
                                  btnOkText: "Aceptar",
                                  btnOkColor: colors.colorGreen,
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .deleteUser(data[index]['id']);
                                    var responseOperator = await Connections()
                                        .deleteOperator(
                                            data[index]['operadore']['id']);
                                    Navigator.pop(context);
                                    await loadData();
                                  },
                                ).show();
                              },
                              child: Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.redAccent,
                              ),
                            )),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> modalAddOperator(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: double.infinity,
                color: Colors.white,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.close))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "AGREGAR",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CreateSubRoutesModal(
                                      idTransport: sharedPrefs!
                                          .getString("idTransportadora")
                                          .toString(),
                                    );
                                  });
                              await loadData();

                              setState(() {});
                            },
                            child: Text(
                              "CREAR SUBRUTA",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        _modelTextFieldCompleteModal(
                            "Usuario", _controllers.userController),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Sub Ruta',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            items: subRoutes
                                .map((item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.split('-')[0],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
                            value: selectedValueRoute,
                            onChanged: (value) async {
                              setState(() {
                                selectedValueRoute = value as String;
                              });
                            },

                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {}
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _modelTextFieldCompleteModal(
                            "Correo", _controllers.mailController),
                        _modelTextFieldCompleteModal("Costo Operador",
                            _controllers.costOperatorController),
                        _modelTextFieldCompleteModal(
                            "Número de Teléfono", _controllers.phoneController),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  minimumSize: Size(200, 40)),
                              onPressed: selectedValueRoute != null
                                  ? () async {
                                      getLoadingModal(context, false);
                                      var responseCode = await Connections()
                                          .generateCodeAccount(
                                              _controllers.mailController.text);
                                      await _controllers.createUser(
                                          code: responseCode.toString(),
                                          success: (id) {
                                            Navigator.pop(context);
                                            // loadData();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Completado",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [],
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () async {
                                                            await loadData();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            "ACEPTAR",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  );
                                                });

                                            _controllers.userController.clear();
                                            _controllers.mailController.clear();
                                            _controllers.phoneController
                                                .clear();
                                            _controllers.costOperatorController
                                                .clear();
                                            selectedValueRoute = null;
                                            setState(() {});
                                          },
                                          error: () {
                                            Navigator.pop(context);
                                            AwesomeDialog(
                                              width: 500,
                                              context: context,
                                              dialogType: DialogType.error,
                                              animType: AnimType.rightSlide,
                                              title: 'Error',
                                              desc: 'Vuelve a intentarlo',
                                              btnCancel: Container(),
                                              btnOkText: "Aceptar",
                                              btnOkColor: colors.colorGreen,
                                              btnCancelOnPress: () {},
                                              btnOkOnPress: () {},
                                            ).show();
                                          },
                                          subruta: selectedValueRoute!
                                              .split('-')[1]);
                                    }
                                  : null,
                              child: Text(
                                "Guardar",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color.fromARGB(255, 245, 244, 244),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (value) {
                  loadData();
                  setState(() {});
                },
                onChanged: (value) {},
                style: TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _controllers.searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _controllers.searchController.clear();
                            });
                            loadData();
                            setState(() {});
                          },
                          child: Icon(Icons.close))
                      : null,
                  hintText: text,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusColor: Colors.black,
                  iconColor: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: GestureDetector(
                onTap: () {
                  loadData();
                },
                child: Icon(Icons.replay_outlined)),
          )
        ],
      ),
    );
  }

  Column _modelTextFieldCompleteModal(title, controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        _modelTextFieldModal(controller: controller),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _modelTextFieldModal({controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
        ),
      ),
    );
  }

  sortFuncUser(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b[name].toString().compareTo(a[name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a[name].toString().compareTo(b[name].toString()));
    }
  }

  sortFuncSubRoute() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['operadore']['sub_ruta']['Titulo']
          .toString()
          .compareTo(a['operadore']['sub_ruta']['Titulo'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['operadore']['sub_ruta']['Titulo']
          .toString()
          .compareTo(b['operadore']['sub_ruta']['Titulo'].toString()));
    }
  }

  sortFuncCostOperator() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['operadore']['Costo_Operador']
          .toString()
          .compareTo(a['operadore']['Costo_Operador'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['operadore']['Costo_Operador']
          .toString()
          .compareTo(b['operadore']['Costo_Operador'].toString()));
    }
  }
}
