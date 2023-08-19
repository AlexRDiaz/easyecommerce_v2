import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddSellerI extends StatefulWidget {
  const AddSellerI({super.key});

  @override
  State<AddSellerI> createState() => _AddSellerIState();
}

class _AddSellerIState extends State<AddSellerI> {
  TextEditingController _usuario = TextEditingController();
  TextEditingController _correo = TextEditingController();
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
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "USUARIO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _usuario,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "CORREO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _correo,
              ),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Reporte de Ventas");
                          } else {
                            reporteVentas = false;
                            vistas.remove("Reporte de Ventas");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Reporte de Ventas",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Agregar Usuarios Vendedores");
                          } else {
                            agregarUsuarios = false;
                            vistas.remove("Agregar Usuarios Vendedores");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Agregar Usuarios Vendedores",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Ingreso de Pedidos");
                          } else {
                            ingresoPedidos = false;
                            vistas.remove("Ingreso de Pedidos");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Ingreso de Pedidos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Estado Entregas Pedidos");
                          } else {
                            estadoEntregas = false;
                            vistas.remove("Estado Entregas Pedidos");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Estado Entregas Pedidos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Pedidos No Deseados");
                          } else {
                            pedidosNoDeseados = false;
                            vistas.remove("Pedidos No Deseados");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Pedidos No Deseados",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                            vistas.add("Retiros en Efectivo");
                          } else {
                            retiros = false;
                            vistas.remove("Retiros en Efectivo");
                          }
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    "Retiros en Efectivo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ))
                ],
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_correo.text.isNotEmpty && _usuario.text.isNotEmpty) {
                      getLoadingModal(context, false);
                      var response = await Connections().createInternalSeller(
                          _usuario.text, _correo.text, vistas);
                      Navigator.pop(context);
                      setState(() {
                        _correo.clear();
                        _usuario.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "GUARDAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "CANCELAR",
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
}
