import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/utils/utils.dart';

class ProviderModel {
  int? id;
  int? userId;
  String? name;
  String? phone;
  String? description;
  int? special;
  String? createdAt;
  int? approved;
  int? active;

  UserModel? user;
  List<WarehouseModel>? warehouses;

  // Constructor
  ProviderModel({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.description,
    this.special,
    this.createdAt,
    this.approved,
    this.active,
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
      special: json['special'],
      approved: json['approved'],
      active: json['active'],
      createdAt: UIUtils.formatDate(json['created_at']),
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
      'special': special,
      'approved': special,
      'active': special,
      'created_at': createdAt,
      'warehouses': warehouses
    };
  }
}
