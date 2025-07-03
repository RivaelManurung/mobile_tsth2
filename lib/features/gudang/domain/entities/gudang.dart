import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/Model/user_model.dart';

class Gudang extends Equatable {
  final int id;
  final String name;
  final String? description;
  final User? user; // The operator/user responsible for the warehouse

  const Gudang({
    required this.id,
    required this.name,
    this.description,
    this.user,
  });

  @override
  List<Object?> get props => [id, name, description, user];
}