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
import 'package:frontend/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/navigators.dart';

class AddCarrier extends StatefulWidget {
  const AddCarrier({super.key});

  @override
  State<AddCarrier> createState() => _AddCarrierState();
}

class _AddCarrierState extends State<AddCarrier> {
  AddCarriersControllers _controllers = AddCarriersControllers();
  List data = [];
  List dataTemporal = [];
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
    var response =
        await Connections().getAllTransport(_controllers.searchController.text);
    data = response;
    dataTemporal = response;

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return AddCarrierModal();
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
                  minWidth: 800,
                  columns: [
                    DataColumn2(
                      label: Text('Usuario'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFuncUser();
                      },
                    ),
                    DataColumn2(
                      label: Text('Ruta'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncRutas();
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
                        sortFuncCosto();
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
                      data.length,
                      (index) => DataRow(cells: [
                            DataCell(Text(data[index]['username'].toString()),
                                onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UpdateCarrierModal(
                                      idP: data[index]['id'].toString(),
                                      idT: data[index]['transportadora']['id']
                                          .toString(),
                                    );
                                  });
                              loadData();
                            }),
                            DataCell(
                                Text(
                                    "${data[index]['transportadora']!=null?data[index]['transportadora']['rutas'] .map((ruta) => ruta['Titulo']).toList().toString():""}"),
                                onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UpdateCarrierModal(
                                      idP: data[index]['id'].toString(),
                                      idT: data[index]['transportadora']['id']
                                          .toString(),
                                    );
                                  });
                              loadData();
                            }),
                            DataCell(Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '+593${data[index]['transportadora']['Telefono1'].toString()}');

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
                                          '+593${data[index]['transportadora']['Telefono1'].toString()}',
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
                                    '\$${data[index]['transportadora']!=null?data[index]['transportadora']['Costo_Transportadora'].toString():""}'),
                                onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UpdateCarrierModal(
                                      idP: data[index]['id'].toString(),
                                      idT: data[index]['transportadora']['id']
                                          .toString(),
                                    );
                                  });
                              loadData();
                            }),
                            DataCell(Text('TRANSPORTADOR'), onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UpdateCarrierModal(
                                      idP: data[index]['id'].toString(),
                                      idT: data[index]['transportadora']['id']
                                          .toString(),
                                    );
                                  });
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
                                        .deleteUser(
                                            data[index]['id'].toString());
                                    var responseOperator = await Connections()
                                        .deleteTransporter(data[index]
                                            ['transportadora']['id']);
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

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          getLoadingModal(context, false);

          setState(() {
            data = dataTemporal;
          });
          if (value.isEmpty) {
            setState(() {
              data = dataTemporal;
            });
          } else {
            var dataTemp = data
                .where((objeto) =>
                    objeto['transportadora']['rutas']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['username']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['transportadora']['Costo_Transportadora']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                .toList();
            setState(() {
              data = dataTemp;
            });
          }
          Navigator.pop(context);

          // loadData();
        },
        onChanged: (value) {},
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });
                    setState(() {
                      data = dataTemporal;
                    });
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
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
          iconColor: Colors.black,
        ),
      ),
    );
  }

  sortFuncUser() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) =>
          b['username'].toString().compareTo(a['username'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) =>
          a['username'].toString().compareTo(b['username'].toString()));
    }
  }

  sortFuncRutas() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['transportadora']['rutas']
          .toString()
          .compareTo(a['transportadora']['rutas'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['transportadora']['rutas']
          .toString()
          .compareTo(b['transportadora']['rutas'].toString()));
    }
  }

  sortFuncCosto() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['transportadora']['Costo_Transportadora']
          .toString()
          .compareTo(a['transportadora']['Costo_Transportadora'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['transportadora']['Costo_Transportadora']
          .toString()
          .compareTo(b['transportadora']['Costo_Transportadora'].toString()));
    }
  }
}
