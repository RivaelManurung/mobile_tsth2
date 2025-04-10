import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/controller/Profile/profile_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/user_services.dart';
import 'package:inventory_tsth2/widget/info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _controller;
  Future<User>? _userFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _controller = ProfileController(userService: UserService(prefs: prefs));
      setState(() {
        _userFuture = _controller.getCurrentUser().catchError((error) {
          setState(() {
            _errorMessage = 'Failed to load profile: ${error.toString()}';
          });
          return User.empty();
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Initialization error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _refreshUser() {
    setState(() {
      _errorMessage = null;
      _userFuture = _controller.getCurrentUser().catchError((error) {
        setState(() {
          _errorMessage = 'Failed to update profile: ${error.toString()}';
        });
        return User.empty();
      });
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Confirm Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6F767E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF6F767E)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _performLogout(context);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _controller.logout(context);
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.login,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() {
          _errorMessage = null;
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data ?? User.empty();
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildProfileHeader(user),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPersonalInfoCard(user),
                    const SizedBox(height: 16),
                    _buildAccountSettingsCard(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildProfileHeader(User user) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4E6AFF),
                Color(0xFF3A56E6),
              ],
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
          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? Image.network(
                  _controller.getPhotoUrl(user.photoUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      _buildInitialsAvatar(user),
                )
              : _buildInitialsAvatar(user),
        ),
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildInitialsAvatar(User user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4E6AFF),
            Color(0xFF3A56E6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          user.getInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(User user) {
    return InfoCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      items: [
        if (user.phone != null && user.phone!.isNotEmpty)
          InfoItem(
            icon: Icons.phone,
            title: 'Phone',
            value: user.phone!, // Fixed: Added required value parameter
          ),
        if (user.address != null && user.address!.isNotEmpty)
          InfoItem(
            icon: Icons.location_on,
            title: 'Address',
            value: user.address!, // Fixed: Added required value parameter
          ),
        InfoItem(
          icon: Icons.calendar_today,
          title: 'Join Date',
          value: user.formattedJoinDate,
        ),
        InfoItem(
          icon: Icons.people,
          title: 'Roles',
          value: user.roles?.join(', ') ?? 'No Roles',
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 20);
  }

  Widget _buildAccountSettingsCard() {
    return InfoCard(
      title: 'Account Settings',
      icon: Icons.settings,
      items: [
        InfoItem(
          icon: Icons.lock,
          title: 'Change Password',
          value: '', // Added an empty string as a placeholder for the required value
          isAction: true,
          onTap: () => _showUpdatePasswordDialog(context),
        ),
        InfoItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          value:'',
          isAction: true,
          onTap: () => _navigateToEditProfile(context),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 20);
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _showLogoutDialog(context),
        child: const Text('Logout'),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 20);
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    try {
      final user = await _userFuture;
      if (user == null || user == User.empty()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(  // Fixed: Removed const
            content: Text('No user data available'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(user: user),
        ),
      );

      if (result != null && mounted) {
        _refreshUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      ),
                      onPressed: () async {
                        if (newPasswordController.text != 
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(  // Fixed: Removed const
                              content: Text('New passwords do not match'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          await _controller.changePassword(
                            currentPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(  // Fixed: Removed const
                                content: Text('Password updated successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}