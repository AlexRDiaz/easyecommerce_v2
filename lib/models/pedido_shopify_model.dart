import 'package:flutter/foundation.dart';

class PedidoShopifyModel extends ChangeNotifier{
  // int? cantidadPedidosCambiados;

  int? id;
  String? numeroOrden;
  String? direccionShipping;
  String? nombreShipping;
  String? telefonoShipping;
  String? precioTotal;
  String? observacion;
  String? ciudadShipping;
  String? estadoInterno;
  String? idComercial;
  String? productoP;
  String? productoExtra;
  String? cantidadTotal;
  String? status;
  String? estadoLogistico;
  String? nameComercial;
  String? marcaTiempoEnvio;
  String? fechaEntrega;
  // String? comentario;
  // String? tipoPago;
  // String? archivo;
  // String? estadoPagado;
  // String? urlPagadoFoto;
  // String? estadoPagoLogistica;
  // String? urlPLFoto;
  // String? estadoDevolucion;
  // String? tiendaTemporal;
  // String? marcaTD;
  // String? marcaTDT;
  // String? marcaTDL;
  // String? marcaTI;
  // String? dt;
  // String? dl;
  // String? fechaConfirmacion;
  // String? createdAt;
  // String? updatedAt;
  // String? createdById;
  // int? updatedById;
  // String? comentarioRechazado;
  // String? revisado;
  // String? costoEnvio;
  // String? costoDevolucion;
  // String? costoTransportadora;
  // String? printedAt;
  // int? printedBy;
  // String? sentAt;
  // int? sentBy;
  // int? receivedBy;
  // String? statusLastModifiedAt;
  // int? statusLastModifiedBy;
  // int? confirmedBy;
  // String? confirmedAt;
  // int? revisadoSeller;
  // String? sku;

  // set _status(String value) {
  //   status = value;
  //   notifyListeners(); // Notificar a los oyentes cuando cambie el estado
  // }

  PedidoShopifyModel({
    this.id,
    this.numeroOrden,
    this.direccionShipping,
    this.nombreShipping,
    this.telefonoShipping,
    this.precioTotal,
    this.observacion,
    this.ciudadShipping,
    this.estadoInterno,
    this.idComercial,
    this.productoP,
    this.productoExtra,
    this.cantidadTotal,
    this.status,
    this.estadoLogistico,
    this.nameComercial,
    this.marcaTiempoEnvio,
    this.fechaEntrega,
    // this.cantidadPedidosCambiados,
    // this.comentario,
    // this.tipoPago,
    // this.archivo,
    // this.estadoPagado,
    // this.urlPagadoFoto,
    // this.estadoPagoLogistica,
    // this.urlPLFoto,
    // this.estadoDevolucion,
    // this.tiendaTemporal,
    // this.marcaTD,
    // this.marcaTDT,
    // this.marcaTDL,
    // this.marcaTI,
    // this.dt,
    // this.dl,
    // this.fechaConfirmacion,
    // this.createdAt,
    // this.updatedAt,
    // this.createdById,
    // this.updatedById,
    // this.comentarioRechazado,
    // this.revisado,
    // this.costoEnvio,
    // this.costoDevolucion,
    // this.costoTransportadora,
    // this.printedAt,
    // this.printedBy,
    // this.sentAt,
    // this.sentBy,
    // this.receivedBy,
    // this.statusLastModifiedAt,
    // this.statusLastModifiedBy,
    // this.confirmedBy,
    // this.confirmedAt,
    // this.revisadoSeller,
    // this.sku,
  });

