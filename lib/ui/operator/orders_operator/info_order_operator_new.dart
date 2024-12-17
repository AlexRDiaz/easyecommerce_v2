import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/update_status_operator/update_status_operator_historial.dart';
import 'package:screenshot/screenshot.dart';

class InfoOrderOperatorNew extends StatefulWidget {
  final Map order;
  final Function function;
  final List? data;

  const InfoOrderOperatorNew({
    super.key,
    required this.order,
    required this.function,
    this.data,
  });

  @override
  State<InfoOrderOperatorNew> createState() => _InfoOrderOperatorNewState();
}

class _InfoOrderOperatorNewState extends State<InfoOrderOperatorNew> {
  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController _marcaTiempo = TextEditingController();
  TextEditingController _fecha = TextEditingController();
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
  TextEditingController _fechaEnvio = TextEditingController();

  var data = {};

  String id = "";
  bool loading = true;
  String devolucionLogistica = "";
  String codigo = "";

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    try {
      // Loading modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      data = widget.order;
      codigo = "${data['vendor']['nombre_comercial']}-${data['numero_orden']}";
      _nombreCliente.text = data['nombre_shipping'].toString();
      _ciudad.text = data['ciudad_shipping'].toString();
      _direccion.text = data['direccion_shipping'].toString();
      _telefonoCliente.text = data['telefono_shipping'].toString();
      _cantidad.text = data['cantidad_total'].toString();
      _producto.text = data['producto_p'].toString();
      _productoExtra.text = data['producto_extra'] == null
          ? ""
          : data['producto_extra'].toString();
      _marcaTiempo.text = data['marca_t_i'];
      _precioTotal.text = data['precio_total'].toString();
      _comentario.text =
          data['comentario'] == null ? "" : data['comentario'].toString();
      _observacion.text =
          data['observacion'] == null ? "" : data['observacion'].toString();
      _vendedor.text = data['name_comercial'].toString();
      _fechaEnvio.text = data['marca_tiempo_envio'].toString();
      _fechaEntrega.text = data['fecha_entrega'].toString();

      _confirmado.text = data['estado_interno'].toString();
      _fechaConfirmacion.text = data['fecha_confirmacion'].toString();
      _estadoLogistico.text = data['estado_logistico'].toString();
      _status.text = data['status'].toString();

      setState(() {});

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      SnackBarHelper.showErrorSnackBar(context, "Error al cargar los datos");
    }
  }

  updateData() async {
    print("updateData");

    var response = await Connections().getOrdersByIdLaravel(widget.order['id']);
    var dataRes = response;

    setState(() {
      _status.text = dataRes['status'].toString();
      _telefonoCliente.text = dataRes['telefono_shipping'].toString();
      _status.text = dataRes['status'].toString();
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: responsive(
          webContainer(),
          mobileContainer(),
          context,
        ));
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                title,
                style: TextStylesSystem().ralewayStyle(
                  20,
                  FontWeight.bold,
                  ColorsSystem().colorLabels,
                ),
              ),
            ),
          ],
        ),
        ...rows
      ],
    );
  }

  Padding webContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateStatusOperatorHistorial(
                            function: widget.function,
                            numberTienda: data['users'][0]['vendedores'][0]
                                    ['telefono_2']
                                .toString(),
                            codigo: codigo,
                            numberCliente: "${data['telefono_shipping']}",
                            id: data['id'].toString(),
                            novedades: data['novedades'],
                            currentStatus: data['status'] == "NOVEDAD" ||
                                    data['status'] == "REAGENDADO"
                                ? ""
                                : data['status'],
                            dataL: widget
                                .data, //lista de datos //quitar en nueva version
                          );
                        });
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    widget.function();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsSystem().colorStore,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    MediaQuery.of(context).size.width > 600
                        ? "Estado de Entrega"
                        : "Estado Entrega",
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 16 : 12,
                    ),
                  ),
                ),
              ],
            ),
            // Summary Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Fecha Envio:", _fechaEnvio.text, 0),
                    _infoRow("Código:", codigo, 0),
                    _infoRow("Ciudad:", _ciudad.text, 0),
                    _infoRow("Nombre Cliente", _nombreCliente.text, 0),
                    _infoRow("Dirección", _direccion.text, 0),
                    _infoRow("Teléfono Cliente", _telefonoCliente.text, 0),
                    TextField(
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      controller: _telefonoCliente,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);

                        var response =
                            await Connections().updatenueva(data['id'], {
                          "telefono_shipping": _telefonoCliente.text,
                        });

                        await updateData();

                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                        widget.function();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsSystem().colorStore,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Actualizar Número",
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 600 ? 16 : 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow("Cantidad:", _cantidad.text, 0),
                    _infoRow("Producto:", _producto.text, 0),
                    _infoRow("Producto Extra", _productoExtra.text, 0),
                    _infoRow("Precio Total:", "\$${_precioTotal.text}", 0),
                    _infoRow("Observacion", _observacion.text, 0),
                    _infoRow("Comentario:", _comentario.text, 0),
                    _infoRow("Status", _status.text, 0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Updates Section
            if (data['novedades'] != null && data['novedades'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSection("Archivos", [
                    data['archivo'].toString().isEmpty ||
                            data['archivo'].toString() == "null"
                        ? Container(
                            height: 200,
                            child: Center(child: Text("No hay archivos ")),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.2,
                            child: Image.network(
                              "$generalServer${data['archivo'].toString()}",
                              fit: BoxFit.fill,
                            )),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    "Novedades",
                    style: TextStylesSystem().ralewayStyle(
                      20,
                      FontWeight.bold,
                      ColorsSystem().colorLabels,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemCount: data['novedades'].length,
                      itemBuilder: (context, index) {
                        final novelty = data['novedades'][index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: ColorsSystem().colorInitialContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Intento: ${novelty['try']}",
                                  style: TextStylesSystem().ralewayStyle(
                                    14,
                                    FontWeight.w500,
                                    ColorsSystem().colorStore,
                                  ),
                                ),
                                Text(
                                  "Comentario: ${novelty['comment']}",
                                  style: TextStylesSystem().ralewayStyle(
                                    14,
                                    FontWeight.w500,
                                    ColorsSystem().colorStore,
                                  ),
                                ),
                                Text(
                                  "Fecha Intento: ${novelty['m_t_novedad']}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ColorsSystem().colorStore,
                                  ),
                                ),
                                if (novelty['url_image']?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Image.network(
                                      "$generalServer${novelty['url_image']}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Padding mobileContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateStatusOperatorHistorial(
                            function: widget.function,
                            numberTienda: data['users'][0]['vendedores'][0]
                                    ['telefono_2']
                                .toString(),
                            codigo: codigo,
                            numberCliente: "${data['telefono_shipping']}",
                            id: data['id'].toString(),
                            novedades: data['novedades'],
                            currentStatus: data['status'] == "NOVEDAD" ||
                                    data['status'] == "REAGENDADO"
                                ? ""
                                : data['status'],
                            dataL: widget
                                .data, //lista de datos //quitar en nueva version
                          );
                        });
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    widget.function();
                    //
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsSystem().colorStore,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Estado Entrega",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            // Summary Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Fecha Envio:", _fechaEnvio.text, 1),
                    _infoRowMobile("Código:", codigo, 1),
                    _infoRow("Ciudad:", _ciudad.text, 1),
                    _infoRowMobile("Nombre Cliente", _nombreCliente.text, 1),
                    _infoRowMobile("Dirección", _direccion.text, 1),
                    _infoRowMobile(
                        "Teléfono Cliente", _telefonoCliente.text, 1),
                    TextField(
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      controller: _telefonoCliente,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);

                        var response =
                            await Connections().updatenueva(data['id'], {
                          "telefono_shipping": _telefonoCliente.text,
                        });

                        await updateData();
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }

                        widget.function();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsSystem().colorStore,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Actualizar Número",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRowMobile("Cantidad:", _cantidad.text, 1),
                    _infoRowMobile("Producto:", _producto.text, 1),
                    _infoRowMobile("Producto Extra", _productoExtra.text, 1),
                    _infoRowMobile(
                        "Precio Total:", "\$${_precioTotal.text}", 1),
                    _infoRowMobile("Observacion", _observacion.text, 1),
                    _infoRowMobile("Comentario:", _comentario.text, 1),
                    _infoRowMobile("Status", _status.text, 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Updates Section
            if (data['novedades'] != null && data['novedades'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Novedades",
                    style: TextStylesSystem().ralewayStyle(
                      20,
                      FontWeight.bold,
                      ColorsSystem().colorLabels,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemCount: data['novedades'].length,
                      itemBuilder: (context, index) {
                        final novelty = data['novedades'][index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: ColorsSystem().colorInitialContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Intento: ${novelty['try']}",
                                  style: TextStylesSystem().ralewayStyle(
                                    14,
                                    FontWeight.w600,
                                    ColorsSystem().colorStore,
                                  ),
                                ),
                                if (novelty['url_image']?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Image.network(
                                      "$generalServer${novelty['url_image']}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, responsive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: TextStylesSystem().ralewayStyle(
              responsive == 0 ? 16 : 12,
              FontWeight.w600,
              ColorsSystem().colorLabels,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: responsive == 0 ? 16 : 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowMobile(String label, String value, int responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: TextStylesSystem().ralewayStyle(
            responsive == 0 ? 16 : 12,
            FontWeight.w600,
            ColorsSystem().colorLabels,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive == 0 ? 16 : 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
      ],
    );
  }
}
