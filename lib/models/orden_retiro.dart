import 'package:flutter/foundation.dart';

class OrdenRetiroModel extends ChangeNotifier {
  // int? cantidadPedidosCambiados;

  int? id;
  String? monto;
  String? codigo;
  String? fecha;
  String? estado;
  String? codigoGenerarado;
  String? fechaTransferencia;
  String? comprobante;
  String? estadoInterno;
  String? comentario;
  String? idVendedor;
  int? rolId;
  String? createdAt;
  String? updatedAt;

  OrdenRetiroModel(
      {this.id,
      this.monto,
      this.codigo,
      this.fecha,
      this.estado,
      this.codigoGenerarado,
      this.fechaTransferencia,
      this.comprobante,
      this.comentario,
      this.idVendedor,
      this.rolId,
      this.createdAt,
      this.updatedAt});

  factory OrdenRetiroModel.fromJson(Map<String, dynamic> json) {
    return OrdenRetiroModel(
        id: json['id'],
        monto: json['monto'],
        codigo: json['codigo'],
        fecha: json['fecha'],
        estado: json['estado'],
        codigoGenerarado: json['codigo_generado'],
        fechaTransferencia: json['fecha_transferencia'],
        comprobante: json['comprobante'],
        comentario: json['comentario'],
        idVendedor: json['id_vendedor'],
        rolId: json['rol_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'codigo': codigo,
      'fecha': fecha,
      'estado': estado,
      'codigoGenerarado': codigoGenerarado,
      'fechaTransferencia': fechaTransferencia,
      'comprobante': comprobante,
      'comentario': comentario,
      'idVendedor': idVendedor,
      'rolId': rolId,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
