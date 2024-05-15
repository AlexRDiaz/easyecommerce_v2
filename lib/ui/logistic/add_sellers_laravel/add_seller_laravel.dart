import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_laravel.controllers/add_carrier_laravel.controlers.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_modal_laravel.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/update_carrier_modal_laravel.dart';
import 'package:frontend/ui/logistic/add_sellers_laravel/controllers/add_sellers_laravel.controllers.dart';
import 'package:frontend/ui/logistic/add_sellers_laravel/edit_seller_laravel.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class AddSellers extends StatefulWidget {
  const AddSellers({super.key});

  @override
  State<AddSellers> createState() => _AddSellersState();
}

class _AddSellersState extends State<AddSellers> {
  AddSellersLaravelControllers _controllers = AddSellersLaravelControllers();
  // List alllData = [];
  // List data = [];

  List dataL = [];
  List principalSellersIds = [];
  int currentPage = 1;
  int pageSize = 300;
  int pageCount = 1;
  bool isFirst = true;
  bool isLoading = false;
  int total = 0;
  int actives = 0;
  int inactives = 0;
  bool _switchValue = false;

  String model = "UpUsersVendedoresLink";

  var sortFieldDefaultValue = "vendedor_id:ASC";
  List populate = [
    'up_user.vendedores',
  ];
  List arrayFiltersAnd = [
    {"/up_user.active": "1"}
  ];
  // List arrayFiltersOr = ["nombre", "costo_transportadora", "telefono_1"];
  List arrayFiltersOr = [
    // "up_user.username",
    "up_user.vendedores.nombre_comercial"
  ];
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

      // if (principalSellersIds.isEmpty) {
      principalSellersIds = await Connections().getPrincipalSellers();
      // }

