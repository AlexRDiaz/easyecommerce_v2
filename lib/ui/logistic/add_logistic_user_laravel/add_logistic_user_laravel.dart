import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/add_logistic_user_laravel/controller/add_logistic_user_controllers.dart';
import 'package:frontend/ui/logistic/add_logistic_user_laravel/edit_logistic_user_laravel.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/logistic/add_logistic_user.dart';
import 'package:frontend/ui/widgets/logistic/add_logistic_user_laravel.dart';
import 'package:url_launcher/url_launcher.dart';

class AddLogisticsUserLaravel extends StatefulWidget {
  const AddLogisticsUserLaravel({super.key});

  @override
  State<AddLogisticsUserLaravel> createState() =>
      _AddLogisticsUserLaravelState();
}

class _AddLogisticsUserLaravelState extends State<AddLogisticsUserLaravel> {
  AddLogisticsLaravelControllers _controllers =
      AddLogisticsLaravelControllers();
  List data = [];
  List dataTemporal = [];
  bool sort = false;

  int currentPage = 1;
  int pageSize = 150;
  int pageCount = 1;
  bool isLoading = false;
  int total = 0;
  bool _switchValue = false;

  String model = "UpUsersRolesFrontLink";

  var sortFieldDefaultValue = "";
  List populate = ["up_user", "roles_front"];
  List arrayFiltersAnd = [
    {"/up_user.active": "1"},
    {"/roles_front_id": "1"}
  ];
  List arrayFiltersOr = ["up_user.username"];
  // List arrayFiltersNot = [{"transportadoras_users_permissions_user_links.up_user.blocked":"0"}];
  List arrayFiltersNot = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
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
        data = [];
        data = responseL['data'];
      });

      total = responseL['total'];
      pageCount = responseL['last_page'];

      isLoading = false;
    } catch (e) {
      isLoading = false;
      _showErrorSnackBar(context, "> Ha ocurrido un error de conexión");
    }
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
              width: MediaQuery.of(context).size.width * 0.4,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
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
            Expanded(
              child: Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: dataTable(context)),
            ),
          ],
        ),
      ),
    );
  }

  DataTable2 dataTable(BuildContext context) {
    return DataTable2(
        headingTextStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dataTextStyle: TextStyle(fontSize: 12, color: Colors.black),
        columnSpacing: 10,
        horizontalMargin: 10,
        minWidth: 800,
        columns: [
          DataColumn2(
            label: Text('Id'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text('Usuario'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {},
          ),
          DataColumn2(
            label: Text('Persona Cargo'),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              // sortFuncPersonaCargo();
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
                  DataCell(Text(data[index]['up_user']['id'].toString())),
                  DataCell(onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return EditLogisticUserLaravel(dataT: data[index]);
                        });
                    loadData();
                  },
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: Colors.amber,
                          ),
                          Text(data[index]['up_user']['username'].toString()),
                        ],
                      )),
                  DataCell(
                      Text(data[index]['up_user']['persona_cargo'].toString()),
                      onTap: () {
                    // Navigators().pushNamed(context,
                    //     '/layout/logistic/logistic-user/info?id=${data[index]['id']}');
                  }),
                  DataCell(Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var _url = Uri(
                              scheme: 'tel',
                              path:
                                  '${data[index]['up_user']['telefono_1'].toString()}');

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
                              "https://api.whatsapp.com/send?phone=${data[index]['up_user']['telefono_1'].toString()}&text=Hola, me gustaría ......");
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
                      Text(data[index]['roles_front']['titulo'].toString()),
                      onTap: () {
                    // Navigators().pushNamed(context,
                    //     '/layout/logistic/logistic-user/info?id=${data[index]['id']}');
                  }),
                  DataCell(data[index]["up_user"] != null &&
                          data[index]["up_user"].isNotEmpty &&
                          (data[index]["up_user"]['active'] == true ||
                              data[index]["up_user"]['active'].toString() ==
                                  "1")
                      ? GestureDetector(
                          onTap: () async {
                            // getLoadingModal(context, false);
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
                                    data[index]["up_user"]['id'].toString(), 0);

                                // ! ------------------------------------

                                await loadData();
                              },
                            ).show();

                            // await Connections()
                            //     .deleteUser(data[index]['up_user']['id'].toString());

                            // Navigator.pop(context);
                            // await loadData();
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
                                    data[index]["up_user"]['id'].toString(), 1);

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

  modalAddLogisticUser(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AddLogisticUserLaravel();
        });
    await loadData();
  }

  _modelTextField({text, controller}) {
    return Container(
      margin: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
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
                      loadData();
                    });
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

  // sortFuncPersonaCargo() {
  //   if (sort) {
  //     setState(() {
  //       sort = false;
  //     });
  //     data.sort((a, b) => b['Persona_Cargo']
  //         .toString()
  //         .compareTo(a['Persona_Cargo'].toString()));
  //   } else {
  //     setState(() {
  //       sort = true;
  //     });
  //     data.sort((a, b) => a['Persona_Cargo']
  //         .toString()
  //         .compareTo(b['Persona_Cargo'].toString()));
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
