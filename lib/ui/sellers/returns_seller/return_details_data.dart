import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:screenshot/screenshot.dart';
import '../../../connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';

class SellerReturnDetailsData extends StatefulWidget {
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

  // Controllers for text input fields
  TextEditingController _marcaTiempo = TextEditingController();
  TextEditingController _fecha = TextEditingController();
  TextEditingController _cantidad = TextEditingController();
  TextEditingController _precioTotal = TextEditingController();
  TextEditingController _producto = TextEditingController();
  TextEditingController _direccion = TextEditingController();
  TextEditingController _ciudad = TextEditingController();
  TextEditingController _comentario = TextEditingController();

  String devolucionLogistica = "";
  String codigo = "";

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

  var data = {};

  @override
  void initState() {
    loadTextEditingControllers(widget.data);
    super.initState();
  }

  loadData() async {
    try {
      // Loading modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var response =
          await Connections().getOrderByIDHistoryLaravel(widget.data['id']);

      setState(() {
        data = response;
        loadTextEditingControllers(data);
      });

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

  loadTextEditingControllers(newData) {
    data = newData;
    _marcaTiempo.text = data['marca_t_i'];
    _fecha.text = data['marca_t_i'].toString().split(' ')[0].toString();
    _cantidad.text = data['cantidad_total'].toString();
    _precioTotal.text = data['precio_total'].toString();
    _producto.text = data['producto_p'].toString();
    _direccion.text = data['direccion_shipping'].toString();
    _ciudad.text = data['ciudad_shipping'].toString();
    _comentario.text = data['comentario'].toString();

    codigo =
        "${data['users'] != null && data['users'].toString() != "[]" ? data['users'][0]['vendedores'][0]['nombre_comercial'] : data['tienda_temporal']}-${data['numero_orden']}";
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
    return Scaffold(
        backgroundColor: Colors.grey[100],
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   // centerTitle: true,
        //   title: responsive(Text(
        //     "Detalles de Devolución",
        //     style: TextStylesSystem().ralewayStyle(
        //       20,
        //       FontWeight.bold,
        //       ColorsSystem().colorLabels,
        //     ),
        //   ), Text(
        //     "Detalles de Devolución",
        //     style: TextStylesSystem().ralewayStyle(
        //       14,
        //       FontWeight.bold,
        //       ColorsSystem().colorLabels,
        //     ),
        //   ), context)
        // ),
        body: responsive(webContainer(), mobileContainer(), context));
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
            // Summary Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Fecha:", _fecha.text, 0),
                    _infoRow("Código:", codigo, 0),
                    _infoRow("Ciudad:", _ciudad.text, 0),
                    _infoRow("Nombre Cliente", _nombreCliente.text, 0),
                    _infoRow("Dirección", _direccion.text, 0),
                    _infoRow("Teléfono Cliente", _telefonoCliente.text, 0),
                    _infoRow("Cantidad:", _cantidad.text, 0),
                    _infoRow("Producto:", _producto.text, 0),
                    _infoRow("Producto Extra", _productoExtra.text, 0),
                    _infoRow("Precio Total:", "\$${_precioTotal.text}", 0),
                    _infoRow("Status", _status.text, 0),
                    _infoRow("Estado Devolución", _estadoDevolucion.text, 0),
                    _infoRow(
                        "Marca Fecha Confirmación", _fechaConfirmacion.text, 0),
                    _infoRow("Comentario:", _comentario.text, 0),
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
            // Summary Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRowMobile("Fecha:", _fecha.text, 1),
                    _infoRowMobile("Código:", codigo, 1),
                    _infoRowMobile("Ciudad:", _ciudad.text, 1),
                    _infoRowMobile("Nombre Cliente", _nombreCliente.text, 1),
                    _infoRowMobile("Dirección", _direccion.text, 1),
                    _infoRowMobile(
                        "Teléfono Cliente", _telefonoCliente.text, 1),
                    _infoRowMobile("Cantidad:", _cantidad.text, 1),
                    _infoRowMobile("Producto:", _producto.text, 1),
                    _infoRowMobile("Producto Extra", _productoExtra.text, 1),
                    _infoRowMobile(
                        "Precio Total:", "\$${_precioTotal.text}", 1),
                    _infoRowMobile("Status", _status.text, 1),
                    _infoRowMobile(
                        "Estado Devolución", _estadoDevolucion.text, 1),
                    _infoRowMobile(
                        "Marca Fecha Confirmación", _fechaConfirmacion.text, 1),
                    _infoRowMobile("Comentario:", _comentario.text, 1),
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
          maxLines: 3, // Limita a 3 líneas, cambia según tus necesidades
        ),
      ],
    );
  }
}
