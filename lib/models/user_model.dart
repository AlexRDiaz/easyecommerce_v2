class UserModel {
  int? id;
  String? username;
  String? email;
  String? provider;
  bool? confirmed;
  bool? blocked;
  String? permisos;

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
  });
  UserModel.empty()
      : id = 0,
        username = '',
        email = '',
        provider = '',
        confirmed = false,
        blocked = false,
        permisos = '';

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
    };
  }
}