  factory PedidoShopifyModel.fromJson(Map<String, dynamic> json) {
    return PedidoShopifyModel(
      id: json['id'],
      numeroOrden: json['numero_orden'],
      direccionShipping: json['direccion_shipping'],
      nombreShipping: json['nombre_shipping'],
      telefonoShipping: json['telefono_shipping'],
      precioTotal: json['precio_total'],
      observacion: json['observacion'],
      ciudadShipping: json['ciudad_shipping'],
      estadoInterno: json['estado_interno'],
      idComercial: json['id_comercial'],
      productoP: json['producto_p'],
      productoExtra: json['producto_extra'],
      cantidadTotal: json['cantidad_total'],
      status: json['status'],
      estadoLogistico: json['estado_logistico'],
      nameComercial: json['name_comercial'],
      marcaTiempoEnvio: json['marca_tiempo_envio'],
      fechaEntrega: json['fecha_entrega'],
      // cantidadPedidosCambiados: json['cantidad_pedidos_cambiados'] ?? 0,
      // comentario: json['comentario'],
      // tipoPago: json['tipo_pago'],
      // archivo: json['archivo'],
      // estadoPagado: json['estado_pagado'],
      // urlPagadoFoto: json['url_pagado_foto'],
      // estadoPagoLogistica: json['estado_pago_logistica'],
      // urlPLFoto: json['url_p_l_foto'],
      // estadoDevolucion: json['estado_devolucion'],
      // tiendaTemporal: json['tienda_temporal'],
      // marcaTD: json['marca_t_d'],
      // marcaTDT: json['marca_t_d_t'],
      // marcaTDL: json['marca_t_d_l'],
      // marcaTI: json['marca_t_i'],
      // dt: json['dt'],
      // dl: json['dl'],
      // fechaConfirmacion: json['fecha_confirmacion'],
      // createdAt: json['created_at'],
      // updatedAt: json['updated_at'],
      // createdById: json['created_by_id'],
      // updatedById: json['updated_by_id'],
      // comentarioRechazado: json['comentario_rechazado'],
      // revisado: json['revisado'],
      // costoEnvio: json['costo_envio'],
      // costoDevolucion: json['costo_devolucion'],
      // costoTransportadora: json['costo_transportadora'],
      // printedAt: json['printed_at'],
      // printedBy: json['printed_by'],
      // sentAt: json['sent_at'],
      // sentBy: json['sent_by'],
      // receivedBy: json['received_by'],
      // statusLastModifiedAt: json['status_last_modified_at'],
      // statusLastModifiedBy: json['status_last_modified_by'],
      // confirmedBy: json['confirmed_by'],
      // confirmedAt: json['confirmed_at'],
      // revisadoSeller: json['revisado_seller'],
      // sku: json['sku'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_orden': numeroOrden,
      'direccion_shipping': direccionShipping,
      'nombre_shipping': nombreShipping,
      'telefono_shipping': telefonoShipping,
      'precio_total': precioTotal,
      'observacion': observacion,
      'ciudad_shipping': ciudadShipping,
      'estado_interno': estadoInterno,
      'id_comercial': idComercial,
      'producto_p': productoP,
      'producto_extra': productoExtra,
      'cantidad_total': cantidadTotal,
      'status': status,
      'estado_logistico': estadoLogistico,
      'name_comercial': nameComercial,
      'marca_tiempo_envio': marcaTiempoEnvio,
      'fecha_entrega': fechaEntrega,
      // 'cantidad_pedidos_cambiados': cantidadPedidosCambiados,
      // 'comentario': this.comentario;
      // 'tipo_pago': this.tipoPago;
      // 'archivo': this.archivo;
      // 'estado_pagado': this.estadoPagado;
      // 'url_pagado_foto': this.urlPagadoFoto;
      // 'estado_pago_logistica': this.estadoPagoLogistica;
      // 'url_p_l_foto': this.urlPLFoto;
      // 'estado_devolucion': this.estadoDevolucion;
      // 'tienda_temporal': this.tiendaTemporal;
      // 'marca_t_d': this.marcaTD;
      // 'marca_t_d_t': this.marcaTDT;
      // 'marca_t_d_l': this.marcaTDL;
      // 'marca_t_i': this.marcaTI;
      // 'dt': this.dt;
      // 'dl': this.dl;
      // 'fecha_confirmacion': this.fechaConfirmacion;
      // 'created_at': this.createdAt;
      // 'updated_at': this.updatedAt;
      // 'created_by_id': this.createdById;
      // 'updated_by_id': this.updatedById;
      // 'comentario_rechazado': this.comentarioRechazado;
      // 'revisado': this.revisado;
      // 'costo_envio': this.costoEnvio;
      // 'costo_devolucion': this.costoDevolucion;
      // 'costo_transportadora': this.costoTransportadora;
      // 'printed_at': this.printedAt;
      // 'printed_by': this.printedBy;
      // 'sent_at': this.sentAt;
      // 'sent_by': this.sentBy;
      // 'received_by': this.receivedBy;
      // 'status_last_modified_at': this.statusLastModifiedAt;
      // 'status_last_modified_by': this.statusLastModifiedBy;
      // 'confirmed_by': this.confirmedBy;
      // 'confirmed_at': this.confirmedAt;
      // 'revisado_seller': this.revisadoSeller;
      // 'sku': this.sku,
    };
  }
}
