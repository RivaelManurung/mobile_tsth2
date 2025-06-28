import 'package:intl/intl.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? photoUrl;
  final List<String>? roles;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.photoUrl,
    this.roles,
    required this.createdAt,
  });

  factory User.empty() {
    return User(
      id: 0,
      name: 'Guest User',
      email: 'guest@example.com',
      phoneNumber: null,
      address: null,
      photoUrl: null,
      roles: null,
      createdAt: DateTime.now(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    print('Parsing User JSON: $json');

    // Handle phone number dengan berbagai kemungkinan key
    String? phoneNumber;
    if (data['phone_number'] != null) {
      phoneNumber = data['phone_number']?.toString();
    } else if (data['phone'] != null) {
      phoneNumber = data['phone']?.toString();
    }

    // Handle photo URL dengan berbagai kemungkinan key
    String? photoUrl;
    if (data['photo_url'] != null) {
      photoUrl = data['photo_url']?.toString();
    } else if (data['avatar'] != null) {
      photoUrl = data['avatar']?.toString();
    }

    print('Parsed phone: $phoneNumber');
    print('Parsed photo: $photoUrl');

    return User(
      id: data['id'] as int? ?? 0,
      name: data['name']?.toString() ?? 'Unknown',
      email: data['email']?.toString() ?? 'unknown@example.com',
      phoneNumber: phoneNumber,
      address: data['address']?.toString(),
      photoUrl: photoUrl,
      roles: data['roles'] != null ? List<String>.from(data['roles']) : null,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'avatar': photoUrl,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber, // Changed from 'phone' to 'phone_number'
      'address': address,
      'photo_url': photoUrl,
    };
  }

  String get formattedJoinDate => DateFormat('MMMM dd, y').format(createdAt);

  String getInitials() {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }
}