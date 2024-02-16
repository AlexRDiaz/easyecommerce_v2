import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_laravel.controllers/add_carrier_laravel.controlers.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_modal_laravel.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/update_carrier_modal_laravel.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


class AddCarrier extends StatefulWidget {
  const AddCarrier({super.key});

  @override
  State<AddCarrier> createState() => _AddCarrierState();
}

class _AddCarrierState extends State<AddCarrier> {
  AddCarriersLaravelControllers _controllers = AddCarriersLaravelControllers();
  // List alllData = [];
  // List data = [];

  List dataL = [];
  int currentPage = 1;
  int pageSize = 150;
  int pageCount = 1;
  bool isFirst = true;
  bool isLoading = false;
  int total = 0;
  int actives = 0;
  int inactives = 0;

  String model = "Transportadora";

  var sortFieldDefaultValue = "";
  List populate = [
    'rutas',
    'transportadoras_users_permissions_user_links.up_user'
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = ["nombre", "costo_transportadora", "telefono_1"];
  // List arrayFiltersNot = [{"transportadoras_users_permissions_user_links.up_user.blocked":"0"}];
  List arrayFiltersNot = [];
  final TextEditingController supervisorController = TextEditingController();

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
      var responseL = await Connections().generalData(
          pageSize,
          pageCount,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersOr,
          _controllers.searchController.text,
          model,
          "",
          "",
          "",
          sortFieldDefaultValue);
      setState(() {
        dataL = [];
        dataL = responseL['data'];
      });

      total = responseL['total'];
      pageCount = responseL['last_page'];

      String respc = contar(dataL);

      actives = int.parse(respc.split('-')[0]);
      inactives = int.parse(respc.split('-')[1]);

      isLoading = false;
    } catch (e) {
      isLoading = false;
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    try {
      var responseL = await Connections().generalData(
          pageSize,
          pageCount,
          populate,
          arrayFiltersNot,
          arrayFiltersAnd,
          arrayFiltersOr,
          _controllers.searchController.text,
          model,
          "",
          "",
          "",
          sortFieldDefaultValue);

      setState(() {
        dataL = [];
        dataL = responseL['data'];

        pageCount = responseL['last_page'];
      });
    } catch (e) {
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }


  @override
  Widget build(BuildContext context) {
    // double heigth = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (context) {
                  return const AddCarrierLaravelModal();
                });
            await loadData();
          },
          backgroundColor: colors.colorGreen,
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        body: Container(
          // padding: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
          child: responsive(
              webContainer(context), movilContainer(context), context),
        ),
      ),
    );
  }

  Column webContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width * 0.5,
          child: _modelTextField(
              text: "Buscar", controller: _controllers.searchController),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(
              width: 2.0,
            ),
            Text(" $actives Activas  "),
            const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
            const SizedBox(
              width: 2.0,
            ),
            Text(" $inactives  Inactivas  "),
            const Icon(Icons.local_shipping_outlined),
            const SizedBox(
              width: 2.0,
            ),
            Text("Total Transportadoras $total  "),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(3.0)),
            child: dataTableTransports(context),
          ),
        ),
      ],
    );
  }

  Column movilContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width * 0.5,
          child: _modelTextField(
              text: "Buscar", controller: _controllers.searchController),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(
              width: 2.0,
            ),
            Text(" $actives Activas  "),
            const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
            const SizedBox(
              width: 2.0,
            ),
            Text(" $inactives  Inactivas  "),
            const Icon(Icons.local_shipping_outlined),
            const SizedBox(
              width: 2.0,
            ),
            Text("Total Transportadoras $total  "),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(3.0)),
            child: dataTableTransports(context),
          ),
        ),
      ],
    );
  }

  DataTable2 dataTableTransports(BuildContext context) {
    return DataTable2(
        headingTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dataTextStyle: TextStyle(
            fontSize: 12,
            // fontWeight: FontWeight.bold,
            color: Colors.black),
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 800,
        columns: [
          DataColumn2(
            label: Text('Usuario'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {
              // sortFuncUser();
            },
          ),
          DataColumn2(
            label: Text('Rutas'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncRutas();
            },
          ),
          DataColumn2(
            label: Text('Teléfono'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncRutas();
            },
          ),
          DataColumn2(
            label: Text(''),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text('Costo Entrega'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncCosto();
            },
          ),
          DataColumn2(
            label: Text('Tipo de Usuario'),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text('Supervisor Novedades'),
            size: ColumnSize.L,
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
            dataL.length,
            (index) => DataRow(cells: [
                  DataCell(Text(dataL[index]['nombre'].toString()),
                      onTap: () async {
                    print(dataL[index]
                                ['transportadoras_users_permissions_user_links']
                            [0]['up_user']['id']
                        .toString());
                    print("-----------------");
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateCarrierModalLaravel(
                              // idT: dataL[index]['id'].toString(),
                              // idP: dataL[index][
                              //             'transportadoras_users_permissions_user_links']
                              //         [0]['up_user']['id']
                              //     .toString(),

                              dataT: dataL[index]

                              // idT: dataL[index]['id'].toString(),
                              );
                        });
                    loadData();
                  }),
                  DataCell(
                    Tooltip(
                      message:
                          '${dataL[index]['rutas'] != null ? dataL[index]['rutas'].map((ruta) => ruta['titulo']).toList().join(', ') : ""}',
                      child: Row(
                        children: [
                          Icon(
                            Icons.route_outlined,
                            color: ColorsSystem().colorPrincipalBrand,
                          ),
                          Flexible(
                            child: Text(
                              "${dataL[index]['rutas'] != null ? dataL[index]['rutas'].map((ruta) => ruta['titulo']).toList().join(', ') : ""}",
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(dataL[index]["telefono_1"].toString()),
                      onTap: () {}),
                  DataCell(Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var _url = Uri(
                              scheme: 'tel',
                              path:
                                  // '+593${data[index]['telefono_1'].toString()}');
                                  '${dataL[index]['telefono_1'].toString()}');

                          if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                        child: Icon(
                          Icons.call,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final Uri _url = Uri(
                            scheme: 'sms',
                            path:
                                // '+593${data[index]['transportadora']['Telefono1'].toString()}',
                                '${dataL[index]['transportadora']['telefono_1'].toString()}',
                            queryParameters: <String, String>{
                              'body': Uri.encodeComponent(''),
                            },
                          );
                          if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                        child: Icon(
                          Icons.message_outlined,
                          size: 20,
                        ),
                      )
                    ],
                  )),
                  DataCell(
                      Text(
                          '\$${dataL[index] != null ? dataL[index]['costo_transportadora'].toString() : ""}'),
                      onTap: () async {
                    // await showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return UpdateCarrierModal(
                    //         idP: data[index]['id'].toString(),
                    //         idT: data[index]['transportadora']['id']
                    //             .toString(),
                    //       );
                    //     });
                    loadData();
                  }),
                  DataCell(Text('TRANSPORTADOR'), onTap: () async {
                    // await showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return UpdateCarrierModal(
                    //         idP: data[index]['id'].toString(),
                    //         idT: data[index]['transportadora']['id']
                    //             .toString(),
                    //       );
                    //     });
                    loadData();
                  }),
                  DataCell(
                    dataL[index]['novelties_supervisor'] != null &&
                            dataL[index]['novelties_supervisor']
                                .toString()
                                .isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blue[400],
                                ),
                                Text(dataL[index]['novelties_supervisor']
                                    .toString()),
                                GestureDetector(
                                  child: Icon(
                                    Icons.change_circle_outlined,
                                    color: Colors.orange,
                                  ),
                                  onTap: () {
                                    AwesomeDialog(
                                      body: Column(
                                        children: [
                                          Text("Actualizar Supervisor",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Container(
                                            margin: EdgeInsets.all(15.0),
                                            child: TextField(
                                              controller:
                                                  supervisorController, // Asume que ya tienes este controlador
                                              keyboardType: TextInputType
                                                  .number, // Muestra el teclado numérico
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                labelText: "Id del Supervisor",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                prefixIcon: Icon(Icons.person,
                                                    color: ColorsSystem()
                                                        .colorSelectMenu),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: ColorsSystem()
                                                          .colorSelectMenu),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                                                // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.info,
                                      animType: AnimType.rightSlide,
                                      btnOkText: "Aceptar",
                                      btnCancelText: "Cancelar",
                                      btnOkColor: Colors
                                          .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                                      btnCancelOnPress: () {
                                        supervisorController.clear();
                                      },
                                      btnOkOnPress: () async {
                                        String supervisorName =
                                            supervisorController.text;

                                        // Lógica para aceptar la acción, por ejemplo, actualizar el supervisor
                                        // getLoadingModal(context, false);

                                        await Connections().updateSupervisor(
                                            dataL[index]['id'].toString(),
                                            supervisorName);
                                        // supervisorController
                                        // .clear();
                                        // Navigator.pop(context);
                                        loadData();
                                      },
                                    ).show();
                                    supervisorController.clear();
                                  },
                                )
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                GestureDetector(
                                  child: Row(
                                    children: [
                                      Text(
                                        "ID ",
                                        style: TextStyle(
                                            color:
                                                ColorsSystem().colorSelectMenu),
                                      ),
                                      Icon(
                                        Icons.app_registration_rounded,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    AwesomeDialog(
                                      body: Column(
                                        children: [
                                          Text("Asignar Nuevo Supervisor",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Container(
                                            margin: EdgeInsets.all(15.0),
                                            child: TextField(
                                              controller:
                                                  supervisorController, // Asume que ya tienes este controlador
                                              keyboardType: TextInputType
                                                  .number, // Muestra el teclado numérico
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                labelText: "Id del Supervisor",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                prefixIcon: Icon(Icons.person,
                                                    color: ColorsSystem()
                                                        .colorSelectMenu),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: ColorsSystem()
                                                          .colorSelectMenu),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                                                // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.info,
                                      animType: AnimType.rightSlide,
                                      btnOkText: "Aceptar",
                                      btnCancelText: "Cancelar",
                                      btnOkColor: Colors
                                          .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                                      btnCancelOnPress: () {
                                        supervisorController.clear();
                                      },
                                      btnOkOnPress: () async {
                                        String supervisorName =
                                            supervisorController.text;

                                        // Lógica para aceptar la acción, por ejemplo, actualizar el supervisor
                                        // getLoadingModal(context, false);

                                        await Connections().updateSupervisor(
                                            dataL[index]['id'].toString(),
                                            supervisorName);
                                        supervisorController.clear();
                                        // Navigator.pop(context);
                                        loadData();
                                      },
                                    ).show();
                                    supervisorController.clear();
                                  },
                                )
                              ]),
                    onTap: () async {
                      // Aquí puedes definir lo que sucede cuando se toca el DataCell
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
                        btnCancelText: "Cancelar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          // getLoadingModal(context, false);
                          await Connections().updateAccountBlock(dataL[index][
                                      'transportadoras_users_permissions_user_links']
                                  [0]['up_user']['id']
                              .toString());

                          // Navigator.pop(context);
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
                        btnCancelText: "Cancelar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          // getLoadingModal(context, false);
                          var response = await Connections()
                              .updateAccountDisBlock(dataL[index][
                                          'transportadoras_users_permissions_user_links']
                                      [0]['up_user']['id']
                                  .toString());

                          // Navigator.pop(context);
                          await loadData();
                        },
                      ).show();
                    },
                    child: Icon(
                      Icons.lock_open_rounded,
                      color: Colors.green,
                    ),
                  )),
                  DataCell(
                    Text(
                      (dataL[index][
                                  'transportadoras_users_permissions_user_links']
                              as List)
                          .firstWhere((link) => link['up_user'] != null,
                              orElse: () => {
                                    'up_user': {'blocked': true}
                                  })['up_user']['blocked']
                          .toString(),
                    ),
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
                        btnCancelText: "Cancelar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          // getLoadingModal(context, false);
                          await Connections().deleteUser(dataL[index][
                                          'transportadoras_users_permissions_user_links'] !=
                                      null &&
                                  dataL[index][
                                          'transportadoras_users_permissions_user_links']
                                      .isNotEmpty
                              ? dataL[index]['transportadoras_users_permissions_user_links']
                                          [0]['up_user'] !=
                                      null
                                  ? dataL[index]
                                              ['transportadoras_users_permissions_user_links']
                                          [0]['up_user']['id']
                                      .toString()
                                  : ""
                              : "");
                          await Connections()
                              .deleteTransporter(dataL[index]['id']);
                          // Navigator.pop(context);
                          await loadData();
                        },
                      ).show();
                    },
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.redAccent,
                    ),
                  )),
                ])));
  }

  String contar(List<dynamic> data) {
    try {
      int actives = 0;
      int inactives = 0;

      for (var element in data) {
        if (element['transportadoras_users_permissions_user_links'] != null &&
            element['transportadoras_users_permissions_user_links']
                .isNotEmpty &&
            element['transportadoras_users_permissions_user_links'][0]
                    ['up_user'] !=
                null) {
          var blockedValue =
              element['transportadoras_users_permissions_user_links'][0]
                  ['up_user']['blocked'];
          if (blockedValue == "1") {
            inactives++;
          } else {
            actives++;
          }
        } else {
          inactives++;
        }
      }
      return "$actives-$inactives";
    } catch (e) {
      return "Error: $e";
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.5,
      // padding: EdgeInsets.only(top: 15.0),
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          paginateData();
          // loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });

                    setState(() {
                      paginateData();
                      // loadData();
                    });
                    // Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
        ),
        backgroundColor: Color.fromARGB(255, 253, 101, 90),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
