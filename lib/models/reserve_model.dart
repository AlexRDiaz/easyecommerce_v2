import 'package:frontend/models/user_model.dart';

class ReserveModel {
  //id|product_id|sku|stock|warehouse_price|id_comercial
  int? id;
  int? productId;
  String? sku;
  int? stock;
  String? warehousePrice;
  int? idComercial;
  // UserModel? user;

  // Constructor
  ReserveModel({
    this.id,
    this.productId,
    this.sku,
    this.stock,
    this.warehousePrice,
    this.idComercial,
  });

  // Método para crear un objeto ProviderModel desde un mapa

  factory ReserveModel.fromJson(Map<String, dynamic> json) {
    return ReserveModel(
      id: json['id'],
      productId: json['product_id'],
      sku: json['sku'],
      stock: json['stock'],
      warehousePrice: json['warehouse_price'],
      idComercial: json['id_comercial'],
      // user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'sku': sku,
      'stock': stock,
      'warehouse_price': warehousePrice,
      'id_comercial': idComercial,
    };
  }
}
