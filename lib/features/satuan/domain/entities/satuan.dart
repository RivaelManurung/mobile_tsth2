import 'package:equatable/equatable.dart';

class Satuan extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Satuan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, name, description, slug, createdAt, updatedAt, deletedAt];
}