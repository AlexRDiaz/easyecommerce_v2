import 'dart:convert';

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

  PedidoShopifyModel? pedidoShopify;

  ProviderTransactionsModel({
    this.id,
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
    this.pedidoShopify,
  });

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
      pedidoShopify: json['pedido'] == null
          ? PedidoShopifyModel()
          : PedidoShopifyModel.fromJson(json['pedido']),
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
      'pedido': pedidoShopify?.toJson(),
    };
  }
}
