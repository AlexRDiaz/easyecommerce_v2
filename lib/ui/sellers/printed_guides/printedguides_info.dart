import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';

class PrintedGuideInfoSeller extends StatefulWidget {
  final String id;
  const PrintedGuideInfoSeller({super.key, required this.id});

  @override
  State<PrintedGuideInfoSeller> createState() => _PrintedGuideInfoStateSeller();
}

class _PrintedGuideInfoStateSeller extends State<PrintedGuideInfoSeller> {
  var data = {};
  bool loading = true;
  var idUser = sharedPrefs!.getString("id");

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = await Connections().getOrdersByIDLogistic(widget.id);
    var response = await Connections().getOrderByIDHistoryLaravel(widget.id);
    data = response;
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: loading == true
            ? Container()
            : ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      _buttons(),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Código: ${data['users'][0]['vendedores'][0]['nombre_comercial'].toString()}-${data['numero_orden']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Ciudad: ${data['ciudad_shipping'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Nombre Cliente: ${data['nombre_shipping'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Dirección: ${data['direccion_shipping'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Cantidad: ${data['cantidad_total'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Producto: ${data['producto_p'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Producto Extra: ${data['producto_extra'] != null ? data['producto_extra'].toString() : ''}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Precio Total: ${data['precio_total'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Estado: ${data['estado_interno'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Estado Logistico: ${data['estado_logistico'].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Transportadora: ${data['transportadora'] != null && data['transportadora'].isNotEmpty ? data['transportadora'][0]['nombre'].toString() : data['pedido_carrier'].isNotEmpty ? data['pedido_carrier'][0]['carrier']['name'].toString() : ""}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }

  Container _buttons() {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ElevatedButton(
          //     onPressed: () async {
          //       getLoadingModal(context, false);
          //       var response = await Connections()
          //           .updateOrderInteralStatusLogistic("NO DESEA", widget.id);
          //       Navigator.pop(context);

          //       setState(() {});

          //       await loadData();
          //     },
          //     child: Text(
          //       "NO DESEA",
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     )),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                // var responsereduceStock = await Connections()
                //     .updateProductVariantStock(data['sku'],
                //         data['cantidad_total'], 0, data['id_comercial']);

                // if (responsereduceStock == 0) {
                var responseL = await Connections().updateOrderWithTime(
                    widget.id.toString(),
                    "estado_logistico:ENVIADO",
                    idUser,
                    "",
                    "");
                // }

                Navigator.pop(context);

                setState(() {});

                await loadData();
                // if (responsereduceStock ==
                //     "No Dispone de Stock en la Reserva Comuniquese con el Proveedor") {
                //   // ignore: use_build_context_synchronously
                //   SnackBarHelper.showErrorSnackBar(
                //       context, "$responsereduceStock");
                // }
              },
              child: const Text(
                "MARCAR ENVIADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                var response = await Connections()
                    .updatenueva(widget.id, {"estado_interno": "RECHAZADO"});
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: const Text(
                "RECHAZADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}
