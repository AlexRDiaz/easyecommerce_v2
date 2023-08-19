import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';

class ValuesWidget extends StatefulWidget {
  final List<Opcion> opciones;
  final Function(dynamic) function;
  String currentValue;
  ValuesWidget(
      {required this.opciones,
      required this.function,
      required this.currentValue});

  @override
  _ValuesWidgetState createState() => _ValuesWidgetState();
}

class _ValuesWidgetState extends State<ValuesWidget> {
  List<bool> hoveredList = List.generate(7, (_) => false);
  List<bool> selectedList = List.generate(7, (_) => false);
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
      padding: EdgeInsets.all(10),
      child: Wrap(
        spacing: 5, // Espacio horizontal mínimo entre los contenedores
        runSpacing: 5, // Espacio vertical mínimo entre los contenedores
        children: List.generate(
          widget.opciones.length,
          (index) => GestureDetector(
            onTap: () {
              widget.currentValue = widget.opciones[index].titulo;
              _updateSelectedIndex(index);
              widget.function({
                "titulo": widget.opciones[index].titulo,
                'color': widget.opciones[index].color
              });
            },
            child: MouseRegion(
              onEnter: (_) => setState(() => hoveredList[index] = true),
              onExit: (_) => setState(() => hoveredList[index] = false),
              child: Column(
                children: [
                  responsive(
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: selectedList[index] || hoveredList[index]
                            ? 120
                            : 110,
                        height:
                            selectedList[index] || hoveredList[index] ? 60 : 50,
                        decoration: BoxDecoration(
                          color: selectedList[index] || hoveredList[index]
                              ? widget.opciones[index].color
                              : widget.opciones[index].color.withOpacity(0.4),
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
                                  widget.opciones[index].icono,
                                  Text('= '),
                                  Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(widget.opciones[index].valor
                                          .toString()))
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                widget.opciones[index].titulo,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 85,
                        height: 25,
                        decoration: BoxDecoration(
                          color: selectedList[index] || hoveredList[index]
                              ? widget.opciones[index].color
                              : widget.opciones[index].color.withOpacity(0.4),
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
                          child: Text(
                            widget.opciones[index].titulo,
                            style: TextStyle(
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
