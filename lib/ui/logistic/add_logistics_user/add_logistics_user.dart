import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/add_logistic_user.dart';
import 'package:url_launcher/url_launcher.dart';

class AddLogisticsUser extends StatefulWidget {
  const AddLogisticsUser({super.key});

  @override
  State<AddLogisticsUser> createState() => _AddLogisticsUserState();
}

class _AddLogisticsUserState extends State<AddLogisticsUser> {
  AddLogisticsControllers _controllers = AddLogisticsControllers();
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
    var response = await Connections()
        .getLogisticUsers(_controllers.searchController.text);
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
          modalAddLogisticUser(context);
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
                      label: Text('Persona Cargo'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncPersonaCargo();
                      },
                    ),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Tipo de Usuario'),
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
                            DataCell(onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/logistic-user/info?id=${data[index]['id']}');
                            }, Text(data[index]['username'].toString())),
                            DataCell(
                                Text(data[index]['Persona_Cargo'].toString()),
                                onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/logistic-user/info?id=${data[index]['id']}');
                            }),
                            DataCell(Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var _url = Uri(
                                        scheme: 'tel',
                                        path:
                                            '${data[index]['Telefono1'].toString()}');

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
                                        "https://api.whatsapp.com/send?phone=${data[index]['Telefono1'].toString()}&text=Hola, me gustaría ......");
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
                                Text(data[index]['roles_front']['Titulo']
                                    .toString()), onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/logistic-user/info?id=${data[index]['id']}');
                            }),
                            DataCell(GestureDetector(
                              onTap: () async {
                                getLoadingModal(context, false);
                                var response = await Connections()
                                    .deleteUser(data[index]['id']);

                                Navigator.pop(context);
                                await loadData();
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

  modalAddLogisticUser(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AddLogisticUser();
        });
    await loadData();
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
                    objeto['Persona_Cargo']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    objeto['username']
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

  sortFuncPersonaCargo() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['Persona_Cargo']
          .toString()
          .compareTo(a['Persona_Cargo'].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['Persona_Cargo']
          .toString()
          .compareTo(b['Persona_Cargo'].toString()));
    }
  }
}
