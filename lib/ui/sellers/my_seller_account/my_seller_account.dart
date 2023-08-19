import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class MySellerAccount extends StatefulWidget {
  const MySellerAccount({super.key});

  @override
  State<MySellerAccount> createState() => _MySellerAccountState();
}

class _MySellerAccountState extends State<MySellerAccount> {
  late MySellerAccountControllers _controllers;
  bool loading = true;
  TextEditingController _validar = TextEditingController();
  var data = {};
  String state = "";
  String costoEntrega = "";
  String costoDevolucion = "";
  String idShopify = "";
  @override
  void initState() {
    super.initState();
    initControllers();
  }

  initControllers() async {
    setState(() {
      loading = true;
    });
    _controllers = MySellerAccountControllers(
      nombreComercial: '',
      numeroTelefono: '',
      telefonoDos: '',
      usuario: '',
      fechaAlta: '',
      correo: '',
    );
    var response = await Connections().getPersonalInfoAccount();
    _controllers = MySellerAccountControllers(
      nombreComercial: response['vendedores'][0]['Nombre_Comercial'].toString(),
      numeroTelefono: response['vendedores'][0]['Telefono1'].toString(),
      telefonoDos: response['vendedores'][0]['Telefono2'].toString(),
      usuario: response['username'].toString(),
      fechaAlta: response['FechaAlta'].toString(),
      correo: response['email'].toString(),
    );
    setState(() {
      data = response;
    idShopify =   data['vendedores'][0]['Id_Master'].toString();
      loading = false;
      state = response['Estado'].toString();
      costoEntrega = response['vendedores'][0]['CostoEnvio'].toString();
      costoDevolucion = response['vendedores'][0]['CostoDevolucion'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: loading == true
            ? Container()
            : SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      _identifier(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "ESTADO: ${state.toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InputRow(
                          controller: _controllers.nombreComercialController,
                          title: 'Nombre Comercial'),
                      InputRow(
                          controller: _controllers.correoController,
                          title: 'Correo'),
                      InputRow(
                          controller: _controllers.usuarioController,
                          title: 'Usuario'),
                      InputRow(
                          controller: _controllers.numeroTelefonoController,
                          title: 'Número de Teléfono'),
                      InputRow(
                          controller: _controllers.telefonoDosController,
                          title: 'Teléfono Dos'),
                      Text(
                        "Fecha Alta: ${_controllers.fechaAltaController.text.toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Costo Entrega: $costoEntrega",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Costo Devolución: $costoDevolucion",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      state != "NO VALIDADO" ? Container() : _validate(),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: 500,
                          child: ElevatedButton(
                            child: Text(
                              "Guardar",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () async {
                              getLoadingModal(context, false);
                              var response = await Connections().updateSeller(
                                  _controllers.usuarioController.text,
                                  _controllers.correoController.text,
                                  "");
                              var responseMaster = await Connections()
                                  .updateSellerGeneralInternalAccount(
                                      _controllers
                                          .nombreComercialController.text,
                                      _controllers
                                          .numeroTelefonoController.text,
                                      _controllers.telefonoDosController.text,
                                      data['vendedores'][0]['id'].toString());
                              await initControllers();
                              Navigator.pop(context);
                            },
                          )),
                      SizedBox(
                        height: 20,
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
                  await initControllers();
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
                var updateCode = print("Guardando");
              },
            )),
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
                Clipboard.setData(ClipboardData(
                    text: "${serverUrlByShopify}/$idShopify"));
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

}
