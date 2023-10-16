import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
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

  const UpdateStatusOperatorHistorial(
      {super.key,
      required this.numberTienda,
      required this.codigo,
      required this.numberCliente,
      required this.id,
      required this.novedades,
      required this.currentStatus});

  @override
  State<UpdateStatusOperatorHistorial> createState() =>
      _UpdateStatusOperatorHistorialState();
}

class _UpdateStatusOperatorHistorialState
    extends State<UpdateStatusOperatorHistorial> {
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
  List novedades = [];
  String dateSelect = "";
  bool efectivo = false;
  bool transferencia = false;
  bool deposito = false;
  TextEditingController _controllerModalText = TextEditingController();
  XFile? imageSelect = null;

  getRefered(id) async {
    var refered = await Connections().getSellerMaster(id);
    return refered;
  }

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
                  children: [generateContent()],
                )
              ],
            )),
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

                      var datacostos = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);

                      String resTransaction = "";
                      var resCredit = await Connections().postCredit(
                          "${datacostos['users'][0]['vendedores'][0]['id_master']}",
                          "${datacostos['precio_total']}",
                          "${datacostos['id']}",
                          "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                          "recaudo",
                          "recaudo de precio total de pedido");
                      if (resCredit == 0) {
                        var resDebit = await Connections().postDebit(
                            "${datacostos['users'][0]['vendedores'][0]['id_master']}",
                            "${datacostos['users'][0]['vendedores'][0]['costo_envio']}",
                            "${datacostos['id']}",
                            "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                            "envio",
                            "costo de envio de pedido entregado");

                        if (resDebit == 0) {
                          var response =
                              await Connections().postDoc(imageSelect!);

                          await Connections()
                              .updateOrderStatusOperatorEntregadoHistorial(
                                  "ENTREGADO",
                                  tipo,
                                  _controllerModalText.text,
                                  response[1],
                                  widget.id);

                          if (datacostos['users'][0]['vendedores'][0]
                                  ['referer'] !=
                              null) {
                            var refered = await getRefered(datacostos['users']
                                [0]['vendedores'][0]['referer']);
                            if (refered != null) {
                              if (refered['referer_cost'] != null) {
                                await Connections().postCredit(
                                    "${datacostos['users'][0]['vendedores'][0]['referer']}",
                                    "${refered['referer_cost']}",
                                    "${datacostos['id']}",
                                    "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                                    "referido",
                                    "acreditacion por comision de vendedor referido");
                              }
                            }
                          }

                          await Connections().updatenueva(widget.id, {
                            "costo_envio": datacostos['users'][0]['vendedores']
                                [0]['costo_envio'],
                            "costo_transportadora": datacostos['users'][0]
                                ['vendedores'][0]['costo_envio'],
                          });
                        } else {
                          resTransaction =
                              "Ha ocurrido un error al ejecutar la transacción";
                        }
                      } else {
                        resTransaction =
                            "Ha ocurrido un error al ejecutar la transacción";
                      }

                      //add transaccion_pedido
                      var today = DateTime.now().toString().split(' ')[0];
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datacostos['transportadora'][0]['id'], today);
                      if (getTransaccion == null) {
                        var resTrans = await Connections()
                            .createTransaccionPedidoTransportadora(
                                widget.id,
                                datacostos['transportadora'][0]['id'],
                                datacostos['operadore'][0]['id'],
                                "ENTREGADO",
                                datacostos['precio_total'],
                                datacostos['transportadora'][0]
                                    ['costo_transportadora']);
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

                      if (resTransaction != "") {
                        // ignore: use_build_context_synchronously
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: resTransaction,
                          //  desc: 'Vuelve a intentarlo',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,

                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            Navigator.pop(context);
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
                          desc: 'Pedido entregado',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,
                          descTextStyle: const TextStyle(color: Colors.green),
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ).show();
                      }
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

                          // if (datacostos['costo_envio'] != null) {

                          // }
                          String resTransaction = "";

                          var resCredit = await Connections().postCredit(
                              "${datacostos['users'][0]['vendedores'][0]['id_master']}",
                              "${datacostos['precio_total']}",
                              "${datacostos['id']}",
                              "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                              "recaudo",
                              "recaudo de precio total de pedido");
                          if (resCredit == 0) {
                            var resDebit = await Connections().postDebit(
                                "${datacostos['users'][0]['vendedores'][0]['id_master']}",
                                "${datacostos['users'][0]['vendedores'][0]['costo_envio']}",
                                "${datacostos['id']}",
                                "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                                "envio",
                                "costo de envio de pedido entregado");

                            await Connections().updatenueva(widget.id, {
                              "costo_envio": datacostos['users'][0]
                                  ['vendedores'][0]['costo_envio'],
                            });

                            if (resDebit == 0) {
                              var respp = await Connections()
                                  .updateOrderStatusOperatorEntregadoHistorial(
                                      "ENTREGADO",
                                      tipo,
                                      _controllerModalText.text,
                                      "",
                                      widget.id);
                              if (datacostos['users'][0]['vendedores'][0]
                                      ['referer'] !=
                                  null) {
                                var refered = getRefered(datacostos['users'][0]
                                    ['vendedores'][0]['referer']);

                                if (refered != null) {
                                  if (refered['referer_cost'] != null) {
                                    await Connections().postCredit(
                                        "${datacostos['users'][0]['vendedores'][0]['referer']}",
                                        "${refered['referer_cost']}",
                                        "${datacostos['id']}",
                                        "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                                        "referido",
                                        "acreditacion por comision de vendedor referido");
                                  }
                                }
                              }
                            } else {
                              resTransaction =
                                  "Ha ocurrido un error al ejecutar la transacción";
                            }
                          } else {
                            resTransaction =
                                "Ha ocurrido un error al ejecutar la transacción";
                          }

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
                            var resTrans = await Connections()
                                .createTransaccionPedidoTransportadora(
                                    widget.id,
                                    data['transportadora'][0]['id'],
                                    data['operadore'][0]['id'],
                                    "ENTREGADO",
                                    data['precio_total'],
                                    data['transportadora'][0]
                                        ['costo_transportadora']);
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
                          if (resTransaction != "") {
                            // ignore: use_build_context_synchronously
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: resTransaction,
                              //  desc: 'Vuelve a intentarlo',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              btnOkColor: Colors.green,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                Navigator.pop(context);
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
                              desc: 'Pedido entregado',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              descTextStyle:
                                  const TextStyle(color: Colors.green),
                              btnOkColor: Colors.green,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ).show();
                          }
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
                      setState(() {});

                      var datane = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);

                      var resTransaction = "";
                      var resDebit = await Connections().postDebit(
                          "${datane['users'][0]['vendedores'][0]['id_master']}",
                          "${datane['users'][0]['vendedores'][0]['costo_envio']}",
                          "${datane['id']}",
                          "${datane['name_comercial']}-${datane['numero_orden']}",
                          "envio",
                          "costo de envio por pedido no entregado");

                      if (resDebit == 0) {
                        var response =
                            await Connections().postDoc(imageSelect!);

                        await Connections()
                            .updateOrderStatusOperatorNoEntregadoHistorial(
                                "NO ENTREGADO",
                                _controllerModalText.text,
                                response[1],
                                widget.id);
                        await Connections().updatenueva(widget.id, {
                          "costo_envio": datane['users'][0]['vendedores'][0]
                              ['costo_envio'],
                        });
                      } else {
                        resTransaction =
                            "Ha ocurrido un error al ejecutar la transacción";
                      }

                      if (resTransaction != "") {
                        // ignore: use_build_context_synchronously
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: resTransaction,
                          //  desc: 'Vuelve a intentarlo',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,
                          dialogBackgroundColor: Colors.red[200],
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            Navigator.pop(context);
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
                          desc: 'Pedio no entregado',
                          descTextStyle: const TextStyle(color: Colors.red),
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ).show();
                      }

                      var today = DateTime.now().toString().split(' ')[0];
                      // today = '2023-10-12';
                      // print("today: $today");
                      var getTransaccion = await Connections()
                          .getTraccionPedidoTransportadora(widget.id,
                              datane['transportadora'][0]['id'], today);
                      if (getTransaccion == null) {
                        var resTrans = await Connections()
                            .createTransaccionPedidoTransportadora(
                                widget.id,
                                datane['transportadora'][0]['id'],
                                datane['operadore'][0]['id'],
                                "NO ENTREGADO",
                                datane['precio_total'],
                                datane['transportadora'][0]
                                    ['costo_transportadora']);
                      } else {
                        var updateTransacc = await Connections()
                            .updateTraccionPedidoTransportadora(
                                getTransaccion[0]['id'], "NO ENTREGADO");
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
                        await Connections()
                            .updateOrderStatusOperatorGeneralHistorialAndDate(
                                "NOVEDAD",
                                _controllerModalText.text,
                                widget.id);
                      } else {
                        await Connections()
                            .updateOrderStatusOperatorGeneralHistorial(
                                "NOVEDAD",
                                _controllerModalText.text,
                                widget.id);
                      }
                      var resTransaction = "";
                      var datacostos = await Connections()
                          .getOrderByIDHistoryLaravel(widget.id);

                      var l = datacostos['estado_devolucion'];

                      if (datacostos['estado_devolucion'] != "PENDIENTE" &&
                          datacostos['estado_devolucion'] !=
                              "ENTREGADO EN OFICINA") {
                        var existTransaction = Connections().getExistTransaction(
                            "debit",
                            "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                            "devolucion",
                            datacostos['users'][0]['vendedores'][0]['id']);
                        if (existTransaction == []) {
                          var resDebit = await Connections().postDebit(
                              "${datacostos['users'][0]['vendedores'][0]['id']}",
                              "${datacostos['users'][0]['vendedores'][0]['costo_devolucion']}",
                              "${datacostos['id']}",
                              "${datacostos['name_comercial']}-${datacostos['numero_orden']}",
                              "devolucion",
                              "costo de devolucion de pedido ");

                          await Connections().updatenueva(widget.id, {
                            "costo_devolucion": datacostos['users'][0]
                                ['vendedores'][0]['costo_devolucion'],
                          });
                          if (resDebit != 1 && resDebit != 2) {
                            resTransaction =
                                "Pedido con novedad con costo devolucion";
                          }
                        }
                      }

                      var _url = Uri.parse(
                          """https://api.whatsapp.com/send?phone=${widget.numberTienda}&text=
                                        El pedido con código ${widget.codigo} cambio su estado a novedad, motivo: ${_controllerModalText.text}. Teléfono del cliente: ${widget.numberCliente}""");
                      if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }

                      if (resTransaction != "") {
                        // ignore: use_build_context_synchronously
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Se ha modificado exitosamente',
                          desc: resTransaction,
                          descTextStyle: const TextStyle(
                              color: Color.fromARGB(255, 255, 235, 59)),
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
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Se ha modificado exitosamente',
                          desc: 'Pedido con novedad',
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
                      await Connections()
                          .updateOrderStatusOperatorPedidoProgramadoHistorial(
                              "REAGENDADO",
                              _controllerModalText.text,
                              date[2].toString().replaceAll('0', '') +
                                  "/" +
                                  date[1].toString().replaceAll('0', '') +
                                  "/" +
                                  date[0].toString(),
                              widget.id);

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

                await Connections().updateOrderStatusOperatorGeneralHistorial(
                    "EN RUTA", _controllerModalText.text, widget.id);

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

                await Connections().updateOrderStatusOperatorGeneralHistorial(
                    "PEDIDO PROGRAMADO", _controllerModalText.text, widget.id);

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

                await Connections().updateOrderStatusOperatorGeneralHistorial(
                    "EN OFICINA", _controllerModalText.text, widget.id);

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
}
