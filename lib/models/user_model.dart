class UserModel {
  int? id;
  String? username;
  String? email;
  String? provider;
  bool? confirmed;
  bool? blocked;
  dynamic? permisos;
  dynamic? warehouses;
  dynamic? vendor;

  // Añade más propiedades según sea necesario

  // Constructor
  UserModel({
    this.id,
    this.username,
    this.email,
    this.provider,
    this.confirmed,
    this.blocked,
    this.permisos,
    this.warehouses,
    this.vendor,
  });
  UserModel.empty()
      : id = 0,
        username = '',
        email = '',
        provider = '',
        confirmed = false,
        blocked = false;

  // Método para crear un objeto UserModel desde un mapa
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      provider: json['provider'],
      confirmed: json['confirmed'],
      blocked: json['blocked'],
      permisos: json['permisos'],
      warehouses: json['warehouses'],
      vendor: json['vendor'],
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'provider': provider,
      'confirmed': confirmed,
      'blocked': blocked,
      'permisos': permisos,
      'vendor': vendor,
    };
  }
}
