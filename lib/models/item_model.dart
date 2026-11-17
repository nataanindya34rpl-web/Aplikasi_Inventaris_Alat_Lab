
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String itemId;
  final String itemName;
  final String category;
  final String code;
  final String status;
  final String image;
  final String specification;
  final DateTime createdAt;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.code,
    required this.status,
    required this.image,
    required this.specification,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'specification': specification,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory ItemModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final rawDate =
        map['created_at'] ?? map['createdAt'];

    DateTime date = DateTime.now();

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    }

    return ItemModel(
      itemId: (map['item_id'] ??
              map['itemId'] ??
              documentId ??
              '')
          .toString(),
      itemName: (map['item_name'] ??
              map['itemName'] ??
              map['ItemName'] ??
              '')
          .toString(),
      category: (map['category'] ?? '').toString(),
      code: (map['code'] ?? map['Code'] ?? '').toString(),
      status: (map['status'] ?? 'Available').toString(),
      image: (map['image'] ??
              map['imageUrl'] ??
              map['Image'] ??
              '')
          .toString()
          .trim(),
      specification: (map['specification'] ??
              map['spesification'] ??
              '')
          .toString(),
      createdAt: date,
    );
  }
}
