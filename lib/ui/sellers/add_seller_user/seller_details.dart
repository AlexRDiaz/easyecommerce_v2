import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
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

class AddSellerDetails extends StatefulWidget {
  const AddSellerDetails({super.key});

  @override
  State<AddSellerDetails> createState() => _AddSellerDetailState();
}

class _AddSellerDetailState extends State<AddSellerDetails> {
  TextEditingController _user = TextEditingController();
  TextEditingController _correo = TextEditingController();
  bool loading = true;
  var data = {};
  String filtros = "";
  bool dashboard = false;
  bool reporteVentas = false;
  bool agregarUsuarios = false;
  bool ingresoPedidos = false;
  bool estadoEntregas = false;
  bool pedidosNoDeseados = false;
  bool billetera = false;
  bool miBilletera = false;
  bool transportStats = false;

  bool devoluciones = false;
  bool retiros = false;
  List vistas = [];
  int idUser = 0;
  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  initControllers() async {
    setState(() {
      loading = true;
    });
    var response = await Connections().getPersonalInfoAccountI();
    var result = await Connections().getPermissionsSellerPrincipalforNewSeller(
        sharedPrefs!.getString("idComercialMasterSeller"));

    accessGeneralofRol = result;

    setState(() {
      data = response;
      loading = false;
      _user.text = response['username'];
      _correo.text = response['email'];

      idUser = response["id"];

      if (response['permisos'] is String) {
        var decoded = jsonDecode(response['permisos']);
        if (decoded is List) {
          accessTemp = decoded;
        } else {
          accessTemp = [];
        }
      }

      filtros = response['permisos'].toString();
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
            : Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () {
                          Navigators().pushNamedAndRemoveUntil(
                              context, "/layout/sellers");
                        },
                        icon: Icon(Icons.arrow_back_ios_new)),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            InputRow(controller: _user, title: 'Usuario'),
                            InputRow(controller: _correo, title: 'Correo'),
                            Text(
                              "PERMISOS ACTUALES: ${filtros.toString()}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "PERMISOS",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.all(20.0),
                              height: 500,
                              width: 500,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0,
                                      color:
                                          Color.fromARGB(255, 224, 222, 222)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Builder(
                                builder: (context) {
                                  return CustomFilterChips(
                                    accessTemp: accessTemp,
                                    accessGeneralofRol: accessGeneralofRol,
                                    loadData: () {},
                                    idUser: idUser.toString(),
                                    onSelectionChanged: (selectedChips) {
                                      setState(() {
                                        vistas = List.from(selectedChips);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                                width: 500,
                                child: ElevatedButton(
                                  child: Text(
                                    "Actualizar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_user.text.isNotEmpty &&
                                        _correo.text.isNotEmpty) {
                                      getLoadingModal(context, false);
                                      var response = await Connections()
                                          .updateSellerI(
                                              _user.text,
                                              _correo.text,
                                              vistas.isNotEmpty
                                                  ? vistas
                                                  : accessTemp);

                                      await initControllers();
                                      Navigator.pop(context);
                                      // getAccessofRolById
                                    }
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
                ],
              ),
      ),
    );
  }
}
