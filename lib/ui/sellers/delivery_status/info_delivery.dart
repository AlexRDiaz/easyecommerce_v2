import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
// import 'package:frontend/helpers/navigators.dart';
// import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/operator/orders_operator/info_novedades.dart';
import 'package:frontend/ui/widgets/loading.dart';
// import 'package:frontend/ui/widgets/update_status_operator/update_status_operator.dart';
import 'package:intl/intl.dart';

class DeliveryStatusSellerInfo extends StatefulWidget {
  final String id;
  final Function(dynamic) function;
  final List data;
  const DeliveryStatusSellerInfo(
      {super.key,
      required this.id,
      required this.function,
      required this.data});

  @override
  State<DeliveryStatusSellerInfo> createState() => _DeliveryStatusSellerInfo();
}

class _DeliveryStatusSellerInfo extends State<DeliveryStatusSellerInfo> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = await Connections().getOrdersByIDHistorial(widget.id);
    var response = await Connections()
        .getOrdersByIdLaravel(int.parse(widget.id));
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorsSystem().colorBlack,
          leading: Container(),
          centerTitle: true,
          title: const Text(
            "Información Pedido",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
        ),
        body: SafeArea(
            child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: ColorsSystem().colorBlack, width: 2.0)),
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
                            ElevatedButton(
                                onPressed: () async {
                                  infoNovedades(context, widget.id);
                                },
                                child: const Text(
                                  "Estado Entrega",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            data['status'] == 'NOVEDAD' &&
                                    data['estado_devolucion'] == 'PENDIENTE'
                                ? ElevatedButton(
                                    onPressed: () async {
                                      widget.function({
                                        'id': data['id'],
                                        'status': 'REAGENDADO'
                                      });
                                    },
                                    child: const Text(
                                      "Reagendar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ))
                                : Container(),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _modelText("Fecha de Entrega",
                            data['fecha_entrega'].toString()),
                        _modelText(
                            "Marca Tiempo de Estado Entrega",
                            data['status_last_modified_at'] != null
                                ? formatDate(
                                    data['status_last_modified_at'].toString())
                                : ""),
                        _modelText("Código",
                            '${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}'),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: ColorsSystem().colorSelectMenu,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "DATOS DEL CLIENTE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        _modelText(
                            "Ciudad", data['ciudad_shipping'].toString()),
                        _modelText("Nombre Cliente",
                            data['nombre_shipping'].toString()),
                        _modelText(
                            "Dirección", data['direccion_shipping'].toString()),
                        _modelText("Teléfono Cliente",
                            data['telefono_shipping'].toString()),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: ColorsSystem().colorSelectMenu,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "DETALLES DEL PEDIDO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        _modelText(
                            "Cantidad", data['cantidad_total'].toString()),
                        _modelText("Producto", data['producto_p'].toString()),
                        _modelText(
                            "Producto Extra",
                            data['producto_extra'] == null ||
                                    data['producto_extra'] == "null"
                                ? ""
                                : data['producto_extra'].toString()),
                        _modelText(
                            "Precio Total", data['precio_total'].toString()),
                        _modelText(
                            "Comentario",
                            data['comentario'] == null ||
                                    data['comentario'] == "null"
                                ? ""
                                : data['comentario'].toString()),
                        _modelText("Status", data['status'].toString()),
                        _modelText(
                            "Confirmado", data['estado_interno'].toString()),
                        _modelText("Estado Logístico",
                            data['estado_logistico'].toString()),
                        _modelText("Estado Devolución",
                            data['estado_devolucion'].toString()),
                        _modelText(
                            "Costo Entrega",
                            data['users'] != null
                                ? data['users'][0]['vendedores'][0]
                                        ['costo_envio']
                                    .toString()
                                : ""),
                        _modelText(
                            "Costo Devolución",
                            data['estado_devolucion'].toString() != "PENDIENTE"
                                ? data['users'] != null
                                    ? data['users'][0]['vendedores'][0]
                                            ['costo_devolucion']
                                        .toString()
                                    : ""
                                : ""),
                        _modelText(
                            "Fecha Ingreso", data['marca_t_i'].toString()),
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
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "  Novedades:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                                      color: const Color.fromARGB(
                                          255, 117, 115, 115),
                                      border: Border.all(color: Colors.black)),
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
                                        data['novedades'][index]['url_image']
                                                    .toString()
                                                    .isEmpty ||
                                                data['novedades'][index]
                                                            ['url_image']
                                                        .toString() ==
                                                    "null"
                                            ? Container()
                                            : Container(
                                                margin:
                                                    const EdgeInsets.all(30),
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
                        )
                      ],
                    ),
            ),
          ),
        )));
  }

  Column _modelText(label, text) {
    return Column(
      children: [
        Text(
          "  $label: $text",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "$text: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: text,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusColor: Colors.black,
                    iconColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Future<dynamic> infoNovedades(BuildContext context, id) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Expanded(child: InfoNovedades(id: id, data: widget.data))
                ],
              ),
            ),
          );
        });
  }
}
