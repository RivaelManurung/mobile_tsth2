import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';

class GudangModel extends Gudang {
  const GudangModel({
    required super.id,
    required super.name,
    super.description,
    super.user,
  });

  factory GudangModel.fromJson(Map<String, dynamic> json) {
    return GudangModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      user: json['user'] != null ? UserModel.fromUserJson(json['user']) as User : null,
    );
  }
}