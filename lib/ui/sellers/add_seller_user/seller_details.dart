import 'package:awesome_dialog/awesome_dialog.dart';
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
  bool devoluciones = false;
  bool retiros = false;
  List vistas = [];
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

    setState(() {
      data = response;
      loading = false;
      _user.text = response['username'];
      _correo.text = response['email'];
      filtros = response['PERMISOS'].toString();
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
                            Center(
                              child: Container(
                                width: 500,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: dashboard,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  dashboard = true;
                                                  vistas.add("DashBoard");
                                                } else {
                                                  dashboard = false;
                                                  vistas.remove("DashBoard");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "DashBoard",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: reporteVentas,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  reporteVentas = true;
                                                  vistas
                                                      .add("Reporte de Ventas");
                                                } else {
                                                  reporteVentas = false;
                                                  vistas.remove(
                                                      "Reporte de Ventas");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Reporte de Ventas",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: agregarUsuarios,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  agregarUsuarios = true;
                                                  vistas.add(
                                                      "Agregar Usuarios Vendedores");
                                                } else {
                                                  agregarUsuarios = false;
                                                  vistas.remove(
                                                      "Agregar Usuarios Vendedores");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Agregar Usuarios Vendedores",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: ingresoPedidos,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  ingresoPedidos = true;
                                                  vistas.add(
                                                      "Ingreso de Pedidos");
                                                } else {
                                                  ingresoPedidos = false;
                                                  vistas.remove(
                                                      "Ingreso de Pedidos");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Ingreso de Pedidos",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: estadoEntregas,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  estadoEntregas = true;
                                                  vistas.add(
                                                      "Estado Entregas Pedidos");
                                                } else {
                                                  estadoEntregas = false;
                                                  vistas.remove(
                                                      "Estado Entregas Pedidos");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Estado Entregas Pedidos",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: pedidosNoDeseados,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  pedidosNoDeseados = true;
                                                  vistas.add(
                                                      "Pedidos No Deseados");
                                                } else {
                                                  pedidosNoDeseados = false;
                                                  vistas.remove(
                                                      "Pedidos No Deseados");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Pedidos No Deseados",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: billetera,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  billetera = true;
                                                  vistas.add("Billetera");
                                                } else {
                                                  billetera = false;
                                                  vistas.remove("Billetera");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Billetera",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: devoluciones,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  devoluciones = true;
                                                  vistas.add("Devoluciones");
                                                } else {
                                                  devoluciones = false;
                                                  vistas.remove("Devoluciones");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Devoluciones",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: retiros,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v!) {
                                                  retiros = true;
                                                  vistas.add(
                                                      "Retiros en Efectivo");
                                                } else {
                                                  retiros = false;
                                                  vistas.remove(
                                                      "Retiros en Efectivo");
                                                }
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "Retiros en Efectivo",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
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
                                                  : data['PERMISOS']);

                                      await initControllers();
                                      Navigator.pop(context);
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
