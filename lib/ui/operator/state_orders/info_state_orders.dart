import 'package:flutter/material.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';

class InfoStateOrdersOperator extends StatefulWidget {
  final String id;
  final String? comment;
  final Function? function;
  final List? data;
  final Map order;

  const InfoStateOrdersOperator({
    super.key,
    required this.id,
    this.comment,
    this.function,
    this.data,
    required this.order,
  });

  @override
  State<InfoStateOrdersOperator> createState() =>
      _InfoStateOrdersOperatorState();
}

class _InfoStateOrdersOperatorState extends State<InfoStateOrdersOperator> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });
    // var response = await Connections().getOrdersByIDOperator(widget.id);
    // // data = response;
    // data = response;
    setState(() {
      loading = true;
    });
    data = widget.order;
    _controllers.editControllers(data);

    // Future.delayed(Duration(milliseconds: 500), () {
    //   Navigator.pop(context);
    //   setState(() {
    //     loading = false;
    //   });
    // });
    // setState(() {});
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyleText = TextStyle(
        // fontWeight: FontWeight.bold,
        fontSize: 18);
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
            child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                            SizedBox(
                              width: 20,
                            ),
                            data['status'].toString() != "ENTREGADO"
                                ? ElevatedButton(
                                    onPressed: () async {
                                      var response = await Connections()
                                          .getSellersByIdMasterOnly(
                                              "${data['id_comercial'].toString()}");

                                      // print(
                                      //     "cmt> ${data['attributes']['Comentario'].toString()}");
                                      // below need to change to laravel

                                      // ignore: use_build_context_synchronously
                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return UpdateStatusOperatorHistorial(
                                              numberTienda:
                                                  response['vendedores'][0]
                                                          ['Telefono2']
                                                      .toString(),
                                              codigo:
                                                  "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data['numero_orden']}",
                                              numberCliente:
                                                  "${data['telefono_shipping']}",
                                              id: widget.id,
                                              novedades: data['novedades'],
                                              currentStatus:
                                                  data['status'] == "NOVEDAD" ||
                                                          data['status'] ==
                                                              "REAGENDADO"
                                                      ? ""
                                                      : data['status'],
                                              comment: widget.comment!,
                                              dataL: widget.data!,
                                              rolidinvoke: 4,
                                            );
                                          });

                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Estado Entrega",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ))
                                : Container(),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha: ${data['marca_tiempo_envio'].toString().split(" ")[0]}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Entrega: ${data['fecha_entrega'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          // "  Código: ${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden'].toString()}",
                          "  Código: ${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Nombre Cliente: ${_controllers.nombreEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Ciudad: ${_controllers.ciudadEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  DIRECCIÓN: ${_controllers.direccionEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  TELEFÓNO CLIENTE: ${_controllers.telefonoEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Cantidad: ${_controllers.cantidadEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto: ${_controllers.productoEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto Extra: ${_controllers.productoExtraEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Precio Total: ${_controllers.precioTotalEditController.text}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Observación: ${data['observacion'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Comentario: ${data['comentario'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Status: ${data['status'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Tipo Pago: ${data['tipo_pago'] != null ? data['tipo_pago'].toString() : ""}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          " MARCA DE TIEMPO DEVOLUCIÓN: ${data['marca_t_d'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          " MARCA DE TIEMPO DE INGRESO DE PEDIDO: ${data['marca_t_i'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          " ESTADO DE PAGO: ${data['estado_pagado'].toString()}",
                          style: customTextStyleText,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Archivo:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
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
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Novedades:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 117, 115, 115),
                                      border: Border.all(color: Colors.black)),
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            "Intento: ${data['novedades'][index]['m_t_novedad']}"),
                                        Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            "Intento: ${data['novedades'][index]['try']}"),
                                        Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            "Comentario: ${data['novedades'][index]['comment']}"),
                                        data['novedades'][index]['url_image']
                                                    .toString()
                                                    .isEmpty ||
                                                data['novedades'][index]
                                                            ['url_image']
                                                        .toString() ==
                                                    "null"
                                            ? Container()
                                            : Container(
                                                margin: EdgeInsets.all(30),
                                                child: Image.network(
                                                  "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                  fit: BoxFit.fill,
                                                )),
                                      ],
                                    ),
                                  ),
                                ),
                                // Otros widgets adicionales para cada elemento
                              );
                            },
                          ),
                        )
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
