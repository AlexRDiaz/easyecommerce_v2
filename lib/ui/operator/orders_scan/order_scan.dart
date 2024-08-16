import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';

class OrderScan extends StatefulWidget {
  const OrderScan({super.key});

  @override
  State<OrderScan> createState() => _OrderScanState();
}

class _OrderScanState extends State<OrderScan> {
  String idUser = sharedPrefs!.getString("id").toString();
  String scannedId = "No se ha escaneado ningún código";
  int idUserOp = 0;
  String interno = "";
  String logistico = "";
  String status = "";
  String devolucion = "";

  bool loading = false;

  bool efectivo = false;
  bool transferencia = false;
  bool deposito = false;

  TextEditingController _controllerModalText = TextEditingController();
  XFile? imageSelect = null;

  var data = {};

  loadData() async {
    setState(() {
      loading = true;
    });

    print(data);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: responsive(
          Container(
            margin: const EdgeInsets.all(22),
            // color: Colors.amber,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    // _btnScanear(context),
                  ],
                ),
              ],
            ),
          ),
          //mobile
          Container(
            margin: const EdgeInsets.all(22),
            child: ListView(
              children: [
                Column(
                  children: [
                    _btnScanear(context),
                  ],
                )
              ],
            ),
          ),
          context),
    );
  }

  ElevatedButton _btnScanear(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        //
        // scannedId = "331";

        scannedId = await scanBarcode();
        idUserOp = 0;
        interno = "";
        logistico = "";
        status = "";
        devolucion = "";

        if (int.parse(scannedId) != 0) {
          // print("scannedId: $scannedId");

          var responseOrder = await Connections().getOrderByIDLaravel(
            scannedId,
            [
              'operadore.up_users',
              'transportadora',
              'users.vendedores',
              'novedades',
              'pedidoFecha',
              'ruta',
              'subRuta',
              "statusLastModifiedBy",
              "carrierExternal",
              "ciudadExternal",
              "pedidoCarrier"
            ],
          );

          // print(responseOrder);
          if (responseOrder['operadore'].isNotEmpty) {
            idUserOp = int.parse(
                responseOrder['operadore'][0]['up_users'][0]['id'].toString());
          }
          // print(idUserOp);
          if (idUserOp != int.parse(idUser)) {
            // ignore: use_build_context_synchronously
            showSuccessModal(
                context,
                "La guia selecciona no pertenece a este usuario.",
                Icons8.warning_1);
          } else {
            interno = responseOrder['estado_interno'];
            logistico = responseOrder['estado_logistico'];
            status = responseOrder['status'];
            devolucion = responseOrder['estado_devolucion'];

            // if (interno == "CONFIRMADO" &&
            //     logistico == "ENVIADO" &&
            //     status != "ENTREGADO" &&
            //     status != "NO ENTREGADO" &&
            //     devolucion == "PENDIENTE") {
            //
            data = responseOrder;

            // ignore: use_build_context_synchronously
            showInfo(context);
            // } else {
            //   // ignore: use_build_context_synchronously
            //   showSuccessModal(
            //       context,
            //       "La guía seleccionada no cumple con los estados requeridos. Verifique los estados y vuelva a intentarlo.",
            //       Icons8.warning_1);
            // }
          }
        } else {
          print("scannedId: $scannedId");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple[300],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
          ),
          Text(
            "  Scanear",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> scanBarcode() async {
    print("*************scanBarcode***********");
    String resId = "0";
    try {
      var result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );
      resId = result.toString();
      print("***resId: $resId");
    } catch (e) {
      //
      print("error_scanBarcode: $e");
    }
    return resId;
  }

  Future<dynamic> showInfo(BuildContext context) {
    if (MediaQuery.of(context).size.width > 930) {
      /*
      return openDialog(
        context,
        MediaQuery.of(context).size.width * 0.4,
        MediaQuery.of(context).size.height * 0.9,
        _orderInfo(context),
        () {},
      );
      */

      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.9,
                child: _orderInfo(context),
              ),
            );
          }).then((value) {
        //
      });
    } else {
      /*
      return openDialog(
        context,
        MediaQuery.of(context).size.width * 0.85,
        MediaQuery.of(context).size.height * 0.9,
        _orderInfo(context),
        () {},
      );
      */
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.9,
                child: _orderInfo(context),
              ),
            );
          }).then((value) {
        //
      });
    }
  }

  Column _orderInfo(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double whidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Text(
              "CÓDIGO: ${data['users'] != null ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal'].toString()}-${data['numero_orden']}",
              // "CODIGO: AmoMUCHOOAmiPerro-E0000003587",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    "Estado Devolución: $devolucion",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                  data['operadore'][0]['up_users'][0]['username'].toString(),
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
                    _buildRow("Teléfono", data['telefono_shipping'].toString(),
                        context),
                    _buildRow(
                        "Cantidad", data['cantidad_total'].toString(), context),
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
                /*
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
                      */
                /*
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
                                                if (data['pedido_carrier']
                                                    .isNotEmpty) {
                                                  launchUrl(Uri.parse(
                                                    "$serverGTMimg${data['novedades'][index]['url_image'].toString()}",
                                                  ));
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
                                                        .isNotEmpty
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
                                ),),
                      ],),
                      */
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
                width: whidth < 600 ? 300 : whidth * 0.2,
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
                    /*
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          contentPadding: const EdgeInsets.only(top: 10.0),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: SingleChildScrollView(
                              child: _Entregado(),
                            ),
                          ),
                        );
                      },
                    );
                    */
                    //
                  },
                  label: const Text(
                    'MARCAR COMO ENTREGADO',
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

  Widget _Entregado() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text("Tipo de Pago",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(
            height: 10,
          ),
          _modelCheckEfectivo(),
          const SizedBox(
            height: 10,
          ),
          _modelCheckTransferencia(),
          const SizedBox(
            height: 10,
          ),
          _modelCheckDeposito(),
          const SizedBox(
            height: 10,
          ),
          transferencia == true
              ? const Text("Foto",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              : Container(),
          const SizedBox(
            height: 10,
          ),
          transferencia == true
              ? TextButton(
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
                  ))
              : Container(),
          transferencia == true
              ? const SizedBox(
                  height: 10,
                )
              : Container(),
          transferencia == true
              ? Text(imageSelect != null ? imageSelect!.name.toString() : '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12))
              : Container(),
          const SizedBox(
            height: 10,
          ),
          const Text("Comentario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: TextField(
              maxLines: null,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              controller: _controllerModalText,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

                        var urlImg = await Connections().postDoc(imageSelect!);

                        var datacostos = await Connections()
                            .getOrderByIDHistoryLaravel(scannedId);

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
                                .getOrderByIDHistoryLaravel(scannedId);

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
                          }
                        : null,
                child: const Text(
                  "Aceptar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _modelCheckEfectivo() {
    return Row(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        )
      ],
    );
  }

  Row _modelCheckTransferencia() {
    return Row(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        )
      ],
    );
  }

  Row _modelCheckDeposito() {
    return Row(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        )
      ],
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
