import 'package:intl/intl.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final List<String>? roles;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photoUrl,
    this.roles,
    required this.createdAt,
  });

  // Add this empty factory constructor
  factory User.empty() {
    return User(
      id: 0,
      name: 'Guest User',
      email: 'guest@example.com',
      phone: null,
      address: null,
      photoUrl: null,
      roles: null,
      createdAt: DateTime.now(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    print('Parsing User JSON: $json'); // Debug print to inspect JSON
    return User(
      id: data['id'] as int? ?? 0, // Safe fallback for id
      name: data['name']?.toString() ?? 'Unknown', // Safe fallback for name
      email: data['email']?.toString() ?? 'unknown@example.com', // Fallback for missing email
      phone: data['phone']?.toString(),
      address: data['address']?.toString(),
      photoUrl: data['photo_url']?.toString(),
      roles: data['roles'] != null 
          ? List<String>.from(data['roles'])
          : null,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(), // Fallback for missing createdAt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
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