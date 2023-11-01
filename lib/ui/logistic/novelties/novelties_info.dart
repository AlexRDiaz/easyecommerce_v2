import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

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
  const NoveltiesInfo({super.key, required this.id, required this.data});

  @override
  State<NoveltiesInfo> createState() => _NoveltiesInfo();
}

class _NoveltiesInfo extends State<NoveltiesInfo> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  TextEditingController _statusController =
      TextEditingController(text: "NOVEDAD RESUELTA");
  TextEditingController _comentarioController = TextEditingController();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    // print("aqui> ${widget.data}");

    var order = widget.data.firstWhere(
        (item) => item['id'].toString() == widget.id,
        orElse: () => null);

    if (order != null) {
      data = order;
      _comentarioController.text = safeValue(data['comentario']);
    } else {
      print("Error: No se encontró el pedido con el ID proporcionado.");
      // Puedes manejar este error como desees. Por ejemplo, mostrar un mensaje al usuario.
    }

    Future.delayed(Duration(milliseconds: 500), () {
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
        title: Text(
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
                        SizedBox(
                          height: 20,
                        ),
                        // Text(
                        //   "  Costo Devolución: ${data['users'] != null ? data['users'][0]['vendedores'][0]['costo_devolucion'].toString() : ""}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.bold, fontSize: 18),
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha Entrega: ${safeValue(data['fecha_entrega'].toString())}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
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
      floatingActionButton: (safeValue(data['status']) == "NOVEDAD")
          ? FloatingActionButton.extended(
              onPressed: _showResolveModal,
              label: Text('Resolver Novedad'),
              icon: Icon(Icons.check_circle),
            )
          : null,
    );
  }

  void _showResolveModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Status:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _statusController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        enabled: false, // makes the input non-editable
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text('Comentario:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _comentarioController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      icon: Icon(Icons.cancel),
                      label: Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, 
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        
                        var respupdtstcmt = await Connections()
                            .editStatusandComment(
                                data['id'],
                                _statusController.text,
                                _comentarioController.text);

                        if (respupdtstcmt == true) {
                          print("okk!");

                        }
                        await sendWhatsAppMessage(context,data);

                        Navigator.pop(context); 
                        // loadData();
                      },
                      icon: Icon(Icons.check),
                      label: Text('Guardar'),
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

  Future<void> sendWhatsAppMessage(
      BuildContext context, Map<dynamic, dynamic> orderData) async {
    // Verificar si el operador está asignado y tiene un número de teléfono
    String? phoneNumber = orderData['operadore']?.isNotEmpty == true
        ? orderData['operadore'][0]['telefono']
        : null;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Construir la URL de WhatsApp
      var message =
          "Buen Día, la guía con el código >> ${orderData['numero_orden']} << de la tienda >> ${orderData['tienda_temporal']} << indica: ' ${orderData['comentario']} ' .";
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        // No se pudo abrir la URL, manejar el error aquí
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      // Operador no asignado o no tiene teléfono, mostrar la alerta
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: const Color.fromARGB(255, 20, 38, 53),
            content: Center(
              child: Text(
                'Operador No Asignado',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text('Ok', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }
}
