import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';

class TransportReturn extends StatefulWidget {
  final String id;
  final String status;
  const TransportReturn({super.key, required this.id, required this.status});

  @override
  State<TransportReturn> createState() => _TransportReturnState();
}

class _TransportReturnState extends State<TransportReturn> {
  bool entregado = false;
  bool ruta = false;
  bool reiniciar = false;
  var idUser = sharedPrefs!.getString("id");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 400,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: ListView(
            children: [
              Text(
                "ESTADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              widget.status == "DEVOLUCION EN RUTA" ||
                      widget.status == "EN BODEGA" ||
                      widget.status == "ENTREGADO EN OFICINA"
                  ? Container()
                  : Row(
                      children: [
                        Checkbox(
                            value: entregado,
                            onChanged: (value) {
                              setState(() {
                                entregado = true;
                                ruta = false;
                                reiniciar = false;
                              });
                            }),
                        Flexible(
                          child: Text(
                            "ENTREGADO EN OFICINA",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      ],
                    ),
              SizedBox(
                height: 10,
              ),
              widget.status == "DEVOLUCION EN RUTA" ||
                      widget.status == "EN BODEGA"
                  ? Container()
                  : Row(
                      children: [
                        Checkbox(
                            value: ruta,
                            onChanged: (value) {
                              setState(() {
                                entregado = false;
                                ruta = true;
                                reiniciar = false;
                              });
                            }),
                        Flexible(
                          child: Text(
                            "DEVOLUCION EN RUTA",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      ],
                    ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Checkbox(
                      value: reiniciar,
                      onChanged: (value) {
                        setState(() {
                          entregado = false;
                          ruta = false;
                          reiniciar = true;
                        });
                      }),
                  Flexible(
                    child: Text(
                      "REINICIAR ESTADO",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Wrap(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "CANCELAR",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      onPressed: entregado == false &&
                              ruta == false &&
                              reiniciar == false
                          ? null
                          : () async {
                              getLoadingModal(context, false);
                              if (entregado) {
                                paymentTransportByReturnStatus(
                                    widget.id.toString(),
                                    "ENTREGADO EN OFICINA");
                              }
                              if (ruta) {
                                paymentTransportByReturnStatus(
                                    widget.id.toString(), "DEVOLUCION EN RUTA");
                              }
                              if (reiniciar) {
                                await Connections().updateOrderWithTime(
                                    widget.id.toString(),
                                    "estado_devolucion:PENDIENTE",
                                    idUser,
                                    "carrier",
                                    "");
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                      child: Text(
                        "GUARDAR",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> paymentTransportByReturnStatus(id, returnStatus) async {
    var resNovelty = await Connections()
        .paymentTransportByReturnStatus(id, "", "", returnStatus);

    dialogNovedad(resNovelty, returnStatus);
  }

  Future<void> dialogNovedad(resNovelty, returnStatus) async {
    if (resNovelty == 1 || resNovelty == 2) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error al modificar estado',
        desc: 'No se pudo cambiar a $returnStatus',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 255, 59, 59)),
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          // Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Se ha modificado exitosamente',
        desc: resNovelty['res'],
        descTextStyle:
            const TextStyle(color: Color.fromARGB(255, 255, 235, 59)),
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          Navigator.pop(context);

          Navigator.pop(context);
        },
      ).show();
    }
  }
}
