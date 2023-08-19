import 'package:flutter/material.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/operator/orders_operator/info_novedades.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator.dart';

class DeliveryStatusSellerInfo extends StatefulWidget {
  final String id;
  final Function(dynamic) function;
  const DeliveryStatusSellerInfo(
      {super.key, required this.id, required this.function});

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
    var response = await Connections().getOrdersByIDHistorial(widget.id);
    // data = response;
    data = response;
    _controllers.editControllers(response);

    Future.delayed(Duration(milliseconds: 500), () {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  infoNovedades(context, widget.id);
                                },
                                child: Text(
                                  "Estado Entrega",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            data['attributes']['Status'] == 'NOVEDAD' &&
                                    data['attributes']['Estado_Devolucion'] ==
                                        'PENDIENTE'
                                ? ElevatedButton(
                                    onPressed: () async {
                                      widget.function({
                                        'id': data['id'],
                                        'status': 'REAGENDADO'
                                      });
                                    },
                                    child: Text(
                                      "Reagendar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ))
                                : Container(),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _modelText("Fecha de Entrega",
                            data['attributes']['Fecha_Entrega'].toString()),
                        _modelText("Código",
                            '${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden'].toString()}'),
                        _modelText("Ciudad",
                            data['attributes']['CiudadShipping'].toString()),
                        _modelText("Nombre Cliente",
                            data['attributes']['NombreShipping'].toString()),
                        _modelText("Dirección",
                            data['attributes']['DireccionShipping'].toString()),
                        _modelText("Teléfono Cliente",
                            data['attributes']['TelefonoShipping'].toString()),
                        _modelText("Cantidad",
                            data['attributes']['Cantidad_Total'].toString()),
                        _modelText("Producto",
                            data['attributes']['ProductoP'].toString()),
                        _modelText("Producto Extra",
                            data['attributes']['ProductoExtra'].toString()),
                        _modelText("Precio Total",
                            data['attributes']['PrecioTotal'].toString()),
                        _modelText("Comentario",
                            data['attributes']['Comentario'].toString()),
                        _modelText(
                            "Status", data['attributes']['Status'].toString()),
                        _modelText("Confirmado",
                            data['attributes']['Estado_Interno'].toString()),
                        _modelText("Estado Logístico",
                            data['attributes']['Estado_Logistico'].toString()),
                        _modelText("Estado Devolución",
                            data['attributes']['Estado_Devolucion'].toString()),
                        _modelText(
                            "Costo Entrega",
                            data['attributes']['users'] != null
                                ? data['attributes']['users']['data'][0]
                                            ['attributes']['vendedores']['data']
                                        [0]['attributes']['CostoEnvio']
                                    .toString()
                                : ""),
                        _modelText(
                            "Costo Devolución",
                            data['attributes']['Estado_Devolucion']
                                        .toString() !=
                                    "PENDIENTE"
                                ? data['attributes']['users'] != null
                                    ? data['attributes']['users']['data'][0]
                                                    ['attributes']['vendedores']
                                                ['data'][0]['attributes']
                                            ['CostoDevolucion']
                                        .toString()
                                    : ""
                                : ""),
                        _modelText("Fecha Ingreso",
                            data['attributes']['Marca_T_I'].toString()),
                        data['attributes']['Archivo'].toString().isEmpty ||
                                data['attributes']['Archivo'].toString() ==
                                    "null"
                            ? Container()
                            : Container(
                                width: 300,
                                height: 400,
                                child: Image.network(
                                  "$generalServer${data['attributes']['Archivo'].toString()}",
                                  fit: BoxFit.fill,
                                )),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Novedades:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Container(
                          height: 500,
                          width: 500,
                          child: ListView.builder(
                            itemCount:
                                data['attributes']['novedades']['data'].length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 117, 115, 115),
                                      border: Border.all(color: Colors.black)),
                                  child: Container(
                                    margin: EdgeInsets.all(10),
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
                                            "Intento: ${data['attributes']['novedades']['data'][index]['attributes']['m_t_novedad']}"),
                                        Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            "Intento: ${data['attributes']['novedades']['data'][index]['attributes']['try']}"),
                                        Text(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            "Comentario: ${data['attributes']['novedades']['data'][index]['attributes']['comment']}"),
                                        data['attributes']['novedades']['data']
                                                                [index]
                                                            ['attributes']
                                                        ['url_image']
                                                    .toString()
                                                    .isEmpty ||
                                                data['attributes']['novedades']
                                                                        ['data']
                                                                    [index]
                                                                ['attributes']
                                                            ['url_image']
                                                        .toString() ==
                                                    "null"
                                            ? Container()
                                            : Container(
                                                margin: EdgeInsets.all(30),
                                                child: Image.network(
                                                  "$generalServer${data['attributes']['novedades']['data'][index]['attributes']['url_image'].toString()}",
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
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
                  Expanded(
                      child: InfoNovedades(
                    id: id,
                  ))
                ],
              ),
            ),
          );
        });
  }
}
