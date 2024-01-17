import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/sellers/my_seller_account/edit_autome.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DeliveryStatusSellerInfo2 extends StatefulWidget {
  final String id;
  final Function(dynamic) function;
  final List data;
  const DeliveryStatusSellerInfo2(
      {super.key,
      required this.id,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = await Connections().getOrdersByIDHistorial(widget.id);
    var response =
        await Connections().getOrdersByIdLaravel(int.parse(widget.id));
    // var response = await Connections().getOrdersByIdLaravel(widget.id);

    // ! ↓esta es la usada
    data = response;
    _controllers.editControllers2(response);

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(17),
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
                        _buildRow('Fecha de Entrega',
                            data['fecha_entrega'].toString()),
                        _buildRow(
                            'Marca Tiempo de Estado Entrega',
                            data['status_last_modified_at'] != null
                                ? formatDate(
                                    data['status_last_modified_at'].toString())
                                : ""),
                        _buildRow("Código",
                            '${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}'),
                      ],
                    ),
                    Divider(),
                    // Sección 2
                    _buildSection(
                      'DATOS DEL CLIENTE',
                      [
                        _buildRow("Ciudad", data['ciudad_shipping'].toString()),
                        _buildRow("Nombre Cliente",
                            data['nombre_shipping'].toString()),
                        _buildRow(
                            "Dirección", data['direccion_shipping'].toString()),
                        _buildRow("Teléfono Cliente",
                            data['telefono_shipping'].toString()),
                      ],
                    ),
                    Divider(),
                    // Sección 3
                    _buildSection(
                      'DETALLES DEL PEDIDO',
                      [
                        _buildRow(
                            "Cantidad", data['cantidad_total'].toString()),
                        _buildRow("Producto", data['producto_p'].toString()),
                        _buildRow(
                            "Producto Extra",
                            data['producto_extra'] == null ||
                                    data['producto_extra'] == "null"
                                ? ""
                                : data['producto_extra'].toString()),
                        _buildRow(
                            "Precio Total", data['precio_total'].toString()),
                        _buildRow(
                            "Comentario",
                            data['comentario'] == null ||
                                    data['comentario'] == "null"
                                ? ""
                                : data['comentario'].toString()),
                        _buildRow("Status", data['status'].toString()),
                        _buildRow(
                            "Confirmado", data['estado_interno'].toString()),
                        _buildRow("Estado Logístico",
                            data['estado_logistico'].toString()),
                        _buildRow("Estado Devolución",
                            data['estado_devolucion'].toString()),
                        _buildRow(
                            "Costo Entrega",
                            data['users'] != null
                                ? data['users'][0]['vendedores'][0]
                                        ['costo_envio']
                                    .toString()
                                : ""),
                        _buildRow(
                            "Costo Devolución",
                            data['estado_devolucion'].toString() != "PENDIENTE"
                                ? data['users'] != null
                                    ? data['users'][0]['vendedores'][0]
                                            ['costo_devolucion']
                                        .toString()
                                    : ""
                                : ""),
                        _buildRow(
                            "Fecha Ingreso", data['marca_t_i'].toString()),
                        _buildRow(
                          "Archivos",
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
                        ),
                        _buildRow(
                            "Novedades",
                            Container(
                              height: 500,
                              width: 500,
                              child: ListView.builder(
                                itemCount: data['novedades'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color.fromARGB(
                                              255, 117, 115, 115),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
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
                                                "Número Intentos: ${data['novedades'][index]['try']}"),
                                            Text(
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                "Comentario: ${data['novedades'][index]['comment']}"),
                                            data['novedades'][index]
                                                            ['url_image']
                                                        .toString()
                                                        .isEmpty ||
                                                    data['novedades'][index]
                                                                ['url_image']
                                                            .toString() ==
                                                        "null"
                                                ? Container()
                                                : Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            30),
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
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -7);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
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
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        ...rows
      ],
    );
  }

  Widget _buildRow(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 250,
            padding: EdgeInsets.only(left: 30),
            child: Text(title),
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
