
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';

class TransactionTypeModel extends TransactionType {
  const TransactionTypeModel({
    required super.id,
    required super.name,
    super.slug,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory TransactionTypeModel.fromJson(Map<String, dynamic> json) {
    return TransactionTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}