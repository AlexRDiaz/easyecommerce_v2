import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/options_modal.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/forms/image_row.dart';
import 'controllers/controllers.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerReturnDetailsData extends StatefulWidget {
  // const SellerReturnDetails({super.key});

  final Map data;
  const SellerReturnDetailsData({super.key, required this.data});

  @override
  State<SellerReturnDetailsData> createState() =>
      _SellerReturnDetailsDataState();
}

class _SellerReturnDetailsDataState extends State<SellerReturnDetailsData> {
  String id = "";
  bool loading = true;

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
    Color color = UIUtils.getColor('NOVEDAD');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              Container(
                width: 500,
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(5),
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
                    SizedBox(height: 2),
                    _modelText("Fecha:", _fechaEntrega.text),
                    SizedBox(height: 2),
                    _modelText("Código", codigo),
                    SizedBox(height: 2),
                    _modelText("Ciudad", _ciudad.text),
                    SizedBox(height: 2),
                    _modelText("Nombre Cliente", _nombreCliente.text),
                    SizedBox(height: 2),
                    //detalle?
                    _modelText("Dirección", _direccion.text),
                    SizedBox(height: 2),
                    _modelText("Teléfono Cliente", _telefonoCliente.text),
                    SizedBox(height: 2),
                    _modelText("Cantidad", _cantidad.text),
                    SizedBox(height: 2),
                    _modelText("Producto", _producto.text),
                    SizedBox(height: 22),
                    _modelText("Producto Extra", _productoExtra.text),
                    SizedBox(height: 2),
                    _modelText("Precio Total", _precioTotal.text),
                    SizedBox(height: 2),
                    _modelText("Status", _status.text),
                    SizedBox(height: 2),
                    _modelText("Estado Devolución", _estadoDevolucion.text),
                    SizedBox(height: 2),
                    _modelText(
                        "Marca Fecha Confirmación", _fechaConfirmacion.text),
                    SizedBox(height: 2),
                    _modelText("Comentario", _comentario.text),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Novedades:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (data['novedades'] != null && data['novedades'].isNotEmpty)
                    Container(
                      height: 500,
                      width: 500,
                      child: ListView.builder(
                        itemCount: data['novedades'].length,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      "Intento: ${data['novedades'][0]['try'].toString()}",
                                    ),
                                    data['novedades'][0]['url_image']
                                                .toString()
                                                .isEmpty ||
                                            data['novedades'][0]['url_image']
                                                    .toString() ==
                                                "null"
                                        ? Container()
                                        : Container(
                                            margin: EdgeInsets.all(15),
                                            child: Image.network(
                                              "$generalServer${data['novedades'][0]['url_image'].toString()}",
                                              fit: BoxFit.fill,
                                            )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    SizedBox(
                      height: 30,
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modelText(String text, String data) {
    return Column(
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
        SizedBox(height: 3),
        Text(
          data,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
