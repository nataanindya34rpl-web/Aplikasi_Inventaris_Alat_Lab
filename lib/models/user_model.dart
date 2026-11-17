import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String kelas;
  final DateTime createdAt;
  final String foto;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.kelas,
    required this.createdAt,
    this.foto = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'kelas': kelas,
      'created_at': Timestamp.fromDate(createdAt),
      'foto': foto,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawDate =
        map['created_at'] ?? map['createdAt'];

    DateTime date = DateTime.now();

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    }

    return UserModel(
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      kelas: (map['kelas'] ?? '').toString(),
      createdAt: date,
      foto: (map['foto'] ?? '').toString(),
    );
  }
}
