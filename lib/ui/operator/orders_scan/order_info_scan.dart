import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class OrderInfoScan extends StatefulWidget {
  final Map order;

  const OrderInfoScan({
    super.key,
    required this.order,
  });

  @override
  State<OrderInfoScan> createState() => _OrderInfoScanState();
}

class _OrderInfoScanState extends State<OrderInfoScan> {
  TextEditingController _controllerModalText = TextEditingController();
  XFile? imageSelect = null;

  String interno = "";
  String logistico = "";
  String status = "";
  String devolucion = "";

  bool efectivo = false;
  bool transferencia = false;
  bool deposito = false;

  var data = {};
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      isLoading = true;
    });
    data = widget.order;
    interno = data['estado_interno'];
    logistico = data['estado_logistico'];
    status = data['status'];
    devolucion = data['estado_devolucion'];
    // print(data);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double whidth = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Text(
                  "CÓDIGO: ${data['users'] != null ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal'].toString()}-${data['numero_orden']}",
                  // "CODIGO: AmoMUCHOOAmiPerro-E0000003587",
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.75,
              // padding: const EdgeInsets.only(bottom: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Center(
                      child: Text(
                        "Status: $status",
                        style: const TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Estado Devolución: $devolucion",
                        style: const TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Sección 1
                    _buildRow(
                      'Fecha Envio',
                      data['marca_tiempo_envio'].toString(),
                      context,
                    ),
                    _buildRow(
                      'Fecha de Entrega',
                      data['fecha_entrega'].toString(),
                      context,
                    ),
                    _buildRow(
                      'Operador',
                      data['operadore'][0]['up_users'][0]['username']
                          .toString(),
                      context,
                    ),
                    const Divider(),
                    // Sección 2
                    _buildSection(
                      'DETALLES DE GUIA',
                      [
                        _buildRow(
                          "Nombre",
                          data['nombre_shipping'].toString(),
                          context,
                        ),
                        _buildRow(
                            "Dirección",
                            "${data['ciudad_shipping'].toString()} / ${data['direccion_shipping'].toString()}",
                            context),
                        _buildRow("Teléfono",
                            data['telefono_shipping'].toString(), context),
                        _buildRow("Cantidad", data['cantidad_total'].toString(),
                            context),
                        _buildRow(
                            "Producto", data['producto_p'].toString(), context),
                        _buildRow(
                            "Producto Extra",
                            data['producto_extra'] == null ||
                                    data['producto_extra'] == "null"
                                ? ""
                                : data['producto_extra'].toString(),
                            context),
                        _buildRow(
                          "Precio Total",
                          data['precio_total'],
                          context,
                        ),
                        _buildRow(
                          "Observacion",
                          data['observacion'] == null ||
                                  data['observacion'] == "null"
                              ? ""
                              : data['observacion'].toString(),
                          context,
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildSection("Archivos", [
                      data['archivo'].toString().isEmpty ||
                              data['archivo'].toString() == "null"
                          ? const SizedBox(
                              height: 200,
                              child: Center(child: Text("No hay archivos ")),
                            )
                          : SizedBox(
                              width: 300,
                              height: 200,
                              child: Image.network(
                                "$generalServer${data['archivo'].toString()}",
                                fit: BoxFit.fill,
                              )),
                    ]),
                    const Divider(),
                    _buildSection(
                      "Novedades",
                      [
                        data['novedades'].length < 1
                            ? const SizedBox(
                                height: 200,
                                child: Center(child: Text("No hay novedades")),
                              )
                            : SizedBox(
                                height: 400,
                                child: ListView.builder(
                                  itemCount: data['novedades'].length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            // Sección de la imagen a la izquierda
                                            GestureDetector(
                                              onTap: () {
                                                // if (data['pedido_carrier']
                                                //     .isNotEmpty) {
                                                //   launchUrl(Uri.parse(
                                                //     "$serverGTMimg${data['novedades'][index]['url_image'].toString()}",
                                                //   ));
                                                // } else {
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
                                                // }
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.blueGrey[50],
                                                  image:
                                                      // data['pedido_carrier']
                                                      //         .isNotEmpty
                                                      //     ? null
                                                      //     :
                                                      DecorationImage(
                                                    image: NetworkImage(
                                                      "$generalServer${data['novedades'][index]['url_image'].toString()}",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                // child: data['pedido_carrier']
                                                //         .isNotEmpty
                                                //     ? Center(
                                                //         child: Text(
                                                //           "Ver Foto",
                                                //           style: TextStyle(
                                                //             decoration:
                                                //                 TextDecoration
                                                //                     .underline,
                                                //             color: ColorsSystem()
                                                //                 .colorVioletDateText,
                                                //           ),
                                                //         ),
                                                //       )
                                                //     : null,
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
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: interno == "CONFIRMADO" &&
                  logistico == "ENVIADO" &&
                  status != "ENTREGADO" &&
                  status != "NO ENTREGADO" &&
                  devolucion == "PENDIENTE",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: whidth < 600 ? 200 : whidth * 0.2,
                    child: FilledButton.tonalIcon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              // return const Color.fromARGB(255, 235, 251, 64);
                              return Color.fromARGB(255, 64, 251, 170);
                            }
                            // return const Color.fromARGB(255, 209, 184, 146);
                            return Color.fromARGB(255, 146, 209, 167);
                          },
                        ),
                      ),
                      onPressed: () async {
                        //

                        showUpdate(context);

                        //
                      },
                      label: const Text(
                        'ENTREGADO',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                title,
                style: const TextStyle(
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

  Widget _buildRow(String title, dynamic content, BuildContext context) {
    double whidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: whidth < 600
                ? const EdgeInsets.only(left: 20)
                : const EdgeInsets.only(left: 40),
            child: Text(title),
          ),
          const SizedBox(width: 5),
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

  Future<void> showUpdate(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        //

        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          content: _Entregado(),
        );
      },
    );
  }

  Widget _Entregado() {
    double height = MediaQuery.of(context).size.height;
    double whidth = MediaQuery.of(context).size.width;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: height * 0.6,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text("Tipo de Pago",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
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
                    const Flexible(
                      child: Text(
                        "Efectivo",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
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
                    const Flexible(
                      child: Text(
                        "Transferencia",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
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
                    const Flexible(
                      child: Text(
                        "Deposito",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                if (transferencia == true) ...[
                  const Text("Foto",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    imageSelect != null ? imageSelect!.name.toString() : '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 10),
                const Text("Comentario",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    maxLines: null,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    controller: _controllerModalText,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
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

                              var urlImg =
                                  await Connections().postDoc(imageSelect!);

                              var datacostos = await Connections()
                                  .getOrderByIDHistoryLaravel(data['id']);

                              await paymentEntregado(datacostos, tipo, urlImg);

                              setState(() {
                                _controllerModalText.clear();
                                tipo = "";
                                deposito = false;
                                efectivo = false;
                                transferencia = false;
                                imageSelect = null;
                              });

                              // widget.function;
                              // Navigator.pop(context);
                              // Navigator.pop(context);
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
                                      .getOrderByIDHistoryLaravel(data['id']);

                                  await paymentEntregado(datacostos, tipo, "");
                                  if (mounted) {
                                    setState(() {
                                      _controllerModalText.clear();
                                      tipo = "";
                                      deposito = false;
                                      efectivo = false;
                                      transferencia = false;
                                      imageSelect = null;
                                    });
                                  }
                                  // widget.function;
                                  // Navigator.pop(context);
                                  // Navigator.pop(context);
                                }
                              : null,
                      child: const Text(
                        "Aceptar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> paymentEntregado(datacostos, String tipo, urlImage) async {
    var resDelivered = await Connections().paymentOrderDelivered(
        datacostos['users'][0]['vendedores'][0]['id_master'],
        datacostos['precio_total'],
        datacostos['users'][0]['vendedores'][0]['costo_envio'],
        datacostos['id'],
        "${datacostos['users'] != null && datacostos['users'].isNotEmpty ? datacostos['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${datacostos['numero_orden']}",
        _controllerModalText.text,
        urlImage != "" ? urlImage[1] : "",
        tipo);

    dialogEntregado(resDelivered);
  }

  Future<void> dialogEntregado(resDelivered) async {
    if (resDelivered == 0) {
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
        descTextStyle: const TextStyle(color: Colors.green),
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context); //cierra info

          Provider.of<NavigationProviderOperator>(context, listen: false)
              .changeIndex(6, "Valores Recibidos");
          //
        },
      ).show();
    } else if (resDelivered == "Transacciones ya Registradas") {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        title: "$resDelivered",
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
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Error al realizar la transaccion",
        //  desc: 'Vuelve a intentarlo',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    }
  }

  //
}
