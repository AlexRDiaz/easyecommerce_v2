import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';

class ProviderModel {
  int? id;
  int? userId;
  String? name;
  String? phone;
  String? description;
  UserModel? user;
  List<WarehouseModel>? warehouses;

  // Constructor
  ProviderModel({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.description,
    this.user,
    this.warehouses,
  });

  // Método para crear un objeto ProviderModel desde un mapa

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    //
    dynamic warehousesData;

    if (json['warehouses'] != null) {
      var warehousesValue = json['warehouses'];
      if (warehousesValue is List<dynamic>) {
        try {
          // Aquí tratamos productsellerValue como una lista de objetos JSON
          warehousesData = warehousesValue;
        } catch (e) {
          print('Error decoding warehouses list: $e');
        }
      }
    }

    List<WarehouseModel>? warehousesModels;
    if (warehousesData != null) {
      // Aquí tratamos productsellerData como una lista de objetos JSON
      warehousesModels = List<WarehouseModel>.from(
          warehousesData.map((item) => WarehouseModel.fromJson(item)));
    }

    return ProviderModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      description: json['description'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      warehouses: warehousesModels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'description': description,
      'warehouses': warehouses
    };
  }
}
