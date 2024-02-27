import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/add_logistic_user_laravel/controller/add_logistic_user_controllers.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class EditLogisticUserLaravel extends StatefulWidget {
  final dataT;
  const EditLogisticUserLaravel({super.key, required this.dataT});

  @override
  State<EditLogisticUserLaravel> createState() =>
      _EditLogisticUserLaravelState();
}

class _EditLogisticUserLaravelState extends State<EditLogisticUserLaravel> {
  AddLogisticsLaravelControllers _controllers =
      AddLogisticsLaravelControllers();

  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  int idUser = 0;
  List data = [];
  bool isLoading = false;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
        data = [widget.dataT];
      });

      accessGeneralofRol = await Connections().getAccessofRolById(1);
      _controllers.updateControllersEdit(data);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("ERROR EN loadData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    idUser = data[0]['up_user']['id'];
    accessTemp = json.decode(data[0]['up_user']['permisos']);
    return CustomProgressModal(
      isLoading: isLoading,
      content: AlertDialog(
        content: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.all(12.0),
            children: [
              responsive(webContainer(context), webContainer(context), context)
            ],
          ),
        ),
      ),
    );
  }

  Column webContainer(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        _styledTextField(
            hintText: "Usuario",
            controller: _controllers.userEditController,
            prefixIcon: Icons.person,
            iconColor: Colors.blue),
        SizedBox(
          height: 10,
        ),
        _styledTextField(
            hintText: "Email",
            controller: _controllers.mailEditController,
            prefixIcon: Icons.email,
            iconColor: Colors.red),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () async {
              // getLoadingModal(context, false);
              var response = await Connections()
                  .updatePassWordbyIdLaravel(idUser, "123456789");
              // Navigator.pop(context);
              if (response["message"] ==
                  "Actualización de contraseña exitosa") {
                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.rightSlide,
                  title: 'Completado',
                  desc: 'Restablecimiento Completada',
                  btnOkText: "Aceptar",
                  btnOkColor: colors.colorGreen,
                  btnOkOnPress: () {},
                ).show();
              } else {
                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Error',
                  desc: 'Error',
                  btnOkText: "Aceptar",
                  btnOkColor: colors.colorGreen,
                  btnOkOnPress: () {},
                ).show();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              "Restablecer Contraseña",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 20,
        ),
        _styledTextField(
            hintText: "Persona Cargo",
            controller: _controllers.personEditController,
            prefixIcon: Icons.supervisor_account,
            iconColor: Colors.deepPurple),
        SizedBox(
          height: 10,
        ),
        _styledTextField(
            hintText: "Teléfono Uno",
            controller: _controllers.phone1EditController,
            prefixIcon: Icons.phone,
            iconColor: Colors.green),
        SizedBox(
          height: 10,
        ),
        _styledTextField(
            hintText: "Teléfono Dos",
            controller: _controllers.phone2EditController,
            prefixIcon: Icons.phone_android,
            iconColor: Colors.orange),
        SizedBox(
          height: 10,
        ),
        _modelText("Fecha de Alta", data[0]["fecha_alta"].toString()),
        // _permisos(),
        SizedBox(
          height: 20,
        ),
        Text(
          "Accesos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Container(
          margin: EdgeInsets.all(20.0),
          height: 500,
          width: 500,
          decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0)),
          child: Builder(
            builder: (context) {
              return CustomFilterChips(
                accessTemp: accessTemp,
                accessGeneralofRol: accessGeneralofRol,
                loadData: loadData,
                idUser: idUser.toString(),
              );
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () async {
              getLoadingModal(context, false);
              await _controllers.updateUser(
                  id: idUser,
                  success: () async {
                    Navigator.pop(context);
                    await loadData();
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Completado',
                      desc: 'Actualización Completada',
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnOkOnPress: () {
                        Navigator.pop(context);
                      },
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
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnOkOnPress: () {
                        Navigator.pop(context);
                      },
                    ).show();
                  });
              loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.colorGreen),
            child: Text(
              "Actualizar Datos",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  // _permisos() {
  //   return Container(
  //     width: 500,
  //     child: Column(
  //       children: [
  //         Text(
  //           "PERMISOS",
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           "PERMISOS ACTUALES: ${data['PERMISOS'].toString()}",
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Column _modelTextFieldComplete(title, controller) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       _modelTextField(controller: controller),
  //       SizedBox(
  //         height: 20,
  //       ),
  //     ],
  //   );
  // }

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

  // _modelTextField({controller}) {
  //   return Container(
  //     width: 500,
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
