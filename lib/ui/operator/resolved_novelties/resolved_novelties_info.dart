import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';
import 'package:url_launcher/url_launcher.dart';

class ResolvedNoveltiesInfo extends StatefulWidget {
  final String id;
  final List data;
  final Function function;

  const ResolvedNoveltiesInfo(
      {super.key,
      required this.id,
      required this.data,
      required this.function});

  @override
  State<ResolvedNoveltiesInfo> createState() => _ResolvedNoveltiesInfo();
}

class _ResolvedNoveltiesInfo extends State<ResolvedNoveltiesInfo> {
  var data = {};
  bool loading = true;
  // OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  final TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  final TextEditingController _comentarioController = TextEditingController();

  String _selectedValue = "";

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
      _comentarioController.text = safeValue(data['comentario']);
      _selectedValue = data['status'];
    } else {
      print("Error: No se encontró el pedido con el ID proporcionado.");
    }

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
            ? data['transportadora'][0]['nombre']
            : 'No disponible';
    String operadorUsername = data['operadore'] != null &&
            data['operadore'].isNotEmpty &&
            data['operadore'][0]['up_users'] != null &&
            data['operadore'][0]['up_users'].isNotEmpty
        ? data['operadore'][0]['up_users'][0]['username']
        : 'No disponible';

    final Map<String, Widget> segmentedControlChildren = {
      if (_selectedValue == 'NOVEDAD RESUELTA')
        'NOVEDAD RESUELTA': const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'NOVEDAD RESUELTA',
            style: TextStyle(color: Colors.white),
          ),
        ),
      'ENTREGADO': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'ENTREGADO',
          style: TextStyle(color: Colors.white),
        ),
      ),
      'NO ENTREGADO': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'NO ENTREGADO',
          style: TextStyle(color: Colors.white),
        ),
      ),
      'EN RUTA': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'EN RUTA',
          style: TextStyle(color: Colors.white),
        ),
      ),
      'EN OFICINA': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'EN OFICINA',
          style: TextStyle(color: Colors.white),
        ),
      ),
      'REAGENDADO': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'REAGENDADO',
          style: TextStyle(color: Colors.white),
        ),
      ),
      'PEDIDO PROGRAMADO': const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'PEDIDO PROGRAMADO',
          style: TextStyle(color: Colors.white),
        ),
      ),
    };

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
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child:
      //     ),
      //   ],
      // ),
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

                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return UpdateStatusOperatorHistorial(
                                              numberTienda:
                                                  response['vendedores'][0]
                                                          ['Telefono2']
                                                      .toString(),
                                              codigo:
                                                  "${data['name_cComercial']}-${data['numero_orden']}",
                                              numberCliente:
                                                  "${data['telefono_shipping']}",
                                              id: widget.id,
                                              novedades: data['novedades'],
                                              currentStatus: '',
                                              // comment: widget.comment!,
                                              function: widget.function!,
                                              // dataL: widget.data!,
                                              // rolidinvoke: 4,
                                            );
                                          });
                                      // print("cmt> ${ data['attributes']
                                      //             ['Comentario']
                                      //         .toString()}");
                                      // await loadData();

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
                          "  Código: ${safeValue(data['numero_orden'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Envio: ${safeValue(data['marca_tiempo_envio'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Nombre Cliente: ${safeValue(data['nombre_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Ciudad: ${safeValue(data['ciudad_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  DIRECCIÓN: ${safeValue(data['direccion_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  TELEFÓNO CLIENTE: ${safeValue(data['telefono_shipping'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Cantidad: ${safeValue(data['cantidad_total'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto: ${safeValue(data['producto_p'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto Extra: ${safeValue(data['producto_extra'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Precio Total: ${safeValue(data['precio_total'])}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Observación: ${safeValue(data['observacion'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Comentario: ${safeValue(data['comentario'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Status: ${safeValue(data['status'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Vendedor: ${safeValue(data['tienda_temporal'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Transportadora: ${safeValue(transportadoraNombre)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Operador: ${safeValue(operadorUsername)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado Devolución: ${safeValue(data['estado_devolucion'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Entrega: ${safeValue(data['fecha_entrega'].toString())}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Text(
                        //   "  Archivo:",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.bold, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // data['archivo'].toString().isEmpty ||
                        //         data['archivo'].toString() ==
                        //             "null"
                        //     ? Container()
                        //     : Container(
                        //         width: 300,
                        //         height: 400,
                        //         child: Image.network(
                        //           "$generalServer${data['archivo'].toString()}",
                        //           fit: BoxFit.fill,
                        //         )),
                        // SizedBox(
                        //   height: 20,
                        // ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
    //   floatingActionButton: FloatingActionButton.extended(
    //     onPressed: _showResolveModal,
    //     label: const Text('Cambiar Status'),
    //     icon: const Icon(Icons.check_circle),
    //   ),
    // );
  }

  void _changeStatus(String status) {
    // Implementa la lógica para manejar el cambio de estado aquí
    print("Estado seleccionado: $status");
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
                        await sendWhatsAppMessage(
                            context, data, _comentarioController.text);
                        await Connections().editStatusandComment(data['id'],
                            _statusController.text, _comentarioController.text);

                        // await widget.functionpass;

                        Navigator.pop(context);
                        Navigator.pop(context);

                        await widget.function();
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

  Future<void> sendWhatsAppMessage(BuildContext context,
      Map<dynamic, dynamic> orderData, String newComment) async {
    String? phoneNumber = orderData['operadore']?.isNotEmpty == true
        ? orderData['operadore'][0]['telefono']
        : null;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      var message =
          "Buen Día, la guía con el código >> ${orderData['numero_orden']} << de la tienda >> ${orderData['tienda_temporal']} << indica: ' $newComment ' .";
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      _showErrorSnackBar(context, "El pedido no tiene un operador asignado.");
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       contentPadding: const EdgeInsets.all(20),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //       backgroundColor: const Color.fromARGB(255, 20, 38, 53),
      //       content: const Center(
      //         child: Text(
      //           'Operador No Asignado',
      //           style: TextStyle(color: Colors.white, fontSize: 18),
      //         ),
      //       ),
      //       actions: <Widget>[
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: const Text('Ok', style: TextStyle(color: Colors.white)),
      //         ),
      //       ],
      //     );
      //   },
      // );
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
