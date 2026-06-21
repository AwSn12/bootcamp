class UserModel {
  final int id;
  final String nama;
  final String role;

  UserModel({required this.id, required this.nama, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'role': role};

  bool get isAdmin => role == 'ADMIN';
  bool get isKurir => role == 'KURIR';
  bool get isUser => role == 'USER';

  String get initials => nama.length >= 2 ? nama.substring(0, 2).toUpperCase() : nama.toUpperCase();
}
