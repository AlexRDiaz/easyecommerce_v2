import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/add_operators_transport/edit_operator_transport.dart';
import 'package:frontend/ui/transport/add_operators_transport/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';

class AddOperatorsTransportLogistic extends StatefulWidget {
  const AddOperatorsTransportLogistic({super.key});

  @override
  State<AddOperatorsTransportLogistic> createState() =>
      _AddOperatorsTransportLogisticState();
}

class _AddOperatorsTransportLogisticState
    extends State<AddOperatorsTransportLogistic> {
  AddOperatorsTransportControllers _controllers =
      AddOperatorsTransportControllers();
  List<String> subRoutes = [];
  String? selectedValueRoute;
  List data = [];
  bool sort = false;

  List defaultArrayFiltersAnd = [];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "username",
    "operadores.transportadoras.nombre",
    "operadores.sub_rutas.rutas.titulo",
    "operadores.sub_rutas.titulo"
  ];

  // "username"
  // "operadores.transportadoras.transportadora_id",
  // "operadores.sub_rutas.rutas.ruta_id",
  // "operadores.sub_rutas.sub_ruta_id",
  // "operadores.costo_operador",

  List<String> listRoutes = ['TODO'];
  List<String> listTransportadores = ['TODO'];
  List<String> listSubRoutes = ['TODO'];
  List<String> listOperators = ['TODO'];

  TextEditingController transportadorasController =
      TextEditingController(text: "TODO");
  TextEditingController routesController = TextEditingController(text: "TODO");
  TextEditingController subRoutesController =
      TextEditingController(text: "TODO");
  TextEditingController operatorsController =
      TextEditingController(text: "TODO");

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

    // * se debe cambiar a que cargue las subrutas dependiendo de la transportadora selecionada

    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        subRoutes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
      });
    }
    var response = await Connections().getOperatorsTransportLaravel(
        arrayFiltersAnd,
        arrayFiltersOr,
        _controllers.searchController.text,
        defaultArrayFiltersAnd);
    data = response;

    if (listTransportadores.length == 1) {
      var responsetransportadoras =
          await Connections().getActiveTransportadoras();
      List<dynamic> transportadorasList = responsetransportadoras;
      for (var transportadora in transportadorasList) {
        listTransportadores.add(transportadora);
      }
    }

    if (listRoutes.length == 1) {
      var responseroutes = await Connections().getActiveRoutes();
      List<dynamic> routesList = responseroutes;
      for (var route in routesList) {
        listRoutes.add(route);
      }
    }

    if (listSubRoutes.length == 1) {
      var responsesubRoutes = await Connections().getSubRoutesID();
      List<dynamic> subRoutesList = responsesubRoutes;
      for (var subroute in subRoutesList) {
        listSubRoutes.add(subroute);
      }
    }
    if (listOperators.length == 1) {
      var responseOperators = await Connections().getOperatorsAvailables();
      List<dynamic> operatorsList = responseOperators;
      for (var subroute in operatorsList) {
        listOperators.add(subroute);
      }
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     modalAddOperator(context);
      //   },
      //   backgroundColor: colors.colorGreen,
      //   child: Center(
      //     child: Icon(
      //       Icons.add,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //   ),
      // ),
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
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.grey)),
                margin: EdgeInsets.all(12.0),
                child: DataTable2(
                    headingRowHeight: 86,
                    headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    columns: [
                      DataColumn2(
                        label: SelectFilter('Usuario', 'id',
                            operatorsController, listOperators),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFuncUser("username");
                        },
                      ),
                      DataColumn2(
                        label: SelectFilter(
                            'SubRuta',
                            'operadores.sub_rutas.sub_ruta_id',
                            subRoutesController,
                            listSubRoutes),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFuncSubRoute();
                        },
                      ),
                      DataColumn2(
                        label: SelectFilter(
                            'Transportadora',
                            'operadores.transportadoras.transportadora_id',
                            transportadorasController,
                            listTransportadores),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: SelectFilter(
                            'Ruta',
                            'operadores.sub_rutas.rutas.ruta_id',
                            routesController,
                            listRoutes),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          // sortFuncCostOperator();
                        },
                      ),
                      DataColumn2(
                        label: Text('Teléfono'),
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
                                    SizedBox(width: 5),
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
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditOperatorLogistic(
                                        idUserE: data[index]['id'].toString(),
                                        idOperator: data[index]['operadores'][0]
                                                ['id']
                                            .toString(),
                                      ),
                                    ),
                                  );
                                  loadData();
                                },
                              ),
                              DataCell(
                                  Row(
                                    children: [
                                      getIcon(
                                          int.parse(data[index]['operadores'][0]
                                                  ['transportadoras'][0]['id']
                                              .toString()),
                                          int.parse(data[index]['operadores'][0]
                                                      ['sub_rutas'][0]
                                                  ['id_operadora']
                                              .toString())),
                                      SizedBox(width: 5),
                                      Expanded(
                                          child: Text(
                                        data[index]['operadores'][0]
                                                ['sub_rutas'][0]['titulo']
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    ],
                                  ), onTap: () {
                                // Navigators().pushNamed(context,
                                // '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                              }),
                              DataCell(
                                Text(
                                  (data.length > index &&
                                          data[index]['operadores'] != null &&
                                          data[index]['operadores']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]
                                                  ['transportadoras'] !=
                                              null &&
                                          data[index]['operadores'][0]
                                                  ['transportadoras']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]
                                                      ['transportadoras'][0]
                                                  ['nombre'] !=
                                              null &&
                                          data[index]['operadores'][0]
                                                      ['transportadoras'][0]
                                                  ['nombre'] !=
                                              "")
                                      ? data[index]['operadores'][0]
                                              ['transportadoras'][0]['nombre']
                                          .toString()
                                      : "",
                                ),
                                onTap: () {
                                  // Aquí puedes colocar el código para manejar la acción onTap
                                  // Navigators().pushNamed(context, '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                                },
                              ),
                              DataCell(
                                Text(
                                  (data.length > index &&
                                          data[index]['operadores'] != null &&
                                          data[index]['operadores']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]
                                                  ['sub_rutas'] !=
                                              null &&
                                          data[index]['operadores'][0]['sub_rutas']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]
                                                  ['sub_rutas'][0]['rutas'] !=
                                              null &&
                                          data[index]['operadores'][0]
                                                  ['sub_rutas'][0]['rutas']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]['sub_rutas']
                                                  [0]['rutas'][0]['titulo'] !=
                                              null &&
                                          data[index]['operadores'][0]['sub_rutas']
                                                  [0]['rutas'][0]['titulo'] !=
                                              "")
                                      ? data[index]['operadores'][0]['sub_rutas'][0]['rutas'][0]['titulo'].toString()
                                      : "",
                                ),
                                onTap: () {
                                  // Aquí puedes colocar el código para manejar la acción onTap
                                  // Navigators().pushNamed(context, '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                                },
                              ),
                              DataCell(
                                Text(
                                  (data.length > index &&
                                          data[index]['operadores'] != null &&
                                          data[index]['operadores']
                                              .isNotEmpty &&
                                          data[index]['operadores'][0]
                                                  ['telefono'] !=
                                              null &&
                                          data[index]['operadores'][0]
                                                  ['telefono']
                                              .isNotEmpty)
                                      ? data[index]['operadores'][0]['telefono']
                                          .toString()
                                      : "",
                                ),
                                onTap: () {
                                  // Aquí puedes colocar el código para manejar la acción onTap
                                  // Navigators().pushNamed(context, '/layout/transport/operator/info?id=${data[index]['id']}&id_Operator=${data[index]['operadore']['id']}');
                                },
                              ),
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

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Container(
          margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
          ),
          height: 40, // Ajusta la altura del contenedor
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: controller.text,
            onChanged: (String? newValue) {
              setState(() {
                controller.text = newValue ?? "";
                arrayFiltersAnd
                    .removeWhere((element) => element.containsKey(filter));

                if (newValue != 'TODO') {
                  if (filter is String) {
                    arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                  } else {
                    reemplazarValor(filter, newValue!);
                    arrayFiltersAnd.add(filter);
                  }
                } else {}

                loadData();
              });
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: listOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10), // Ajusta el espacio alrededor del texto
                  child: Text(
                    value.split('-')[0],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }

  Widget getIcon(dynamic idTransportadora, dynamic idOperadora) {
    // Verificar si las cadenas son nulas o vacías antes de la conversión
    if (idTransportadora != null &&
        idOperadora != null &&
        idTransportadora.toString().isNotEmpty &&
        idOperadora.toString().isNotEmpty) {
      try {
        // Intentar convertir las cadenas a números
        int parsedIdTransportadora = int.parse(idTransportadora.toString());
        int parsedIdOperadora = int.parse(idOperadora.toString());

        // Verificar si la conversión fue exitosa y las dos variables son iguales
        if (parsedIdTransportadora == parsedIdOperadora) {
          return const Icon(Icons.check, color: Colors.green);
        }
      } catch (e) {
        // Manejar cualquier excepción que pueda ocurrir durante la conversión
        print('Error al convertir las cadenas a números: $e');
      }
    }

    return const Icon(Icons.close, color: Colors.orange);
  }

  void _mostrarVentanaModal(BuildContext context, Widget contenidoModal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: contenidoModal,
        );
      },
    );
  }
}
