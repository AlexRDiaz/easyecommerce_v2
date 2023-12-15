import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:provider/provider.dart';

class InfoTransportationBilling extends StatefulWidget {
  final String id;
  const InfoTransportationBilling({super.key, required this.id});

  @override
  State<InfoTransportationBilling> createState() =>
      _InfoTransportationBilling();
}

class _InfoTransportationBilling extends State<InfoTransportationBilling> {
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
    var response = await Connections().getOrdersByIDTransport(widget.id);
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
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: ColorsSystem().colorBlack, width: 2.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "  Fecha: ${data['attributes']['Marca_Tiempo_Envio'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Fecha de Entrega: ${data['attributes']['Fecha_Entrega'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Código: ${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle, // Icono de usuario
                                color: ColorsSystem()
                                    .colorSelectMenu, // Color del ícono
                                size: 24, // Tamaño del ícono
                              ),
                              SizedBox(
                                  width:
                                      10), // Espacio entre el icono y el texto
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
                          "  TELEFÓNO CLIENTE: ${_controllers.telefonoEditController.text}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded, // Icono de usuario
                                color: ColorsSystem()
                                    .colorSelectMenu, // Color del ícono
                                size: 24, // Tamaño del ícono
                              ),
                              SizedBox(
                                  width:
                                      10), // Espacio entre el icono y el texto
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
                          "  Status: ${data['attributes']['Status'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Tipo de Pago: ${data['attributes']['TipoPago'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Operador: ${data['attributes']['operadore']['data'] != null ? data['attributes']['operadore']['data']['attributes']['user']['data']['attributes']['username'] : "".toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado Devolución: ${data['attributes']['Estado_Devolucion'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Estado de Pago: ${data['attributes']['Estado_Pagado'].toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // ! modificacion aqui para el comentario
                        Text(
                          "  Comentario: ${data['attributes']['Comentario'].toString()}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            // color: Colors.red
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "  Archivo:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_notifications, // Icono de usuario
                                color: ColorsSystem()
                                    .colorSelectMenu, // Color del ícono
                                size: 24, // Tamaño del ícono
                              ),
                              SizedBox(
                                  width:
                                      10), // Espacio entre el icono y el texto
                              Text(
                                "NOVEDADES: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: ColorsSystem().colorSelectMenu,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                            height: 500,
                            width: 500,
                            child: ListView.builder(
                                itemCount: data['attributes']['novedades']
                                        ['data']
                                    .length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Radio de esquina para hacerlo redondeado
                                        border: Border.all(
                                          color: ColorsSystem()
                                              .colorBlack, // Color del borde
                                          width: 2.0, // Ancho del borde
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Comentario Novedad:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.red)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              " ${data['attributes']['novedades']['data'][index]['attributes']['comment']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                // color: Colors.red
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Intento:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.red)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${data['attributes']['novedades']['data'][index]['attributes']['try']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                // color: Colors.red
                                              ),
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.all(30),
                                              child: Image.network(
                                                "$generalServer${data['attributes']['novedades']['data'][index]['attributes']['url_image'].toString()}",
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                })),

                        SizedBox(
                          height: 20,
                        ),
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
