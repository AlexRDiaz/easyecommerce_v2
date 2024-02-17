import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/routes/sub_routes_new.dart';

class MyOrdersPRVInfoNew extends StatefulWidget {
  final Map order;
  final int index;
  // final String codigo;
  final Function(BuildContext, int) sumarNumero;
  final List data;
  const MyOrdersPRVInfoNew(
      {super.key,
      required this.order,
      required this.index,
      required this.sumarNumero,
      // required this.codigo,
      required this.data});

  @override
  State<MyOrdersPRVInfoNew> createState() => _MyOrdersPRVInfoNewState();
}

class _MyOrdersPRVInfoNewState extends State<MyOrdersPRVInfoNew> {
  var data = {};
  bool isLoading = true;
  OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  String subRoute = "";
  String operator = "";

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

    _controllers.editControllers(data);

    setState(() {
      subRoute = data['sub_ruta'] != null && data['sub_ruta'].toString() != "[]"
          ? data['sub_ruta'][0]['titulo'].toString()
          : "";
      operator = data['operadore'].toString() != null &&
              data['operadore'].toString().isNotEmpty
          ? data['operadore'] != null &&
                  data['operadore'].isNotEmpty &&
                  data['operadore'][0]['up_users'] != null &&
                  data['operadore'][0]['up_users'].isNotEmpty &&
                  data['operadore'][0]['up_users'][0]['username'] != null
              ? data['operadore'][0]['up_users'][0]['username']
              : ""
          : "";
    });

    setState(() {
      isLoading = false;
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    var response =
        await Connections().getOrderByIDHistoryLaravel(widget.order['id']);
    _controllers.editControllers(response);

    setState(() {
      subRoute =
          response['sub_ruta'] != null && data['sub_ruta'].toString() != "[]"
              ? response['sub_ruta'][0]['titulo'].toString()
              : "";
      operator = response['operadore'].toString() != null &&
              response['operadore'].toString().isNotEmpty
          ? response['operadore'] != null &&
                  response['operadore'].isNotEmpty &&
                  response['operadore'][0]['up_users'] != null &&
                  response['operadore'][0]['up_users'].isNotEmpty &&
                  response['operadore'][0]['up_users'][0]['username'] != null
              ? response['operadore'][0]['up_users'][0]['username']
              : ""
          : "";
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyleText = TextStyle(
        // fontWeight: FontWeight.bold,
        fontSize: 18);

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
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
              padding: EdgeInsets.fromLTRB(30, 1, 30, 10),
              child: SingleChildScrollView(
                child: isLoading == true
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
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return SubRoutesModalNew(
                                            idOrder: data['id'],
                                            someOrders: false,
                                          );
                                        });

                                    setState(() {});
                                    // loadData();
                                    await getData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFF031749),
                                    ),
                                  ),
                                  child: const Text(
                                    "Asignar SubRuta",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Código: ${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            // "  Fecha: ${data['attributes']['pedido_fecha']['data']['attributes']['Fecha'].toString()}",
                            "Fecha Ingreso: ${data['marca_t_i'].toString()}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Nombre Cliente: ${_controllers.nombreEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Ciudad: ${_controllers.ciudadEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "DIRECCIÓN: ${_controllers.direccionEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "TELEFÓNO CLIENTE: ${_controllers.telefonoEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Sub Ruta: $subRoute",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Operador: $operator",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Cantidad: ${_controllers.cantidadEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Producto: ${_controllers.productoEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Producto Extra: ${_controllers.productoExtraEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Precio Total: ${_controllers.precioTotalEditController.text}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Status: ${data['status'].toString()}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Confirmado?: ${data['estado_interno'].toString()}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Estado Logistico: ${data['estado_logistico'].toString()}",
                            style: customTextStyleText,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
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
}
