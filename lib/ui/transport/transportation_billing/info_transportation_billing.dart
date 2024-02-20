import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/transport/transportation_billing/controllers/controller-backup.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/rich_text.dart';

class InfoTransportationBilling extends StatefulWidget {
  // final String id;
  final Map order;

  const InfoTransportationBilling({
    super.key,
    // required this.id,
    required this.order,
  });

  @override
  State<InfoTransportationBilling> createState() =>
      _InfoTransportationBilling();
}

class _InfoTransportationBilling extends State<InfoTransportationBilling> {
  var data = {};
  bool loading = true;
  // final OrderInfoOperatorBackupControllers _controllers =
  //     OrderInfoOperatorBackupControllers();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = await Connections().getOrdersByIDTransport(widget.id);
    // data = response;
    data = widget.order;
    // _controllers.editControllers(data);

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorsSystem().colorBlack,
          leading: Container(),
          centerTitle: true,
          title: const Text(
            "Información Pedido",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
        ),
        body: SafeArea(
            child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: ColorsSystem().colorBlack, width: 2.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichTextTitleContent(
                          title: "Fecha Envio",
                          content: data['marca_tiempo_envio'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Fecha de Entrega",
                          content: data['fecha_entrega'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Código",
                          content:
                              "${data['users'] != null && data['users'].isNotEmpty ? data['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data['numero_orden'].toString()}",
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: ColorsSystem().colorSelectMenu,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "DATOS DEL CLIENTE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Nombre Cliente",
                          content: data['nombre_shipping'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Dirección",
                          content: data['direccion_shipping'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Telefóno cliente",
                          content: data['telefono_shipping'].toString(),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: ColorsSystem().colorSelectMenu,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "DETALLES DEL PEDIDO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichTextTitleContent(
                          title: "Cantidad",
                          content: data['cantidad_total'],
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Producto",
                          content: data['producto_p'],
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Producto Extra",
                          content: data['producto_extra'] == null ||
                                  data['producto_extra'].toString() == "null"
                              ? ""
                              : data['producto_extra'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Precio Total",
                          content: "\$ ${data['precio_total'].toString()}",
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Status",
                          content: data['status'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Tipo de Pago",
                          content: data['tipo_pago'] == null ||
                                  data['tipo_pago'].toString() == "null"
                              ? ""
                              : data['tipo_pago'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Operador",
                          content: data['operadore'].toString() != null &&
                                  data['operadore'].toString().isNotEmpty
                              ? data['operadore'] != null &&
                                      data['operadore'].isNotEmpty &&
                                      data['operadore'][0]['up_users'] !=
                                          null &&
                                      data['operadore'][0]['up_users']
                                          .isNotEmpty &&
                                      data['operadore'][0]['up_users'][0]
                                              ['username'] !=
                                          null
                                  ? data['operadore'][0]['up_users'][0]
                                      ['username']
                                  : ""
                              : "",
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Estado Devolución",
                          content: data['estado_devolucion'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Estado de Pago",
                          content: data['estado_pagado'].toString(),
                        ),
                        const SizedBox(height: 20),
                        RichTextTitleContent(
                          title: "Comentario",
                          content: data['comentario'] == null ||
                                  data['comentario'].toString() == "null"
                              ? ""
                              : data['comentario'].toString(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Archivo:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        data['archivo'].toString().isEmpty ||
                                data['archivo'].toString() == "null"
                            ? Container()
                            : Container(
                                width: 300,
                                height: 400,
                                child: Image.network(
                                  "$generalServer${data['archivo'].toString()}",
                                  fit: BoxFit.fill,
                                )),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_notifications,
                                color: ColorsSystem().colorSelectMenu,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "NOVEDADES: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            height: 500,
                            width: 500,
                            child: ListView.builder(
                                itemCount: data['novedades'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Radio de esquina para hacerlo redondeado
                                        border: Border.all(
                                          color: ColorsSystem()
                                              .colorBlack, // Color del borde
                                          width: 2.0, // Ancho del borde
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Comentario Novedad:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.red)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              " ${data['novedades'][index]['comment']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                // color: Colors.red
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Intento:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.red)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${data['novedades'][index]['try']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                // color: Colors.red
                                              ),
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.all(30),
                                              child: Image.network(
                                                "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                })),
                        const SizedBox(height: 20),
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
}
