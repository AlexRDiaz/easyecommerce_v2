import 'package:frontend/models/user_model.dart';

class SubProviderModel {
  int? id;
  int? userId;
  String? name;
  String? phone;
  String? description;
  UserModel? user;

  // Constructor
  SubProviderModel({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.description,
    this.user,
  });

  // Método para crear un objeto SubProviderModel desde un mapa
  factory SubProviderModel.fromJson(Map<String, dynamic> json) {
    return SubProviderModel(
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
