import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/novedad_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateStatusOperatorHistorial extends StatefulWidget {
  final String numberTienda;
  final String codigo;
  final String numberCliente;
  final String id;
  final List novedades;
  final String currentStatus;
  final String? comment;
  final Function? function;
  final List? dataL;
  final int? rolidinvoke;

  const UpdateStatusOperatorHistorial(
      {super.key,
      required this.numberTienda,
      required this.codigo,
      required this.numberCliente,
      required this.id,
      required this.novedades,
      required this.currentStatus,
      this.comment,
      this.function,
      this.dataL,
      this.rolidinvoke});

  @override
  State<UpdateStatusOperatorHistorial> createState() =>
      _UpdateStatusOperatorHistorialState();
}

class _UpdateStatusOperatorHistorialState
    extends State<UpdateStatusOperatorHistorial> {
  List<String> status = [];
  String? selectedValueStatus;
  List<DateTime?> _dates = [];
  List novedades = [];
  String dateSelect = "";
  bool efectivo = false;
  bool transferencia = false;
  bool deposito = false;
  TextEditingController _controllerModalText = TextEditingController();
  XFile? imageSelect = null;
  var dataL = {};

  final TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  final TextEditingController _comentarioController = TextEditingController();

  createlistStatus() {
    if (widget.rolidinvoke == 1) {
      status = [
        "ENTREGADO",
        "NO ENTREGADO",
        "NOVEDAD",
        "NOVEDAD RESUELTA",
        "REAGENDADO",
        "EN RUTA",
        "PEDIDO PROGRAMADO",
        "EN OFICINA"
      ];
    } else {
      status = [
        "ENTREGADO",
        "NO ENTREGADO",
        "NOVEDAD",
        "REAGENDADO",
        "EN RUTA",
        "PEDIDO PROGRAMADO",
        "EN OFICINA"
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    createlistStatus();

    var order = widget.dataL!.firstWhere(
        (item) => item['id'].toString() == widget.id,
        orElse: () => null);

    dataL = order;

    // _comentarioController.text = safeValue(dataL['comentario']);
    _comentarioController.text = widget.comment!;
  }

  var idUser = sharedPrefs!.getString("id");

  getRefered(id) async {
    // loadData();
    var refered = await Connections().getSellerMaster(id);
    return refered;
  }

  @override
  Widget build(BuildContext context) {
    loadData();
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
                    .where((item) => item != widget.currentStatus)
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
                  children: [generateContent(_statusController)],
                )
              ],
            )),
          ],
        ),
      ),
    );
  }

  generateContent(_statusController) {
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
      case "NOVEDAD RESUELTA":
        return _NovedadResuelta(_statusController);
      default:
    }
  }

  Container _Entregado() {
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text("Tipo de Pago",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(
            height: 10,
          ),
          _modelCheckEfectivo(),
          const SizedBox(
            height: 10,
          ),
          _modelCheckTransferencia(),
          const SizedBox(
            height: 10,
          ),
          _modelCheckDeposito(),
          const SizedBox(
            height: 10,
          ),
          transferencia == true
              ? const Text("Foto",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              : Container(),
          const SizedBox(
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
                  child: const Text(
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
          const SizedBox(
            height: 10,
          ),
          const Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(
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

                      var urlImg = await Connections().postDoc(imageSelect!);

                      var datacostos = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);

                      await paymentEntregado(datacostos, tipo, urlImg);

                      //add transaccion_pedido
                      var today = DateTime.now().toString().split(' ')[0];
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datacostos['transportadora'][0]['id'], today);
                      if (getTransaccion == null) {
                        var idOper = "";
                        if (datacostos.containsKey("operadore") &&
                            datacostos["operadore"] is List &&
                            datacostos["operadore"].isNotEmpty) {
                          idOper = datacostos["operadore"][0]["id"].toString();
                          print(idOper);
                        } else {
                          print("problemas con idOper");
                        }
                        try {
                          var resTrans = await Connections()
                              .createTransaccionPedidoTransportadora(
                                  widget.id,
                                  datacostos['transportadora'][0]['id'],
                                  idOper,
                                  "ENTREGADO",
                                  datacostos['precio_total'],
                                  datacostos['transportadora'][0]
                                      ['costo_transportadora']);
                        } catch (e) {
                          print("error en createTPT");
                        }
                      } else {
                        var updateTransacc = await Connections()
                            .updateTraccionPedidoTransportadora(
                                getTransaccion[0]['id'].toString(),
                                "ENTREGADO");
                      }

                      setState(() {
                        _controllerModalText.clear();
                        tipo = "";
                        deposito = false;
                        efectivo = false;
                        transferencia = false;
                        imageSelect = null;
                      });
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

                          // ! aqui consultar para que traiga los costos_envio,costo_devolucion
                          var datacostos = await Connections()
                              .getOrderByIDHistoryLaravel(widget.id);

                          await paymentEntregado(datacostos, tipo, "");

                          //add transaccion_pedido
                          var data = await Connections()
                              .getOrderByIDHistoryLaravel(widget.id);

                          var today = DateTime.now().toString().split(' ')[0];
                          // today = '2023-10-12';
                          // print("today: $today");
                          var getTransaccion = await Connections()
                              .getTraccionPedidoTransportadora(widget.id,
                                  data['transportadora'][0]['id'], today);
                          if (getTransaccion == null) {
                            var idOper = "";
                            if (datacostos.containsKey("operadore") &&
                                datacostos["operadore"] is List &&
                                datacostos["operadore"].isNotEmpty) {
                              idOper =
                                  datacostos["operadore"][0]["id"].toString();
                              print(idOper);
                            } else {
                              print("problemas con idOper");
                              print(idOper);
                            }
                            try {
                              var resTrans = await Connections()
                                  .createTransaccionPedidoTransportadora(
                                      widget.id,
                                      data['transportadora'][0]['id'],
                                      idOper,
                                      "ENTREGADO",
                                      data['precio_total'],
                                      data['transportadora'][0]
                                          ['costo_transportadora']);
                            } catch (e) {
                              print("error en createTPT");
                            }
                          } else {
                            var updateTransacc = await Connections()
                                .updateTraccionPedidoTransportadora(
                                    getTransaccion[0]['id'], "ENTREGADO");
                          }

                          setState(() {
                            _controllerModalText.clear();
                            tipo = "";
                            deposito = false;
                            efectivo = false;
                            transferencia = false;
                            imageSelect = null;
                          });
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

  Future<void> dialogNoEntregado(resDelivered) async {
    if (resDelivered == 0) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Se ha modificado exitosamente',
        desc: 'Pedido no entregado',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        descTextStyle: const TextStyle(color: Colors.green),
        btnOkColor: Colors.green,
        dialogBackgroundColor: Colors.red[200],
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Error al realizar la transaccion",
        //  desc: 'Vuelve a intentarlo',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    }
  }

  Future<void> dialogEntregado(resDelivered) async {
    if (resDelivered == 0) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Se ha modificado exitosamente',
        desc: 'Pedido entregado',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        descTextStyle: const TextStyle(color: Colors.green),
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Error al realizar la transaccion",
        //  desc: 'Vuelve a intentarlo',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    }
  }

  Future<void> paymentEntregado(datacostos, String tipo, urlImage) async {
    var resDelivered = await Connections().paymentOrderDelivered(
        datacostos['users'][0]['vendedores'][0]['id_master'],
        datacostos['precio_total'],
        datacostos['users'][0]['vendedores'][0]['costo_envio'],
        datacostos['id'],
        "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
        _controllerModalText.text,
        urlImage != "" ? urlImage[1] : "",
        tipo);

    dialogEntregado(resDelivered);
  }

  Future<void> paymentNoEntregado(datane) async {
    var response = await Connections().postDoc(imageSelect!);
    var resDelivered = await Connections().paymentOrderNotDelivered(
        datane['users'][0]['vendedores'][0]['id_master'],
        datane['users'][0]['vendedores'][0]['costo_envio'],
        datane['id'],
        "${datane['name_comercial']}-${datane['numero_orden']}",
        _controllerModalText.text,
        response[1]);

    dialogNoEntregado(resDelivered);
  }

  Future<void> dialogNovedad(resNovelty) async {
    if (resNovelty != 1 || resNovelty != 2) {
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
        btnOkOnPress: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error al modificar estado',
        desc: 'No se pudo cambiar a novedad',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        descTextStyle: const TextStyle(color: Color.fromARGB(255, 255, 59, 59)),
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ).show();
    }
  }

  Future<void> paymentNovedad(id) async {
    var resNovelty =
        await Connections().paymentNovedad(id, _controllerModalText.text, "");

    dialogNovedad(resNovelty);
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
                      setState(() {});

                      var datane = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);

                      paymentNoEntregado(datane);

                      var today = DateTime.now().toString().split(' ')[0];
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datane['transportadora'][0]['id'], today);

                      if (getTransaccion == null) {
                        var idOper = "";
                        if (datane.containsKey("operadore") &&
                            datane["operadore"] is List &&
                            datane["operadore"].isNotEmpty) {
                          idOper = datane["operadore"][0]["id"].toString();
                          print(idOper);
                        } else {
                          print("problemas con idOper");
                        }
                        try {
                          var resTrans = await Connections()
                              .createTransaccionPedidoTransportadora(
                                  widget.id,
                                  datane['transportadora'][0]['id'],
                                  idOper,
                                  "NO ENTREGADO",
                                  datane['precio_total'],
                                  datane['transportadora'][0]
                                      ['costo_transportadora']);
                        } catch (e) {
                          print("error en createTPT $e");
                        }
                      } else {
                        try {
                          var updateTransacc = await Connections()
                              .updateTraccionPedidoTransportadora(
                                  getTransaccion[0]['id'], "NO ENTREGADO");
                        } catch (e) {
                          print(
                              "error en updateTraccionPedidoTransportadora: $e");
                        }
                      }

                      setState(() {
                        _controllerModalText.clear();

                        imageSelect = null;
                      });
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
          Text("Foto Novedad",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(
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
              child: const Text(
                "Seleccionar:",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 10,
          ),
          Text("${imageSelect != null ? imageSelect!.name.toString() : ''}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: imageSelect != null
                  ? () async {
                      getLoadingModal(context, false);
                      if (widget.novedades.length < 4) {
                        var response =
                            await Connections().postDoc(imageSelect!);
                        await saveNovedad(
                            widget.id,
                            widget.novedades.length + 1,
                            response[1],
                            _controllerModalText.text);
                      }

                      if (widget.novedades.isEmpty) {
                        await Connections().updateOrderWithTime(
                            widget.id.toString(),
                            "status:NOVEDAD_date",
                            idUser,
                            "", {
                          "comentario": _controllerModalText.text,
                          "archivo": ""
                        });
                        //
                      } else {
                        await Connections().updateOrderWithTime(
                            widget.id.toString(),
                            "status:NOVEDAD",
                            idUser,
                            "", {
                          "comentario": _controllerModalText.text,
                          "archivo": ""
                        });
                      }
                      var resTransaction = "";
                      paymentNovedad(widget.id);
                      var datacostos = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);
                      var _url = Uri.parse(
                          """https://api.whatsapp.com/send?phone=${widget.numberTienda}&text=
                                        El pedido con código ${widget.codigo} cambió su estado a novedad, motivo: ${_controllerModalText.text}. Teléfono del cliente: ${widget.numberCliente}""");
                      if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }

                      // * if it exists, delete transaccion_pedidos_transportadora
                      var today = DateTime.now().toString().split(' ')[0];
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datacostos['transportadora'][0]['id'], today);
                      if (getTransaccion != null) {
                        var deleteTransacc = await Connections()
                            .deleteTraccionPedidoTransportadora(
                                getTransaccion[0]['id']);
                      }

                      setState(() {
                        _controllerModalText.clear();
                        imageSelect = null;
                      });
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

  confirmedDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo al presionar "Aceptar"
              },
            ),
          ],
        );
      },
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
                      List date = dateSelect.split('-');
                      await Connections().updateOrderWithTime(
                          widget.id.toString(),
                          "status:REAGENDADO",
                          idUser,
                          "", {
                        "comentario": _controllerModalText.text,
                        "archivo": "",
                        "fecha_entrega":
                            "${int.parse(date[2])}/${int.parse(date[1])}/${date[0]}"
                      });

                      // * if it exists, delete transaccion_pedidos_transportadora
                      var datares = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);
                      var today = DateTime.now().toString().split(' ')[0];
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datares['transportadora'][0]['id'], today);
                      if (getTransaccion != null) {
                        var deleteTransacc = await Connections()
                            .deleteTraccionPedidoTransportadora(
                                getTransaccion[0]['id']);
                      }

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

                // await Connections().updateOrderStatusOperatorGeneralHistorial(
                //     "EN RUTA", _controllerModalText.text, widget.id);

                //upt for the above and status_last_modified_by and by
                await Connections().updateOrderWithTime(
                    widget.id.toString(),
                    "status:EN RUTA",
                    idUser,
                    "",
                    {"comentario": _controllerModalText.text, "archivo": ""});

                // * if it exists, delete transaccion_pedidos_transportadora
                var datares =
                    await Connections().getOrderByIDHistoryLaravel(widget.id);
                var today = DateTime.now().toString().split(' ')[0];
                var getTransaccion = await Connections()
                    .getTraccionPedidoTransportadora(
                        widget.id, datares['transportadora'][0]['id'], today);
                if (getTransaccion != null) {
                  var deleteTransacc = await Connections()
                      .deleteTraccionPedidoTransportadora(
                          getTransaccion[0]['id']);
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

                // await Connections().updateOrderStatusOperatorGeneralHistorial(
                //     "PEDIDO PROGRAMADO", _controllerModalText.text, widget.id);

                //upt for the above and status_last_modified_by and by
                await Connections().updateOrderWithTime(
                    widget.id.toString(),
                    "status:PEDIDO PROGRAMADO",
                    idUser,
                    "",
                    {"comentario": _controllerModalText.text, "archivo": ""});

                // * if it exists, delete transaccion_pedidos_transportadora
                var datares =
                    await Connections().getOrderByIDHistoryLaravel(widget.id);
                var today = DateTime.now().toString().split(' ')[0];
                var getTransaccion = await Connections()
                    .getTraccionPedidoTransportadora(
                        widget.id, datares['transportadora'][0]['id'], today);
                if (getTransaccion != null) {
                  var deleteTransacc = await Connections()
                      .deleteTraccionPedidoTransportadora(
                          getTransaccion[0]['id']);
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

                // await Connections().updateOrderStatusOperatorGeneralHistorial(
                //     "EN OFICINA", _controllerModalText.text, widget.id);

                // //upt for the above and status_last_modified_by and by
                await Connections().updateOrderWithTime(
                    widget.id.toString(),
                    "status:EN OFICINA",
                    idUser,
                    "",
                    {"comentario": _controllerModalText.text, "archivo": ""});

                // * if it exists, delete transaccion_pedidos_transportadora
                var datares =
                    await Connections().getOrderByIDHistoryLaravel(widget.id);
                var today = DateTime.now().toString().split(' ')[0];
                var getTransaccion = await Connections()
                    .getTraccionPedidoTransportadora(
                        widget.id, datares['transportadora'][0]['id'], today);
                if (getTransaccion != null) {
                  var deleteTransacc = await Connections()
                      .deleteTraccionPedidoTransportadora(
                          getTransaccion[0]['id']);
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

  Future<void> saveNovedad(id_pedido, intento, url_imagen, comment) async {
    var response = await Connections()
        .createNovedad(id_pedido, intento, url_imagen, comment);
  }

  // ! **********************************************

  Container _NovedadResuelta(_statusController) {
    var resChange = "";

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Status:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _statusController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('Comentario:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (dataL['operadore'] != null &&
                      dataL['operadore'].isNotEmpty) {
                    await sendWhatsAppMessage(
                        context, dataL, _comentarioController.text);
                    var resaux = await Connections().updateOrderWithTime(
                        dataL['id'].toString(),
                        "status:${_statusController.text}",
                        idUser,
                        "",
                        {"comentario": _comentarioController.text});
                    if (resaux != null) {
                      resChange = "ok";
                    }
                  } else {
                    _showErrorSnackBar(
                        context, "El pedido no tiene un Operador Asignado.");
                  }

                  if (resChange == "ok") {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Estado Actualizado a Novedad Resuelta',
                      // desc: resChange,
                      descTextStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 235, 59)),
                      btnCancel: Container(),
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        // widget.function!();
                      },
                    ).show();
                  } else {
                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error ',
                      // desc: 'Pedido con novedad',
                      btnCancel: Container(),
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      descTextStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 235, 59)),
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ).show();
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> sendWhatsAppMessage(BuildContext context,
      Map<dynamic, dynamic> orderData, String newComment) async {
    String? phoneNumber = "";
    if (widget.rolidinvoke == 3 || widget.rolidinvoke == 1) {
      phoneNumber = orderData['operadore'].isNotEmpty == true &&
              orderData['operadore'] != null
          ? orderData['operadore'][0]['telefono']
          : null;
    } else if (widget.rolidinvoke == 4) {
      phoneNumber = orderData['attributes']['operadore'] != null
          ? orderData['attributes']['operadore']['data']['attributes']
              ['Telefono']
          : null;
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      var message = "";
      var whatsappUrl = "";
      if (widget.rolidinvoke! == 3 || widget.rolidinvoke! == 1) {
        message =
            // "Buen Día, la guía con el código ${orderData['name_comercial']}-${orderData['numero_orden']} << de la tienda >> ${orderData['tienda_temporal']} << indica: ' $newComment ' .";
            "Buen Día, la guía con el código ${orderData['name_comercial']}-${orderData['numero_orden']} indica que ' $newComment ' .";
        whatsappUrl =
            "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";
      } else if (widget.rolidinvoke! == 4) {
        // "${data['attributes']['Name_Comercial']}-${data['attributes']['NumeroOrden']}
        message =
            "Buen Día, la guía con el código >> ${orderData['attributes']['NumeroOrden']} << de la tienda >> ${orderData['attributes']['Tienda_Temporal']} << indica: ' $newComment ' .";
        whatsappUrl =
            "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";
      }

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      // _showErrorSnackBar(context, "El pedido no tiene un operador asignado.");
    }
  }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
        ),
        backgroundColor: Color.fromARGB(255, 253, 101, 90),
        duration: Duration(seconds: 4),
      ),
    );
  }

  String safeValue(dynamic value, [String defaultValue = '']) {
    return (value ?? defaultValue).toString();
  }
}
