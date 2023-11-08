import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator.dart';
import 'package:url_launcher/url_launcher.dart';

class NoveltiesInfo extends StatefulWidget {
  final String id;
  final List data;
  final Function function;

  const NoveltiesInfo(
      {super.key,
      required this.id,
      required this.data,
      required this.function});

  @override
  State<NoveltiesInfo> createState() => _NoveltiesInfo();
}

class _NoveltiesInfo extends State<NoveltiesInfo> {
  var data = {};
  bool loading = true;
  // OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  final TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  final TextEditingController _comentarioController = TextEditingController();

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
      print("data> $data");
      _comentarioController.text = safeValue(data['comentario']);
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
                          Divider(
                            height: 1.0,
                            color: Colors.grey[200],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "  Datos Cliente ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: ColorsSystem().colorSelectMenu),
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
                          Text(
                            "  Detalle Pedido ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: ColorsSystem().colorSelectMenu),
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
                            "  Producto Extra: ${safeValue(data['producto_extra'])}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "  Precio Total: \$ ${safeValue(data['precio_total'])}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Colors.green[600]),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "  Observación: ${safeValue(data['observacion'].toString())}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "  Comentario: ${safeValue(data['comentario'].toString())}",
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
                          Divider(
                            height: 1.0,
                            color: Colors.grey[200],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "  Datos Adicionales ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: ColorsSystem().colorSelectMenu),
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
                            "  Transportadora: ${safeValue(transportadoraNombre)}",
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
                          //         data['archivo'].toString() == "null"
                          //     ? Container()
                          //     : Container(
                          //         width: 300,
                          //         height: 400,
                          //         child: Image.network(
                          //           "$generalServer${data['archivo'].toString()}",
                          //           fit: BoxFit.fill,
                          //         )),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showResolveModal,
          label: const Text('Resolver Novedad'),
          icon: const Icon(Icons.check_circle),
        ));
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