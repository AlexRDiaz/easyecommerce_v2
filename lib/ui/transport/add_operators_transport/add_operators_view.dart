import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/transport/add_operators_transport/add_operator_new.dart';
import 'package:frontend/ui/transport/add_operators_transport/controllers/controllers.dart';
import 'package:frontend/ui/transport/add_operators_transport/edit_operator_new.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route_new.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AddOperatorsView extends StatefulWidget {
  const AddOperatorsView({super.key});

  @override
  State<AddOperatorsView> createState() => _AddOperatorsViewState();
}

class _AddOperatorsViewState extends State<AddOperatorsView> {
  AddOperatorsTransportControllers _controllers =
      AddOperatorsTransportControllers();

  bool isLoading = false;

  List data = [];
  List defaultArrayFiltersAnd = [];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "username",
    "email",
    // "operadores.transportadoras.nombre",
    "operadores.sub_rutas.rutas.titulo",
    "operadores.sub_rutas.titulo"
  ];

  final formKey = GlobalKey<FormState>();
  bool usersDeleted = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (usersDeleted == false) {
        arrayFiltersAnd = [
          {
            "operadores.transportadoras.transportadora_id":
                sharedPrefs!.getString("idTransportadora").toString()
          },
          {"active": true}
        ];
      } else {
        arrayFiltersAnd = [
          {
            "operadores.transportadoras.transportadora_id":
                sharedPrefs!.getString("idTransportadora").toString()
          },
          {"active": false}
        ];
      }

      var response = await Connections().getOperatorsTransportLaravel(
          arrayFiltersAnd,
          arrayFiltersOr,
          _controllers.searchController.text,
          defaultArrayFiltersAnd);
      data = response;
      // print(data);
      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  void resetFilters() {
    // getOldValue(true);

    // arrayFiltersAnd = [];
    _controllers.searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // showAddOperator(context);
            showCreateOperator(context);
          },
          backgroundColor: Colors.green,
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _searchBar(screenWith, screenHeight, context),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  dividerThickness: 1,
                  dataRowColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue
                          .withOpacity(0.5); // Color para fila seleccionada
                    } else if (states.contains(MaterialState.hovered)) {
                      return const Color.fromARGB(255, 234, 241, 251);
                    }
                    return const Color.fromARGB(0, 173, 233, 231);
                  }),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(color: Colors.black),
                  columnSpacing: 12,
                  headingRowHeight: 45,
                  horizontalMargin: 32,
                  minWidth: 1500,
                  columns: getColumns(),
                  rows: buildDataRows(data),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: responsive(
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: _modelTextField(
                        text: "Buscar",
                        controller: _controllers.searchController),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Totales: ${data.length}",
              ),
              const SizedBox(width: 20),
              userDeletedSwitch(),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () async {
                      resetFilters();
                      setState(() {
                        usersDeleted = false;
                      });
                      loadData();
                    },
                    icon: Icon(
                      Icons.autorenew_rounded,
                      // size: 35,
                      color: Colors.indigo[900],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: _modelTextField(
                            text: "Buscar",
                            controller: _controllers.searchController),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () async {
                          resetFilters();
                          loadData();
                        },
                        icon: Icon(
                          Icons.autorenew_rounded,
                          // size: 35,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Totales: ${data.length}",
                  ),
                  const SizedBox(width: 20),
                  userDeletedSwitch(),
                ],
              ),
            ],
          ),
          context),
    );
  }

  Row userDeletedSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Oper. Eliminados",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        Switch(
          value: usersDeleted,
          onChanged: (value) async {
            setState(() {
              usersDeleted = value;
            });
            loadData();
          },
          activeColor: ColorsSystem().mainBlue,
          activeTrackColor: Colors.blue,
          inactiveTrackColor: ColorsSystem().violetWidgets,
          inactiveThumbColor: Colors.blueGrey,
        ),
      ],
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _searchBar(width, heigth, context),
              const SizedBox(height: 10),
              _dataTableOrders(heigth),
            ],
          ),
        ),
      ],
    );
  }

  Container _dataTableOrders(height) {
    return Container(
      width: double.infinity,
      height: height * 0.70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Expanded(
        child: DataTableModelPrincipal(
          columnWidth: 200,
          columns: getColumns(),
          rows: buildDataRows(data),
        ),
      ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Center(
          child: Text('Usuario'),
        ),
        size: ColumnSize.S,
        // fixedWidth: 250,
      ),
      const DataColumn2(
        label: Center(
          child: Text('Sub Ruta'),
        ),
        size: ColumnSize.S,
        // fixedWidth: 250,
      ),
      const DataColumn2(
        label: Center(
          child: Text('Telefono'),
        ),
        fixedWidth: 170,
      ),
      const DataColumn2(
        label: Center(
          child: Text(''),
        ),
        // size: ColumnSize.S,
        fixedWidth: 100,
      ),
      const DataColumn2(
        label: Center(
          child: Text('Costo Operador'),
        ),
        // size: ColumnSize.S,
        fixedWidth: 110,
      ),
      const DataColumn2(
        label: Center(
          child: Text('Transportadora'),
        ),
        size: ColumnSize.S,
        // fixedWidth: 250,
      ),
      // const DataColumn2(
      //   label: Center(
      //     child: Text('Bloquear'),
      //   ),
      //   // size: ColumnSize.S,
      //   fixedWidth: 100,
      // ),
      // const DataColumn2(
      //   label: Center(
      //     child: Text('Desbloquear'),
      //   ),
      //   // size: ColumnSize.S,
      //   fixedWidth: 100,
      // ),
      const DataColumn2(
        label: Center(
          child: Text('Bloquear/Desbloquear'),
        ),
        // size: ColumnSize.S,
        fixedWidth: 200,
      ),
      const DataColumn2(
        label: Center(
          child: Text('Bloqueado?'),
        ),
        // size: ColumnSize.S,
        fixedWidth: 100,
      ),
      const DataColumn2(
        label: Text(''),
        fixedWidth: 80,
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: data[index]['username'] != null &&
                          data[index]['username'].isNotEmpty
                      ? ColorsSystem().colorSelectMenu
                      : null,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    data[index]['username'] != null
                        ? data[index]['username'].toString()
                        : "",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onTap: () async {
              if (data[index]['active'] == true) {
                editOperator(context, data[index]);
              }
            },
          ),
          DataCell(
            Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  color: ColorsSystem().colorPrincipalBrand,
                ),
                Flexible(
                  child: Text(
                    data[index]['operadores'][0]['sub_rutas'] != null
                        ? data[index]['operadores'][0]['sub_rutas'][0]['titulo']
                            .toString()
                        : "",
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            onTap: () {
              if (data[index]['active'] == true) {
                editOperator(context, data[index]);
              }
            },
          ),
          DataCell(
            Center(
              child: Text(
                data[index]['operadores'][0]['telefono'].toString(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              if (data[index]['active'] == true) {
                editOperator(context, data[index]);
              }
            },
          ),
          DataCell(Visibility(
            visible: data[index]['operadores'][0]['telefono'].toString() != "",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    var _url = Uri(
                        scheme: 'tel',
                        path:
                            // '+593${data[index]['telefono_1'].toString()}');
                            '${data[index]['operadores'][0]['telefono'].toString()}');

                    if (!await launchUrl(_url)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                  child: const Icon(
                    Icons.call,
                    size: 20,
                  ),
                ),
              ],
            ),
          )),
          DataCell(
            Center(
              child: Text(
                "\$${data[index]['operadores'][0]['costo_operador'].toString()}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              if (data[index]['active'] == true) {
                editOperator(context, data[index]);
              }
            },
          ),
          DataCell(
            Center(
              child: Text(
                (data.length > index &&
                        data[index]['operadores'] != null &&
                        data[index]['operadores'].isNotEmpty &&
                        data[index]['operadores'][0]['transportadoras'] !=
                            null &&
                        data[index]['operadores'][0]['transportadoras']
                            .isNotEmpty &&
                        data[index]['operadores'][0]['transportadoras'][0]
                                ['nombre'] !=
                            null &&
                        data[index]['operadores'][0]['transportadoras'][0]
                                ['nombre'] !=
                            "")
                    ? data[index]['operadores'][0]['transportadoras'][0]
                            ['nombre']
                        .toString()
                    : "",
              ),
            ),
            // onTap: () {
            //   info(context, index);
            // },
          ),
          /*
          DataCell(
            Center(
              child: Visibility(
                visible: data[index]['active'] == true,
                child: GestureDetector(
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

                        var response = await Connections().updateUserGeneral(
                            data[index]['id'], {"blocked": true});

                        Navigator.pop(context);
                        await loadData();
                      },
                    ).show();
                  },
                  child: const Icon(
                    Icons.block,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: Visibility(
                visible: data[index]['active'] == true,
                child: GestureDetector(
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

                        var response = await Connections().updateUserGeneral(
                            data[index]['id'], {"blocked": false});

                        Navigator.pop(context);
                        await loadData();
                      },
                    ).show();
                  },
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
          */
          DataCell(
            Center(
              child: Switch(
                value: data[index]['blocked'],
                onChanged: (value) async {
                  if (value) {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title:
                          'Seguro de Bloquear al Usuario: ${data[index]['username']}?',
                      desc: '',
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        getLoadingModal(context, false);

                        var response = await Connections().updateUserGeneral(
                            data[index]['id'], {"blocked": true});

                        Navigator.pop(context);
                        await loadData();
                      },
                    ).show();
                  } else {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title:
                          'Seguro de Desbloquear al Usuario: ${data[index]['username']}?',
                      desc: '',
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        getLoadingModal(context, false);

                        var response = await Connections().updateUserGeneral(
                            data[index]['id'], {"blocked": false});

                        Navigator.pop(context);
                        await loadData();
                      },
                    ).show();
                  }
                },
                activeColor: ColorsSystem().mainBlue,
                activeTrackColor: Colors.blue,
                inactiveTrackColor: ColorsSystem().violetWidgets,
                inactiveThumbColor: Colors.blueGrey,
              ),
            ),
          ),
          DataCell(
            Center(
              child: Tooltip(
                message: data[index]['blocked'] != true
                    ? 'Desbloqueado'
                    : 'Bloqueado',
                child: Icon(
                  data[index]['blocked'] != true
                      ? Icons.lock_open_rounded
                      : Icons.lock_sharp,
                  color: data[index]['blocked'] != true
                      ? Colors.green
                      : Colors.redAccent,
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: Row(
                children: [
                  Visibility(
                    visible: data[index]['active'] == true,
                    child: GestureDetector(
                      onTap: () async {
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title:
                              'Seguro de Eliminar al Usuario: ${data[index]['username']}?',
                          desc:
                              'Si tiene asignado algun pedido en el sistema puede causar conflictos internos.',
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            getLoadingModal(context, false);
                            var response = await Connections()
                                .updateUserGeneral(
                                    data[index]['id'], {"active": false});

                            Navigator.pop(context);
                            await loadData();
                          },
                        ).show();
                      },
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: data[index]['active'] == false,
                    child: GestureDetector(
                      onTap: () async {
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title:
                              'Seguro de Restaurar al Usuario: ${data[index]['username']}?',
                          // desc: '',
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            getLoadingModal(context, false);
                            var response = await Connections()
                                .updateUserGeneral(
                                    data[index]['id'], {"active": true});

                            Navigator.pop(context);
                            await loadData();
                          },
                        ).show();
                      },
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                    await loadData();
                  },
                  child: const Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Future<dynamic> editOperator(BuildContext context, data) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              //
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                contentPadding: EdgeInsets.all(0),
                content: EditOperatorNew(
                  data: data,
                ),
              );
            },
          );
        }).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showCreateOperator(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return const AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: AddOperatorNew(),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }
}
