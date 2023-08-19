import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';

class MyOperatorAccount extends StatefulWidget {
  const MyOperatorAccount({super.key});

  @override
  State<MyOperatorAccount> createState() => _MyOperatorAccountState();
}

class _MyOperatorAccountState extends State<MyOperatorAccount> {
  var data = {};
  TextEditingController _validar = TextEditingController();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _correo = TextEditingController();
  TextEditingController _costo = TextEditingController();
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
    setState(() {
      _nombre.text = response['username'].toString();
      _correo.text = response['email'].toString();
      _costo.text = response['operadore']['Costo_Operador'].toString();
    });
    data = {
      "usuario": response['username'].toString(),
      "correo": response['email'].toString(),
      "fechaAlta": response['FechaAlta'].toString(),
      "costo": response['operadore']['Costo_Operador'].toString(),
      "CodigoGenerado": response['CodigoGenerado'].toString(),
      "idO": response['operadore']['id'].toString()
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
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Nombre:",
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _nombre,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Correo:",
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _correo,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Costo: ${_costo.text}",
                style: TextStyle(fontSize: 16),
              ),
           
              SizedBox(
                height: 20,
              ),
              Text(
                "Fecha Alta: ${data['fechaAlta']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Estado Cuenta: ${state}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              state != "NO VALIDADO" ? Container() : _validate(),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    getLoadingModal(context, false);
                    var response = await Connections()
                        .updateOperatorUser(_nombre.text, _correo.text);
                    var responseO = await Connections()
                        .updateOperatorGeneralAccount(_costo.text, data['idO']);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "GUARDAR CAMBIOS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 20,
              ),
            ],
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
