import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/rich_text.dart';
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
      subRoute = response['sub_ruta'] != null &&
              response['sub_ruta'].toString() != "[]"
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
    double fontSize = 18;

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
                          RichTextTitleContent(
                            title: "Código",
                            content:
                                "${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden'].toString()}",
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Fecha Envio",
                            content: data['marca_tiempo_envio'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Nombre Cliente",
                            content: _controllers.nombreEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Ciudad",
                            content: _controllers.ciudadEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Dirección",
                            content: _controllers.direccionEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Telefóno cliente",
                            content: _controllers.telefonoEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Sub Ruta",
                            content: subRoute,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Operador",
                            content: operator,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Cantidad",
                            content: _controllers.cantidadEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Producto",
                            content: _controllers.productoEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Producto Extra",
                            content:
                                _controllers.productoExtraEditController.text,
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Precio Total",
                            content:
                                "\$ ${_controllers.precioTotalEditController.text}",
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Status",
                            content: data['status'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Confirmado?",
                            content: data['estado_interno'].toString(),
                          ),
                          const SizedBox(height: 20),
                          RichTextTitleContent(
                            title: "Estado Logistico",
                            content: data['estado_logistico'].toString(),
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
}
