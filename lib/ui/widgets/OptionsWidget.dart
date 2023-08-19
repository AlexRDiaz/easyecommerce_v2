import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';

class OptionsWidget extends StatefulWidget {
  final List<Opcion> options;
  final Function(dynamic) function;
  String currentValue;
  OptionsWidget(
      {required this.options,
      required this.function,
      required this.currentValue});

  @override
  _OptionsWidgetState createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
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
                        duration: Duration(milliseconds: 200),
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
                                  widget.options[index].icono,
                                  Text('= '),
                                  Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(widget.options[index].valor
                                          .toString()))
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                widget.options[index].titulo,
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
                          child: Text(
                            widget.options[index].titulo,
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
