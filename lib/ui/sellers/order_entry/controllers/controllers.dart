import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class OrderEntryControllers extends ChangeNotifier {
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
    codigoEditController.text = data['numero_orden'].toString();
    // fechaEditController.text = data['pedido_fecha'][0]['fecha'].toString();
    fechaEditController.text = data['marca_t_i'].toString();
    ciudadEditController.text =
        (data['ciudad_shipping'] != null && data['ciudad_shipping'] != "null")
            ? data['ciudad_shipping'].toString()
            : "";
    nombreEditController.text =
        (data['nombre_shipping'] != null && data['nombre_shipping'] != "null")
            ? data['nombre_shipping'].toString()
            : "";
    productoEditController.text =
        (data['producto_p'] != null && data['producto_p'] != "null")
            ? data['producto_p'].toString()
            : "";
    productoExtraEditController.text =
        (data['producto_extra'] != null && data['producto_extra'] != "null")
            ? data['producto_extra'].toString()
            : "";
    cantidadEditController.text =
        (data['cantidad_total'] != null && data['cantidad_total'] != "null")
            ? data['cantidad_total'].toString()
            : "";
    direccionEditController.text = (data['direccion_shipping'] != null &&
            data['direccion_shipping'] != "null")
        ? data['direccion_shipping'].toString()
        : "";
    telefonoEditController.text = (data['telefono_shipping'] != null &&
            data['telefono_shipping'] != "null")
        ? data['telefono_shipping'].toString()
        : "";
    precioTotalEditController.text =
        (data['precio_total'] != null && data['precio_total'] != "null")
            ? data['precio_total'].toString()
            : "";
    observacionEditController.text =
        (data['observacion'] != null && data['observacion'] != "null")
            ? data['observacion'].toString()
            : "";
    /*
    ciudadEditController.text = data['ciudad_shipping'].toString();
    nombreEditController.text = data['nombre_shipping'].toString();
    productoEditController.text = data['producto_p'].toString();
    productoExtraEditController.text =
        data['producto_extra'].toString();
    cantidadEditController.text =
        data['cantidad_total'].toString();
    direccionEditController.text =
        data['direccion_shipping'].toString();
    telefonoEditController.text =
        data['telefono_shipping'].toString();
    precioTotalEditController.text =
        data['precio_total'].toString();
    observacionEditController.text =
        data['observacion'].toString();
        */
    notifyListeners();
  }

  updateInfo({success, error, id}) async {
    var responseGeneralSeller = await Connections()
        .updateOrderInfoSellerLaravel(
            ciudadEditController.text,
            nombreEditController.text,
            direccionEditController.text,
            telefonoEditController.text,
            cantidadEditController.text,
            productoEditController.text,
            productoExtraEditController.text,
            precioTotalEditController.text,
            observacionEditController.text,
            id);

    if (responseGeneralSeller) {
      success();
    } else {
      error();
    }
  }
}
