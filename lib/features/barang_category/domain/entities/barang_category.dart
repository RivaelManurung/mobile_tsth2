import 'package:equatable/equatable.dart';

class BarangCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const BarangCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, name, slug, createdAt, updatedAt, deletedAt];
}