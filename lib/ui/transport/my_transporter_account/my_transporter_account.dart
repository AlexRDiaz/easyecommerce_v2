import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class MyTransporterAccount extends StatefulWidget {
  const MyTransporterAccount({super.key});

  @override
  State<MyTransporterAccount> createState() => _MyTransporterAccountState();
}

class _MyTransporterAccountState extends State<MyTransporterAccount> {
  String id = "";
  var data = {};
  TextEditingController _validar = TextEditingController();

  String state = "";
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      data = {
        "usuario": "",
        "correo": "",
        "fechaAlta": "",
        "costo": "",
        "CodigoGenerado": ""
      };
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getPersonalInfoAccount();
    data = {
      "usuario": response['username'].toString(),
      "correo": response['email'].toString(),
      "fechaAlta": response['FechaAlta'].toString(),
      "costo": response['transportadora']['Costo_Transportadora'].toString(),
      "CodigoGenerado": response['CodigoGenerado'].toString()
    };
    state = response['Estado'].toString();
    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                RowLabel(
                  title: 'ESTADO',
                  value: state.toString(),
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Usuario',
                  value: data['usuario'],
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Correo',
                  value: data['correo'],
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Fecha de alta',
                  value: data['fechaAlta'],
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Costo por Entrega',
                  value: data['costo'],
                  color: Colors.black,
                ),
                state != "NO VALIDADO" ? Container() : _validate(),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _validate() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          width: 500,
          child: TextField(
            controller: _validar,
            decoration: InputDecoration(
                hintText: "CÓDIGO DE VALIDACÓN",
                hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
            width: 500,
            child: ElevatedButton(
              child: Text(
                "VALIDAR",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () async {
                getLoadingModal(context, false);
                if (_validar.text.toString() == data['CodigoGenerado']) {
                  var update = await Connections().updateAccountStatus();
                  await loadData();
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  AwesomeDialog(
                    width: 500,
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'Incorrecto',
                    btnCancel: Container(),
                    btnOkText: "Aceptar",
                    btnOkColor: colors.colorGreen,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  ).show();
                }
              },
            )),
      ],
    );
  }
}
