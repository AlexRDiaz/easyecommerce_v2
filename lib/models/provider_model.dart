import 'package:frontend/models/user_model.dart';

class ProviderModel {
  int? id;
  int? userId;
  String? name;
  String? phone;
  String? description;
  UserModel? user;

  // Constructor
  ProviderModel({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.description,
    this.user,
  });

  // Método para crear un objeto ProviderModel desde un mapa
  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      description: json['description'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'description': description,
    };
  }
}
