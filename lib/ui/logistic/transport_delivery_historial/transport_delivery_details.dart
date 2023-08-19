import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes_historial.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransportDeliveryHistoryDetails extends StatefulWidget {
  final String id;
  const TransportDeliveryHistoryDetails({super.key, required this.id});

  @override
  State<TransportDeliveryHistoryDetails> createState() =>
      _TransportDeliveryHistoryDetailsState();
}

class _TransportDeliveryHistoryDetailsState
    extends State<TransportDeliveryHistoryDetails> {
  ScreenshotController screenshotController = ScreenshotController();

  String codigo = "";
  TextEditingController _marcaTiempo = TextEditingController();
  TextEditingController _fecha = TextEditingController();
  String devolucionLogistica = "";
  TextEditingController _cantidad = TextEditingController();
  TextEditingController _precioTotal = TextEditingController();
  TextEditingController _producto = TextEditingController();
  TextEditingController _direccion = TextEditingController();
  TextEditingController _ciudad = TextEditingController();
  TextEditingController _comentario = TextEditingController();
  TextEditingController _tipoDePago = TextEditingController();
  TextEditingController _ruta = TextEditingController();
  TextEditingController _transportadora = TextEditingController();
  TextEditingController _subRuta = TextEditingController();
  TextEditingController _operador = TextEditingController();
  TextEditingController _vendedor = TextEditingController();
  TextEditingController _fechaEntrega = TextEditingController();
  TextEditingController _nombreCliente = TextEditingController();
  TextEditingController _productoExtra = TextEditingController();
  TextEditingController _confirmado = TextEditingController();
  TextEditingController _fechaConfirmacion = TextEditingController();
  TextEditingController _estadoLogistico = TextEditingController();
  TextEditingController _status = TextEditingController();
  TextEditingController _estadoDeposito = TextEditingController();
  TextEditingController _observacion = TextEditingController();
  TextEditingController _telefonoCliente = TextEditingController();
  TextEditingController _costoTrans = TextEditingController();
  TextEditingController _costoOperador = TextEditingController();
  TextEditingController _estadoDevolucion = TextEditingController();
  TextEditingController _marcaTiempoEnvio = TextEditingController();
  TextEditingController _estadoPago = TextEditingController();

  var data = {};
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getOrderByIDHistory(widget.id);
    codigo =
        '${response['attributes']['users']['data'] != null ? response['attributes']['users']['data'][0]['attributes']['vendedores']['data'][0]['attributes']['Nombre_Comercial'] : response['attributes']['Tienda_Temporal'].toString()}-${response['attributes']['NumeroOrden']}';
    _marcaTiempo.text = '${response['attributes']['Marca_T_I'].toString()}';
    _fecha.text =
        '${response['attributes']['pedido_fecha']['data']['attributes']['Fecha'].toString()}';
    _cantidad.text = "${response['attributes']['Cantidad_Total'].toString()}";
    _precioTotal.text = "${response['attributes']['PrecioTotal'].toString()}";
    _producto.text = "${response['attributes']['ProductoP'].toString()}";
    _direccion.text =
        "${response['attributes']['DireccionShipping'].toString()}";
    _ciudad.text = "${response['attributes']['CiudadShipping'].toString()}";
    _comentario.text = "${response['attributes']['Comentario'].toString()}";
    _tipoDePago.text = "${response['attributes']['TipoPago'].toString()}";
    _ruta.text = response['attributes']['ruta'] != null
        ? response['attributes']['ruta']['data'] != null
            ? response['attributes']['ruta']['data']['attributes']['Titulo']
                .toString()
            : ""
        : "";
    _transportadora.text = response['attributes']['transportadora'] != null
        ? response['attributes']['transportadora']['data'] != null
            ? response['attributes']['transportadora']['data']['attributes']
                    ['Nombre']
                .toString()
            : ""
        : "";
    _subRuta.text = response['attributes']['sub_ruta'] != null
        ? response['attributes']['sub_ruta']['data'] != null
            ? response['attributes']['sub_ruta']['data']['attributes']['Titulo']
                .toString()
            : ""
        : "";
    _operador.text = response['attributes']['operadore'] != null
        ? response['attributes']['operadore']['data'] != null
            ? response['attributes']['operadore']['data']['attributes']['user']
                    ['data']['attributes']['username']
                .toString()
            : ""
        : "";
    _vendedor.text = response['attributes']['Name_Comercial'].toString();
    _fechaEntrega.text = response['attributes']['Fecha_Entrega'].toString();
    _nombreCliente.text = response['attributes']['NombreShipping'].toString();
    _productoExtra.text =
        "${response['attributes']['ProductoExtra'].toString()}";
    _confirmado.text = response['attributes']['Estado_Interno'].toString();
    _fechaConfirmacion.text =
        response['attributes']['Fecha_Confirmacion'].toString();
    _estadoLogistico.text =
        response['attributes']['Estado_Logistico'].toString();
    _status.text = response['attributes']['Status'].toString();
    _estadoPago.text = response['attributes']['Estado_Pagado'].toString();
    _observacion.text = response['attributes']['Observacion'].toString();
    _telefonoCliente.text =
        response['attributes']['TelefonoShipping'].toString();
    _costoTrans.text = response['attributes']['transportadora'] != null
        ? response['attributes']['transportadora']['data'] != null
            ? response['attributes']['transportadora']['data']['attributes']
                    ['Costo_Transportadora']
                .toString()
            : ""
        : "";
    _costoOperador.text = response['attributes']['operadore'] != null
        ? response['attributes']['operadore']['data'] != null
            ? response['attributes']['operadore']['data']['attributes']
                    ['Costo_Operador']
                .toString()
            : ""
        : "";
    _estadoDevolucion.text =
        response['attributes']['Estado_Devolucion'].toString();
    _marcaTiempoEnvio.text =
        response['attributes']['Marca_Tiempo_Envio'].toString();

    _estadoDeposito.text =
        response['attributes']['Estado_Pago_Logistica'].toString();
    devolucionLogistica =
        response['attributes']['Estado_Devolucion'].toString();
    setState(() {
      data = response;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.black;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(),
        centerTitle: true,
        title: const Text(
          "Detalles",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  runSpacing: 10.0,
                  spacing: 10.0,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: (context),
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    width: 500,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.close)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return RoutesModal(
                                                        idOrder: widget.id,
                                                        someOrders: false,
                                                        phoneClient: "",
                                                        codigo: "");
                                                  });

                                              setState(() {});
                                              await loadData();
                                            },
                                            child: Text(
                                              "Asignar Ruta",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return SubRoutesModalHistorial(
                                                      idOrder: widget.id,
                                                      someOrders: false,
                                                    );
                                                  });

                                              setState(() {});
                                              await loadData();
                                            },
                                            child: Text(
                                              "Asignar SubRuta y Operador",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              var response = await Connections()
                                                  .updateOrderLogisticStatus(
                                                      "IMPRESO", widget.id);
                                              await loadData();

                                              Navigator.pop(context);

                                              setState(() {});
                                            },
                                            child: Text(
                                              "IMPRESO",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);

                                              var response = await Connections()
                                                  .updateOrderLogisticStatusPrint(
                                                      "ENVIADO", widget.id);
                                              await loadData();
                                              Navigator.pop(context);

                                              setState(() {});
                                            },
                                            child: Text(
                                              "ENVIADO",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              var response = await Connections()
                                                  .getSellersByIdMasterOnly(
                                                      "${data['attributes']['IdComercial'].toString()}");
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return UpdateStatusOperatorHistorial(
                                                      numberTienda:
                                                          response['vendedores']
                                                                      [0]
                                                                  ['Telefono2']
                                                              .toString(),
                                                      codigo:
                                                          "${data['attributes']['Name_Comercial']}-${data['attributes']['NumeroOrden']}",
                                                      numberCliente:
                                                          "${data['attributes']['TelefonoShipping']}",
                                                      id: widget.id,
                                                      novedades:
                                                          data['attributes']
                                                                  ['novedades']
                                                              ['data'],
                                                    );
                                                  });
                                              await loadData();
                                            },
                                            child: Text(
                                              "Estado Entrega",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              const double point = 1.0;
                                              const double inch = 72.0;
                                              const double cm = inch / 2.54;
                                              const double mm = inch / 25.4;
                                              getLoadingModal(context, false);
                                              final doc = pw.Document();

                                              final capturedImage =
                                                  await screenshotController
                                                      .captureFromWidget(
                                                          Container(
                                                              child: ModelGuide(
                                                address: data['attributes']
                                                        ['DireccionShipping']
                                                    .toString(),
                                                city: data['attributes']
                                                        ['CiudadShipping']
                                                    .toString(),
                                                date: data['attributes']
                                                                ['pedido_fecha']
                                                            ['data']
                                                        ['attributes']['Fecha']
                                                    .toString(),
                                                extraProduct: data['attributes']
                                                        ['ProductoExtra']
                                                    .toString(),
                                                idForBarcode: widget.id,
                                                name: data['attributes']
                                                        ['NombreShipping']
                                                    .toString(),
                                                numPedido: codigo.toString(),
                                                observation: data['attributes']
                                                        ['Observacion']
                                                    .toString(),
                                                phone: data['attributes']
                                                        ['TelefonoShipping']
                                                    .toString(),
                                                price: data['attributes']
                                                        ['PrecioTotal']
                                                    .toString(),
                                                product: data['attributes']
                                                        ['ProductoP']
                                                    .toString(),
                                                qrLink: data['attributes']
                                                            ['users'] !=
                                                        null
                                                    ? data['attributes']['users']
                                                                        ['data'][0]
                                                                    ['attributes']
                                                                ['vendedores']['data'][0]
                                                            [
                                                            'attributes']['Url_Tienda']
                                                        .toString()
                                                    : "",
                                                quantity: data['attributes']
                                                        ['Cantidad_Total']
                                                    .toString(),
                                                transport:
                                                    "${data['attributes']['transportadora']['data'] != null ? data['attributes']['transportadora']['data']['attributes']['Nombre'].toString() : ''}",
                                              )));

                                              doc.addPage(pw.Page(
                                                pageFormat: PdfPageFormat(
                                                    21.0 * cm, 21.0 * cm,
                                                    marginAll: 0.1 * cm),
                                                build: (pw.Context context) {
                                                  return pw.Row(
                                                    children: [
                                                      pw.Image(
                                                          pw.MemoryImage(
                                                              capturedImage),
                                                          fit:
                                                              pw.BoxFit.contain)
                                                    ],
                                                  );
                                                },
                                              ));
                                              // var response = await Connections()
                                              //     .updateOrderLogisticStatus(
                                              //         "IMPRESO", Get.parameters['id'].toString());
                                              await Printing.layoutPdf(
                                                  onLayout: (PdfPageFormat
                                                          format) async =>
                                                      await doc.save());
                                              setState(() {});
                                              Navigator.pop(context);
                                              await loadData();
                                            },
                                            child: Text(
                                              "Imprimir",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          "Logistico",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: (context),
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    width: 500,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.close)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              var response = await Connections()
                                                  .updateOrderInteralStatusHistorial(
                                                      "PENDIENTE", widget.id);
                                              Navigator.pop(context);
                                              await loadData();
                                            },
                                            child: Text(
                                              "Pendiente",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              var response = await Connections()
                                                  .updateOrderInteralStatusHistorial(
                                                      "CONFIRMADO", widget.id);
                                              Navigator.pop(context);
                                              await loadData();
                                            },
                                            child: Text(
                                              "Confirmar",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              var response = await Connections()
                                                  .updateOrderInteralStatusHistorial(
                                                      "NO DESEA", widget.id);
                                              Navigator.pop(context);
                                              await loadData();
                                            },
                                            child: Text(
                                              "No Desea",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          "Confirmado",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),

                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: (context),
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    width: 500,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.close)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              await Connections()
                                                  .updateOrderReturnAll(
                                                      widget.id);
                                              await loadData();
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "PENDIENTE",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              await Connections()
                                                  .updateOrderReturnOperator(
                                                      widget.id);
                                              await loadData();
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "En Oficina",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              getLoadingModal(context, false);
                                              await Connections()
                                                  .updateOrderReturnLogistic(
                                                      widget.id);
                                              await loadData();
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "En Bodega",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          "Devolución",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: (context),
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    width: 500,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.close)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    TextEditingController
                                                        _rechazado =
                                                        TextEditingController();
                                                    _rechazado.text = data[
                                                                'attributes'][
                                                            'ComentarioRechazado']
                                                        .toString();

                                                    return AlertDialog(
                                                      content: Container(
                                                        width: 400,
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  getLoadingModal(
                                                                      context,
                                                                      false);
                                                                  var valorTemporal =
                                                                      0.0;

                                                                  var data = await Connections()
                                                                      .updateOrderPendienteStateLogisticUser(
                                                                          widget
                                                                              .id);

                                                                  Navigator.pop(
                                                                      context);

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "MARCAR PENDIENTE PEDIDOS DIFERENTE A ENTREGADO",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .blueAccent),
                                                                )),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(),
                                                            TextButton(
                                                                onPressed: () {
                                                                  launchUrl(
                                                                      Uri.parse(
                                                                          "$generalServer${data['attributes']['Url_P_L_Foto']}"));
                                                                },
                                                                child: Text(
                                                                  "VER COMPROBANTE",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black),
                                                                )),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  getLoadingModal(
                                                                      context,
                                                                      false);
                                                                  var valorTemporal =
                                                                      0.0;

                                                                  var data = await Connections()
                                                                      .updateOrderPayStateLogisticUser(
                                                                          widget
                                                                              .id);

                                                                  Navigator.pop(
                                                                      context);

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "MARCAR RECIBIDO",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .greenAccent),
                                                                )),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(),
                                                            Text(
                                                              "Para marcar como rechazado primero llenar el campo de texto y luego aplastar el botón rechazado",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  _rechazado,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              decoration:
                                                                  InputDecoration(
                                                                      hintText:
                                                                          "Comentario de Rechazado"),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  getLoadingModal(
                                                                      context,
                                                                      false);

                                                                  var data = await Connections().updateOrderPayStateLogisticUserRechazado(
                                                                      widget.id,
                                                                      _rechazado
                                                                          .text);

                                                                  Navigator.pop(
                                                                      context);

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "RECHAZADO",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .redAccent),
                                                                )),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Divider(),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "SALIR",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                              await loadData();
                                            },
                                            child: Text(
                                              "LOGISTICA",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          "PAGO",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),

                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: (context),
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    width: 500,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.close)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              var _url = Uri.parse(
                                                  """https://api.whatsapp.com/send?phone=${_telefonoCliente.text.toString()}""");
                                              if (!await launchUrl(_url)) {
                                                throw Exception(
                                                    'Could not launch $_url');
                                              }
                                            },
                                            child: Text(
                                              "WhatsApp",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              var _url = Uri(
                                                  scheme: 'tel',
                                                  path:
                                                      '${_telefonoCliente.text.toString()}');

                                              if (!await launchUrl(_url)) {
                                                throw Exception(
                                                    'Could not launch $_url');
                                              }
                                            },
                                            child: Text(
                                              "Llamada",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text(
                          "Llamadas",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),

///////////////////////////////////////divicion
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                _modelText("Código", codigo),
                _modelText("Marca de Tiempo", _marcaTiempo.text),
                _modelText("Fecha", _fecha.text),
                _modelTextField("Cantidad", _cantidad),
                _modelTextField("Precio Total", _precioTotal),
                _modelTextField("Producto", _producto),
                _modelTextField("Dirección", _direccion),
                _modelTextField("Ciudad", _ciudad),
                _modelTextField("Comentario", _comentario),
                _modelTextField("Tipo de Pago", _tipoDePago),
                _modelText("Ruta Asignada", _ruta.text),
                _modelText("Transportadora", _transportadora.text),
                _modelText("Sub Ruta", _subRuta.text),
                _modelText("Operador", _operador.text),
                _modelText("Vendedor", _vendedor.text),
                _modelText("Fecha Entrega", _fechaEntrega.text),
                _modelTextField("Nombre Cliente", _nombreCliente),
                _modelTextField("Producto Extra", _productoExtra),
                _modelText("Confirmado?", _confirmado.text),
                _modelText("Fecha Confirmación", _fechaConfirmacion.text),
                _modelText("Estado Logistico", _estadoLogistico.text),
                _modelText("Status", _status.text),
                _modelText("Estado Deposito", _estadoDeposito.text),
                _modelTextField("Observación", _observacion),
                _modelTextField("Teléfono Cliente", _telefonoCliente),
                _modelText("Costo Transportadora", _costoTrans.text),
                _modelText("Costo Operador", _costoOperador.text),
                _modelText("Estado Devolución", _estadoDevolucion.text),
                _modelText("Marca Tiempo Envio", _marcaTiempoEnvio.text),
                _modelText("Estado Pago", _estadoPago.text),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () async {
                      getLoadingModal(context, false);
                      await Connections().updateOrderInfoHistorial(
                          _cantidad.text,
                          _precioTotal.text,
                          _producto.text,
                          _direccion.text,
                          _ciudad.text,
                          _comentario.text,
                          _tipoDePago.text,
                          _nombreCliente.text,
                          _productoExtra.text,
                          _observacion.text,
                          _telefonoCliente.text,
                          widget.id);
                      Navigator.pop(context);
                      await loadData();
                    },
                    child: Text(
                      "GUARDAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _modelTextField(text, controller) {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$text",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          TextField(
            controller: controller,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Container _modelText(text, data) {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$text: $data",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
