import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
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
                Text(
                  "PERMISOS",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: ingresos,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              ingresos = true;
                              vistas.add("Ingresos y Egresos");
                            } else {
                              ingresos = false;
                              vistas.remove("Ingresos y Egresos");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Ingresos y Egresos",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: agregarV,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              agregarV = true;
                              vistas.add("Agregar Vendedores");
                            } else {
                              agregarV = false;
                              vistas.remove("Agregar Vendedores");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Agregar Vendedores",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: agregarT,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              agregarT = true;
                              vistas.add("Agregar Transportistas");
                            } else {
                              agregarT = false;
                              vistas.remove("Agregar Transportistas");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Agregar Transportistas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: agregarL,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              agregarL = true;
                              vistas.add("Agregar Usuario Logística");
                            } else {
                              agregarL = false;
                              vistas.remove("Agregar Usuario Logística");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Agregar Usuario Logística",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: estadoCuenta,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              estadoCuenta = true;
                              vistas.add("Estado de Cuenta");
                            } else {
                              estadoCuenta = false;
                              vistas.remove("Estado de Cuenta");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Estado de Cuenta",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: facturaV,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              facturaV = true;
                              vistas.add("Facturas Vendedores");
                            } else {
                              facturaV = false;
                              vistas.remove("Facturas Vendedores");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Facturas Vendedores",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: comprobantes,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              comprobantes = true;
                              vistas.add("Comprobantes de Pago");
                            } else {
                              comprobantes = false;
                              vistas.remove("Comprobantes de Pago");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Comprobantes de Pago",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: saldoC,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              saldoC = true;
                              vistas.add("Saldo Contable");
                            } else {
                              saldoC = false;
                              vistas.remove("Saldo Contable");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Saldo Contable",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: saldoL,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              saldoL = true;
                              vistas.add("Saldo Logística");
                            } else {
                              saldoL = false;
                              vistas.remove("Saldo Logística");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Saldo Logística",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: solicitud,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              solicitud = true;
                              vistas.add("Solicitud de Retiro Vendedores");
                            } else {
                              solicitud = false;
                              vistas.remove("Solicitud de Retiro Vendedores");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Solicitud de Retiro Vendedores",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: estadoE,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              estadoE = true;
                              vistas.add("Estado de Entregas");
                            } else {
                              estadoE = false;
                              vistas.remove("Estado de Entregas");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Estado de Entregas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: historial,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              historial = true;
                              vistas.add("Historial Pedidos Transportadora");
                            } else {
                              historial = false;
                              vistas.remove("Historial Pedidos Transportadora");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Historial Pedidos Transportadora",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: imprimir,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              imprimir = true;
                              vistas.add("Imprimir Guías");
                            } else {
                              imprimir = false;
                              vistas.remove("Imprimir Guías");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Imprimir Guías",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: impresas,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              impresas = true;
                              vistas.add("Guías Impresas");
                            } else {
                              impresas = false;
                              vistas.remove("Guías Impresas");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Guías Impresas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: enviadas,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              enviadas = true;
                              vistas.add("Guías Enviadas");
                            } else {
                              enviadas = false;
                              vistas.remove("Guías Enviadas");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Guías Enviadas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: devolucion,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              devolucion = true;
                              vistas.add("Devoluciones");
                            } else {
                              devolucion = false;
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: devolucionEnBodega,
                        onChanged: (v) {
                          setState(() {
                            if (v!) {
                              devolucionEnBodega = true;
                              vistas.add("Devolución en bodega");
                            } else {
                              devolucionEnBodega = false;
                              vistas.remove("Devolución en bodega");
                            }
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      "Devolución en bodega",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: Size(200, 40)),
                      onPressed: () async {
                        getLoadingModal(context, false);
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
