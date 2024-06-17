import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';

import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryStatusSellerInfo2 extends StatefulWidget {
  final Map order;
  final Function(dynamic) function;
  final List data;
  const DeliveryStatusSellerInfo2(
      {super.key,
      required this.order,
      required this.function,
      required this.data});

  @override
  State<DeliveryStatusSellerInfo2> createState() =>
      _DeliveryStatusSellerInfo2State();
}

class _DeliveryStatusSellerInfo2State extends State<DeliveryStatusSellerInfo2> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  final TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  final TextEditingController _comentarioController = TextEditingController();
  var idUser = sharedPrefs!.getString("id");
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    setState(() {
      loading = true;
    });

    data = widget.order;
    _controllers.editControllers2(widget.order);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double whidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Center(
          child: Container(
              margin: EdgeInsets.only(bottom: 20, top: 10),
              child: Text(
                "DETALLES DE GUÍA",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
        ),
        Divider(),

        Container(
          height: height * 0.73,
          padding: EdgeInsets.only(bottom: 40),
          child: loading == true
              ? Container()
              : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección 1
                        _buildSection(
                          'INFORMACIÓN DE PEDIDO',
                          [
                            _buildRow('Fecha Envio',
                                data['marca_tiempo_envio'].toString(), context),
                            _buildRow('Fecha de Entrega',
                                data['fecha_entrega'].toString(), context),
                            _buildRow(
                                'Marca Tiempo de Estado Entrega',
                                data['status_last_modified_at'] != null
                                    ? UIUtils.formatDate(
                                        data['status_last_modified_at']
                                            .toString())
                                    : "",
                                context),
                            _buildRow(
                                "Código",
                                '${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}',
                                context),
                            _buildRow(
                                "Status", data['status'].toString(), context),
                          ],
                        ),
                        Divider(),
                        // Sección 2
                        _buildSection(
                          'DATOS DEL CLIENTE',
                          [
                            _buildRow("Ciudad",
                                data['ciudad_shipping'].toString(), context),
                            _buildRow("Nombre Cliente",
                                data['nombre_shipping'].toString(), context),
                            // _buildRow("Dirección",
                            //     data['direccion_shipping'].toString(), context),
                            // _buildRow("Teléfono Cliente",
                            //     data['telefono_shipping'].toString(), context),
                          ],
                        ),
                        Divider(),
                        // Sección 3
                        _buildSection(
                          'DETALLES DEL PEDIDO',
                          [
                            _buildRow("Cantidad",
                                data['cantidad_total'].toString(), context),
                            _buildRow("Producto", data['producto_p'].toString(),
                                context),
                            _buildRow(
                                "Producto Extra",
                                data['producto_extra'] == null ||
                                        data['producto_extra'] == "null"
                                    ? ""
                                    : data['producto_extra'].toString(),
                                context),
                            _buildRow("Precio Total",
                                data['precio_total'].toString(), context),
                            _buildRow(
                                "Observacion",
                                data['observacion'] == null ||
                                        data['observacion'] == "null"
                                    ? ""
                                    : data['observacion'].toString(),
                                context),
                            _buildRow(
                                "Comentario",
                                data['comentario'] == null ||
                                        data['comentario'] == "null"
                                    ? ""
                                    : data['comentario'].toString(),
                                context),
                            _buildRow(
                                "Comentario Novedades",
                                getStateFromJson(
                                    data['gestioned_novelty']?.toString(),
                                    'comment'),
                                context),
                            _buildRow("Confirmado",
                                data['estado_interno'].toString(), context),
                            _buildRow("Estado Logístico",
                                data['estado_logistico'].toString(), context),
                            _buildRow("Estado Devolución",
                                data['estado_devolucion'].toString(), context),
                            // _buildRow(
                            //     "Costo Entrega",
                            //     data['users'] != null
                            //         ? data['users'][0]['vendedores'][0]
                            //                 ['costo_envio']
                            //             .toString()
                            //         : "",
                            //     context),
                            // _buildRow(
                            //     "Costo Devolución",
                            //     data['estado_devolucion'].toString() !=
                            //             "PENDIENTE"
                            //         ? data['users'] != null
                            //             ? data['users'][0]['vendedores'][0]
                            //                     ['costo_devolucion']
                            //                 .toString()
                            //             : ""
                            //         : "",
                            //     context),
                            _buildRow("Fecha Ingreso",
                                data['marca_t_i'].toString(), context),
                          ],
                        ),
                        Divider(),
                        _buildSection("Archivos", [
                          data['archivo'].toString().isEmpty ||
                                  data['archivo'].toString() == "null"
                              ? Container(
                                  height: 200,
                                  child:
                                      Center(child: Text("No hay archivos ")),
                                )
                              : Container(
                                  width: 300,
                                  height: 200,
                                  child: Image.network(
                                    "$generalServer${data['archivo'].toString()}",
                                    fit: BoxFit.fill,
                                  )),
                        ]),
                        Divider(),
                        _buildSection("Novedades", [
                          data['novedades'].length < 1
                              ? Container(
                                  height: 200,
                                  child:
                                      Center(child: Text("No hay novedades")),
                                )
                              : Container(
                                  height: 400,
                                  child: ListView.builder(
                                    itemCount: data['novedades'].length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          side: BorderSide(color: Colors.black),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // Sección de la imagen a la izquierda
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: PhotoViewGallery
                                                            .builder(
                                                          itemCount: 1,
                                                          builder:
                                                              (context, index) {
                                                            return PhotoViewGalleryPageOptions(
                                                              imageProvider:
                                                                  NetworkImage(
                                                                "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                              ),
                                                              minScale:
                                                                  PhotoViewComputedScale
                                                                      .contained,
                                                              maxScale:
                                                                  PhotoViewComputedScale
                                                                          .covered *
                                                                      2,
                                                              // onTapUp: (context, _, __, ___) {
                                                              //   Navigator.of(context).pop(); }
                                                              // },
                                                            );
                                                          },
                                                          scrollPhysics:
                                                              BouncingScrollPhysics(),
                                                          backgroundDecoration:
                                                              BoxDecoration(
                                                            color: Colors.black,
                                                          ),
                                                          pageController:
                                                              PageController(),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  width:
                                                      100, // Ancho deseado para la imagen
                                                  height:
                                                      100, // Alto deseado para la imagen
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        255, 117, 115, 115),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Separador entre la imagen y la información
                                              const SizedBox(width: 20),
                                              // Sección de la información a la derecha
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Comentario: ${data['novedades'][index]['comment']}",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "Fecha: ${data['novedades'][index]['m_t_novedad']} / Intento: ${data['novedades'][index]['try']}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                        ]),
                      ],
                    ),
                  ),
                ),
        ),
        Divider(),

        // FilledButton.tonal(
        //   onPressed: () {},
        //   child: const Text('Enabled'),
        // ),
      ],
    );
    // );
  }

  void _showResolveModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Status:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                        if (data['operadore'] != null &&
                            data['operadore'].isNotEmpty) {
                          await updateGestionedNovelty(
                              context, data, _comentarioController.text);
                          // await Connections().updateOrderWithTime(
                          //     data['id'].toString(),
                          //     "status:${_statusController.text}",
                          //     idUser,
                          //     "",
                          //     {"comentario": _comentarioController.text});

                          await sendWhatsAppMessage(
                              context, data, _comentarioController.text);
                        } else {
                          _showErrorSnackBar(context,
                              "El pedido no tiene un Operador Asignado.");
                        }

                        Navigator.pop(context);
                        Navigator.pop(context);

                        // await widget.function();
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
        });
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
      // print('Error al decodificar JSON: $e');
      return ''; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
  }

  updateGestionedNovelty(context, data, comment) async {
    // getLoadingModal(context, false);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d/M/yyyy HH:mm:ss').format(now);

    print(formattedDate);

    comment = "$comment UID: ${sharedPrefs!.getString("id")}";

    var resp = await Connections().postGestinodNovelty(
      data['id'],
      comment,
      sharedPrefs!.getString("id"),
      2,
      formattedDate,
    );
  }

  // Métodos auxiliares
  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        ...rows
      ],
    );
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

  Future<void> sendWhatsAppMessageConfirm(BuildContext context,
      Map<dynamic, dynamic> data, String newComment) async {
    var client = data['nombre_shipping'].toString();
    var code = data['users'] != null && data['users'].toString() != "[]"
        ? "${data['users'][0]['vendedores'][0]['nombre_comercial']}-${data['numero_orden']}"
        : "${data['tienda_temporal']}-${data['numero_orden']}";

    var product = data['producto_p'].toString();
    var extraProduct = data['producto_extra'] != null &&
            data['producto_extra'].toString() != 'null' &&
            data['producto_extra'].toString() != ''
        ? ' ${data['producto_extra'].toString()}'
        : '';
    var store = data['users'] != null && data['users'].isNotEmpty
        ? data['users'][0]['vendedores'][0]['nombre_comercial']
        : "NaN";
    var telefono = data['telefono_shipping'].toString();

    // String? phoneNumber = data['operadore']?.isNotEmpty == true
    //     ? data['operadore'][0]['telefono']
    //     : null;

    if (telefono != null && telefono.isNotEmpty) {
      var message =
          messageConfirmedDelivery(client, store, code, product, extraProduct);
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$telefono&text=${Uri.encodeFull(message)}";

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

  Widget _buildRow(String title, dynamic content, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            padding: EdgeInsets.only(left: 30),
            child: Text(title),
          ),
          SizedBox(
            width: 10,
          ),
          content is Widget
              ? Expanded(child: content)
              : Expanded(
                  child: Text(
                    content.toString(),
                  ),
                ),
        ],
      ),
    );
  }

  // ... (resto del código)
}
