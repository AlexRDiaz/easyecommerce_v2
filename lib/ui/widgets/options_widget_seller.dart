import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/sellers/delivery_status/alert_dialog.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';

class OptionsWidgetSeller extends StatefulWidget {
  final List<Opcion> options;
  final Function(dynamic) function;
  // final void Function( dynamic filtro) function;
  String currentValue;
  OptionsWidgetSeller(
      {required this.options,
      required this.function,
      required this.currentValue});

  @override
  _OptionsWidgetSellerState createState() => _OptionsWidgetSellerState();
}

class _OptionsWidgetSellerState extends State<OptionsWidgetSeller> {
  List<bool> hoveredList = List.generate(12, (_) => false);
  List<bool> selectedList = List.generate(12, (_) => false);
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
      padding: EdgeInsets.only(left: 5, right: 5, top: 5),
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
                              ? Colors.white
                              : Colors.white,
                          border: selectedList[index] || hoveredList[index]
                              ? null
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
                              // Mostrar el título si no es "Referenciados"
                              if (widget.options[index].titulo.toString() !=
                                  "Referenciados")
                                Text(
                                  widget.options[index].titulo,
                                  style: TextStylesSystem().ralewayStyle(
                                    12,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels,
                                  ),
                                ),

                              // Fila de widgets condicionales
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Primer widget condicional
                                  if (widget.options[index].filtro !=
                                      "Referenciados")
                                    Container(), // Si no es "Referenciados", muestra un Container vacío

                                  // Segundo widget condicional
                                  if (widget.options[index].filtro !=
                                      "Referenciados")
                                    Container(), // Si no es "Referenciados", muestra otro Container vacío

                                  // Tercer widget condicional
                                  if (widget.options[index].filtro !=
                                      "Referenciados")
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: widget.options[index].color,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        widget.options[index].valor.toString(),
                                        style:
                                            TextStylesSystem().montserratStyle(
                                          18,
                                          FontWeight.w400,
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  else
                                    // Si es "Referenciados", muestra un TextButton
                                    TextButton(
                                      child: Text(
                                        "Referenciados",
                                        style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w400,
                                          ColorsSystem().colorLabels,
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              insetPadding: EdgeInsets.all(0),
                                              child: FractionallySizedBox(
                                                widthFactor:
                                                    0.5, // 50% del ancho de la pantalla
                                                child: Container(
                                                  height: 690,
                                                  child: AlertDialogReferer(),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        // width: 113,
                        // _calculateTextWidth(widget.options[index].titulo)
                        width:
                            _calculateTextWidth(widget.options[index].titulo),
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
                          child: Text(widget.options[index].titulo,
                              style: TextStylesSystem().ralewayStyle(
                                  10, FontWeight.w400, Colors.white)
                              // const TextStyle(
                              //   color: Colors.white,
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: 12,
                              // ),
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

  double _calculateTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(fontSize: 16)), // Ajusta el tamaño según necesidad
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }
}

getCurrentValue() {
  return "sfsfds";
}
