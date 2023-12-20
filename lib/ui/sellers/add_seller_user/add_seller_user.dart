import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/widgets/sellers/add_sellers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controllers/controllers.dart';
import '../../widgets/show_error_snackbar.dart';

class AddSellerUser extends StatefulWidget {
  const AddSellerUser({super.key});

  @override
  State<AddSellerUser> createState() => _AddSellerUserState();
}

class _AddSellerUserState extends State<AddSellerUser> {
  final AddSellerUserControllers _controllers = AddSellerUserControllers();
  List data = [];
  List<dynamic> accessTemp = [];
  var response;
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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
      response = await Connections()
          .getSellersByIdMaster(_controllers.searchController.text);
      data = response;
      print("cero> ${response[0]['permisos']}");

      if (response[0]['permisos'] != null) {
        if (response[0]['permisos'] is String) {
          accessTemp = jsonDecode(response[0]['permisos']);
        } else if (response[0]['permisos'] is List) {
          accessTemp = response[0]['permisos'];
        }
        print("at> $accessTemp");
      } else {
        print("response[0]['permisos'] es null");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: isLoading,
      blurEffectIntensity: 0,
      progressIndicator: SpinKitFadingCircle(
        color: const Color.fromARGB(255, 4, 2, 5),
        size: 90.0,
      ),
      dismissible: false,
      opacity: 0.1,
      color: Colors.black87,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
                context: (context),
                builder: (context) {
                  return AddSellerI(
                    accessTemp: accessTemp,
                  );
                  // return AddSellerI(accessTemp: [],);
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
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _modelTextField(
                    text: "Búsqueda",
                    controller: _controllers.searchController),
              ),
              Expanded(
                child: DataTable2(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 6,
                  minWidth: 650,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn2(
                      label: Text('Usuario'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Email'),
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
                      label: Text('Permisos'),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    data.length,
                    (index) {
                      Color rowColor = UIUtils.getColor('NINGUNO');
                      return DataRow(
                        onSelectChanged: (bool? selected) {
                          Navigators().pushNamed(
                            context,
                            '/layout/sellers/seller/details?id=${data[index]['id']}',
                          );
                        },
                        cells: [
                          DataCell(
                            Text(
                              data[index]['username'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data[index]['email'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
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
                          DataCell(
                            Text(
                              data[index]['permisos'].toString(),
                              style: TextStyle(
                                color: rowColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (v) async {
          await loadData();
        },
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: const Icon(Icons.close),
                )
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