      // print(principalSellersIds);
      // print(responseL);

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
                  return modalAddSeller(context);
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
              // webContainer(context), movilContainer(context), context),
              webContainer(context),
              webContainer(context),
              context),
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
        // Container(
        //   margin: const EdgeInsets.all(10.0),
        //   child:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Usuarios Actuales"),
          Switch(
            value: _switchValue,
            onChanged: (newValue) {
              setState(() {
                _switchValue = newValue;
                // Modificar el valor de active en arrayFiltersAnd
                if (_switchValue) {
                  arrayFiltersAnd[0]["/up_user.active"] = "0";
                } else {
                  arrayFiltersAnd[0]["/up_user.active"] = "1";
                }
                // Volver a cargar los datos con los nuevos filtros
                loadData();
              });
            },
          ),
          Text("Usuarios Eliminados"),
        ]),
        //     const Icon(
        //       Icons.check_circle,
        //       color: Colors.green,
        //     ),
        //     const SizedBox(
        //       width: 2.0,
        //     ),
        //     Text(" $actives Activas  "),
        //     const Icon(
        //       Icons.close_rounded,
        //       color: Colors.red,
        //     ),
        //     const SizedBox(
        //       width: 2.0,
        //     ),
        //     Text(" $inactives  Inactivas  "),
        //     const Icon(Icons.local_shipping_outlined),
        //     const SizedBox(
        //       width: 2.0,
        //     ),
        //     Text("Total Transportadoras $total  "),
        //   ]),
        // ),
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
        minWidth: 850,
        columns: [
          DataColumn2(
            label: Text('Id'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {
              // sortFuncUser();
            },
          ),
          DataColumn2(
            label: Text('Tipo Vendedor'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncUser();
            },
          ),
          DataColumn2(
            label: Text('Nombre Comercial'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncUser();
            },
          ),
          DataColumn2(
            label: Text('Usuario'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncRutas();
            },
          ),
          DataColumn2(
            label: Text('Email'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncRutas();
            },
          ),
          DataColumn2(
            label: Text('Segundo Telf'),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(''),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Costo Envio'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncCosto();
            },
          ),
          DataColumn2(
            label: Text('Costo Devolución'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncCosto();
            },
          ),
          DataColumn2(
            label: Text('Referido Por'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncCosto();
            },
          ),
          DataColumn2(
            label: Text('Costo Referido'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              // sortFuncCosto();
            },
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
                  DataCell(Text(dataL[index]["up_user"]['id'].toString()),
                      onTap: () {}),
                  DataCell(
                      Row(
                        children: [
                          if (_principal(_getTypeSeller(dataL[index]
                                          ["up_user"] !=
                                      null &&
                                  dataL[index]["up_user"].isNotEmpty
                              ? dataL[index]["up_user"]['id'] != null
                                  ? int.parse(
                                      dataL[index]["up_user"]['id'].toString())
                                  : 0
                              : 0))) // Esta es una función que determina si es el principal.
                            Icon(Icons.star, color: Colors.orange),
                          Flexible(
                            child: Text(
                              _getTypeSeller(
                                dataL[index]["up_user"] != null &&
                                        dataL[index]["up_user"].isNotEmpty
                                    ? dataL[index]["up_user"]['id'] != null
                                        ? int.parse(dataL[index]["up_user"]
                                                ['id']
                                            .toString())
                                        : 0
                                    : 0,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {}),
                  DataCell(
                      Text(dataL[index]["up_user"]['vendedores'][0]
                              ['nombre_comercial']
                          .toString()), onTap: () async {
                    // print(dataL[index]
                    //             ['transportadoras_users_permissions_user_links']
                    //         [0]['up_user']['id']
                    //     .toString());
                    // print("-----------------");
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return EditSellersLaravel(
                              //           // idT: dataL[index]['id'].toString(),
                              //           // idP: dataL[index][
                              //           //             'transportadoras_users_permissions_user_links']
                              //           //         [0]['up_user']['id']
                              //           //     .toString(),

                              dataT: dataL[index]

                              //           // idT: dataL[index]['id'].toString(),
                              );
                        });
                    loadData();
                  }),
                  // DataCell(
                  //   Tooltip(
                  //     message:
                  //         '${dataL[index]['rutas'] != null ? dataL[index]['rutas'].map((ruta) => ruta['titulo']).toList().join(', ') : ""}',
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           Icons.route_outlined,
                  //           color: ColorsSystem().colorPrincipalBrand,
                  //         ),
                  //         Flexible(
                  //           child: Text(
                  //             "${dataL[index]['rutas'] != null ? dataL[index]['rutas'].map((ruta) => ruta['titulo']).toList().join(', ') : ""}",
                  //             overflow: TextOverflow.ellipsis,
                  //             softWrap: false,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  DataCell(
                      Text(dataL[index]["up_user"] != null &&
                              dataL[index]["up_user"].isNotEmpty
                          ? dataL[index]["up_user"]['username'] != null
                              ? dataL[index]["up_user"]['username'].toString()
                              : ""
                          : ""),
                      onTap: () {}),
                  DataCell(
                      Text(dataL[index]["up_user"] != null &&
                              dataL[index]["up_user"].isNotEmpty
                          ? dataL[index]["up_user"]['email'] != null
                              ? dataL[index]["up_user"]['email'].toString()
                              : ""
                          : ""),
                      onTap: () {}),
                  DataCell(
                      Text(dataL[index]["up_user"]['vendedores'][0]
                              ['telefono_2']
                          .toString()),
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
                                  '${dataL[index]["up_user"]['vendedores'][0]['telefono_1'].toString()}');

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
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final Uri _url = Uri(
                            scheme: 'sms',
                            path:
                                // '+593${data[index]['transportadora']['Telefono1'].toString()}',
                                '${dataL[index]["up_user"]['vendedores'][0]['telefono_1'].toString()}',
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
                      Text(dataL[index]["up_user"]['vendedores'][0]
                              ['costo_envio']
                          .toString()),
                      onTap: () {}),
                  DataCell(
                      Text(dataL[index]["up_user"]['vendedores'][0]
                              ['costo_devolucion']
                          .toString()),
                      onTap: () {}),
                  DataCell(
                      Text(dataL[index]["up_user"]['vendedores'][0]
                                  ['referer'] !=
                              null
                          ? dataL[index]["up_user"]['vendedores'][0]['referer']
                              .toString()
                          : ""),
                      onTap: () {}),
                  DataCell(
                      // dataL[index]["up_user"]['vendedores'][0]['referer_cost'] != null &&
                      // dataL[index]["up_user"]['vendedores'][0]['referer_cost'].toString().isNotEmpty?

                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(dataL[index]["up_user"]['vendedores'][0]
                                        ['referer_cost'] !=
                                    null
                                ? dataL[index]["up_user"]['vendedores'][0]
                                        ['referer_cost']
                                    .toString()
                                : ""),
                            GestureDetector(
                              child: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onTap: () {
                                AwesomeDialog(
                                  body: Column(
                                    children: [
                                      Text("Actualizar Costo Referenciado",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "Ingrese valores en el formato  decimal (ej: 0.50)"),
                                      Container(
                                        margin: EdgeInsets.all(15.0),
                                        child: TextField(
                                          controller:
                                              supervisorController, // Asume que ya tienes este controlador
                                          // keyboardType: TextInputType
                                          //     .number, // Muestra el teclado numérico
                                          // inputFormatters: [
                                          //   FilteringTextInputFormatter
                                          //       .digitsOnly
                                          // ],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal:
                                                  true), // Permite números y punto decimal
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'^\d*\.?\d*')), // Expresión regular para números con o sin decimales
                                          ],
                                          decoration: InputDecoration(
                                            labelText: "Valor por Referenciado",
                                            labelStyle: const TextStyle(
                                                color: Colors.grey),
                                            prefixIcon: Icon(Icons.attach_money,
                                                color: ColorsSystem()
                                                    .colorSelectMenu),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: ColorsSystem()
                                                      .colorSelectMenu),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
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
                                    if (supervisorName != "") {
                                      await Connections().updateRefererCost(
                                          dataL[index]['vendedor_id']
                                              .toString(),
                                          supervisorName);
                                      loadData();
                                    } else {
                                      _showErrorSnackBar(context,
                                          "Costo Referido Vacío, Ingrese un Valor.");
                                    }
                                  },
                                ).show();
                                supervisorController.clear();
                              },
                            )
                          ])
                      // :Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // children: [
                      //     GestureDetector(
                      //       child: Row(
                      //         children: [
                      //           Text(
                      //             "ID ",
                      //             style: TextStyle(
                      //                 color:
                      //                     ColorsSystem().colorSelectMenu),
                      //           ),
                      //           Icon(
                      //             Icons.app_registration_rounded,
                      //             color: Colors.orange,
                      //           ),
                      //         ],
                      //       ),
                      //       onTap: () {
                      //         AwesomeDialog(
                      //           body: Column(
                      //             children: [
                      //               Text("Asignar Nuevo Supervisor",
                      //                   style: TextStyle(
                      //                       fontSize: 18,
                      //                       fontWeight: FontWeight.bold)),
                      //               Container(
                      //                 margin: EdgeInsets.all(15.0),
                      //                 child: TextField(
                      //                   controller:
                      //                       supervisorController, // Asume que ya tienes este controlador
                      //                   keyboardType: TextInputType
                      //                       .number, // Muestra el teclado numérico
                      //                   inputFormatters: [
                      //                     FilteringTextInputFormatter
                      //                         .digitsOnly
                      //                   ],
                      //                   decoration: InputDecoration(
                      //                     labelText: "Id del Supervisor",
                      //                     labelStyle: TextStyle(
                      //                         color: Colors.grey),
                      //                     prefixIcon: Icon(Icons.person,
                      //                         color: ColorsSystem()
                      //                             .colorSelectMenu),
                      //                     enabledBorder:
                      //                         OutlineInputBorder(
                      //                       borderSide: BorderSide(
                      //                           color: ColorsSystem()
                      //                               .colorSelectMenu),
                      //                       borderRadius:
                      //                           BorderRadius.circular(
                      //                               15.0),
                      //                     ),
                      //                     focusedBorder:
                      //                         OutlineInputBorder(
                      //                       borderSide: BorderSide(
                      //                           color: Colors.blue),
                      //                       borderRadius:
                      //                           BorderRadius.circular(
                      //                               15.0),
                      //                     ),
                      //                     // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                      //                     // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //           width: 500,
                      //           context: context,
                      //           dialogType: DialogType.info,
                      //           animType: AnimType.rightSlide,
                      //           btnOkText: "Aceptar",
                      //           btnCancelText: "Cancelar",
                      //           btnOkColor: Colors
                      //               .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                      //           btnCancelOnPress: () {
                      //             supervisorController.clear();
                      //           },
                      //           btnOkOnPress: () async {
                      //             String supervisorName =
                      //                 supervisorController.text;

                      //             // Lógica para aceptar la acción, por ejemplo, actualizar el supervisor
                      //             // getLoadingModal(context, false);

                      //             await Connections().updateSupervisor(
                      //                 dataL[index]['id'].toString(),
                      //                 supervisorName);
                      //             supervisorController.clear();
                      //             // Navigator.pop(context);
                      //             loadData();
                      //           },
                      //         ).show();
                      //         supervisorController.clear();
                      //       },
                      //     )
                      //   ])
                      ,
                      onTap: () {}),
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
                          await Connections().updateAccountBlock(
                              dataL[index]["up_user"]['id'].toString());

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
                              .updateAccountDisBlock(
                                  dataL[index]["up_user"]['id'].toString());

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
                      Text(dataL[index]["up_user"] != null &&
                              dataL[index]["up_user"].isNotEmpty
                          ? dataL[index]["up_user"]['blocked'] != null
                              ? dataL[index]["up_user"]['blocked'].toString()
                              : ""
                          : ""),
                      onTap: () {}),
                  DataCell(dataL[index]["up_user"] != null &&
                          dataL[index]["up_user"].isNotEmpty &&
                          (dataL[index]["up_user"]['active'] == true ||
                              dataL[index]["up_user"]['active'].toString() ==
                                  "1")
                      ? GestureDetector(
                          onTap: () async {
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Seguro de Eliminar Usuario?',
                              desc:
                                  'Se eliminara el usuario selecionado del sistema, puede recuperarlo desde el apartado Usuarios Eliminados.',
                              btnOkText: "Aceptar",
                              btnCancelText: "Cancelar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                // getLoadingModal(context, false);
                                // await Connections().deleteUser(dataL[index]['id']);
                                // ! --------------- USANDO ACTUALMENTE---------------------
                                // await Connections().deleteUser(
                                //     dataL[index]["up_user"]['id'].toString());
                                // await Connections().deleteSellers(
                                //     dataL[index]["up_user"]['vendedores'][0]['id']);
                                await Connections().updateUserActiveStatus(
                                    dataL[index]["up_user"]['id'].toString(),
                                    0);

                                // ! ------------------------------------

                                await loadData();
                              },
                            ).show();
                          },
                          child: Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Seguro de Restaurar el Usuario?',
                              desc:
                                  'Se restaurara el usuario seleccionado en la plataforma.',
                              btnOkText: "Aceptar",
                              btnCancelText: "Cancelar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                // getLoadingModal(context, false);
                                // await Connections().deleteUser(dataL[index]['id']);
                                // ! --------------- USANDO ACTUALMENTE---------------------
                                // await Connections().deleteUser(
                                //     dataL[index]["up_user"]['id'].toString());
                                // await Connections().deleteSellers(
                                //     dataL[index]["up_user"]['vendedores'][0]['id']);
                                await Connections().updateUserActiveStatus(
                                    dataL[index]["up_user"]['id'].toString(),
                                    1);

                                // ! ------------------------------------

                                await loadData();
                              },
                            ).show();
                          },
                          child: Icon(
                            Icons.screen_rotation_alt_outlined,
                            color: Colors.green,
                          ),
                        )),
                ])));
  }

  String _getTypeSeller(idData) {
    String result = "Secundario";

    for (var idSeller in principalSellersIds) {
      if (idData == idSeller) {
        result = "Principal";
      }
    }
    return result;
  }

  bool _principal(value) {
    bool result = false;

    if (value == "Principal") {
      result = true;
    }

    return result;
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

  AlertDialog modalAddSeller(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 500,
        height: 550,
        child: ListView(
          padding: EdgeInsets.all(12.0),
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Asegura que los hijos de la Row se distribuyan al inicio y al final
                  children: [
                    Text(
                      "Registro de Vendedor",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(), // Inserta un Spacer aquí
                    Align(
                      alignment: Alignment
                          .centerRight, // Corrige el alineamiento aquí si es necesario, aunque puede no ser necesario con el uso de Spacer
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                _styledTextField(
                    controller: _controllers.comercialNameController,
                    hintText: "Nombre Comercial",
                    prefixIcon: Icons.business,
                    iconColor: Colors.orange),
                _styledTextField(
                    controller: _controllers.phone1Controller,
                    hintText: "Número de Teléfono",
                    prefixIcon: Icons.phone_android,
                    iconColor: Colors.teal),
                _styledTextField(
                    controller: _controllers.phone2Controller,
                    hintText: "Teléfono Dos",
                    prefixIcon: Icons.phone,
                    iconColor: Colors.brown),
                _styledTextField(
                    controller: _controllers.userController,
                    hintText: "Usuario",
                    prefixIcon: Icons.person,
                    iconColor: Colors.deepPurpleAccent),
                _styledTextField(
                    controller: _controllers.mailController,
                    hintText: "Correo",
                    prefixIcon: Icons.email_outlined,
                    iconColor: ColorsSystem().colorSelectMenu),
                _styledTextField(
                    controller: _controllers.sendCostController,
                    hintText: "Costo Envío",
                    prefixIcon: Icons.attach_money,
                    iconColor: Colors.green),
                _styledTextField(
                    controller: _controllers.returnCostController,
                    hintText: "Costo Devolución",
                    prefixIcon: Icons.attach_money,
                    iconColor: Colors.green),
                _styledTextField(
                    controller: _controllers.urlComercialController,
                    hintText: "Url Tienda",
                    prefixIcon: Icons.wysiwyg_rounded,
                    iconColor: Colors.red),
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  width: 450,
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          // getLoadingModal(context, false);

                          await _controllers.createUser(success: (id) {
                            // Navigator.pop(context);
                            loadData();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Completado",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text:
                                                      // "${serverUrlByShopify}/$id"));
                                                      "${serverUrlByShopifyLaravel}/$id"));

                                              Get.snackbar('COPIADO',
                                                  'Copiado al Clipboard');
                                            },
                                            child: Text(
                                              "Copiar",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Flexible(
                                            child: Text(
                                          // 'Identificador: ${serverUrlByShopify}/$id',
                                          'Identificador: ${serverUrlByShopifyLaravel}/$id',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "ACEPTAR",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                      SizedBox(
                                        width: 10,
                                      )
                                    ],
                                  );
                                });
                            _controllers.comercialNameController.clear();
                            _controllers.phone1Controller.clear();
                            _controllers.phone2Controller.clear();
                            _controllers.userController.clear();
                            _controllers.mailController.clear();
                            _controllers.sendCostController.clear();
                            _controllers.returnCostController.clear();
                            _controllers.urlComercialController.clear();
                            setState(() {});
                          }, error: () {
                            // Navigator.pop(context);
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Vuelve a intentarlo',
                              btnOkText: "Aceptar",
                              btnCancelText: "Cancelar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                Navigator.pop(context);
                              },
                            ).show();
                          });
                        },
                        child: Text(
                          "Guardar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
    // });
  }

  // Column _modelTextFieldCompleteModal(title, controller) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       _modelTextFieldModal(controller: controller),
  //       SizedBox(
  //         height: 20,
  //       ),
  //     ],
  //   );
  // }

  // _modelTextFieldModal({controller}) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10.0),
  //       color: Color.fromARGB(255, 245, 244, 244),
  //     ),
  //     child: TextField(
  //       controller: controller,
  //       onChanged: (value) {
  //         setState(() {});
  //       },
  //       style: TextStyle(fontWeight: FontWeight.bold),
  //       decoration: InputDecoration(
  //         enabledBorder: OutlineInputBorder(
  //           borderSide:
  //               BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide:
  //               BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         focusColor: Colors.black,
  //       ),
  //     ),
  //   );
  // }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    Color iconColor = Colors.green,
    BorderSide borderStyle = const BorderSide(color: Colors.blueGrey),
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      height: 45.0,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: iconColor) : null,
          enabledBorder: OutlineInputBorder(
            borderSide: borderStyle,
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Colors.blue[50],
          filled: true,
        ),
      ),
    );
  }
}
