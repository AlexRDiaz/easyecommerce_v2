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
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';

import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryStatusSellerInfo2 extends StatefulWidget {
  final Map order;
  final Function(dynamic) function;
  final Function(dynamic)? functionBack;
  final List data;
  final bool isMobile;

  const DeliveryStatusSellerInfo2({
    super.key,
    required this.order,
    required this.function,
    required this.data,
    this.isMobile = false,
    this.functionBack,
  });

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

  int idCarrierExternal = 0;
  final TextEditingController _callePrinController = TextEditingController();
  final TextEditingController _calleSecunController = TextEditingController();
  final TextEditingController _numeracionController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  String direccion = "";
  String lastNovComment = "";

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
    direccion = data['direccion_shipping'].toString();
    _callePrinController.text = direccion;
    _celularController.text = data['telefono_shipping'].toString();
    dateSentOrder = data['sent_at'];

    DateTime currentDate = DateTime.now();
    DateTime adjustedCurrentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    DateTime dtDateSent = DateTime.parse(dateSentOrder!);

    int diffinDaysCurrentSent =
        dtDateSent.difference(adjustedCurrentDate).inDays;
    print("diferencia_envio-hoy: $diffinDaysCurrentSent");

    if (data['pedido_carrier'].isNotEmpty) {
      // print(data['pedido_carrier']);
      idCarrierExternal =
          int.parse(data['pedido_carrier'][0]['carrier_id'].toString());
    }
    if (data['novedades'].length >= 1) {
      List<dynamic> novedades = data['novedades'];

      if (novedades.isNotEmpty) {
        Map<String, dynamic> ultimaNovedad = novedades.last;
        if (ultimaNovedad['external_id'] != null) {
          razones =
              jsonDecode(data['pedido_carrier'][0]['carrier']['novedades']);

          int externalId = ultimaNovedad['external_id'];
          dateLastNov = ultimaNovedad['m_t_novedad'];
          lastNovComment = ultimaNovedad['comment'];
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
              if (idCarrierExternal == 5) {
                // dateLastNov = "15/11/2024 15:07";

                DateTime now = DateTime.now();
                // Convertir `dateLastNov` a DateTime
                DateTime dateLastNovForm = DateTime.parse(
                    "${dateLastNov.toString().split(' ')[0].split('/').reversed.join('-')}T${dateLastNov.toString().split(' ')[1]}:00");

                Duration difference = now.difference(dateLastNovForm);
                bool isMoreThanThreeDays = difference.inDays > 3;

                if (isMoreThanThreeDays) {
                  gestLastNov = false;
                }
              }
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
      direccion = dataRes['direccion_shipping'].toString();
      _celularController.text = dataRes['telefono_shipping'].toString();
    });

    setState(() {
      loading = false;
    });
  }

  @override
  // Widget build(BuildContext context) {
  Widget build(BuildContext context) {
    // return CustomProgressModal(
    //   isLoading: loading,
    //   content: Scaffold(
    //     body: Container(
    //         width: double.infinity,
    //         height: double.infinity,
    //         child: responsive(
    //             webMainContainer(context), webMainContainer(context), context)),
    //   ),
    // );

    return CustomProgressModal(
      isLoading: loading,
      content: Scaffold(
        body: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Bordes redondeados
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: responsive(
              webMainContainer(context),
              mobileMainContainer(context),
              context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStylesSystem()
            .montserratStyle(14, FontWeight.w500, ColorsSystem().colorLabels),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: ColorsSystem().colorLabels,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Stack mobileMainContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Container(
            height: 140,
            color: ColorsSystem().colorInitialContainer,
          ),
        ],
      ),
      Positioned(
        top: 8,
        left: 20,
        right: 20,
        bottom: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalles de Guía",
              style: TextStylesSystem()
                  .ralewayStyle(12, FontWeight.bold, ColorsSystem().colorStore),
            ),
            Row(
              children: [
                data['status'] != "NOVEDAD RESUELTA" &&
                        data['status'] != "NO ENTREGADO" &&
                        data['estado_devolucion'] == "PENDIENTE" &&
                        data['status'] != "ENTREGADO" &&
                        data['pedido_carrier'].isEmpty
                    ? Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: FilledButton.tonalIcon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return ColorsSystem().colorSelected;
                                }
                                return ColorsSystem().colorStore;
                              },
                            ),
                          ),
                          onPressed: () {
                            _showResolveModal(true);
                          },
                          label: Text(
                            'RESOLVER NOVEDAD',
                            style: TextStylesSystem().montserratStyle(
                                10, FontWeight.w500, Colors.white),
                          ),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 5,
                ),
                data['status'] == 'NOVEDAD' &&
                        data['estado_devolucion'] == 'PENDIENTE' &&
                        data['pedido_carrier'].isEmpty
                    ? Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: FilledButton.tonalIcon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.grey;
                                }
                                return ColorsSystem().colorLabels;
                              },
                            ),
                          ),
                          onPressed: () async {
                            widget.function(
                                {'id': data['id'], 'status': 'REAGENDADO'});
                          },
                          label: Text(
                            'REAGENDAR',
                            style: TextStylesSystem().montserratStyle(
                                10, FontWeight.w500, Colors.white),
                          ),
                          icon: Icon(Icons.watch_later,
                              color: Colors.white, size: 14),
                        ),
                      )
                    : Container(),
                data['pedido_carrier'].isNotEmpty &&
                        data['status'] != "NOVEDAD RESUELTA" &&
                        data['status'] != "NO ENTREGADO" &&
                        data['estado_devolucion'] == "PENDIENTE" &&
                        data['status'] != "ENTREGADO" &&
                        gestLastNov
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: FilledButton.tonalIcon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return ColorsSystem().colorSelected;
                                }
                                return ColorsSystem().colorStore;
                              },
                            ),
                          ),
                          onPressed: idCarrierExternal == 1
                              ? _showResolveExternalModal
                              : idCarrierExternal == 5
                                  ? _showResolveExternalModalLaar
                                  : null,
                          label: Text(
                            'GESTIONAR NOVEDAD',
                            style: TextStylesSystem().montserratStyle(
                                12, FontWeight.w500, Colors.white),
                          ),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Código: ${data['users'][0]['vendedores'][0]['nombre_comercial']}-${data['numero_orden']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.bold, ColorsSystem().colorSelected),
                          ),
                          const SizedBox(height: 8),
                          Text("Fecha de Ingreso: ${data['marca_t_i']}",
                              style: TextStylesSystem().montserratStyle(12,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                          const SizedBox(height: 8),
                          Text(
                              "Fecha de Envío: ${UIUtils.formatDate(data['sent_at'])}",
                              style: TextStylesSystem().montserratStyle(12,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                          const SizedBox(height: 8),
                          Text("Fecha de Entrega: ${data['fecha_entrega']}",
                              style: TextStylesSystem().montserratStyle(12,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                          const SizedBox(height: 8),
                          Text(
                            "Datos del Cliente",
                            style: TextStylesSystem().ralewayStyle(
                                12, FontWeight.w600, ColorsSystem().colorStore),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Nombre: ${data['nombre_shipping']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ciudad: ${data['ciudad_shipping']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Dirección: ${data['direccion_shipping']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Teléfono: ${data['telefono_shipping']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['producto_p'], // Nombre del producto
                                    style: TextStylesSystem().montserratStyle(
                                        14,
                                        FontWeight.bold,
                                        ColorsSystem().colorStore),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Precio:",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                      Text("\$${data['precio_total']}",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Cantidad:",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                      Text("${data['cantidad_total']}",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total:",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                      Text("\$${data['precio_total']}",
                                          style: TextStylesSystem()
                                              .montserratStyle(
                                                  12,
                                                  FontWeight.w500,
                                                  ColorsSystem().colorStore)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estatus Orden",
                            style: TextStylesSystem().ralewayStyle(
                                12, FontWeight.bold, ColorsSystem().colorStore),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Status: $estadoEntrega",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estado Interno: ${data['estado_interno']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estado Logístico: ${data['estado_logistico']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estado Devolución: ${data['estado_devolucion']}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Detalle Adicional",
                            style: TextStylesSystem().montserratStyle(
                                12, FontWeight.bold, ColorsSystem().colorStore),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Producto Extra: ${data['producto_extra'] ?? ''}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Costo Entrega: ${data['users']?[0]['vendedores']?[0]['costo_envio'] ?? ''}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Costo Devolución: ${data['estado_devolucion'].toString() != "PENDIENTE" ? data['users'] != null ? data['users'][0]['vendedores'][0]['costo_devolucion'].toString() : "" : ""}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Comentario: ${data['comentario'] ?? ''}",
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w400, ColorsSystem().colorLabels),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 8),
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
                                    height: 900,
                                    child: ListView.builder(
                                      itemCount: data['novedades'].length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                                color:
                                                    ColorsSystem().colorLabels),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (data['pedido_carrier']
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
                                                                  "") {
                                                            if (idCarrierExternal ==
                                                                1) {
                                                              // print("Case GTM");

                                                              launchUrl(
                                                                  Uri.parse(
                                                                "$serverGTMimg${data['novedades'][index]['url_image'].toString()}",
                                                              ));
                                                            } else if (idCarrierExternal ==
                                                                5) {
                                                              // print("CaseLaar");

                                                              launchUrl(
                                                                  Uri.parse(
                                                                "$serverLaarTracking${data['pedido_carrier'][0]['external_id'].toString()}",
                                                              ));
                                                            }

                                                            //
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  child: PhotoViewGallery
                                                                      .builder(
                                                                    itemCount:
                                                                        1,
                                                                    builder:
                                                                        (context,
                                                                            index) {
                                                                      return PhotoViewGalleryPageOptions(
                                                                        imageProvider:
                                                                            NetworkImage(
                                                                          "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                                        ),
                                                                        minScale:
                                                                            PhotoViewComputedScale.contained,
                                                                        maxScale:
                                                                            PhotoViewComputedScale.covered *
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
                                                                      color: Colors
                                                                          .black,
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
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .blueGrey[50],
                                                            image: data['pedido_carrier']
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
                                                          child: data[
                                                                          'pedido_carrier']
                                                                      .isNotEmpty &&
                                                                  data['novedades'][index]
                                                                              [
                                                                              'url_image']
                                                                          .toString() !=
                                                                      "null" &&
                                                                  data['novedades'][index]
                                                                              [
                                                                              'url_image']
                                                                          .toString() !=
                                                                      ""
                                                              ? Center(
                                                                  child: Text(
                                                                    "Ver Foto",
                                                                    style:
                                                                        TextStyle(
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
                                                      const SizedBox(width: 20),
                                                    ],
                                                  ),
                                                  Text(
                                                    "Comentario: ${data['novedades'][index]['comment']}",
                                                    style: TextStylesSystem()
                                                        .montserratStyle(
                                                            12,
                                                            FontWeight.bold,
                                                            ColorsSystem()
                                                                .colorStore),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Fecha: ${data['novedades'][index]['m_t_novedad']} / Intento: ${data['novedades'][index]['try']}",
                                                    style: TextStylesSystem()
                                                        .montserratStyle(
                                                            12,
                                                            FontWeight.w400,
                                                            ColorsSystem()
                                                                .colorLabels),
                                                    maxLines: null,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    softWrap: true,
                                                  ),
                                                ],
                                              )),
                                        );
                                      },
                                    )),
                          ]),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  Stack webMainContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Container(
            height: 230,
            color: ColorsSystem()
                .colorInitialContainer, // Cambia a tu color deseado
          ),
        ],
      ),
      Positioned(
        top: 20,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height * 0.95,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Detalles de Guía",
                    style: TextStylesSystem().ralewayStyle(
                        18, FontWeight.bold, ColorsSystem().colorStore),
                  ),
                  // ! --------
                  const SizedBox(
                    width: 10,
                  ),
                  data['status'] != "NOVEDAD RESUELTA" &&
                          data['status'] != "NO ENTREGADO" &&
                          data['estado_devolucion'] == "PENDIENTE" &&
                          data['status'] != "ENTREGADO" &&
                          data['pedido_carrier'].isEmpty
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: FilledButton.tonalIcon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    // Color cuando el botón está presionado
                                    return ColorsSystem().colorSelected;
                                  }
                                  // Color cuando el botón está en su estado normal
                                  return ColorsSystem().colorStore;
                                },
                              ),
                              // Otros estilos pueden ir aquí
                            ),
                            //  backgroundColor: Color.fromARGB(255, 196, 134, 207),
                            onPressed: () {
                              _showResolveModal(false);
                            },
                            label: Text(
                              'RESOLVER NOVEDAD',
                              style: TextStylesSystem().montserratStyle(
                                  16, FontWeight.w500, Colors.white),
                            ),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
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
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: FilledButton.tonalIcon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    // Color cuando el botón está presionado
                                    return Colors.grey;
                                  }
                                  // Color cuando el botón está en su estado normal
                                  return ColorsSystem().colorLabels;
                                },
                              ),
                              // Otros estilos pueden ir aquí
                            ),
                            onPressed: () async {
                              widget.function(
                                  {'id': data['id'], 'status': 'REAGENDADO'});
                            },
                            label: Text(
                              'REAGENDAR',
                              style: TextStylesSystem().montserratStyle(
                                  16, FontWeight.w500, Colors.white),
                            ),
                            icon: Icon(Icons.watch_later, color: Colors.white),
                          ),
                        )
                      : Container(),
                  data['pedido_carrier'].isNotEmpty &&
                          data['status'] != "NOVEDAD RESUELTA" &&
                          data['status'] != "NO ENTREGADO" &&
                          data['estado_devolucion'] == "PENDIENTE" &&
                          data['status'] != "ENTREGADO" &&
                          gestLastNov
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: FilledButton.tonalIcon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return ColorsSystem().colorSelected;
                                  }
                                  // Color cuando el botón está en su estado normal
                                  return ColorsSystem().colorStore;
                                },
                              ),
                            ),
                            onPressed: idCarrierExternal == 1
                                ? _showResolveExternalModal
                                : idCarrierExternal == 5
                                    ? _showResolveExternalModalLaar
                                    : null,
                            label: Text(
                              'GESTIONAR NOVEDAD',
                              style: TextStylesSystem().montserratStyle(
                                  16, FontWeight.w500, Colors.white),
                            ),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                  // ! --------
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Código: ${data['users'][0]['vendedores'][0]['nombre_comercial']}-${data['numero_orden']}",
                                style: TextStylesSystem().montserratStyle(
                                    16,
                                    FontWeight.bold,
                                    ColorsSystem().colorSelected),
                              ),
                              SizedBox(height: 8),
                              Text("Fecha de Ingreso: ${data['marca_t_i']}",
                                  style: TextStylesSystem().montserratStyle(
                                      14,
                                      FontWeight.w400,
                                      ColorsSystem().colorLabels)),
                              SizedBox(height: 8),
                              Text(
                                  "Fecha de Envío: ${UIUtils.formatDate(data['sent_at'])}",
                                  style: TextStylesSystem().montserratStyle(
                                      14,
                                      FontWeight.w400,
                                      ColorsSystem().colorLabels)),
                              SizedBox(height: 8),
                              Text("Fecha de Entrega: ${data['fecha_entrega']}",
                                  style: TextStylesSystem().montserratStyle(
                                      14,
                                      FontWeight.w400,
                                      ColorsSystem().colorLabels)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    // 📌 Agregado para que la tarjeta ocupe todo el espacio disponible
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Datos del Cliente",
                                style: TextStylesSystem().ralewayStyle(16,
                                    FontWeight.w600, ColorsSystem().colorStore),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Nombre: ${data['nombre_shipping']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Ciudad: ${data['ciudad_shipping']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Flexible(
                                // 📌 Envolver en Flexible para que el texto se ajuste
                                child: Text(
                                  "Dirección: ${data['direccion_shipping']}",
                                  style: TextStylesSystem().montserratStyle(
                                      14,
                                      FontWeight.w400,
                                      ColorsSystem().colorLabels),
                                  maxLines: null, // Permite múltiples líneas
                                  overflow:
                                      TextOverflow.visible, // Evita recortes
                                  softWrap: true, // Asegura el ajuste de línea
                                ),
                              ),
                              Text(
                                "Teléfono: ${data['telefono_shipping']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                                color: ColorsSystem().colorSelected,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                )),
                            children: [
                              _buildHeaderCell("Producto"),
                              _buildHeaderCell("Precio"),
                              _buildHeaderCell("Cantidad"),
                              _buildHeaderCell("Total"),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                )),
                            children: [
                              _buildDataCell(data['producto_p']),
                              _buildDataCell("\$${data['precio_total']}"),
                              _buildDataCell(data['cantidad_total'].toString()),
                              _buildDataCell("\$${data['precio_total']}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Estatus",
                                style: TextStylesSystem().montserratStyle(16,
                                    FontWeight.bold, ColorsSystem().colorStore),
                              ),
                              SizedBox(height: 8),
                              Text(
                                // "Status: ${data['status']}",
                                "Status: $estadoEntrega",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Estado Interno: ${data['estado_interno']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Estado Logístico: ${data['estado_logistico']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Estado Devolución: ${data['estado_devolucion']}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Detalle Adicional",
                                style: TextStylesSystem().montserratStyle(16,
                                    FontWeight.bold, ColorsSystem().colorStore),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Producto Extra: ${data['producto_extra'] ?? ''}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Costo Entrega: ${data['users']?[0]['vendedores']?[0]['costo_envio'] ?? ''}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Text(
                                "Costo Devolución: ${data['estado_devolucion'].toString() != "PENDIENTE" ? data['users'] != null ? data['users'][0]['vendedores'][0]['costo_devolucion'].toString() : "" : ""}",
                                // "Costo Devolución: ${data['estado_devolucion'] != "PENDIENTE" ? data['users']?[0]['vendedores']?[0]['costo_devolucion'] ?? "" : ""}",
                                style: TextStylesSystem().montserratStyle(
                                    14,
                                    FontWeight.w400,
                                    ColorsSystem().colorLabels),
                              ),
                              Flexible(
                                // 📌 Envolviendo la dirección en Flexible
                                child: Text(
                                  "Comentario: ${data['comentario'] ?? ''}",
                                  style: TextStylesSystem().montserratStyle(
                                      14,
                                      FontWeight.w400,
                                      ColorsSystem().colorLabels),
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              _buildSection("Archivos", [
                data['archivo'].toString().isEmpty ||
                        data['archivo'].toString() == "null"
                    ? Container(
                        height: 200,
                        child: Center(child: Text("No hay archivos ")),
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
                        child: Center(child: Text("No hay novedades")),
                      )
                    : Container(
                        height: 900,
                        child: ListView.builder(
                          itemCount: data['novedades'].length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Sección de la imagen a la izquierda
                                    GestureDetector(
                                      onTap: () {
                                        if (data['pedido_carrier'].isNotEmpty &&
                                            data['novedades'][index]
                                                        ['url_image']
                                                    .toString() !=
                                                "null" &&
                                            data['novedades'][index]
                                                        ['url_image']
                                                    .toString() !=
                                                "") {
                                          if (idCarrierExternal == 1) {
                                            // print("CaseGTM");

                                            launchUrl(Uri.parse(
                                              "$serverGTMimg${data['novedades'][index]['url_image'].toString()}",
                                            ));
                                          } else if (idCarrierExternal == 5) {
                                            // print("CaseLaar");

                                            launchUrl(Uri.parse(
                                              "$serverLaarTracking${data['pedido_carrier'][0]['external_id'].toString()}",
                                            ));
                                          }
                                          //
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: PhotoViewGallery.builder(
                                                  itemCount: 1,
                                                  builder: (context, index) {
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
                                                    color: Colors.black,
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
                                              BorderRadius.circular(10),
                                          color: Colors.blueGrey[50],
                                          image:
                                              data['pedido_carrier'].isNotEmpty
                                                  ? null
                                                  : DecorationImage(
                                                      image: NetworkImage(
                                                        "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                        ),
                                        child: data['pedido_carrier']
                                                    .isNotEmpty &&
                                                data['novedades'][index]
                                                            ['url_image']
                                                        .toString() !=
                                                    "null" &&
                                                data['novedades'][index]
                                                            ['url_image']
                                                        .toString() !=
                                                    ""
                                            ? Center(
                                                child: Text(
                                                  "Ver Foto",
                                                  style: TextStyle(
                                                    decoration: TextDecoration
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
                                              fontWeight: FontWeight.bold,
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
              Divider(),
              SizedBox(height: 20),
            ],
          ),
        ),
        // ])
      )
    ]);
  }

  _showResolveModal(isMobile) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Status:',
                        style: TextStylesSystem().montserratStyle(
                            isMobile ? 12 : 14,
                            FontWeight.bold,
                            ColorsSystem().colorLabels),
                      ),
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
                    Expanded(
                      child: Text('Comentario:',
                          style: TextStylesSystem().montserratStyle(
                              isMobile ? 12 : 14,
                              FontWeight.bold,
                              ColorsSystem().colorLabels)),
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

                          // await sendWhatsAppMessage(
                          //     context, data, _comentarioController.text);
                        } else {
                          _showErrorSnackBar(context,
                              "El pedido no tiene un Operador Asignado.");
                        }

                        Navigator.pop(context);
                        Navigator.pop(context);

                        widget.functionBack!({'id': data['id']});
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

  void _showResolveExternalModalLaar() {
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GESTIONAR NOVEDAD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text('Novedad:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(lastNovComment.toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SOLUCION:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Por favor, ingrese los datos correctos para resolver la novedad. De lo contrario, presione el botón 'Efectuar Devolución' para cerrar el caso.",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  /*
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Calle Principal:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _callePrinController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Calle Secundaria:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _calleSecunController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Numeracion:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _numeracionController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Referencia:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _referenciaController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Celular:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _celularController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  */
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _novObservacionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:
                                "-Por favor comunicarse con 0918001234\n-Por favor entregar en la calle A y calle B,num. 1001313, casa azul",
                          ),
                          onTap: () {
                            _novObservacionController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          //
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Seguro de Solicitar Devolucion a Bodega?',
                            // desc:
                            //     'Se eliminara el usuario selecionado del sistema, puede recuperarlo desde el apartado Usuarios Eliminados.',
                            btnOkText: "Aceptar",
                            btnCancelText: "Cancelar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              getLoadingModal(context, false);

                              int idDestinoCity = int.parse(
                                  getIdCiudadRefByCarrier(
                                          data['pedido_carrier'][0]
                                              ['city_external'],
                                          5)
                                      .toString());
                              var dataNoveltyUpt;
                              var autorizado;

                              autorizado = {
                                "isDevolucion":
                                    true, //“es true si solicitan la devolucion”
                                "nombre": sharedPrefs!
                                    .getString("username")
                                    .toString(), //“Nombre de la persona que autoriza”
                                "observacion": _novObservacionController.text
                              };

                              dataNoveltyUpt = {
                                "guia": data['pedido_carrier'][0]['external_id']
                                    .toString(),
                                "destino": {
                                  "ciudad":
                                      idDestinoCity, //“Si cambia de ciudad se genera nueva guía”
                                  "nombre": data['nombre_shipping']
                                      .toString(), //“Se debe mantener el mismo nombre”
                                  "cedula": "",
                                  "callePrincipal":
                                      data['direccion_shipping'].toString(),
                                  "numeracion": "",
                                  "calleSecundaria": "",
                                  "referencia": "",
                                  "telefono": "",
                                  "celular":
                                      data['telefono_shipping'].toString(),
                                  "observacion": _novObservacionController.text,
                                  "correo": ""
                                },
                                "autorizado": autorizado
                              };
                              // print(jsonEncode(dataNoveltyUpt));

                              var responseDevolucionLaar = await Connections()
                                  .updateNoveltyOrderLaar(dataNoveltyUpt);

                              // print(
                              //     "responseUptNoveltyLaar: $responseDevolucionLaar");

                              if (responseDevolucionLaar != 1 &&
                                  responseDevolucionLaar != 2) {
                                //

                                // print("Se envio la actualizacion");

                                DateTime now = DateTime.now();
                                String formattedDate =
                                    DateFormat('d/M/yyyy HH:mm:ss').format(now);

                                var resp =
                                    await Connections().postGestinodNovelty(
                                  data['id'],
                                  "Efectuar devolución ${_novObservacionController.text}",
                                  idUser,
                                  1, //gestioned
                                  formattedDate,
                                );

                                await updateData();

                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                //error
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                                if (mounted) {
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    title:
                                        "Hubo un error en la actualización de la información.",
                                    btnCancel: Container(),
                                    btnOkText: "Aceptar",
                                    btnOkColor: Colors.green,
                                    btnOkOnPress: () async {
                                      // Navigator.pop(context);
                                    },
                                    btnCancelOnPress: () async {},
                                  ).show();
                                }
                              }
                            },
                          ).show();
                        },
                        icon: const Icon(Icons.keyboard_backspace_sharp),
                        label: const Text('Efectuar devolución'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsSystem().mainBlue,
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
                          //
                          if (_novObservacionController.text.isEmpty) {
                            //
                            showSuccessModal(
                                context,
                                "Por favor, envíe una solución.",
                                Icons8.warning_1);
                          } else {
                            getLoadingModal(context, false);

                            int idDestinoCity = int.parse(
                                getIdCiudadRefByCarrier(
                                        data['pedido_carrier'][0]
                                            ['city_external'],
                                        5)
                                    .toString());
                            var dataNoveltyUpt;
                            var autorizado;
                            autorizado = {
                              "isDevolucion":
                                  false, //“es true si solicitan la devolucion”
                              "nombre": sharedPrefs!
                                  .getString("username")
                                  .toString(), //“Nombre de la persona que autoriza”
                              "observacion": ""
                            };

                            dataNoveltyUpt = {
                              "guia": data['pedido_carrier'][0]['external_id']
                                  .toString(),
                              "destino": {
                                "ciudad": idDestinoCity,
                                "nombre": data['nombre_shipping'].toString(),
                                "cedula": "",
                                "callePrincipal":
                                    data['direccion_shipping'].toString(),
                                "numeracion": "",
                                "calleSecundaria": "",
                                "referencia": "",
                                "telefono": "",
                                "celular": data['telefono_shipping'].toString(),
                                "observacion": _novObservacionController.text,
                                "correo": ""
                              },
                              "autorizado": autorizado
                            };
                            // print(jsonEncode(dataNoveltyUpt));

                            var responseUptNoveltyLaar = await Connections()
                                .updateNoveltyOrderLaar(dataNoveltyUpt);

                            // print(
                            //     "responseUptNoveltyLaar: $responseUptNoveltyLaar");

                            if (responseUptNoveltyLaar != 1 &&
                                responseUptNoveltyLaar != 2) {
                              //
                              String newDireccion =
                                  "${_callePrinController.text}/${_calleSecunController.text}/${_numeracionController.text}/${_referenciaController.text}";
                              // print("Se envio la actualizacion");

                              DateTime now = DateTime.now();
                              String formattedDate =
                                  DateFormat('d/M/yyyy HH:mm:ss').format(now);

                              var resp =
                                  await Connections().postGestinodNovelty(
                                data['id'],
                                _novObservacionController.text,
                                idUser,
                                2, //resolved
                                formattedDate,
                              );

                              // var response = await Connections().updatenueva(
                              //     data['id'], {
                              //   "direccion_shipping": newDireccion,
                              //   "telefono_shipping": _celularController.text
                              // });
                              await updateData();

                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else {
                              //error
                              if (mounted) {
                                Navigator.pop(context);
                              }
                              if (mounted) {
                                AwesomeDialog(
                                  width: 500,
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title:
                                      "Hubo un error en la actualización de la información.",
                                  btnCancel: Container(),
                                  btnOkText: "Aceptar",
                                  btnOkColor: Colors.green,
                                  btnOkOnPress: () async {
                                    // Navigator.pop(context);
                                  },
                                  btnCancelOnPress: () async {},
                                ).show();
                              }
                            }
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

  int? getIdCiudadRefByCarrier(
      Map<String, dynamic> pedidoCarrier, int idCarrier) {
    if (pedidoCarrier.containsKey('carrier_coverages') &&
        pedidoCarrier['carrier_coverages'] is List) {
      final carrierCoverages = pedidoCarrier['carrier_coverages'] as List;

      for (var coverage in carrierCoverages) {
        if (coverage is Map<String, dynamic>) {
          if (coverage['id_carrier'] == idCarrier) {
            print("${coverage['id_ciudad_ref']}");
            return int.parse(coverage['id_ciudad_ref'].toString());
          }
        }
      }
    }
    return null;
  }

  //
}
