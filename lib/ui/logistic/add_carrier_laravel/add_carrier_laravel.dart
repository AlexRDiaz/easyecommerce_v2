import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/add_carrier/add_carrier_modal.dart';
import 'package:frontend/ui/logistic/add_carrier/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_carrier/update_carrier_modal.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_laravel.controllers/add_carrier_laravel.controlers.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_modal_laravel.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/update_carrier_modal_laravel.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/navigators.dart';

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
  String model = "Transportadora";

  var sortFieldDefaultValue = "";
  List populate = [
    'rutas',
    'transportadoras_users_permissions_user_links.up_user'
  ];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = ["nombre", "costo_transportadora", "telefono_1"];
  List arrayFiltersNot = [];

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
      // var response= [];
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
          "");

      total = responseL['total'];
      pageCount = responseL['last_page'];

      setState(() {
        dataL = [];
        dataL = responseL['data'];
      });

      isLoading = false;
    } catch (e) {
      isLoading = false;
      // print("error!!!:  $e");
      // print(isLoading);
      // ignore: use_build_context_synchronously
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
          "");

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return AddCarrierLaravelModal();
              });
          await loadData();
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
              // padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.5,
              child: _modelTextField(
                  text: "Buscar", controller: _controllers.searchController),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(3.0)),
                child: DataTable2(
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
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
                        label: Text('Ruta'),
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
                                await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return UpdateCarrierModalLaravel(
                                        // idP: dataL[index]['transportadoras_users_permissions_user_links'][0]['up_user']['id'].toString(),
                                        idT: dataL[index]['id'].toString(),
                                      );
                                    });
                                loadData();
                              }),
                              DataCell(
                                  Text(
                                      "${dataL[index]['rutas'] != null ? dataL[index]['rutas'].map((ruta) => ruta['titulo']).toList().toString() : ""}"),
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
                              DataCell(Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      var _url = Uri(
                                          scheme: 'tel',
                                          path:
                                              // '+593${data[index]['telefono_1'].toString()}');
                                              '${dataL[index]['telefono_1'].toString()}');

                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                            'Could not launch $_url');
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
                                        throw Exception(
                                            'Could not launch $_url');
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
                                              dataL[index]['id'].toString());

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
                                              dataL[index]['id'].toString());

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
                                Text(
                                  (dataL[index][
                                              'transportadoras_users_permissions_user_links']
                                          as List)
                                      .firstWhere(
                                          (link) => link['up_user'] != null,
                                          orElse: () => {
                                                'up_user': {
                                                  'blocked': 'false'
                                                }
                                              })['up_user']['blocked']
                                      .toString(),
                                ),
                              ),
                              DataCell(GestureDetector(
                                onTap: () async {
                                  // AwesomeDialog(
                                  //   width: 500,
                                  //   context: context,
                                  //   dialogType: DialogType.error,
                                  //   animType: AnimType.rightSlide,
                                  //   title: 'Seguro de Eliminar Usuario?',
                                  //   desc:
                                  //       'Si tiene asignado algun pedido en el sistema puede causar conflictos internos.',
                                  //   btnOkText: "Aceptar",
                                  //   btnOkColor: colors.colorGreen,
                                  //   btnCancelOnPress: () {},
                                  //   btnOkOnPress: () async {
                                  //     getLoadingModal(context, false);
                                  //     var response = await Connections()
                                  //         .deleteUser(
                                  //             data[index]['id'].toString());
                                  //     var responseOperator = await Connections()
                                  //         .deleteTransporter(data[index]
                                  //             ['transportadora']['id']);
                                  //     Navigator.pop(context);
                                  //     await loadData();

                                  //   },
                                  // ).show();
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
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });

                    setState(() {
                      paginateData();
                      // loadData();
                    });
                    Navigator.pop(context);
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

  // _modelTextField({text, controller}) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10.0),
  //       color: Color.fromARGB(255, 245, 244, 244),
  //     ),
  //     child: TextField(
  //       controller: controller,
  //       onSubmitted: (value) {
  //         getLoadingModal(context, false);

  //         setState(() {
  //           data = dataTemporal;
  //         });
  //         if (value.isEmpty) {
  //           setState(() {
  //             data = dataTemporal;
  //           });
  //         } else {
  //           var dataTemp = data
  //               .where((objeto) =>
  //                   objeto['transportadora']['rutas']
  //                       .toString()
  //                       .toLowerCase()
  //                       .contains(value.toLowerCase()) ||
  //                   objeto['username']
  //                       .toString()
  //                       .toLowerCase()
  //                       .contains(value.toLowerCase()) ||
  //                   objeto['transportadora']['Costo_Transportadora']
  //                       .toString()
  //                       .toLowerCase()
  //                       .contains(value.toLowerCase()))
  //               .toList();
  //           setState(() {
  //             data = dataTemp;
  //           });
  //         }
  //         Navigator.pop(context);

  //         // loadData();
  //       },
  //       onChanged: (value) {},
  //       style: TextStyle(fontWeight: FontWeight.bold),
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(Icons.search),
  //         suffixIcon: _controllers.searchController.text.isNotEmpty
  //             ? GestureDetector(
  //                 onTap: () {
  //                   getLoadingModal(context, false);
  //                   setState(() {
  //                     _controllers.searchController.clear();
  //                   });
  //                   setState(() {
  //                     data = dataTemporal;
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //                 child: Icon(Icons.close))
  //             : null,
  //         hintText: text,
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
  //         iconColor: Colors.black,
  //       ),
  //     ),
  //   );
  // }

  // sortFuncUser() {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) =>
  //         b['username'].toString().compareTo(a['username'].toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) =>
  //         a['username'].toString().compareTo(b['username'].toString()));
  //   }
  // }

  // sortFuncRutas() {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) => b['transportadora']['rutas']
  //         .toString()
  //         .compareTo(a['transportadora']['rutas'].toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) => a['transportadora']['rutas']
  //         .toString()
  //         .compareTo(b['transportadora']['rutas'].toString()));
  //   }
  // }

  // sortFuncCosto() {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) => b['transportadora']['Costo_Transportadora']
  //         .toString()
  //         .compareTo(a['transportadora']['Costo_Transportadora'].toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) => a['transportadora']['Costo_Transportadora']
  //         .toString()
  //         .compareTo(b['transportadora']['Costo_Transportadora'].toString()));
  //   }
  // }
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
