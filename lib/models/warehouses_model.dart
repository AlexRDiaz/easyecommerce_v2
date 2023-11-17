class WarehouseModel {
  int? id;
  String? branchName;
  String? address;
  String? reference;
  String? description;
  int? providerId;

  // Considerar si necesitas un objeto relacionado como en ProviderModel
  // ProviderModel? provider;

  // Constructor
  WarehouseModel({
    this.id,
    this.branchName,
    this.address,
    this.reference,
    this.description,
    this.providerId,
    // this.provider,
  });

  // Método para crear un objeto WarehouseModel desde un mapa
  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['warehouse_id'],
      branchName: json['branch_name'],
      address: json['address'],
      reference: json['reference'],
      description: json['description'],     
      providerId: json['provider_id'],
      // provider: ProviderModel.fromJson(json['provider']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': id,
      'branch_name': branchName,
      'address': address,
      'reference': reference,
      'description': description,
      'provider_id': providerId,
      // Si tienes un objeto relacionado
      // 'provider': provider?.toJson(),
    };
  }
}
