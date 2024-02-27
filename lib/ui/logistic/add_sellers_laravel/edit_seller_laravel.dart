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
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/logistic/add_sellers_laravel/controllers/add_sellers_laravel.controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class EditSellersLaravel extends StatefulWidget {
  final dataT;

  const EditSellersLaravel({super.key, required this.dataT});

  @override
  State<EditSellersLaravel> createState() => _EditSellersLaravelState();
}

class _EditSellersLaravelState extends State<EditSellersLaravel> {
  AddSellersLaravelControllers _controllers = AddSellersLaravelControllers();
  String usernameTemp = "";
  String emailTemp = "";
  String idShopify = "";
  int idUser = 0;
  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  List dataL = [];
  bool isLoading = false;

  var data = {};
  

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
        dataL = [widget.dataT];
      });
      accessGeneralofRol = await Connections().getAccessofRolById(2);
      _controllers.updateControllersEdit(dataL);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("ERROR EN loadData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      idUser = dataL[0]['up_user']['id'];
      usernameTemp = dataL[0]['up_user']['username'].toString();
      emailTemp = dataL[0]['up_user']['email'].toString();
      idShopify = dataL[0]['up_user']['vendedores'][0]['id_master'];
      accessTemp = json.decode(dataL[0]['up_user']['permisos']);
    });
    return CustomProgressModal(
        isLoading: isLoading,
        content: AlertDialog(
            content: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.all(12.0),
            children: [responsive(webContainer(context), webContainer(context), context)],
          ),
        )));
  }

  Column webContainer(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Bloqueado: ${dataL[0]["up_user"] != null && dataL[0]["up_user"].isNotEmpty ? dataL[0]["up_user"]['blocked'] != null ? dataL[0]["up_user"]['blocked'].toString() : "" : ""}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        SizedBox(
          height: 30,
        ),
        // Text(
        //   "ESTADO: ${data["Estado"].toString()}",
        //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.only(right: 8.0),
        //       child: FloatingActionButton(
        //         heroTag: "fab1",
        //         onPressed: () {
        //           // Manejo del boton
        //         },
        //         child: Icon(Icons.arrow_back),
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(left: 8.0),
        //       child: FloatingActionButton(
        //         heroTag: "fab2",
        //         onPressed: () {
        //           // Manejo del boton
        //         },
        //         child: Icon(Icons.arrow_forward),
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(
        //   height: 30,
        // ),
        _identifier(),
        SizedBox(
          height: 20,
        ),

        _styledTextField(
          controller: _controllers.comercialNameEditController,
          labelText: "Nombre Comercial",
          prefixIcon: Icons.business,
          iconColor: Colors.orange,
        ),
        _styledTextField(
          controller: _controllers.userEditController,
          labelText: "Usuario",
          prefixIcon: Icons.person,
          iconColor: Colors
              .green, // Asumiendo que quieres un color específico para cada uno
        ),
        _styledTextField(
          controller: _controllers.mailEditController,
          labelText: "Correo",
          prefixIcon: Icons.email,
          iconColor: Colors.red,
        ),
        ElevatedButton(
            onPressed: () async {
              // getLoadingModal(context, false
              var response = await Connections().updatePassWordbyIdLaravel(idUser, "123456789");

              // print(response);
              // Navigator.pop(context);
              if (response["message"] == "Actualización de contraseña exitosa")  {
                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.rightSlide,
                  title: 'Completado',
                  desc: 'Restablecimiento Completada',
                  btnOkText: "Aceptar",
                  btnOkColor: colors.colorGreen,
                  btnCancelOnPress: () {},
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
                  btnCancelOnPress: () {},
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
          controller: _controllers.phone1EditController,
          labelText: "Número de Teléfono",
          prefixIcon: Icons.phone_android,
          iconColor: Colors.teal,
        ),
        _styledTextField(
          controller: _controllers.phone2EditController,
          labelText: "Teléfono Dos",
          prefixIcon: Icons.phone,
          iconColor: Colors.brown,
        ),
// Asume que _modelText y otros widgets específicos son manejados separadamente
        _styledTextField(
          controller: _controllers.sendCostEditController,
          labelText: "Costo Envio",
          prefixIcon: Icons.attach_money,
          iconColor: Colors.green, // Ajusta según necesites
        ),
        _styledTextField(
          controller: _controllers.returnCostEditController,
          labelText: "Costo Devolución",
          prefixIcon: Icons.attach_money,
          iconColor: Colors.green, // Ajusta según necesites
        ),
        _styledTextField(
          controller: _controllers.urlTiendaEditController,
          labelText: "Url Tienda",
          prefixIcon: Icons.link,
          iconColor: Colors.cyan, // Ajusta según necesites
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
              // getLoadingModal(context, false);
              await _controllers.updateUser(
                  idUser: idUser,
                  // email: emailTemp,
                  success: () {
                    // Navigator.pop(context);
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
                      btnOkOnPress: () {
                        Navigator.pop(context);
                      },
                    ).show();
                  },
                  error: () {
                    // Navigator.pop(context);
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

  _identifier() {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: "${serverUrlByShopify}/$idShopify"));
                Get.snackbar('COPIADO', 'Copiado al Clipboard');
              },
              child: Text(
                "Copiar",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 10,
          ),
          Text(
            'Identificador:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '${serverUrlByShopify}/$idShopify',
            style: TextStyle(),
          ),
        ],
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

  Widget _styledTextField({
    required TextEditingController controller,
    required String labelText,
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
          labelText: labelText,
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
          // floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}
