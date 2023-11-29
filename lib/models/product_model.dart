import 'dart:convert';

import 'package:frontend/models/warehouses_model.dart';

class ProductModel {
  int? productId;
  String? productName;
  int? stock;
  double? price;
  dynamic urlImg;
  int? isvariable;
  dynamic features;
  int? approved;
  int? active;
  int? warehouseId;
  String? createdAt;
  String? updatedAt;
  // Considerar si necesitas un objeto relacionado como en ProviderModel
  WarehouseModel? warehouse;

  ProductModel({
    this.productId,
    this.productName,
    this.stock,
    this.price,
    this.urlImg,
    this.isvariable,
    this.features,
    this.approved,
    this.active,
    this.warehouseId,
    this.createdAt,
    this.updatedAt,
    this.warehouse,
  });

  // Método para crear un objeto ProviderModel desde un mapa
  // factory ProductModel.fromJson(Map<String, dynamic> json) {
  //   return ProductModel(
  //     productId: json['product_id'],
  //     productName: json['product_name'],
  //     stock: json['stock'],
  //     features: json['features'],
  //     price: json['price'],
  //     urlImg: json['url_img'],
  //     createdAt: json['created_at'],
  //     approved: json['approved'],
  //     active: json['active'],
  //     warehouseId: json['warehouse_id'],
  //   );
  // }
  // Método para crear un objeto ProductModel desde un mapa
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    dynamic warehouseData;

    if (json['warehouse'] != null) {
      var warehouseValue = json['warehouse'];

      if (warehouseValue is String) {
        try {
          warehouseData = jsonDecode(warehouseValue);
        } catch (e) {
          print('Error decoding warehouse string: $e');
        }
      } else if (warehouseValue is Map<String, dynamic>) {
        warehouseData = warehouseValue;
      }
    }

    WarehouseModel? warehouseModel;
    if (warehouseData != null) {
      warehouseModel = WarehouseModel.fromJson(warehouseData);
    }

    return ProductModel(
      productId: json['product_id'],
      productName: json['product_name'],
      stock: json['stock'],
      price: json['price'],
      urlImg: json['url_img'],
      isvariable: json['isvariable'],
      features: json['features'],
      approved: json['approved'],
      active: json['active'],
      createdAt: json['created_at'],
      warehouseId: json['warehouse_id'],
      warehouse: warehouseModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'stock': stock,
      'price': price,
      'url_img': urlImg,
      'isvariable': isvariable,
      'features': features,
      'approved': approved,
      'active': active,
      'created_at': createdAt,
      'warehouse_id': warehouseId,
      'warehouse': warehouse?.toJson(),
    };
  }
}
