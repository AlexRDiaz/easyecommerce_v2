import 'dart:convert';

import 'package:frontend/models/provider_model.dart';

class WarehouseModel {
  int? id;
  String? branchName;
  String? address;
  String? reference;
  String? description;
  String? url_image;
  String? city;
  dynamic collection;
  int? active;
  int? providerId;

  // Considerar si necesitas un objeto relacionado como en ProviderModel
  ProviderModel? provider;

  // Constructor
  WarehouseModel({
    this.id,
    this.branchName,
    this.address,
    this.reference,
    this.description,
    this.url_image,
    this.city,
    this.collection,
    this.active,
    this.providerId,
    this.provider,
  });

  // Método para crear un objeto WarehouseModel desde un mapa
 factory WarehouseModel.fromJson(Map<String, dynamic> json) {
  dynamic providerData;

  if (json['provider'] != null) {
    var providerValue = json['provider'];

    if (providerValue is String) {
      try {
        providerData = jsonDecode(providerValue);
      } catch (e) {
        print('Error decoding provider string: $e');
      }
    } else if (providerValue is Map<String, dynamic>) {
      providerData = providerValue;
    }
  }

  ProviderModel? providerModel;
  if (providerData != null) {
    providerModel = ProviderModel.fromJson(providerData);
  }

  return WarehouseModel(
    id: json['warehouse_id'],
    branchName: json['branch_name'],
    address: json['address'],
    reference: json['reference'],
    description: json['description'],
    url_image: json['url_image'],
    city: json['city'],
    collection: json['collection'],
    active: json['active'],
    providerId: json['provider_id'],
    provider: providerModel,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': id,
      'branch_name': branchName,
      'address': address,
      'reference': reference,
      'description': description,
      'url_image': url_image,
      'city': city,
      'collection' : collection,
      'active' : active,
      'provider_id': providerId,
      // Si tienes un objeto relacionado
      // 'provider': provider?.toJson(),
    };
  }
}
