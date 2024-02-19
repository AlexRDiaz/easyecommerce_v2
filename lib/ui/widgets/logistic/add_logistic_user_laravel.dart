import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/add_logistic_user_laravel/controller/add_logistic_user_controllers.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddLogisticUserLaravel extends StatefulWidget {
  const AddLogisticUserLaravel({super.key});

  @override
  State<AddLogisticUserLaravel> createState() => _AddLogisticUserLaravelState();
}

class _AddLogisticUserLaravelState extends State<AddLogisticUserLaravel> {
  AddLogisticsLaravelControllers _controllers = AddLogisticsLaravelControllers();

  List vistas = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height * 0.65,
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
                _styledTextField(
                    controller:  _controllers.userController,
                    hintText: "Usuario", 
                    prefixIcon: Icons.person,
                    iconColor: Colors.blue),
                _styledTextField(
                    controller: _controllers.personController,
                    hintText: "Persona Cargo", 
                    prefixIcon: Icons.supervisor_account,
                    iconColor: Colors.deepPurple),
                _styledTextField(
                    controller: _controllers.phone1Controller,
                    hintText: "Teléfono Uno", 
                    prefixIcon: Icons.phone),
                _styledTextField(
                    controller: _controllers.phone2Controller,
                    hintText: "Teléfono Dos", 
                    prefixIcon: Icons.phone_android,
                    iconColor: Colors.orange),
                _styledTextField(
                    controller: _controllers.mailController,
                    hintText: "Correo", 
                    prefixIcon: Icons.email,
                    iconColor: Colors.red),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: Size(200, 40)),
                      onPressed: () async {
                        getLoadingModal(context, false);

                        var accesofRol = await Connections()
                            .getAccessofSpecificRol("LOGISTICA");
                        vistas = accesofRol;

                        await _controllers.createLogisticUser(
                            permisos: vistas,
                            success: (id) {
                              Navigator.pop(context);
                              // loadData();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Completado",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {});
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
                              _controllers.userController.clear();
                              _controllers.personController.clear();
                              _controllers.phone1Controller.clear();
                              _controllers.phone2Controller.clear();
                              _controllers.mailController.clear();

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
