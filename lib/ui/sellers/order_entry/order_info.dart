import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';

class OrderInfo extends StatefulWidget {
  final Map order;
  final int index;
  final String codigo;
  final Function(BuildContext, int) sumarNumero;
  final List data;

  const OrderInfo(
      {super.key,
      required this.order,
      required this.index,
      required this.sumarNumero,
      required this.codigo,
      required this.data});

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  var data = {};
  bool loading = true;
  OrderEntryControllers _controllers = OrderEntryControllers();
  String estadoEntrega = "";
  String estadoLogistic = "";

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    data = widget.order;
    _controllers.editControllers(widget.order);
    setState(() {
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
    });

    setState(() {
      loading = false;
    });
  }

  updateData() async {
    var response = await Connections().getOrdersByIdLaravel(widget.order['id']);
    data = response;
    //print(data);
    _controllers.editControllers(response);
    setState(() {
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Container(),
          centerTitle: true,
          title: Text(
            "Información Pedido",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          ),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            estadoLogistic == "ENVIADO"
                                ? Container()
                                : ElevatedButton(
                                    onPressed: () async {
                                      var response = await Connections()
                                          .updateOrderInteralStatusLaravel(
                                              "NO DESEA", widget.order["id"]);

                                      widget.sumarNumero(context, widget.index);

                                      setState(() {});
                                    },
                                    child: const Text(
                                      "No Desea",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return RoutesModalv2(
                                          idOrder: widget.order["id"],
                                          someOrders: false,
                                          phoneClient: data['telefono_shipping']
                                              .toString(),
                                          codigo: widget.codigo,
                                          origin: "",
                                        );
                                      });
                                  updateData();
                                },
                                child: Text(
                                  "Confirmar",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    getLoadingModal(context, false);
                                    await _controllers.updateInfo(
                                        id: widget.order["id"],
                                        success: () async {
                                          Navigator.pop(context);
                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.success,
                                            animType: AnimType.rightSlide,
                                            title: 'Guardado',
                                            desc: '',
                                            btnCancel: Container(),
                                            btnOkText: "Aceptar",
                                            btnOkColor: colors.colorGreen,
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () {},
                                          ).show();
                                          await updateData();
                                        },
                                        error: () {
                                          Navigator.pop(context);

                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.rightSlide,
                                            title: 'Data Incorrecta',
                                            desc: 'Vuelve a intentarlo',
                                            btnCancel: Container(),
                                            btnOkText: "Aceptar",
                                            btnOkColor: colors.colorGreen,
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () {},
                                          ).show();
                                        });
                                  }
                                },
                                child: Text(
                                  "Guardar",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          // "  Fecha: ${data['pedido_fecha'][0]['fecha'].toString()}",
                          "  Fecha: ${data['marca_t_i'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _modelTextFormField2(
                            text: "Ciudad",
                            controller: _controllers.ciudadEditController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                              // else if (containsEmoji(value)) {
                              //   return "No se permiten emojis en este campo";
                              // }
                            }),
                        _modelTextFormField2(
                            text: "Nombre Cliente",
                            controller: _controllers.nombreEditController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                              // else if (containsEmoji(value)) {
                              //   return "No se permiten emojis en este campo";
                              // }
                            }),
                        _modelTextFormField2(
                            text: "Dirección",
                            controller: _controllers.direccionEditController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                              // else if (containsEmoji(value)) {
                              //   return "No se permiten emojis en este campo";
                              // }
                            }),
                        _modelTextFormField2(
                            text: "Teléfono",
                            controller: _controllers.telefonoEditController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+]')),
                            ],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                            }),
                        _modelTextFormField2(
                            text: "Cantidad",
                            controller: _controllers.cantidadEditController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                            }),
                        _modelTextFormField2(
                            text: "Producto",
                            controller: _controllers.productoEditController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                              // else if (containsEmoji(value)) {
                              //   return "No se permiten emojis en este campo";
                              // }
                            }),
                        _modelTextField(
                            text: "Producto Extra",
                            controller:
                                _controllers.productoExtraEditController),
                        _modelTextFormField2(
                            text: "Precio Total",
                            controller: _controllers.precioTotalEditController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'^\d+\.?\d{0,2}$')), // "." y hasta 2 decimales
                            ],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo requerido";
                              }
                            }),
                        _modelTextField(
                            text: "Observacion",
                            controller: _controllers.observacionEditController),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Confirmado: ${data['estado_interno'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado Entrega: $estadoEntrega",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado Logístico: $estadoLogistic",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Ciudad: ${data['ruta'] != null && data['ruta'].isNotEmpty ? data['ruta'][0]['titulo'].toString() : ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Transportadora: ${data['transportadora'] != null && data['transportadora'].isNotEmpty ? data['transportadora'][0]['nombre'].toString() : ''}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
            ),
          ),
        )));
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "$text: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: text,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusColor: Colors.black,
                    iconColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  _modelTextFormField2({
    text,
    controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "$text: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: text,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusColor: Colors.black,
                    iconColor: Colors.black,
                  ),
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: validator,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
