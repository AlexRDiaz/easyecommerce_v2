class ProductSellerModel {
  int? id;
  int? productId;
  int? idMaster;
  int? favorite;
  int? onsale;
  String? createdAt;
  String? updatedAt;

  ProductSellerModel({
    this.id,
    this.productId,
    this.idMaster,
    this.favorite,
    this.onsale,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductSellerModel.fromJson(Map<String, dynamic> json) {
    return ProductSellerModel(
      id: json['id'],
      productId: json['product_id'],
      idMaster: json['id_master'],
      favorite: json['favorite'],
      onsale: json['onsale'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'id_master': idMaster,
      'favorite': favorite,
      'onsale': onsale,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
