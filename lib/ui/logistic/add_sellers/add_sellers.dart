import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/server.dart';
import 'package:get/route_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class AddSellers extends StatefulWidget {
  const AddSellers({super.key});

  @override
  State<AddSellers> createState() => _AddSellersState();
}

class _AddSellersState extends State<AddSellers> {
  AddSellersControllers _controllers = AddSellersControllers();
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
        await Connections().getSellers(_controllers.searchController.text);
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
        onPressed: () {
          modalAddSeller(context);
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
                      label: Text('Nombre Comercial'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFuncComercial();
                      },
                    ),
                    DataColumn2(
                      label: Text('Usuario'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncUser();
                      },
                    ),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Costo Envio'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncCostoEnvio();
                      },
                    ),
                    DataColumn2(
                      label: Text('Costo Devolución'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncCostoDevolucion();
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
                      data.length,
                      (index) => DataRow(cells: [
                            DataCell(
                                Text(data[index]['vendedores']!=null && data[index]['vendedores'].toString() !="[]"?data[index]['vendedores'][0]
                                        ['Nombre_Comercial']
                                    .toString():""), onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/sellers/info?id=${data[index]['id']}&id_Comercial=${data[index]['vendedores'][0]['id']}');
                            }),
                            DataCell(Text(data[index]['username'].toString()),
                                onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/sellers/info?id=${data[index]['id']}&id_Comercial=${data[index]['vendedores'][0]['id']}');
                            }),
                            DataCell(Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '+593${data[index]['vendedores'][0]['Telefono1'].toString()}');

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
                                    var _url = Uri.parse(
                                        "https://api.whatsapp.com/send?phone=+593${data[index]['vendedores'][0]['Telefono1'].toString()}&text=Hola, me gustaría ......");
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
                                    '\$${data[index]['vendedores']!=null&&data[index]['vendedores'].toString()!="[]"?data[index]['vendedores'][0]['CostoEnvio']:""}'),
                                onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/sellers/info?id=${data[index]['id']}&id_Comercial=${data[index]['vendedores'][0]['id']}');
                            }),
                            DataCell(
                                Text(
                                    '\$${data[index]['vendedores']!=null&&data[index]['vendedores'].toString()!="[]"?data[index]['vendedores'][0]['CostoDevolucion']:""}'),
                                onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/sellers/info?id=${data[index]['id']}&id_Comercial=${data[index]['vendedores'][0]['id']}');
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
                                        .deleteSellers(
                                            data[index]['vendedores'][0]['id']);
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

  Future<dynamic> modalAddSeller(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
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
                      _modelTextFieldCompleteModal("Nombre Comercial",
                          _controllers.comercialNameController),
                      _modelTextFieldCompleteModal(
                          "Número de Teléfono", _controllers.phone1Controller),
                      _modelTextFieldCompleteModal(
                          "Teléfono Dos", _controllers.phone2Controller),
                      _modelTextFieldCompleteModal(
                          "Usuario", _controllers.userController),
                      _modelTextFieldCompleteModal(
                          "Correo", _controllers.mailController),
                      _modelTextFieldCompleteModal(
                          "Costo Envío", _controllers.sendCostController),
                      _modelTextFieldCompleteModal("Costo Devolución",
                          _controllers.returnCostController),
                      _modelTextFieldCompleteModal(
                          "Url Tienda", _controllers.urlComercialController),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                minimumSize: Size(200, 40)),
                            onPressed: () async {
                              getLoadingModal(context, false);
                              var responseCode = await Connections()
                                  .generateCodeAccount(
                                      _controllers.mailController.text);
                              await _controllers.createUser(
                                  code: responseCode.toString(),
                                  success: (id) {
                                    Navigator.pop(context);
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
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "${serverUrlByShopify}/$id"));
                                                      Get.snackbar('COPIADO',
                                                          'Copiado al Clipboard');
                                                    },
                                                    child: Text(
                                                      "Copiar",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                Flexible(
                                                    child: Text(
                                                  'Identificador: ${serverUrlByShopify}/$id',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        });
                                    _controllers.comercialNameController
                                        .clear();
                                    _controllers.phone1Controller.clear();
                                    _controllers.phone2Controller.clear();
                                    _controllers.userController.clear();
                                    _controllers.mailController.clear();
                                    _controllers.sendCostController.clear();
                                    _controllers.returnCostController.clear();
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
                                  });
                            },
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
                    objeto['vendedores'][0]['Nombre_Comercial']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['username']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['vendedores'][0]['CostoEnvio']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['vendedores'][0]['CostoDevolucion']
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

  sortFuncComercial() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['vendedores'][0]['Nombre_Comercial']
          .toString()
          .compareTo(a['vendedores'][0]['Nombre_Comercial'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['vendedores'][0]['Nombre_Comercial']
          .toString()
          .compareTo(b['vendedores'][0]['Nombre_Comercial'].toString()));
    }
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

  sortFuncCostoEnvio() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['vendedores'][0]['CostoEnvio']
          .toString()
          .compareTo(a['vendedores'][0]['CostoEnvio'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['vendedores'][0]['CostoEnvio']
          .toString()
          .compareTo(b['vendedores'][0]['CostoEnvio'].toString()));
    }
  }

  sortFuncCostoDevolucion() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['vendedores'][0]['CostoDevolucion']
          .toString()
          .compareTo(a['vendedores'][0]['CostoDevolucion'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['vendedores'][0]['CostoDevolucion']
          .toString()
          .compareTo(b['vendedores'][0]['CostoDevolucion'].toString()));
    }
  }
}
