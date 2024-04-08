import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/sellers/delivery_status/alert_dialog.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';

class OptionsWidget extends StatefulWidget {
  final List<Opcion> options;
  final Function(dynamic) function;
  // final void Function( dynamic filtro) function;
  String currentValue;
  OptionsWidget(
      {required this.options,
      required this.function,
      required this.currentValue});

  @override
  _OptionsWidgetState createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  List<bool> hoveredList = List.generate(11, (_) => false);
  List<bool> selectedList = List.generate(11, (_) => false);
  int selectedIndex = -1;

  // Variable para almacenar el valor actual del String
  @override
  void _updateSelectedIndex(int index) {
    if (selectedIndex != index) {
      setState(() {
        if (selectedIndex != -1) {
          selectedList[selectedIndex] = false;
        }
        selectedIndex = index;
        selectedList[selectedIndex] = true;
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Wrap(
        spacing: 5, // Espacio horizontal mínimo entre los contenedores
        runSpacing: 5, // Espacio vertical mínimo entre los contenedores
        children: List.generate(
          widget.options.length,
          (index) => GestureDetector(
            onTap: () {
              widget.currentValue = widget.options[index].titulo;
              _updateSelectedIndex(index);
              widget.function({
                "filtro": widget.options[index].filtro,
                'color': widget.options[index].color
              });
            },
            child: MouseRegion(
              onEnter: (_) => setState(() => hoveredList[index] = true),
              onExit: (_) => setState(() => hoveredList[index] = false),
              child: Column(
                children: [
                  responsive(
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selectedList[index] || hoveredList[index]
                            ? 120
                            : 110,
                        height:
                            selectedList[index] || hoveredList[index] ? 60 : 50,
                        decoration: BoxDecoration(
                          color: selectedList[index] || hoveredList[index]
                              ? widget.options[index].color
                              : widget.options[index].color.withOpacity(0.4),
                          border: selectedList[index] || hoveredList[index]
                              ? Border.all()
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.options[index].filtro !=
                                          "Referenciados"
                                      ? widget.options[index].icono
                                      : Container(),
                                  widget.options[index].filtro !=
                                          "Referenciados"
                                      ? const Text('= ')
                                      : Container(),
                                  widget.options[index].filtro !=
                                          "Referenciados"
                                      ? Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Text(widget
                                              .options[index].valor
                                              .toString()))
                                      : Container(
                                          child: TextButton(
                                            child: Text("Referenciados",style: TextStyle(fontSize: 12,color: Colors.white),),
                                          // icon: Icon(Icons.check_circle),
                                          // color: Colors.white,
                                          // iconSize: 5,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // Usamos Dialog en lugar de AlertDialog directamente para poder controlar el tamaño.
                                                return Dialog(
                                                  // Sin margen para el Dialog, haciendo que se expanda lo máximo posible.
                                                  insetPadding:
                                                      EdgeInsets.all(0),
                                                  child: FractionallySizedBox(
                                                    widthFactor:
                                                        0.5, // Esto hace que el diálogo sea el 80% del ancho de la pantalla
                                                    child: Container(
                                                      height: 650,
                                                      child: AlertDialogReferer()),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ))
                                ],
                              ),
                              // SizedBox(height: 5),
                              widget.options[index].titulo.toString() != "Referenciados" ?
                              Text(
                                widget.options[index].titulo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ):Container(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 113,
                        height: 25,
                        decoration: BoxDecoration(
                          color: selectedList[index] || hoveredList[index]
                              ? widget.options[index].color
                              : widget.options[index].color.withOpacity(0.4),
                          border: selectedList[index] || hoveredList[index]
                              ? Border.all()
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.options[index].titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

getCurrentValue() {
  return "sfsfds";
}
