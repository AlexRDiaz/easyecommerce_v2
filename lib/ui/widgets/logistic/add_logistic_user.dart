import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddLogisticUser extends StatefulWidget {
  const AddLogisticUser({super.key});

  @override
  State<AddLogisticUser> createState() => _AddLogisticUserState();
}

class _AddLogisticUserState extends State<AddLogisticUser> {
  AddLogisticsControllers _controllers = AddLogisticsControllers();
  bool dashboard = false;
  bool ingresos = false;
  bool agregarV = false;
  bool agregarT = false;
  bool agregarL = false;
  bool estadoCuenta = false;
  bool estadoCuenta2 = false;
  bool facturaV = false;
  bool comprobantes = false;
  bool saldoC = false;
  bool saldoL = false;
  bool solicitud = false;
  bool estadoE = false;
  bool historial = false;
  bool imprimir = false;
  bool impresas = false;
  bool enviadas = false;
  bool devolucion = false;
  bool transaccion = false;
  bool configroles = false;
  bool devolucionEnBodega = false;

  List vistas = [];

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                _modelTextFieldCompleteModal(
                    "Usuario", _controllers.userController),
                _modelTextFieldCompleteModal(
                    "Persona Cargo", _controllers.personController),
                _modelTextFieldCompleteModal(
                    "Teléfono Uno", _controllers.phone1Controller),
                _modelTextFieldCompleteModal(
                    "Teléfono Dos", _controllers.phone2Controller),
                _modelTextFieldCompleteModal(
                    "Correo", _controllers.mailController),
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
}
