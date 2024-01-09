import 'dart:convert';

import 'package:frontend/models/product_seller.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/utils/utils.dart';

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
  List<ProductSellerModel>? productseller;
  List<ReserveModel>? reserves;

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
    this.productseller,
    this.reserves,
  });

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

    dynamic productsellerData;

    if (json['productseller'] != null) {
      var productsellerValue = json['productseller'];

      if (productsellerValue is List<dynamic>) {
        try {
          // Aquí tratamos productsellerValue como una lista de objetos JSON
          productsellerData = productsellerValue;
        } catch (e) {
          print('Error decoding productseller list: $e');
        }
      }
    }

    List<ProductSellerModel>? productsellerModels;
    if (productsellerData != null) {
      // Aquí tratamos productsellerData como una lista de objetos JSON
      productsellerModels = List<ProductSellerModel>.from(
          productsellerData.map((item) => ProductSellerModel.fromJson(item)));
    }

    dynamic reservesData;

    if (json['reserve'] != null) {
      var reserveValue = json['reserve'];
      if (reserveValue is List<dynamic>) {
        try {
          // Aquí tratamos productsellerValue como una lista de objetos JSON
          reservesData = reserveValue;
        } catch (e) {
          print('Error decoding reserves list: $e');
        }
      }
    }

    List<ReserveModel>? reservesModels;
    if (reservesData != null) {
      // Aquí tratamos productsellerData como una lista de objetos JSON
      reservesModels = List<ReserveModel>.from(
          reservesData.map((item) => ReserveModel.fromJson(item)));
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
      productseller: productsellerModels,
      reserves: reservesModels,
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
      'productseller': productseller?.map((item) => item.toJson()).toList(),
      'reserve': reserves?.map((item) => item.toJson()).toList(),
    };
  }
}
