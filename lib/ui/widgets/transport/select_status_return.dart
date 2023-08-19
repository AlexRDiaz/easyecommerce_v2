import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class SelectStatusReturn extends StatefulWidget {
  // final String id;

  // final String status;
  final Function(dynamic) function;
  const SelectStatusReturn({super.key, required this.function});

  @override
  State<SelectStatusReturn> createState() => _SelectStatusReturnState();
}

class _SelectStatusReturnState extends State<SelectStatusReturn> {
  bool entregado = false;
  bool ruta = false;
  bool reiniciar = false;
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
                "Seleccione estado para productos escaneados",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                                widget.function("ENTREGADO EN OFICINA");
                                // await Connections().updateOrderReturnTransport(
                                //     widget.id, "ENTREGADO EN OFICINA");
                                // Navigator.pop(context);
                                // Navigator.pop(context);
                              }
                              if (ruta) {
                                widget.function("DEVOLUCION EN RUTA");

                                // await Connections().updateOrderReturnTransport(
                                //     widget.id, "DEVOLUCION EN RUTA");
                                // Navigator.pop(context);
                                // Navigator.pop(context);
                              }
                              if (reiniciar) {
                                widget.function("PENDIENTE");

                                // await Connections()
                                //     .updateOrderReturnTransportRestart(
                                //         widget.id);
                                // Navigator.pop(context);
                                // Navigator.pop(context);
                              }
                            },
                      child: Text(
                        "SIGUIENTE",
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
}
