import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/Model/user_model.dart';

class Transaction {
  final int id;
  final String transactionCode;
  final String transactionDate;
  final User user;
  final TransactionType transactionType;
  final List<TransactionDetail> items;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.transactionCode,
    required this.transactionDate,
    required this.user,
    required this.transactionType,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    print('Parsing Transaction JSON: $json');
    return Transaction(
      id: json['id'] as int? ?? 0,
      transactionCode: json['transaction_code']?.toString() ?? '',
      transactionDate: json['transaction_date']?.toString() ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {'id': 0, 'name': 'Unknown'}),
      transactionType: TransactionType.fromJson(
          json['transaction_type'] as Map<String, dynamic>? ?? {'id': 0, 'name': 'Unknown'}),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) {
                print('Parsing TransactionDetail item: $item');
                return TransactionDetail.fromJson(item as Map<String, dynamic>? ?? {});
              })
              .toList() ??
          [],
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
class TransactionDetail {
  final Barang barang;
  final Gudang gudang;
  final int quantity;
  final String? tanggalKembali;

  TransactionDetail({
    required this.barang,
    required this.gudang,
    required this.quantity,
    this.tanggalKembali,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    print('Parsing TransactionDetail JSON: $json');
    return TransactionDetail(
      barang: Barang.fromJson(json['barang'] as Map<String, dynamic>? ?? {'id': 0, 'barang_nama': 'Unknown', 'barang_kode': 'UNKNOWN'}),
      gudang: Gudang.fromJson(json['gudang'] as Map<String, dynamic>? ?? {'id': 0, 'name': 'Unknown'}), // Perbaiki 'nama' menjadi 'name'
      quantity: json['quantity'] as int? ?? 0,
      tanggalKembali: json['tanggal_kembali']?.toString(),
    );
  }
}