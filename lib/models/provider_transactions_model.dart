import 'dart:convert';

import 'package:frontend/models/orden_retiro.dart';
import 'package:frontend/models/pedido_shopify_model.dart';

class ProviderTransactionsModel {
  int? id;
  String? transactionType;
  String? amount;
  String? previousValue;
  String? currentValue;
  String? timestamp;
  int? originId;
  String? originCode;
  int? providerId;
  String? comment;
  String? generatedBy;
  String? status;
  String? description;

  PedidoShopifyModel? pedidoShopify;
  OrdenRetiroModel? ordenRetiro;

  ProviderTransactionsModel(
      {this.id,
      this.transactionType,
      this.amount,
      this.previousValue,
      this.currentValue,
      this.timestamp,
      this.originId,
      this.originCode,
      this.providerId,
      this.comment,
      this.generatedBy,
      this.status,
      this.description,
      this.pedidoShopify,
      this.ordenRetiro});

  factory ProviderTransactionsModel.fromJson(Map<String, dynamic> json) {
    return ProviderTransactionsModel(
      id: json['id'],
      transactionType: json['transaction_type'],
      amount: json['amount'],
      previousValue: json['previous_value'],
      currentValue: json['current_value'],
      timestamp: json['timestamp'],
      originId: json['origin_id'],
      originCode: json['origin_code'],
      providerId: json['provider_id'],
      comment: json['comment'],
      generatedBy: json['generated_by'],
      status: json['status'],
      description: json['description'],
      pedidoShopify: json['pedido'] == null
          ? null
          : PedidoShopifyModel.fromJson(json['pedido']),
      ordenRetiro: json['orden_retiro'] == null
          ? null
          : OrdenRetiroModel.fromJson(json['orden_retiro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_type': transactionType,
      'amount': amount,
      'previous_value': previousValue,
      'current_value': currentValue,
      'timestamp': timestamp,
      'origin_id': originId,
      'origin_code': originCode,
      'provider_id': providerId,
      'comment': comment,
      'generated_by': generatedBy,
      'status': status,
      'description': description,
      'pedido': pedidoShopify?.toJson(),
      'orden_retiro': ordenRetiro?.toJson(),
    };
  }
}
