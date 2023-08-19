import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/add_operators_transport/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class EditOperatorTransport extends StatefulWidget {
  const EditOperatorTransport({super.key});

  @override
  State<EditOperatorTransport> createState() => _EditOperatorTransportState();
}

class _EditOperatorTransportState extends State<EditOperatorTransport> {
  AddOperatorsTransportControllers _controllers =
      AddOperatorsTransportControllers();
  List<String> subRoutes = [];
  String? selectedValueRoute;
  TextEditingController _password = TextEditingController();
  var data = {};
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
    });
    routesList = await Connections().getSubRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        subRoutes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
      });
    }
    var response = await Connections().getOperatorsGeneralByID();
    data = response;
    _controllers.updateControllersEdit(response);
    setState(() {
      selectedValueRoute =
          '${response['operadore']['sub_ruta']['Titulo']}-${response['operadore']['sub_ruta']['id']}';
    });
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators()
                  .pushNamedAndRemoveUntil(context, "/layout/transport");
            },
            child: Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: Text(
          "Información",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: ListView(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Bloqueado: ${data["blocked"].toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _modelTextFieldComplete(
                      "Usuario", _controllers.userEditController),
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
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      dropdownWidth: 500,
                      buttonWidth: 500,
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
                  _modelTextFieldComplete(
                      "Correo", _controllers.mailEditController),
                  _modelTextFieldComplete(
                      "Teléfono", _controllers.phoneEditController),
                  _modelTextFieldComplete("Costo Operador",
                      _controllers.costOperatorEditController),
                  ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        await _controllers.updateOperator(
                            success: () {
                              Navigator.pop(context);
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'Completado',
                                desc: 'Actualización Completada',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            },
                            error: () {
                              Navigator.pop(context);
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: 'Revisa los Campos',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            },
                            subRoute: selectedValueRoute!.split('-')[1]);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "Actualizar Datos",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  _modelTextFieldComplete("Contraseña", _password),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        var response = await Connections().updatePasswordById(
                          _password.text,
                        );
                        Navigator.pop(context);
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Completado',
                          desc: 'Actualización Completada',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "Actualizar Contraseña",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Column _modelTextFieldComplete(title, controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        _modelTextField(controller: controller),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _modelText(title, text) {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  _modelTextField({controller}) {
    return Container(
      width: 500,
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
}
