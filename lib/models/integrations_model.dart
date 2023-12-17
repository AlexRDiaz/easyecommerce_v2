class IntegrationsModel {
  int? id;
  String? name;
  String? description;
  Null? storeUrl;
  String? userId;
  String? token;
  String? createdAt;
  String? updatedAt;

  IntegrationsModel(
      {this.id,
      this.name,
      this.description,
      this.storeUrl,
      this.userId,
      this.token,
      this.createdAt,
      this.updatedAt});

  IntegrationsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    storeUrl = json['store_url'];
    userId = json['user_id'];
    token = json['token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['store_url'] = this.storeUrl;
    data['user_id'] = this.userId;
    data['token'] = this.token;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
