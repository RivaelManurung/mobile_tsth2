import 'package:equatable/equatable.dart';

class TransactionType extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TransactionType({
    required this.id,
    required this.name,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, name, slug, createdAt, updatedAt, deletedAt];
}