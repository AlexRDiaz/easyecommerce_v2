import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NoveltiesInfoOnlyNovelties extends StatefulWidget {
  final String id;
  final List data;
  final Function function;

  const NoveltiesInfoOnlyNovelties(
      {super.key,
      required this.id,
      required this.data,
      required this.function});

  @override
  State<NoveltiesInfoOnlyNovelties> createState() =>
      _NoveltiesInfoOnlyNovelties();
}

class _NoveltiesInfoOnlyNovelties extends State<NoveltiesInfoOnlyNovelties> {
  var data = {};
  bool loading = true;
  // OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  final TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  final TextEditingController _comentarioController = TextEditingController();
  var idUser = sharedPrefs!.getString("id");

  String lastStatusBy = "";
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var order = widget.data.firstWhere(
        (item) => item['id'].toString() == widget.id,
        orElse: () => null);

    if (order != null) {
      data = order;
      // print("data> $data");
      _comentarioController.text = safeValue(data['comentario']);
    } else {
      print("Error: No se encontró el pedido con el ID proporcionado.");
    }

    lastStatusBy = data['status_last_modified_by'] != null
        ? "${data['status_last_modified_by']['username'].toString()}-${data['status_last_modified_by']['id'].toString()}"
        : "";

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
    setState(() {});
  }

  String safeValue(dynamic value, [String defaultValue = '']) {
    return (value ?? defaultValue).toString();
  }

  @override
  Widget build(BuildContext context) {
    String transportadoraNombre =
        data['transportadora'] != null && data['transportadora'].isNotEmpty
            ? data['transportadora'][0]['nombre'].toString()
            : data['pedido_carrier'].isNotEmpty
                ? data['pedido_carrier'][0]['carrier']['name'].toString()
                : 'No disponible';
    String operadorUsername = data['operadore'] != null &&
            data['operadore'].isNotEmpty &&
            data['operadore'][0]['up_users'] != null &&
            data['operadore'][0]['up_users'].isNotEmpty
        ? data['operadore'][0]['up_users'][0]['username']
        : 'No disponible';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(),
        centerTitle: true,
        title: const Text(
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
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Código: ${data['users'][0]['vendedores'][0]['nombre_comercial']}-${safeValue(data['numero_orden'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        Visibility(
                          visible: data['pedido_carrier'].isNotEmpty,
                          child: const SizedBox(height: 10),
                        ),
                        Visibility(
                          visible: data['pedido_carrier'].isNotEmpty,
                          child: Text(
                            "  Guía Externa: ${data['pedido_carrier'].isNotEmpty ? data['pedido_carrier'][0]['external_id'].toString() : ""}",
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Transportadora: ${safeValue(transportadoraNombre)}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Envio: ${safeValue(data['marca_tiempo_envio'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Marca Tiempo Entrega: ${data['status_last_modified_at'].toString() != "null" ? UIUtils.formatDate(safeValue(data['status_last_modified_at'].toString())) : ""}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          // "  Modificado Estado Entrega por: ${data['status_last_modified_by'] != null && data['status_last_modified_by'] != null ? "${data['users'][0]['username'].toString()}-${data['status_last_modified_by'].toString()}" : ''}",
                          "  Modificado Estado Entrega por: $lastStatusBy",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                            Text(
                              "  Datos Cliente ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Nombre Cliente: ${safeValue(data['nombre_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Ciudad: ${safeValue(data['ciudad_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Dirección: ${safeValue(data['direccion_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Teléfono Cliente: ${safeValue(data['telefono_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.list,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                            Text(
                              "  Detalle Pedido ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Cantidad: ${safeValue(data['cantidad_total'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto: ${safeValue(data['producto_p'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto Extra: ${safeValue(data['producto_extra'] == null ? "" : data['producto_extra'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Precio Total: \$ ${safeValue(data['precio_total'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Observación: ${safeValue(data['observacion'] == null ? "" : data['observacion'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Comentario: ${safeValue(data['comentario'] == null ? "" : data['comentario'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Status: ${safeValue(data['status'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            "  Comentario Novedad: ${getStateFromJson(data['gestioned_novelty']?.toString(), 'comment')}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18)),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                            Text(
                              "  Datos Adicionales ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Vendedor: ${safeValue(data['tienda_temporal'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Operador: ${safeValue(operadorUsername)}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado Devolución: ${safeValue(data['estado_devolucion'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Entrega: ${safeValue(data['fecha_entrega'].toString())}",
                          style: const TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.folder,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                            Text(
                              "  Archivo ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu),
                            ),
                          ],
                        ),
                        Container(
                          height: 500,
                          width: 500,
                          child: Column(
                            children: [
                              data['archivo'].toString().isEmpty ||
                                      data['archivo'].toString() == "null"
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(top: 20.0),
                                      child: Image.network(
                                        "$generalServer${data['archivo'].toString()}",
                                        fit: BoxFit.fill,
                                      )),
                            ],
                          ),
                        ),
                        // Otros widgets adicionales para cada elemento

                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                            Text(
                              "  Novedades ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
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
                                      color: Color.fromARGB(255, 172, 169, 169),
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
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      // floatingActionButton: data['status'] != "NOVEDAD RESUELTA"
      //     ? FloatingActionButton.extended(
      //         onPressed: _showResolveModal,
      //         label: const Text('Resolver Novedad'),
      //         icon: const Icon(Icons.check_circle),
      //       )
      //     : null,
    );
  }

  // void _showResolveModal() {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Container(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: [
  //                   const Expanded(
  //                     child: Text('Status:',
  //                         style: TextStyle(fontWeight: FontWeight.bold)),
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Expanded(
  //                     flex: 3,
  //                     child: TextFormField(
  //                       controller: _statusController,
  //                       decoration: const InputDecoration(
  //                         border: OutlineInputBorder(),
  //                       ),
  //                       enabled: false,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 20),
  //               Row(
  //                 children: [
  //                   const Expanded(
  //                     child: Text('Comentario:',
  //                         style: TextStyle(fontWeight: FontWeight.bold)),
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Expanded(
  //                     flex: 3,
  //                     child: TextFormField(
  //                       controller: _comentarioController,
  //                       decoration: const InputDecoration(
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   ElevatedButton.icon(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     icon: const Icon(Icons.cancel),
  //                     label: const Text('Cancelar'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.redAccent,
  //                     ),
  //                   ),
  //                   ElevatedButton.icon(
  //                     onPressed: () async {
  //                       if (data['operadore'] != null &&
  //                           data['operadore'].isNotEmpty) {
  //                         // await Connections().editStatusandComment(
  //                         //     data['id'],
  //                         //     _statusController.text,
  //                         //     _comentarioController.text);

  //                         await Connections().updateOrderWithTime(
  //                             data['id'].toString(),
  //                             "status:${_statusController.text}",
  //                             idUser,
  //                             "",
  //                             {"comentario": _comentarioController.text});

  //                         await sendWhatsAppMessage(
  //                             context, data, _comentarioController.text);
  //                       } else {
  //                         //  Navigator.pop(context);
  //                         _showErrorSnackBar(context,
  //                             "El pedido no tiene un Operador Asignado.");
  //                       }

  //                       // await widget.functionpass;

  //                       Navigator.pop(context);
  //                       Navigator.pop(context);

  //                       await widget.function();
  //                     },
  //                     icon: const Icon(Icons.check),
  //                     label: const Text('Guardar'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.green,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

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

  Future<void> sendWhatsAppMessage(BuildContext context,
      Map<dynamic, dynamic> orderData, String newComment) async {
    String? phoneNumber = orderData['operadore']?.isNotEmpty == true
        ? orderData['operadore'][0]['telefono']
        : null;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      var message =
          "Buen Día, la guía con el código ${orderData['name_comercial']}-${orderData['numero_orden']} indica que ' $newComment ' .";
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      _showErrorSnackBar(context, "El pedido no tiene un operador asignado.");
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
}
