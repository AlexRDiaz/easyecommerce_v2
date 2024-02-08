import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class OrderInfoOperatorBackupControllers extends ChangeNotifier {
  TextEditingController searchController = TextEditingController(text: "");
  TextEditingController codigoEditController = TextEditingController(text: "");
  TextEditingController fechaEditController = TextEditingController(text: "");
  TextEditingController ciudadEditController = TextEditingController(text: "");
  TextEditingController nombreEditController = TextEditingController(text: "");
  TextEditingController direccionEditController =
      TextEditingController(text: "");
  TextEditingController telefonoEditController =
      TextEditingController(text: "");
  TextEditingController precioTotalEditController =
      TextEditingController(text: "");
  TextEditingController observacionEditController =
      TextEditingController(text: "");
  TextEditingController confirmadoEditController =
      TextEditingController(text: "");
  TextEditingController productoEditController =
      TextEditingController(text: "");
  TextEditingController productoExtraEditController =
      TextEditingController(text: "");
  TextEditingController cantidadEditController =
      TextEditingController(text: "");

  editControllers(data) {
    codigoEditController.text = data['attributes']['NumeroOrden'].toString();
    fechaEditController.text = data['attributes']['pedido_fecha']['data']
            ['attributes']['Fecha']
        .toString();
    ciudadEditController.text = data['attributes']['CiudadShipping'].toString();
    nombreEditController.text = data['attributes']['NombreShipping'].toString();
    productoEditController.text = data['attributes']['ProductoP'].toString();
    productoExtraEditController.text =
        data['attributes']['ProductoExtra'].toString();
    cantidadEditController.text =
        data['attributes']['Cantidad_Total'].toString();
    direccionEditController.text =
        data['attributes']['DireccionShipping'].toString();
    telefonoEditController.text =
        data['attributes']['TelefonoShipping'].toString();
    precioTotalEditController.text =
        data['attributes']['PrecioTotal'].toString();
    observacionEditController.text =
        data['attributes']['Observacion'].toString();
    notifyListeners();
  }

  editControllers2(data) {
    codigoEditController.text = data['numero_orden'].toString();
    fechaEditController.text = data['pedido_fecha'][0]['fecha'].toString();
    ciudadEditController.text = data['ciudad_shipping'].toString();
    nombreEditController.text = data['nombre_shipping'].toString();
    productoEditController.text = data['producto_p'].toString();
    productoExtraEditController.text = data['producto_extra'].toString();
    cantidadEditController.text = data['cantidad_total'].toString();
    direccionEditController.text = data['direccion_shipping'].toString();
    telefonoEditController.text = data['telefono_shipping'].toString();
    precioTotalEditController.text = data['precio_total'].toString();
    observacionEditController.text = data['observacion'].toString();
    notifyListeners();
  }

  updateInfo({success, error}) async {
    var responseGeneralSeller = await Connections().updateOrderInfo(
        ciudadEditController.text,
        nombreEditController.text,
        direccionEditController.text,
        telefonoEditController.text,
        cantidadEditController.text,
        productoEditController.text,
        productoExtraEditController.text,
        precioTotalEditController.text,
        observacionEditController.text);

    if (responseGeneralSeller) {
      success();
    } else {
      error();
    }
  }
}

