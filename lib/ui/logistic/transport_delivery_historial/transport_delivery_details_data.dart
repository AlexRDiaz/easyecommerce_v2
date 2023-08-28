import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:frontend/ui/widgets/routes/sub_routes_historial.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
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

class TransportDeliveryHistoryDetailsData extends StatefulWidget {
  final Map data;
  const TransportDeliveryHistoryDetailsData({super.key, required this.data});

  @override
  State<TransportDeliveryHistoryDetailsData> createState() =>
      _TransportDeliveryHistoryDetailsDataState();
}

class _TransportDeliveryHistoryDetailsDataState
    extends State<TransportDeliveryHistoryDetailsData> {
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
  // @override
  // void didChangeDependencies() {
  //   loadTextEdtingControllers();
  //   super.didChangeDependencies();
  // }
  @override
  void initState() {
    loadTextEdtingControllers(widget.data);

    super.initState();
  }

  loadData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var response =
          await Connections().getOrderByIDHistoryLaravel(widget.data['id']);

      setState(() {
        data = response;
        loadTextEdtingControllers(data);
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
      setState(() {});
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      SnackBarHelper.showErrorSnackBar(context, "Error al guardar los datos");
    }
  }

  loadTextEdtingControllers(newData) {
    data = newData;
    codigo =
        "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal']}-${data['numero_orden']}";
    _marcaTiempo.text = data['marca_t_i'];
    _fecha.text = data['marca_t_i'].toString().split(' ')[0].toString();
    _cantidad.text = data['cantidad_total'].toString();
    _precioTotal.text = data['precio_total'].toString();
    _producto.text = data['producto_p'].toString();
    _direccion.text = data['direccion_shipping'].toString();
    _ciudad.text = data['ciudad_shipping'].toString();
    _comentario.text = data['comentario'].toString();
    _tipoDePago.text = data['tipo_pago'] ?? "ninguno";
    _ruta.text = data['ruta'] != null && data['ruta'].toString() != "[]"
        ? data['ruta'][0]['titulo'].toString()
        : "";
    _transportadora.text = data['transportadora'] != null &&
            data['transportadora'].toString() != "[]"
        ? data['transportadora'][0]['costo_transportadora'].toString()
        : "";
    _subRuta.text = //   data['sub_ruta'] != null &&
        data['sub_ruta'].toString() != "[]"
            ? data['sub_ruta'][0]['titulo'].toString()
            : "";
    _operador.text = //   data['operadore'] != null &&
        data['operadore'].toString() != "[]"
            ? data['operadore'][0]['up_users'][0]['username'].toString()
            : "";
    _vendedor.text = data['name_comercial'].toString();
    _fechaEntrega.text = data['fecha_entrega'].toString();
    _nombreCliente.text = data['nombre_shipping'].toString();
    _productoExtra.text = data['producto_extra'].toString();
    _confirmado.text = data['estado_interno'].toString();
    _fechaConfirmacion.text = data['fecha_confirmacion'].toString();
    _estadoLogistico.text = data['estado_logistico'].toString();
    _status.text = data['status'].toString();
    _estadoPago.text = data['estado_pagado'].toString();
    _observacion.text = data['observacion'].toString();
    _telefonoCliente.text = data['telefono_shipping'].toString();
    _costoTrans.text = data['transportadora'] != null &&
            data['transportadora'].toString() != "[]"
        ? data['transportadora'][0]['nombre'].toString()
        : "";
    _costoOperador.text =
        data['operadore'] != null && data['operadore'].toString() != "[]"
            ? data['operadore'][0]['costo_operador'].toString()
            : "";
    _estadoDevolucion.text = data['estado_devolucion'].toString();
    _marcaTiempoEnvio.text = data['marca_tiempo_envio'].toString();

    _estadoDeposito.text = data['estado_pago_logistica'].toString();
    devolucionLogistica = data['estado_devolucion'].toString();

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
        color: Color.fromARGB(255, 206, 225, 235),
        width: double.infinity,
        height: double.infinity,
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
                              return logisticOptions(context);
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
                                content: confirmadoOptions(context),
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
                                          var response = await Connections()
                                              .updateOrderReturnAll(
                                                  widget.data['id']);

                                          Navigator.pop(context);
                                          showCustomModal(response, context);
                                          await Future.delayed(
                                              const Duration(seconds: 3), () {
                                            Navigator.pop(context);
                                          });
                                          await loadData();
                                        },
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "Pendiente",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          getLoadingModal(context, false);
                                          var response = await Connections()
                                              .updateOrderReturnOperator(
                                                  widget.data['id']);
                                          Navigator.pop(context);

                                          showCustomModal(response, context);
                                          await Future.delayed(
                                              const Duration(seconds: 3), () {
                                            Navigator.pop(context);
                                          });
                                          await loadData();
                                        },
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "En oficina",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          getLoadingModal(context, false);
                                          var response = await Connections()
                                              .updateOrderReturnLogistic(
                                                  widget.data['id']);

                                          Navigator.pop(context);
                                          showCustomModal(response, context);
                                          await Future.delayed(
                                              const Duration(seconds: 3), () {
                                            Navigator.pop(context);
                                          });
                                          await loadData();
                                        },
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "En Bodega",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                                _rechazado
                                                    .text = data['attributes']
                                                        ['ComentarioRechazado']
                                                    .toString();

                                                return AlertDialog(
                                                  content: Container(
                                                    width: 400,
                                                    height:
                                                        MediaQuery.of(context)
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
                                                                          .data[
                                                                              'id']
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
                                                              launchUrl(Uri.parse(
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
                                                                      widget.data[
                                                                          'id']);

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
                                                              color:
                                                                  Colors.black,
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

                                                              var data = await Connections()
                                                                  .updateOrderPayStateLogisticUserRechazado(
                                                                      widget.data[
                                                                          'id'],
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
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "LOGÍSTICA",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "WhatsApp",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              "Llamada",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      )
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
                    // await Connections().updateOrderInfoHistorial(
                    //     _cantidad.text,
                    //     _precioTotal.text,
                    //     _producto.text,
                    //     _direccion.text,
                    //     _ciudad.text,
                    //     _comentario.text,
                    //     _tipoDePago.text,
                    //     _nombreCliente.text,
                    //     _productoExtra.text,
                    //     _observacion.text,
                    //     _telefonoCliente.text,
                    //     widget.id);
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
    );
  }

  Container confirmadoOptions(BuildContext context) {
    return Container(
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
                      "PENDIENTE", widget.data['id']);
              Navigator.pop(context);

              showCustomModal(response, context);
              await Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context);
              });
              await loadData();
            },
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Center(
                child: Text(
                  "Pendiente",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              getLoadingModal(context, false);
              var response = await Connections()
                  .updateOrderInteralStatusHistorial(
                      "CONFIRMADO", widget.data['id']);
              Navigator.pop(context);

              showCustomModal(response, context);

              await Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context);
              });
              await loadData();
            },
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Center(
                child: Text(
                  "Confirmar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              getLoadingModal(context, false);
              var response = await Connections()
                  .updateOrderInteralStatusHistorial(
                      "NO DESEA", widget.data['id']);
              Navigator.pop(context);
              showCustomModal(response, context);
              await Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context);
              });
              await loadData();
            },
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Center(
                child: Text(
                  "No desea",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog logisticOptions(BuildContext context) {
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
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.close),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return RoutesModal(
                      idOrder: widget.data['id'],
                      someOrders: false,
                      phoneClient: "",
                      codigo: "",
                    );
                  },
                );

                setState(() {});
                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Asignar Ruta",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return SubRoutesModalHistorial(
                      idOrder: widget.data['id'],
                      someOrders: false,
                    );
                  },
                );

                setState(() {});
                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Asignar SubRuta y Operador",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);
                var response = await Connections().updateOrderLogisticStatus(
                  "IMPRESO",
                  widget.data['id'],
                );

                Navigator.pop(context);
                showCustomModal(response, context);
                await Future.delayed(const Duration(seconds: 3), () {
                  Navigator.pop(context);
                });

                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "IMPRESO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                getLoadingModal(context, false);
                var response =
                    await Connections().updateOrderLogisticStatusPrint(
                  "ENVIADO",
                  widget.data['id'],
                );
                Navigator.pop(context);
                showCustomModal(response, context);
                await Future.delayed(const Duration(seconds: 3), () {
                  Navigator.pop(context);
                });
                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "ENVIADO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var com = data['id_comercial'];
                var response = await Connections().getSellersByIdMasterOnly(
                  data['id_comercial'],
                );
                await showDialog(
                  context: context,
                  builder: (context) {
                    return UpdateStatusOperatorHistorial(
                      numberTienda:
                          response['vendedores'][0]['Telefono2'].toString(),
                      codigo:
                          "${data['name_comercial']}-${data['numero_orden']}",
                      numberCliente: "${data['telefono_shipping']}",
                      id: widget.data['id'].toString(),
                      novedades: data['novedades'],
                    );
                  },
                );
                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Estado Entrega",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                const double point = 1.0;
                const double inch = 72.0;
                const double cm = inch / 2.54;
                const double mm = inch / 25.4;
                getLoadingModal(context, false);
                final doc = pw.Document();

                final capturedImage =
                    await screenshotController.captureFromWidget(
                  Container(
                    child: ModelGuide(
                      address: data['direccion_shipping'].toString(),
                      city: data['ciudad_shipping'].toString(),
                      date: data['pedido_fecha'][0]['fecha'].toString(),
                      extraProduct: data['producto_extra'].toString(),
                      idForBarcode: widget.data['id'].toString(),
                      name: data['nombre_shipping'].toString(),
                      numPedido: codigo.toString(),
                      observation: data['observacion'].toString(),
                      phone: data['telefono_shipping'].toString(),
                      price: data['precio_total'].toString(),
                      product: data['producto_p'].toString(),
                      qrLink: data['users'] != null
                          ? data['users'][0]['vendedores'][0]['url_tienda']
                              .toString()
                          : "",
                      quantity: data['cantidad_total'].toString(),
                      transport:
                          "${data['transportadora'] != null ? data['transportadora'][0]['nombre'].toString() : ''}",
                    ),
                  ),
                );

                doc.addPage(
                  pw.Page(
                    pageFormat: PdfPageFormat(21.0 * cm, 21.0 * cm,
                        marginAll: 0.1 * cm),
                    build: (pw.Context context) {
                      return pw.Row(
                        children: [
                          pw.Image(pw.MemoryImage(capturedImage),
                              fit: pw.BoxFit.contain),
                        ],
                      );
                    },
                  ),
                );

                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => await doc.save(),
                );

                setState(() {});
                Navigator.pop(context);
                await loadData();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Imprimir",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCustomModal(response, BuildContext context) {
    if (response == 1) {
      showSuccessModal(
          context, "No se pudo guardar los cambios", Icons8.fatal_error);
    }
    if (response == 2) {
      showSuccessModal(context, "Error de conexión", Icons8.no_connection);
    }

    if (response == 0) {
      showSuccessModal(
          context, "Se ha modificado exitosamente", Icons8.check_circle_color);
    }
  }

  Container _modelTextField(String text, TextEditingController controller) {
    return Container(
      width: 500,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[400]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Container _modelText(String text, String data) {
    return Container(
      width: 500,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            data,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
