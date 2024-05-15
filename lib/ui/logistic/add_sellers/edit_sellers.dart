import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class EditSellers extends StatefulWidget {
  const EditSellers({super.key});

  @override
  State<EditSellers> createState() => _EditSellersState();
}

class _EditSellersState extends State<EditSellers> {
  AddSellersControllers _controllers = AddSellersControllers();
  String usernameTemp = "";
  String emailTemp = "";
  String idShopify = "";
  int idUser = 0;
  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
  }

  var data = {};
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      var response = await Connections().getSellerGeneralByID();
      accessGeneralofRol = await Connections().getAccessofRolById(2);
      data = response;
      _controllers.updateControllersEdit(response);

      setState(() {
        idUser = data["id"];
        usernameTemp = data["username"].toString();
        emailTemp = data["email"].toString();
        idShopify = data['vendedores'][0]['Id_Master'].toString();
        accessTemp = data['PERMISOS'];
      });

      if (accessTemp == null || accessTemp.isEmpty) {
        print("ERROR: accessTemp está vacío o es nulo.");
      }

      if (accessGeneralofRol == null || accessGeneralofRol.isEmpty) {
        print("ERROR: accessGeneralofRol está vacío o es nulo.");
      }

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("ERROR EN loadData: $e");
    }
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
                  .pushNamedAndRemoveUntil(context, "/layout/logistic/sellers");
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
                  Text(
                    "ESTADO: ${data["Estado"].toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FloatingActionButton(
                          heroTag: "fab1",
                          onPressed: () {
                            // Manejo del boton
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FloatingActionButton(
                          heroTag: "fab2",
                          onPressed: () {
                            // Manejo del boton
                          },
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _identifier(),
                  SizedBox(
                    height: 20,
                  ),
                  _modelTextFieldComplete("Nombre Comercial",
                      _controllers.comercialNameEditController),
                  _modelTextFieldComplete(
                      "Usuario", _controllers.userEditController),
                  _modelTextFieldComplete(
                      "Correo", _controllers.mailEditController),
                  ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        var response =
                            await Connections().updatePasswordById("123456789");
                        Navigator.pop(context);
                        if (response) {
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Completado',
                            desc: 'Restablecimiento Completada',
                            btnCancel: Container(),
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
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: Text(
                        "Restablecer Contraseña",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  _modelTextFieldComplete(
                      "Número de teléfono", _controllers.phone1EditController),
                  _modelTextFieldComplete(
                      "Teléfono dos", _controllers.phone2EditController),
                  _modelText("Fecha de Alta", data["FechaAlta"].toString()),
                  _modelTextFieldComplete(
                      "Costo Envio", _controllers.sendCostEditController),
                  _modelTextFieldComplete(
                      "CostoDevolucion", _controllers.returnCostEditController),
                  _modelTextFieldComplete(
                      "Url Tienda", _controllers.urlTiendaEditController),
                  Text(
                    "Accesos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    height: 500,
                    width: 500,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0,
                            color: Color.fromARGB(255, 224, 222, 222)),
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
                            username: usernameTemp,
                            email: emailTemp,
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
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "Actualizar Datos",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
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
                    // ClipboardData(text: "${serverUrlByShopify}/$idShopify"));
                    ClipboardData(
                        text: "${serverUrlByShopifyLaravel}/$idShopify"));
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
            // '${serverUrlByShopify}/$idShopify',
            '${serverUrlByShopifyLaravel}/$idShopify',
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
}
