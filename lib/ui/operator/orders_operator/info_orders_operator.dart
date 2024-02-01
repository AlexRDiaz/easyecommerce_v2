import 'package:flutter/material.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';

class InfoOrdersOperator extends StatefulWidget {
  final String id;
  final Function function;
  const InfoOrdersOperator(
      {super.key, required this.id, required this.function});

  @override
  State<InfoOrdersOperator> createState() => _InfoOrdersOperatorState();
}

class _InfoOrdersOperatorState extends State<InfoOrdersOperator> {
  var data = {};
  bool loading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  TextEditingController _numerController = TextEditingController();
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getOrdersByIDOperator(widget.id);
    data = response;

    //
    _controllers.editControllers(response);
    setState(() {
      _numerController.text = data['attributes']['TelefonoShipping'].toString();
    });
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
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  var response = await Connections()
                                      .getSellersByIdMasterOnly(
                                          "${data['attributes']['IdComercial'].toString()}");
                                  // ignore: use_build_context_synchronously
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        var datos = data;
                                        return UpdateStatusOperatorHistorial(
                                            numberTienda: response['vendedores']
                                                    [0]['Telefono2']
                                                .toString(),
                                            codigo:
                                                "${data['attributes']['users'] != null && data['attributes']['users'].toString() != "[]" ? data['attributes']['users']['data'][0]['attributes']['vendedores']['data'][0]['attributes']['Nombre_Comercial'] : "NaN"}-${data['attributes']['NumeroOrden']}",
                                            numberCliente:
                                                "${data['attributes']['TelefonoShipping']}",
                                            id: widget.id,
                                            novedades: data['attributes']
                                                ['novedades']['data'],
                                            currentStatus: '');
                                      });

                                  Navigator.pop(context);

                                  widget.function();
                                },
                                child: Text(
                                  "Estado Entrega",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha: ${data['attributes']['Marca_Tiempo_Envio'].toString().split(" ")[0]}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          // "  Código: ${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden'].toString()}",
                          "  Código: ${data['attributes']['users']['data'] != null ? data['attributes']['users']['data'][0]['attributes']['vendedores']['data'][0]['attributes']['Nombre_Comercial'] : data['attributes']['Tienda_Temporal'].toString()}-${data['attributes']['NumeroOrden']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Ciudad: ${_controllers.ciudadEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Nombre Cliente: ${_controllers.nombreEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  DIRECCIÓN: ${_controllers.direccionEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  TELEFÓNO CLIENTE:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextField(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          controller: _numerController,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              getLoadingModal(context, false);
                              var reponse = await Connections()
                                  .updateOrderInfoNumberOperator(
                                      _numerController.text, widget.id);
                              Navigator.pop(context);
                              await loadData();
                            },
                            child: Text(
                              "ACTUALIZAR NÚMERO",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Cantidad: ${_controllers.cantidadEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto: ${_controllers.productoEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Producto Extra: ${_controllers.productoExtraEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Precio Total: ${_controllers.precioTotalEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Observación: ${data['attributes']['Observacion'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Comentario: ${data['attributes']['Comentario'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Status: ${data['attributes']['Status'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
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
}
