import 'package:flutter/material.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/config/colors.dart';
import 'package:intl/intl.dart';

class TransportProDeliveryHistoryDetails extends StatefulWidget {
  final String id;
  final String? comment;
  final Function? function;
  final List? data;
  const TransportProDeliveryHistoryDetails(
      {super.key, required this.id, this.comment, this.function, this.data});

  @override
  State<TransportProDeliveryHistoryDetails> createState() =>
      _TransportProDeliveryHistoryDetails();
}

class _TransportProDeliveryHistoryDetails
    extends State<TransportProDeliveryHistoryDetails> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response =
    //     await Connections().getOrdersByIDHistorialTransport(widget.id);
    var response = await Connections().getOrderByIDHistoryLaravel(widget.id);

    data = response;
    // _controllers.editControllers(response);

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
          decoration: BoxDecoration(
              border: Border.all(color: ColorsSystem().colorBlack, width: 2.0)),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  : Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                data['estado_devolucion'].toString() !=
                                            "PENDIENTE" ||
                                        data['status'].toString() == "ENTREGADO"
                                    ? Container()
                                    : Row(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return SubRoutesModal(
                                                        idOrder: widget.id,
                                                        someOrders: false,
                                                      );
                                                    });

                                                setState(() {});
                                                await loadData();
                                              },
                                              child: const Text(
                                                "Asignar SubRuta",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                var response = await Connections()
                                                    .getSellersByIdMasterOnly(
                                                        "${data['id_comercial'].toString()}");

                                                await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return UpdateStatusOperatorHistorial(
                                                        numberTienda: response[
                                                                    'vendedores']
                                                                [0]['Telefono2']
                                                            .toString(),
                                                        codigo:
                                                            "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data['numero_orden']}",
                                                        numberCliente:
                                                            "${data['telefono_shipping']}",
                                                        id: widget.id,
                                                        novedades:
                                                            data['novedades'],
                                                        currentStatus:
                                                            data['status'],
                                                        dataL: widget.data!,
                                                      );
                                                    });

                                                await loadData();
                                              },
                                              child: Text(
                                                "Estado de Entrega",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ],
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Fecha: ${data['marca_tiempo_envio'].toString().split(" ")[0]}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Fecha Entrega: ${data['fecha_entrega'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Marca Tiempo de Estado Entrega: ${data['status_last_modified_at'] != null ? formatDate(data['status_last_modified_at'].toString()) : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Modificado Estado Entrega por: ${data['status_last_modified_by'] != null && data['status_last_modified_by'].isNotEmpty ? "${data['status_last_modified_by']['username'].toString()}-${data['status_last_modified_by']['id'].toString()}" : ''}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Código: ${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_circle, // Icono de usuario
                                    color: ColorsSystem()
                                        .colorSelectMenu, // Color del ícono
                                    size: 24, // Tamaño del ícono
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Espacio entre el icono y el texto
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
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Nombre Cliente: ${data['nombre_shipping']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Ciudad: ${data['ciudad_shipping']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DIRECCIÓN: ${data['direccion_shipping']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  TELEFÓNO CLIENTE: ${data['telefono_shipping']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .shopping_bag_rounded, // Icono de usuario
                                    color: ColorsSystem()
                                        .colorSelectMenu, // Color del ícono
                                    size: 24, // Tamaño del ícono
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Espacio entre el icono y el texto
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
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Cantidad: ${data['cantidad_total'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Producto: ${data['producto_p']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Producto Extra: ${data['producto_extra']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Precio Total: ${data['precio_total']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Observación: ${data['observacion'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Comentario: ${data['comentario'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Status: ${data['status'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Tipo de Pago: ${data['tipo_pago'] != null ? data['tipo_pago'].toString() : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Sub Ruta: ${data['sub_ruta'].toString() != "[]" ? data['sub_ruta'][0]['titulo'].toString() : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Operador: ${data['operadore'].toString() != "[]" ? data['operadore'][0]['up_users'][0]['username'].toString() : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Estado Pago: ${data['estado_pagado'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Estado Devolución: ${data['estado_devolucion'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DO: ${data['do'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DL: ${data['dl'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Marca Tiempo Devo: ${data['marca_t_d'] != null ? data['marca_t_d'].toString() : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Marca Tiempo Ingreso: ${data['marca_t_i'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Status: ${data['status'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            /**/
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Color.fromARGB(
                                              255, 117, 115, 115),
                                          border:
                                              Border.all(color: Colors.black)),
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
                                            data['novedades'][index]
                                                            ['url_image']
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
                        SizedBox(width: 20), // Espacio entre columnas
                        Column()
                      ],
                      /*
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                data['attributes']['Estado_Devolucion']
                                                .toString() !=
                                            "PENDIENTE" ||
                                        data['attributes']['Status']
                                                .toString() ==
                                            "ENTREGADO"
                                    ? Container()
                                    : Row(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return SubRoutesModal(
                                                        idOrder: widget.id,
                                                        someOrders: false,
                                                      );
                                                    });

                                                setState(() {});
                                                await loadData();
                                              },
                                              child: const Text(
                                                "Asignar SubRuta",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                var response = await Connections()
                                                    .getSellersByIdMasterOnly(
                                                        "${data['attributes']['IdComercial'].toString()}");

                                                await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return UpdateStatusOperatorHistorial(
                                                        numberTienda: response[
                                                                    'vendedores']
                                                                [0]['Telefono2']
                                                            .toString(),
                                                        codigo:
                                                            "${data['attributes']['Name_Comercial']}-${data['attributes']['NumeroOrden']}",
                                                        numberCliente:
                                                            "${data['attributes']['TelefonoShipping']}",
                                                        id: widget.id,
                                                        novedades:
                                                            data['attributes'][
                                                                    'novedades']
                                                                ['data'],
                                                        currentStatus:
                                                            data['attributes']
                                                                ['Status'],
                                                        comment: data['attributes']['Comentario'].toString(),
                                                        function: widget.function!,
                                                        dataL: widget.data!,
                                                        rolidinvoke: 3,
                                                      );
                                                    });
                                                // await loadData();
                                                // await widget.function!();
                                                // await loadData();
                                                Navigator.pop(context);

                                              },
                                              child: Text(
                                                "Estado de Entrega",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ],
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Fecha: ${data['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0]}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Fecha Entrega: ${data['attributes']['Fecha_Entrega'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Código: ${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_circle, // Icono de usuario
                                    color: ColorsSystem()
                                        .colorSelectMenu, // Color del ícono
                                    size: 24, // Tamaño del ícono
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Espacio entre el icono y el texto
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
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Nombre Cliente: ${_controllers.nombreEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Ciudad: ${_controllers.ciudadEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DIRECCIÓN: ${_controllers.direccionEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  TELEFÓNO CLIENTE: ${_controllers.telefonoEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .shopping_bag_rounded, // Icono de usuario
                                    color: ColorsSystem()
                                        .colorSelectMenu, // Color del ícono
                                    size: 24, // Tamaño del ícono
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Espacio entre el icono y el texto
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
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Cantidad: ${_controllers.cantidadEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Producto: ${_controllers.productoEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Producto Extra: ${_controllers.productoExtraEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Precio Total: ${_controllers.precioTotalEditController.text}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Observación: ${data['attributes']['Observacion'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Comentario: ${data['attributes']['Comentario'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Status: ${data['attributes']['Status'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Tipo de Pago: ${data['attributes']['TipoPago'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Sub Ruta: ${data['attributes']['sub_ruta']['data'] != null ? data['attributes']['sub_ruta']['data']['attributes']['Titulo'].toString() : ""}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Operador: ${data['attributes']['operadore']['data'] != null ? data['attributes']['operadore']['data']['attributes']['user']['data']['attributes']['username'] : "".toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Estado Pago: ${data['attributes']['Estado_Pagado'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Estado Devolución: ${data['attributes']['Estado_Devolucion'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DO: ${data['attributes']['DO'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  DL: ${data['attributes']['DL'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Marca Tiempo Devo: ${data['attributes']['Marca_T_D'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  Marca Tiempo Ingreso: ${data['attributes']['Marca_T_I'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Text(
                            //   "  Status: ${data['attributes']['Status'].toString()}",
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold, fontSize: 18),
                            // ),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            Text(
                              "  Archivo:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            data['attributes']['Archivo'].toString().isEmpty ||
                                    data['attributes']['Archivo'].toString() ==
                                        "null"
                                ? Container()
                                : Container(
                                    width: 300,
                                    height: 400,
                                    child: Image.network(
                                      "$generalServer${data['attributes']['Archivo'].toString()}",
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
                                itemCount: data['attributes']['novedades']
                                        ['data']
                                    .length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Color.fromARGB(
                                              255, 117, 115, 115),
                                          border:
                                              Border.all(color: Colors.black)),
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
                                                "Intento: ${data['attributes']['novedades']['data'][index]['attributes']['m_t_novedad']}"),
                                            Text(
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                "Intento: ${data['attributes']['novedades']['data'][index]['attributes']['try']}"),
                                            Text(
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                "Comentario: ${data['attributes']['novedades']['data'][index]['attributes']['comment']}"),
                                            data['attributes']['novedades']
                                                                        ['data']
                                                                    [index]
                                                                ['attributes']
                                                            ['url_image']
                                                        .toString()
                                                        .isEmpty ||
                                                    data['attributes']['novedades']
                                                                            ['data']
                                                                        [index][
                                                                    'attributes']
                                                                ['url_image']
                                                            .toString() ==
                                                        "null"
                                                ? Container()
                                                : Container(
                                                    margin: EdgeInsets.all(30),
                                                    child: Image.network(
                                                      "$generalServer${data['attributes']['novedades']['data'][index]['attributes']['url_image'].toString()}",
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
                        SizedBox(width: 20), // Espacio entre columnas
                        Column()
                      ],
                      */
                    ),
            ),
          ),
        )));
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
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
