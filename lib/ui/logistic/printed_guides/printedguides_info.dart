import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';

class PrintedGuideInfo extends StatefulWidget {
  final String id;
  const PrintedGuideInfo({super.key, required this.id});

  @override
  State<PrintedGuideInfo> createState() => _PrintedGuideInfoState();
}

class _PrintedGuideInfoState extends State<PrintedGuideInfo> {
  var data = {};
  bool loading = true;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getOrdersByIDLogistic(widget.id);
    // data = response;
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
                      SizedBox(
                        height: 10,
                      ),
                      _buttons(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Código: ${data['attributes']['Name_Comercial'].toString()}-${data['attributes']['NumeroOrden']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Ciudad: ${data['attributes']['CiudadShipping'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Nombre Cliente: ${data['attributes']['NombreShipping'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Dirección: ${data['attributes']['DireccionShipping'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Cantidad: ${data['attributes']['Cantidad_Total'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Producto: ${data['attributes']['ProductoP'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Producto Extra: ${data['attributes']['ProductoExtra'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Precio Total: ${data['attributes']['PrecioTotal'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Estado: ${data['attributes']['Estado_Interno'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Estado Logistico: ${data['attributes']['Estado_Logistico'].toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        " Transportadora: ${data['attributes']['transportadora']['data'] != null ? data['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
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
      margin: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);
                var response = await Connections()
                    .updateOrderInteralStatusLogistic(
                        "NO DESEA", widget.id);
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: Text(
                "NO DESEA",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);

                var response = await Connections()
                    .updateOrderLogisticStatusPrint(
                        "ENVIADO",widget.id);
                Navigator.pop(context);

                setState(() {});

                await loadData();
              },
              child: Text(
                "MARCAR ENVIADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}
