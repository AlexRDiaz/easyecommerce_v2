import 'dart:convert';

import 'package:frontend/models/provider_model.dart';
import 'package:frontend/ui/utils/utils.dart';

class WarehouseModel {
  int? id;
  String? branchName;
  String? address;
  String? customerphoneNumber;
  String? reference;
  String? description;
  String? url_image;
  int? id_provincia;
  String? city;
  dynamic collection;
  int? active;
  int? approved;
  int? providerId;
  String? createdAt;

  // Considerar si necesitas un objeto relacionado como en ProviderModel
  ProviderModel? provider;

  // Constructor
  WarehouseModel({
    this.id,
    this.branchName,
    this.address,
    this.customerphoneNumber,
    this.reference,
    this.description,
    this.url_image,
    this.id_provincia,
    this.city,
    this.collection,
    this.active,
    this.approved,
    this.createdAt,
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
      customerphoneNumber: json['customer_service_phone'],
      reference: json['reference'],
      description: json['description'],
      url_image: json['url_image'],
      id_provincia: json['id_provincia'],
      city: json['city'],
      collection: json['collection'],
      active: json['active'],
      approved: json['approved'],
      createdAt: json['created_at'],
      providerId: json['provider_id'],
      provider: providerModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': id,
      'branch_name': branchName,
      'address': address,
      'customerphoneNumber': customerphoneNumber,
      'reference': reference,
      'description': description,
      'id_provincia': id_provincia,
      'url_image': url_image,
      'city': city,
      'collection': collection,
      'active': active,
      'approved': approved,
      'created_at': createdAt,
      'provider_id': providerId,
      // Si tienes un objeto relacionado
      // 'provider': provider?.toJson(),
    };
  }
}
