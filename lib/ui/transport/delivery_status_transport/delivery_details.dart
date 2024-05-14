import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/rich_text.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes_new.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';
import 'package:frontend/config/colors.dart';

class TransportProDeliveryHistoryDetails extends StatefulWidget {
  final String id;
  final Map order;
  final String? comment;
  final Function? function;
  final List? data;
  const TransportProDeliveryHistoryDetails(
      {super.key,
      required this.id,
      required this.order,
      this.comment,
      this.function,
      this.data});

  @override
  State<TransportProDeliveryHistoryDetails> createState() =>
      _TransportProDeliveryHistoryDetails();
}

class _TransportProDeliveryHistoryDetails
    extends State<TransportProDeliveryHistoryDetails> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  String estadoLogistic = "";
  String status = "";
  String fecha_entrega = "";
  bool btnStatus = true;
  bool btnRuta = true;
  String subRuta = "";
  String operador = "";
  String lastStatusAt = "";
  String lastStatusBy = "";

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      loading = true;
    });

    data = widget.order;
    _controllers.editControllers(widget.order);

    setState(() {
      fecha_entrega = data['fecha_entrega'].toString();
      status = data['status'].toString();
      //
      subRuta = data['sub_ruta'].toString() != "[]"
          ? data['sub_ruta'][0]['titulo'].toString()
          : "";
      operador = data['operadore'].toString() != "[]"
          ? data['operadore'][0]['up_users'][0]['username'].toString()
          : "";
      lastStatusAt = data['status_last_modified_at'] != null
          ? UIUtils.formatDate(data['status_last_modified_at'].toString())
          : "";
      lastStatusBy = data['status_last_modified_by'] != null
          ? "${data['status_last_modified_by']['username'].toString()}-${data['status_last_modified_by']['id'].toString()}"
          : "";
    });

    setState(() {
      loading = false;
    });
  }

  getData() async {
    setState(() {
      loading = true;
    });
    print("entro a getData");
    var response = await Connections().getOrderByIDHistoryLaravel(widget.id);
    _controllers.editControllers(response);
    setState(() {
      fecha_entrega = response['fecha_entrega'].toString();
      status = response['status'].toString();
      // estadoLogistic = response['estado_logistico'].toString();
      subRuta = response['sub_ruta'].toString() != "[]"
          ? response['sub_ruta'][0]['titulo'].toString()
          : "";
      operador = response['operadore'].toString() != "[]"
          ? response['operadore'][0]['up_users'][0]['username'].toString()
          : "";

      lastStatusAt = response['status_last_modified_at'] != null
          ? UIUtils.formatDate(response['status_last_modified_at'].toString())
          : "";
      lastStatusBy = response['status_last_modified_by'] != null
          ? "${response['status_last_modified_by']['username'].toString()}-${response['status_last_modified_by']['id'].toString()}"
          : "";
    });
    if (response['status'].toString() == "ENTREGADO") {
      setState(() {
        btnStatus = false;
        btnRuta = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyleText = TextStyle(
        // fontWeight: FontWeight.bold,
        fontSize: 18);

    return CustomProgressModal(
      isLoading: loading,
      content: Scaffold(
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 1, 20, 10),
              child: SingleChildScrollView(
                child: loading == true
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (data['estado_devolucion'].toString() !=
                                              "PENDIENTE" ||
                                          data['status'].toString() ==
                                              "ENTREGADO" || data['status'].toString() ==
                                              "NO ENTREGADO"  ) ||
                                      btnRuta == false
                                  ? Container()
                                  : Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    // return SubRoutesModal(
                                                    //   idOrder: widget.id,
                                                    //   someOrders: false,
                                                    // );
                                                    return SubRoutesModalNew(
                                                      idOrder: widget.id,
                                                      someOrders: false,
                                                    );
                                                  });

                                              setState(() {});
                                              await getData();
                                            },
                                            child: const Text(
                                              "Asignar SubRuta",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        data['status']!="NO ENTREGADO" ?
                                        ElevatedButton(
                                            onPressed: operador != "" &&
                                                    btnStatus == true
                                                ? () async {
                                                    // var response =
                                                    //     await Connections()
                                                    //         .getSellersByIdMasterOnly(
                                                    //             "${data['id_comercial'].toString()}");

                                                    await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return UpdateStatusOperatorHistorial(
                                                            function:
                                                                widget.function,
                                                            // numberTienda:
                                                            //     response['vendedores'][0]['Telefono2']
                                                            //         .toString(),
                                                            numberTienda: data['users']
                                                                            [0][
                                                                        'vendedores'][0]
                                                                    [
                                                                    'telefono_2']
                                                                .toString(),
                                                            codigo:
                                                                "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${data['numero_orden']}",
                                                            numberCliente:
                                                                "${data['telefono_shipping']}",
                                                            id: widget.id,
                                                            novedades: data[
                                                                'novedades'],
                                                            currentStatus: data[
                                                                            'status'] ==
                                                                        "NOVEDAD" ||
                                                                    data['status'] ==
                                                                        "REAGENDADO"
                                                                ? ""
                                                                : data[
                                                                    'status'],
                                                            dataL: widget.data!,
                                                          );
                                                        });

                                                    setState(() {});
                                                    await getData();
                                                  }
                                                : null,
                                            child: Text(
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? "Estado de Entrega"
                                                  : "Estado Entrega",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))
                                        : Container()
                                      ],
                                    ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Fecha Envio",
                            content: data['marca_tiempo_envio']
                                .toString()
                                .split(" ")[0],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Fecha Entrega",
                            content: fecha_entrega,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Marca Tiempo de Estado Entrega",
                            content: lastStatusAt,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Modificado Estado Entrega por",
                            content: lastStatusBy,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Código",
                            content:
                                "${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}",
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
                            content: data['nombre_shipping'],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Ciudad",
                            content: data['ciudad_shipping'],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Dirección",
                            content: data['direccion_shipping'],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Telefóno cliente",
                            content: data['telefono_shipping'],
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
                          const SizedBox(height: 20),
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
                            content:
                                "${data['producto_extra'] == null || data['producto_extra'].toString() == "null" ? "" : data['producto_extra']}",
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Precio Total",
                            content: data['precio_total'],
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Observación",
                            content: data['observacion'] == null ||
                                    data['observacion'].toString() == "null"
                                ? ""
                                : data['observacion'].toString(),
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
                          RichTextTitleContent(
                            title: "Status",
                            content: status,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Com. Novedades",
                            content: getStateFromJson(
                                data['gestioned_novelty']?.toString(),
                                'comment'),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Tipo de Pago",
                            content: data['tipo_pago'] != null
                                ? data['tipo_pago'].toString()
                                : "",
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Sub Ruta",
                            content: subRuta,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Operador",
                            content: operador,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Estado Pago",
                            content: data['estado_pagado'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Estado Devolución",
                            content: data['estado_devolucion'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "DO",
                            content: data['do'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "DL",
                            content: data['dl'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Marca Tiempo Dev.",
                            content: data['marca_t_d'] != null
                                ? data['marca_t_d'].toString()
                                : "",
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Marca Tiempo Ingreso",
                            content: data['marca_t_i'].toString(),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          /**/
                          const Text(
                            "Archivo:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
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
                          const Text(
                            "Novedades:",
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
                                        color:
                                            Color.fromARGB(255, 117, 115, 115),
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
          ),
        ),
      ),
    );
  }

  String getStateFromJson(String? jsonString, String claveAbuscar) {
    // Verificar si jsonString es null
    if (jsonString == null || jsonString.isEmpty) {
      return ''; // Retorna una cadena vacía si el valor es null o está vacío
    }

    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap[claveAbuscar]?.toString() ?? '';
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return ''; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
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
