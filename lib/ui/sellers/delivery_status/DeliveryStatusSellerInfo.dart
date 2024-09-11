import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';

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

  List<String> solucionesToSelect = [
    "Volver a Ofrecer",
    "Efectuar devolución",
    "Ajustar Recaudo"
  ];
  String? solucionSelected;

  List<dynamic> razones = [];
  bool gestLastNov = false;
  String? dateLastNov;
  String? dateSentOrder;
  final TextEditingController _novObservacionController =
      TextEditingController();
  final TextEditingController _novNewRecaudoController =
      TextEditingController();

  List<DateTime?> _dates = [];
  TextEditingController _dateController = TextEditingController(text: "");
  String estadoEntrega = "";
  String precio = "";

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
    estadoEntrega = data['status'].toString();
    precio = data['precio_total'].toString();

    dateSentOrder = data['sent_at'];

    DateTime currentDate = DateTime.now();
    DateTime adjustedCurrentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    DateTime dtDateSent = DateTime.parse(dateSentOrder!);

    int diffinDaysCurrentSent =
        dtDateSent.difference(adjustedCurrentDate).inDays;
    print("envio-hoy: $diffinDaysCurrentSent");

    if (data['novedades'].length >= 1) {
      List<dynamic> novedades = data['novedades'];

      if (novedades.isNotEmpty) {
        Map<String, dynamic> ultimaNovedad = novedades.last;
        if (ultimaNovedad['external_id'] != null) {
          razones =
              jsonDecode(data['pedido_carrier'][0]['carrier']['novedades']);

          int externalId = ultimaNovedad['external_id'];
          dateLastNov = ultimaNovedad['m_t_novedad'];
          print("dateLastNov: $dateLastNov");
          print("externalId: $externalId");

          Map<String, dynamic>? razonEncontrada = razones.firstWhere(
            (razon) => razon['id'] == externalId,
            orElse: () => null,
          );

          if (razonEncontrada != null) {
            print("Tipo de la razón encontrada: ${razonEncontrada['tipo']}");
            if (razonEncontrada['tipo'] == 1) {
              gestLastNov = true;
            }
          } else {
            print("No se encontró una razón con el external_id dado.");
          }
        }
      } else {
        print("No hay novedades disponibles.");
      }
    }

    setState(() {
      loading = false;
    });
  }

  updateData() async {
    var response = await Connections().getOrdersByIdLaravel(widget.order['id']);
    var dataRes = response;
    print(dataRes['gestioned_novelty']);
    setState(() {
      estadoEntrega = dataRes['status'].toString();
      precio = dataRes['precio_total'].toString();
    });

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
                            Visibility(
                              visible: data['pedido_carrier'].isNotEmpty,
                              child: _buildRow(
                                  "Guía Externa",
                                  data['pedido_carrier'].isNotEmpty
                                      ? data['pedido_carrier'][0]['external_id']
                                          .toString()
                                      : "",
                                  context),
                            ),
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
                            _buildRow("Dirección",
                                data['direccion_shipping'].toString(), context),
                            _buildRow("Teléfono Cliente",
                                data['telefono_shipping'].toString(), context),
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
                            _buildRow("Precio Total", precio, context),
                            _buildRow(
                                "Comentario",
                                data['comentario'] == null ||
                                        data['comentario'] == "null"
                                    ? ""
                                    : data['comentario'].toString(),
                                context),
                            _buildRow("Status", estadoEntrega, context),
                            _buildRow("Confirmado",
                                data['estado_interno'].toString(), context),
                            _buildRow("Estado Logístico",
                                data['estado_logistico'].toString(), context),
                            _buildRow("Estado Devolución",
                                data['estado_devolucion'].toString(), context),
                            _buildRow(
                                "Costo Entrega",
                                data['users'] != null
                                    ? data['users'][0]['vendedores'][0]
                                            ['costo_envio']
                                        .toString()
                                    : "",
                                context),
                            _buildRow(
                                "Costo Devolución",
                                data['estado_devolucion'].toString() !=
                                        "PENDIENTE"
                                    ? data['users'] != null
                                        ? data['users'][0]['vendedores'][0]
                                                ['costo_devolucion']
                                            .toString()
                                        : ""
                                    : "",
                                context),
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
                                                  if (data[
                                                              'pedido_carrier']
                                                          .isNotEmpty &&
                                                      data['novedades'][index]
                                                                  ['url_image']
                                                              .toString() !=
                                                          "null" &&
                                                      data['novedades'][index]
                                                                  ['url_image']
                                                              .toString() !=
                                                          "") {
                                                    launchUrl(Uri.parse(
                                                      "$serverGTMimg${data['novedades'][index]['url_image'].toString()}",
                                                    ));
                                                    //
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          child:
                                                              PhotoViewGallery
                                                                  .builder(
                                                            itemCount: 1,
                                                            builder: (context,
                                                                index) {
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
                                                                const BouncingScrollPhysics(),
                                                            backgroundDecoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            pageController:
                                                                PageController(),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.blueGrey[50],
                                                    image:
                                                        data['pedido_carrier']
                                                                .isNotEmpty
                                                            ? null
                                                            : DecorationImage(
                                                                image:
                                                                    NetworkImage(
                                                                  "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                  ),
                                                  child: data['pedido_carrier']
                                                              .isNotEmpty &&
                                                          data['novedades'][
                                                                          index]
                                                                      [
                                                                      'url_image']
                                                                  .toString() !=
                                                              "null" &&
                                                          data['novedades'][
                                                                          index]
                                                                      [
                                                                      'url_image']
                                                                  .toString() !=
                                                              ""
                                                      ? Center(
                                                          child: Text(
                                                            "Ver Foto",
                                                            style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: ColorsSystem()
                                                                  .colorVioletDateText,
                                                            ),
                                                          ),
                                                        )
                                                      : null,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            data['status'] != "NOVEDAD RESUELTA" &&
                    data['status'] != "NO ENTREGADO" &&
                    data['estado_devolucion'] == "PENDIENTE" &&
                    data['status'] != "ENTREGADO" &&
                    data['pedido_carrier'].isEmpty
                ? Container(
                    width: whidth * 0.15,
                    child: FilledButton.tonalIcon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              // Color cuando el botón está presionado
                              return Color.fromARGB(255, 235, 251, 64);
                            }
                            // Color cuando el botón está en su estado normal
                            return Color.fromARGB(255, 209, 184, 146);
                          },
                        ),
                        // Otros estilos pueden ir aquí
                      ),
                      //  backgroundColor: Color.fromARGB(255, 196, 134, 207),
                      onPressed: _showResolveModal,
                      label: const Text(
                        'RESOLVER NOVEDAD',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle),
                    ),
                  )
                : Container(),
            SizedBox(
              width: 10,
            ),
            data['status'] == 'NOVEDAD' &&
                    data['estado_devolucion'] == 'PENDIENTE' &&
                    data['pedido_carrier'].isEmpty
                ? Container(
                    width: whidth * 0.15,
                    child: FilledButton.tonalIcon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              // Color cuando el botón está presionado
                              return Colors.purpleAccent;
                            }
                            // Color cuando el botón está en su estado normal
                            return Color.fromARGB(255, 197, 165, 202);
                          },
                        ),
                        // Otros estilos pueden ir aquí
                      ),
                      onPressed: () async {
                        widget.function(
                            {'id': data['id'], 'status': 'REAGENDADO'});
                      },
                      label: const Text(
                        'REAGENDAR',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: Icon(Icons.watch_later),
                    ),
                  )
                : Container(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // idUser == "2" &&
            data['pedido_carrier'].isNotEmpty &&
                    data['status'] != "NOVEDAD RESUELTA" &&
                    data['status'] != "NO ENTREGADO" &&
                    data['estado_devolucion'] == "PENDIENTE" &&
                    data['status'] != "ENTREGADO" &&
                    gestLastNov
                ? Container(
                    width: whidth * 0.15,
                    child: FilledButton.tonalIcon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color.fromARGB(255, 235, 251, 64);
                            }
                            return const Color.fromARGB(255, 209, 184, 146);
                          },
                        ),
                      ),
                      onPressed: _showResolveExternalModal,
                      label: const Text(
                        'GESTIONAR NOVEDAD',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle),
                    ),
                  )
                : Container(),
          ],
        ),
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

  void _showResolveExternalModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Solución: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          width: 250,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(
                                'Seleccione una Solución',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              items: solucionesToSelect.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                  ),
                                );
                              }).toList(),
                              value: solucionSelected,
                              onChanged: (String? value) {
                                setModalState(() {
                                  solucionSelected = value;
                                });
                                setState(() {
                                  solucionSelected = value;
                                });
                                // print(solucionSelected);
                              },
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                height: 40,
                                width: 140,
                              ),
                              dropdownStyleData: const DropdownStyleData(
                                maxHeight: 150,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              iconStyleData: const IconStyleData(
                                openMenuIcon: Icon(Icons.arrow_drop_up),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: solucionSelected == "Volver a Ofrecer" ||
                        solucionSelected == "Ajustar Recaudo",
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Fecha entrega:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () async {
                                  _dateController.text =
                                      await OpenCalendarExternal(
                                          dateLastNov.toString(),
                                          dateSentOrder.toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: solucionSelected == "Volver a Ofrecer",
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Observacion:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _novObservacionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: solucionSelected == "Ajustar Recaudo",
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Recaudo:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _novNewRecaudoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}$')),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          //
                          bool readyAdd = true;
                          if (solucionSelected == null) {
                            readyAdd = false;
                            showSuccessModal(context,
                                "Seleccione una solución.", Icons8.warning_1);
                          }
                          if (solucionSelected == "Volver a Ofrecer" &&
                              (_dateController.text.isEmpty ||
                                  _novObservacionController.text.isEmpty)) {
                            readyAdd = false;
                            showSuccessModal(
                                context,
                                "Seleccione una fecha y agregue una observación.",
                                Icons8.warning_1);
                          } else if (solucionSelected == "Ajustar Recaudo" &&
                              (_novNewRecaudoController.text.isEmpty ||
                                  _dateController.text.isEmpty ||
                                  (double.tryParse(
                                              _novNewRecaudoController.text) ??
                                          0) <
                                      8)) {
                            readyAdd = false;
                            showSuccessModal(
                                context,
                                "Seleccione una fecha e Ingrese un nuevo recaudo válido. El valor no puede ser menor a \$8.",
                                Icons8.warning_1);
                          }

                          String idGuideExternal = data['pedido_carrier'][0]
                                  ['external_id']
                              .toString();

                          var dataSolucion;

                          if (readyAdd) {
                            getLoadingModal(context, false);

                            DateTime now = DateTime.now();
                            String formattedDate =
                                DateFormat('d/M/yyyy HH:mm:ss').format(now);

                            if (solucionSelected == "Volver a Ofrecer") {
                              //
                              // Parsear la fecha desde el formato original
                              DateFormat originalFormat =
                                  DateFormat('d/M/yyyy');
                              DateTime dateTime =
                                  originalFormat.parse(_dateController.text);

                              // Formatear la fecha al nuevo formato
                              DateFormat newFormat = DateFormat('yyyy-MM-dd');
                              String newDateStr = newFormat.format(dateTime);

                              dataSolucion = {
                                "guia": idGuideExternal,
                                "observacion": _novObservacionController.text,
                                "solucion": "Volver a Ofrecer",
                                "fecha_entrega": newDateStr,
                                "recaudo": "",
                              };
                            } else if (solucionSelected ==
                                "Efectuar devolución") {
                              //
                              dataSolucion = {
                                "guia": idGuideExternal,
                                "observacion": _novObservacionController.text,
                                "solucion": "Efectuar devolución",
                                "fecha_entrega": "",
                                "recaudo": "",
                              };
                            } else if (solucionSelected == "Ajustar Recaudo") {
                              //
                              // Parsear la fecha desde el formato original
                              DateFormat originalFormat =
                                  DateFormat('d/M/yyyy');
                              DateTime dateTime =
                                  originalFormat.parse(_dateController.text);

                              // Formatear la fecha al nuevo formato
                              DateFormat newFormat = DateFormat('yyyy-MM-dd');
                              String newDateStr = newFormat.format(dateTime);

                              dataSolucion = {
                                "guia": idGuideExternal,
                                "observacion": _novObservacionController.text,
                                "solucion": "Ajustar Recaudo",
                                "fecha_entrega": newDateStr,
                                "recaudo": _novNewRecaudoController.text,
                              };
                            }
                            print(dataSolucion);

                            // /*
                            var resSolucionGTM = await Connections()
                                .postSolucionGintra(dataSolucion);

                            if (resSolucionGTM != []) {
                              bool statusError = resSolucionGTM['error'];
                              String mess = "";

                              if (statusError) {
                                mess = resSolucionGTM['message'];

                                Navigator.pop(context);

                                // ignore: use_build_context_synchronously
                                AwesomeDialog(
                                  width: 500,
                                  context: context,
                                  dialogType: DialogType.info,
                                  animType: AnimType.rightSlide,
                                  title: "Error en envio de Solucion.",
                                  desc: mess,
                                  btnCancel: Container(),
                                  btnOkText: "Aceptar",
                                  btnOkColor: Colors.green,
                                  btnOkOnPress: () async {},
                                  btnCancelOnPress: () async {},
                                ).show();
                              } else {
                                // */
                                if (solucionSelected == "Volver a Ofrecer") {
                                  var resp =
                                      await Connections().postGestinodNovelty(
                                    data['id'],
                                    "$solucionSelected ${_novObservacionController.text} ${_novNewRecaudoController.text}",
                                    idUser,
                                    2,
                                    formattedDate,
                                  );
                                } else {
                                  var resp =
                                      await Connections().postGestinodNovelty(
                                    data['id'],
                                    "$solucionSelected ${_novObservacionController.text} ${_novNewRecaudoController.text}",
                                    idUser,
                                    1,
                                    formattedDate,
                                  );
                                }
                                if (solucionSelected == "Ajustar Recaudo") {
                                  var response = await Connections()
                                      .updatenueva(data['id'], {
                                    "precio_total":
                                        _novNewRecaudoController.text,
                                  });
                                }

                                //mess para operador
                                // await sendWhatsAppMessage(context, data,
                                //     _novObservacionController.text);

                                await updateData();

                                Navigator.pop(context);
                                Navigator.pop(context);
                                // /*
                              }
                            } else {
                              Navigator.pop(context);

                              // ignore: use_build_context_synchronously
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                title: "Error en envio de Solucion.",
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: Colors.green,
                                btnOkOnPress: () async {},
                                btnCancelOnPress: () async {},
                              ).show();
                            }
                            // */
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
          },
        );
      },
    );
  }

  Future<String> OpenCalendarExternal(
      String dateLastNov, String dateSent) async {
    // print("dateLastNov: $dateLastNov");
    // print("dateSent: $dateSent");
    String nuevaFecha = "";

    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    DateTime referenceDateNov = dateFormat.parse(dateLastNov);
    DateTime referenceDateSent = DateTime.parse(dateSent);
    DateTime currentDate = DateTime.now();

    DateTime adjustedDateNov = DateTime(
        referenceDateNov.year, referenceDateNov.month, referenceDateNov.day);
    DateTime adjustedDateSent = DateTime(
        referenceDateSent.year, referenceDateSent.month, referenceDateSent.day);
    DateTime adjustedCurrentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedYearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        selectableDayPredicate: (DateTime date) {
          int differenceInDaysFromLastNov =
              date.difference(adjustedDateNov).inDays;
          int differenceInDaysFromSent =
              date.difference(adjustedDateSent).inDays;
          int differenceInDaysFromCurrent =
              date.difference(adjustedCurrentDate).inDays;

          return date.weekday != 7 &&
              differenceInDaysFromLastNov != 0 &&
              differenceInDaysFromLastNov > 0 && // No antes de la novedad
              differenceInDaysFromSent > 0 &&
              differenceInDaysFromSent <= 9;
          //&& differenceInDaysFromCurrent >= 0; // No antes de la fecha actual
        },
      ),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );

    setState(() {
      if (results != null) {
        String fechaOriginal = results![0]
            .toString()
            .split(" ")[0]
            .split('-')
            .reversed
            .join('-')
            .replaceAll("-", "/");
        List<String> componentes = fechaOriginal.split('/');

        String dia = int.parse(componentes[0]).toString();
        String mes = int.parse(componentes[1]).toString();
        String anio = componentes[2];

        nuevaFecha = "$dia/$mes/$anio";
      }
    });
    return nuevaFecha;
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
