import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/add_logistics_user/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';

class EditLogisticUser extends StatefulWidget {
  const EditLogisticUser({super.key});

  @override
  State<EditLogisticUser> createState() => _EditLogisticUserState();
}

class _EditLogisticUserState extends State<EditLogisticUser> {
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
    var response = await Connections().getLogisticGeneralByID();
    // data = response;
    data = response;
    _controllers.updateControllersEdit(response);
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    setState(() {});
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
                  _modelTextFieldComplete(
                      "Usuario", _controllers.userEditController),
                  _modelTextFieldComplete(
                      "Email", _controllers.mailEditController),
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
                      "Persona Cargo", _controllers.personEditController),
                  _modelTextFieldComplete(
                      "Teléfono Uno", _controllers.phone1EditController),
                  _modelTextFieldComplete(
                      "Teléfono Dos", _controllers.phone2EditController),
                  _modelText("Fecha de Alta", data["FechaAlta"].toString()),
                  _permisos(),
                  ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        await _controllers.updateUser(
                            permisos:
                                vistas.isNotEmpty ? vistas : data['PERMISOS'],
                            success: () async {
                              Navigator.pop(context);
                              await loadData();
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
                                btnOkOnPress: () async {},
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

  _permisos() {
    return Container(
      width: 500,
      child: Column(
        children: [
          Text(
            "PERMISOS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "PERMISOS ACTUALES: ${data['PERMISOS'].toString()}",
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                "Devolución en bodega ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ))
            ],
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
