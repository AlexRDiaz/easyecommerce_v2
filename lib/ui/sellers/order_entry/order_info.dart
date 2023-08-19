import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/main.dart';

class OrderInfo extends StatefulWidget {
  final String id;
  final int index;
  final String codigo;
  final Function(BuildContext, int) sumarNumero;

  const OrderInfo(
      {super.key,
      required this.id,
      required this.index,
      required this.sumarNumero,
      required this.codigo});

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  var data = {};
  bool loading = true;
  OrderEntryControllers _controllers = OrderEntryControllers();
  String estadoEntrega = "";
  String estadoLogistic = "";

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getOrdersByIDSeller(widget.id);
    // data = response;
    data = response;
    _controllers.editControllers(response);
    setState(() {
      estadoEntrega = data['attributes']['Status'].toString();
      estadoLogistic = data['attributes']['Estado_Logistico'].toString();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
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
                          estadoLogistic == "ENVIADO"
                              ? Container()
                              : ElevatedButton(
                                  onPressed: () async {
                                    var response = await Connections()
                                        .updateOrderInteralStatus(
                                            "NO DESEA", widget.id);

                                    //  Navigator.pop(context);
                                    widget.sumarNumero(context, widget.index);

                                    setState(() {});
                                    //loadData();
                                    //Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "No Desea",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                var response = await Connections()
                                    .updateOrderInteralStatus(
                                        "CONFIRMADO", widget.id);
                                setState(() {});
                                await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return RoutesModal(
                                        idOrder: widget.id,
                                        someOrders: false,
                                        phoneClient: data['attributes']
                                                ['TelefonoShipping']
                                            .toString(),
                                        codigo: widget.codigo,
                                      );
                                    });
                                loadData();
                              },
                              child: Text(
                                "Confirmar",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                getLoadingModal(context, false);

                                await _controllers.updateInfo(
                                    id: widget.id,
                                    success: () async {
                                      Navigator.pop(context);
                                      AwesomeDialog(
                                        width: 500,
                                        context: context,
                                        dialogType: DialogType.success,
                                        animType: AnimType.rightSlide,
                                        title: 'Guardado',
                                        desc: '',
                                        btnCancel: Container(),
                                        btnOkText: "Aceptar",
                                        btnOkColor: colors.colorGreen,
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {},
                                      ).show();
                                      await loadData();
                                    },
                                    error: () {
                                      Navigator.pop(context);

                                      AwesomeDialog(
                                        width: 500,
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.rightSlide,
                                        title: 'Data Incorrecta',
                                        desc: 'Vuelve a intentarlo',
                                        btnCancel: Container(),
                                        btnOkText: "Aceptar",
                                        btnOkColor: colors.colorGreen,
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {},
                                      ).show();
                                    });
                              },
                              child: Text(
                                "Guardar",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['attributes']['NumeroOrden'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Fecha: ${data['attributes']['pedido_fecha']['data']['attributes']['Fecha'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _modelTextField(
                          text: "Ciudad",
                          controller: _controllers.ciudadEditController),
                      _modelTextField(
                          text: "Nombre Cliente",
                          controller: _controllers.nombreEditController),
                      _modelTextField(
                          text: "Dirección",
                          controller: _controllers.direccionEditController),
                      _modelTextField(
                          text: "Teléfono",
                          controller: _controllers.telefonoEditController),
                      _modelTextField(
                          text: "Cantidad",
                          controller: _controllers.cantidadEditController),
                      _modelTextField(
                          text: "Producto",
                          controller: _controllers.productoEditController),
                      _modelTextField(
                          text: "Producto Extra",
                          controller: _controllers.productoExtraEditController),
                      _modelTextField(
                          text: "Precio Total",
                          controller: _controllers.precioTotalEditController),
                      _modelTextField(
                          text: "Observacion",
                          controller: _controllers.observacionEditController),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Confirmado?: ${data['attributes']['Estado_Interno'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Estado Entrega: $estadoEntrega",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Estado Logístico: $estadoLogistic",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Ciudad: ${data['attributes']['ruta']['data'] != null ? data['attributes']['ruta']['data']['attributes']['Titulo'].toString() : ''}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Transportadora: ${data['attributes']['transportadora']['data'] != null ? data['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
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
