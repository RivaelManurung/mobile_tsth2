import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  late Future<User> _userFuture;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getCurrentUser();
  }

  void _refreshUser() {
    setState(() {
      _userFuture = _userService.getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final user = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade800, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          Positioned(
                            right: -50,
                            top: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -30,
                            bottom: 80,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildProfileAvatar(user),
                                  const SizedBox(height: 16),
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        items: [
                          if (user.phone != null) _InfoItem(
                            icon: Icons.phone,
                            title: 'Phone',
                            value: user.phone!,
                          ),
                          if (user.address != null) _InfoItem(
                            icon: Icons.location_on,
                            title: 'Address',
                            value: user.address!,
                          ),
                          _InfoItem(
                            icon: Icons.calendar_today,
                            title: 'Join Date',
                            value: user.formattedJoinDate,
                          ),
                          _InfoItem(
                            icon: Icons.people,
                            title: 'Role',
                            value: user.roles?.join(', ') ?? 'No Role',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        title: 'Account Settings',
                        icon: Icons.settings,
                        items: [
                          _InfoItem(
                            icon: Icons.lock,
                            title: 'Change Password',
                            isAction: true,
                            onTap: () => _showUpdatePasswordDialog(context),
                          ),
                          _InfoItem(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            isAction: true,
                            onTap: () => _navigateToEditProfile(context, user),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showLogoutDialog(context),
                          child: const Text('Log Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(User user) {
    return Hero(
      tag: 'profile-avatar',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: ClipOval(
          child: user.photoUrl != null
              ? Image.network(
                  '${_userService.baseUrl}/storage/${user.photoUrl}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(user),
                )
              : _buildInitialsAvatar(user),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildInfoItem(item, items)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(_InfoItem item, List<_InfoItem> items) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.value != null)
                        Text(
                          item.value!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.isAction)
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (item != items.last)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }

  Future<void> _navigateToEditProfile(BuildContext context, User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );
    
    if (result != null && result is User) {
      _refreshUser();
    }
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  await _userService.changePassword(
                    currentPassword: oldPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _userService.logout();
                  await _storage.delete(key: 'auth_token');
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['data']['id'],
      name: json['name'] ?? json['data']['name'],
      email: json['email'] ?? json['data']['email'],
      phone: json['phone'] ?? json['data']['phone'],
      address: json['address'] ?? json['data']['address'],
      photoUrl: json['photo_url'] ?? json['data']['photo_url'],
      roles: json['roles'] != null 
          ? List<String>.from(json['roles'] ?? json['data']['roles'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? json['data']['created_at']),
    );
  }

  String get formattedJoinDate => DateFormat('MMMM dd, y').format(createdAt);
}

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    headers: {'Accept': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();

  String get baseUrl => _dio.options.baseUrl;

  Future<User> getCurrentUser() async {
    final token = await _storage.read(key: 'auth_token');
    
    try {
      final response = await _dio.get(
        '/auth/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return User.fromJson(response.data);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateUser(int userId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'auth_token');
    
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    
    try {
      await _dio.post(
        '/users/change-password',
        data: {
          'old_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: 'auth_token');
    
    try {
      await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioError e) {
    if (e.response?.data != null) {
      if (e.response?.data['message'] != null) {
        return e.response!.data['message'];
      }
      if (e.response?.data['error'] != null) {
        return e.response!.data['error'];
      }
    }
    return e.message ?? 'An error occurred';
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String? value;
  final bool isAction;
  final VoidCallback? onTap;

  _InfoItem({
    required this.icon,
    required this.title,
    this.value,
    this.isAction = false,
    this.onTap,
  });
}

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedUser = await _userService.updateUser(
        widget.user.id,
        {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
          'address': _addressController.text.isEmpty ? null : _addressController.text,
        },
      );
      
      if (mounted) {
        Navigator.pop(context, updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}