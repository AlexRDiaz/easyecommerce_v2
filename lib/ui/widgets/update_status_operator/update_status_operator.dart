import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateStatusOperator extends StatefulWidget {
  final String numberTienda;
  final String codigo;
  final String numberCliente;

  const UpdateStatusOperator(
      {super.key,
      required this.numberTienda,
      required this.codigo,
      required this.numberCliente});

  @override
  State<UpdateStatusOperator> createState() => _UpdateStatusOperatorState();
}

class _UpdateStatusOperatorState extends State<UpdateStatusOperator> {
  List<String> status = [
    "ENTREGADO",
    "NO ENTREGADO",
    "NOVEDAD",
    "REAGENDADO",
    "EN RUTA",
    "PEDIDO PROGRAMADO",
    "EN OFICINA"
  ];
  String? selectedValueStatus;
  List<DateTime?> _dates = [];
  String dateSelect = "";
  bool efectivo = false;
  bool transferencia = false;
  bool deposito = false;
  TextEditingController _controllerModalText = TextEditingController();
  XFile? imageSelect = null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 400,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Status',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: status
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueStatus,
                onChanged: (value) async {
                  setState(() {
                    selectedValueStatus = value as String;
                  });
                },

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {}
                },
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                Column(
                  children: [generateContent()],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  generateContent() {
    switch (selectedValueStatus) {
      case null:
        return Container();
      case "ENTREGADO":
        return _Entregado();
      case "NO ENTREGADO":
        return _NoEntregado();
      case "NOVEDAD":
        return _Novdedad();
      case "REAGENDADO":
        return _Reagendado();
      case "EN RUTA":
        return _EnRuta();
      case "PEDIDO PROGRAMADO":
        return _PedidoProgramado();

      case "EN OFICINA":
        return _EnOficina();

      default:
    }
  }

  Container _Entregado() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Tipo de Pago",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          _modelCheckEfectivo(),
          SizedBox(
            height: 10,
          ),
          _modelCheckTransferencia(),
          SizedBox(
            height: 10,
          ),
          _modelCheckDeposito(),
          SizedBox(
            height: 10,
          ),
          transferencia == true
              ? Text("Foto",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              : Container(),
          SizedBox(
            height: 10,
          ),
          transferencia == true
              ? TextButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);

                    setState(() {
                      imageSelect = image;
                    });
                  },
                  child: Text(
                    "Seleccionar:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
              : Container(),
          transferencia == true
              ? SizedBox(
                  height: 10,
                )
              : Container(),
          transferencia == true
              ? Text(
                  "${imageSelect != null ? imageSelect!.name.toString() : ''}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              : Container(),
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: imageSelect != null && transferencia
                  ? () async {
                      getLoadingModal(context, false);
                      String tipo = "";
                      if (efectivo) {
                        tipo = "Efectivo";
                      }
                      if (deposito) {
                        tipo = "Deposito";
                      }
                      if (transferencia) {
                        tipo = "Transferencia";
                      }
                      setState(() {});
                      var response = await Connections().postDoc(imageSelect!);

                      await Connections().updateOrderStatusOperatorEntregado(
                          "ENTREGADO",
                          tipo,
                          _controllerModalText.text,
                          response[1]);
                      setState(() {
                        _controllerModalText.clear();
                        tipo = "";
                        deposito = false;
                        efectivo = false;
                        transferencia = false;
                        imageSelect = null;
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  : deposito == true || efectivo == true
                      ? () async {
                          getLoadingModal(context, false);
                          String tipo = "";
                          if (efectivo) {
                            tipo = "Efectivo";
                          }
                          if (deposito) {
                            tipo = "Deposito";
                          }
                          if (transferencia) {
                            tipo = "Transferencia";
                          }
                          setState(() {});

                          await Connections()
                              .updateOrderStatusOperatorEntregado("ENTREGADO",
                                  tipo, _controllerModalText.text, "");
                          setState(() {
                            _controllerModalText.clear();
                            tipo = "";
                            deposito = false;
                            efectivo = false;
                            transferencia = false;
                            imageSelect = null;
                          });

                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      : null,
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _NoEntregado() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Foto",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  imageSelect = image;
                });
              },
              child: Text(
                "Seleccionar:",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 10,
          ),
          Text("${imageSelect != null ? imageSelect!.name.toString() : ''}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: imageSelect != null
                  ? () async {
                      getLoadingModal(context, false);

                      var response = await Connections().postDoc(imageSelect!);

                      await Connections().updateOrderStatusOperatorNoEntregado(
                          "NO ENTREGADO",
                          _controllerModalText.text,
                          response[1]);
                      setState(() {
                        _controllerModalText.clear();

                        imageSelect = null;
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _Novdedad() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                await Connections().updateOrderStatusOperatorGeneral(
                    "NOVEDAD", _controllerModalText.text);
                var _url = Uri.parse(
                    """https://api.whatsapp.com/send?phone=${widget.numberTienda}&text= 
                                        El pedido con código ${widget.codigo} cambio su estado a novedad, motivo: ${_controllerModalText.text}. Teléfono del cliente: ${widget.numberCliente}""");
                if (!await launchUrl(_url)) {
                  throw Exception('Could not launch $_url');
                }
                setState(() {
                  _controllerModalText.clear();
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _Reagendado() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Fecha",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () async {
                var results = await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    selectedYearTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                    weekdayLabelTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),
                  dialogSize: const Size(325, 400),
                  value: _dates,
                  borderRadius: BorderRadius.circular(15),
                );
                setState(() {
                  if (results != null) {
                    dateSelect = results![0].toString().split(" ")[0];
                  }
                });
              },
              child: Text(
                "Fecha: $dateSelect ",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: dateSelect != ""
                  ? () async {
                      getLoadingModal(context, false);

                      await Connections()
                          .updateOrderStatusOperatorPedidoProgramado(
                              "REAGENDADO",
                              _controllerModalText.text,
                              dateSelect.split('-').reversed.join('-'));
                      setState(() {
                        _controllerModalText.clear();
                        dateSelect = "";
                        _dates.clear();
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _EnRuta() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                await Connections().updateOrderStatusOperatorGeneral(
                    "EN RUTA", _controllerModalText.text);
                setState(() {
                  _controllerModalText.clear();
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _PedidoProgramado() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                await Connections().updateOrderStatusOperatorGeneral(
                    "PEDIDO PROGRAMADO", _controllerModalText.text);
                setState(() {
                  _controllerModalText.clear();
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Container _EnOficina() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                await Connections().updateOrderStatusOperatorGeneral(
                    "EN OFICINA", _controllerModalText.text);
                setState(() {
                  _controllerModalText.clear();
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Guardar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Salir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Row _modelCheckEfectivo() {
    return Row(
      children: [
        Checkbox(
            value: efectivo,
            onChanged: (v) {
              setState(() {
                efectivo = v!;
                transferencia = false;
                deposito = false;

                imageSelect = null;
              });
            }),
        Flexible(
            child: Text(
          "Efectivo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ))
      ],
    );
  }

  Row _modelCheckTransferencia() {
    return Row(
      children: [
        Checkbox(
            value: transferencia,
            onChanged: (v) {
              setState(() {
                transferencia = v!;
                efectivo = false;
                deposito = false;
                imageSelect = null;
              });
            }),
        Flexible(
            child: Text(
          "Transferencia",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ))
      ],
    );
  }

  Row _modelCheckDeposito() {
    return Row(
      children: [
        Checkbox(
            value: deposito,
            onChanged: (v) {
              setState(() {
                deposito = v!;
                efectivo = false;
                transferencia = false;
                imageSelect = null;
              });
            }),
        Flexible(
            child: Text(
          "Deposito",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ))
      ],
    );
  }
}
