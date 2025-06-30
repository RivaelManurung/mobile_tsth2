import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/controller/profile_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/user_services.dart';
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

  // Palet warna yang selaras dengan Dashboard
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color backgroundColor = const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = ProfileController(userService: UserService());
      _userFuture = _controller.getCurrentUser();

      _userFuture!.catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
          });
        }
        return User.empty();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Initialization error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Konfirmasi Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin keluar dari akun ini?',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: const Color(0xFF6F767E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF6F767E),
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _performLogout();
                      },
                      child: Text('Logout',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Future<void> _performLogout() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _controller.logout();
      Get.back(); // Close the loading dialog
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.login, (route) => false);
    } catch (e) {
      Get.back(); // Close the loading dialog
      Get.snackbar('Logout Gagal', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : FutureBuilder<User>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == User.empty()) {
                      return _buildErrorWidget(
                          error: snapshot.error?.toString());
                    }

                    final user = snapshot.data!;
                    final isSmallScreen =
                        MediaQuery.of(context).size.width < 400;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildProfileHeader(user, isSmallScreen),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildPersonalInfoCard(user, isSmallScreen),
                              const SizedBox(height: 16),
                              _buildAccountSettingsCard(isSmallScreen),
                              const SizedBox(height: 24),
                              _buildLogoutButton(isSmallScreen),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildErrorWidget({String? error}) {
    final displayError = error ?? _errorMessage ?? 'An unknown error occurred.';
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text('Gagal Memuat Profil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 8),
            Text(
              displayError,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6F767E),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (displayError.contains('No token found') ||
                displayError.contains('Unauthenticated'))
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RoutesName.login, (route) => false);
                  },
                  child: Text('Kembali ke Login',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
    );
  }

  SliverAppBar _buildProfileHeader(User user, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 240 : 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProfileAvatar(user, isSmallScreen),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 22 : 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 4),
                      Text(
                        user.email!,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(User user, bool isSmallScreen) {
    return Hero(
      tag: 'profileadrenergic-avatar',
      child: GestureDetector(
        onTap: () => _navigateToEditProfile(context),
        child: Container(
          width: isSmallScreen ? 100 : 120,
          height: isSmallScreen ? 100 : 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? Image.network(
                    _controller.getPhotoUrl(user.photoUrl!),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)),
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(user, isSmallScreen),
                  )
                : _buildInitialsAvatar(user, isSmallScreen),
          ),
        ),
      ),
    )
        .animate()
        .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn();
  }

  Widget _buildInitialsAvatar(User user, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF4338CA)],
        ),
      ),
      child: Center(
        child: Text(
          user.getInitials(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isSmallScreen ? 36 : 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(User user, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pribadi',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D1F),
            ),
          ),
          const SizedBox(height: 12),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            _buildInfoItem(
              icon: Icons.phone_outlined,
              title: 'Telepon',
              value: user.phoneNumber!,
              isSmallScreen: isSmallScreen,
            ),
          if (user.address != null && user.address!.isNotEmpty)
            _buildInfoItem(
              icon: Icons.location_on_outlined,
              title: 'Alamat',
              value: user.address!,
              isSmallScreen: isSmallScreen,
            ),
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            title: 'Tanggal Bergabung',
            value: user.formattedJoinDate,
            isSmallScreen: isSmallScreen,
          ),
          _buildInfoItem(
            icon: Icons.shield_outlined,
            title: 'Roles',
            value: user.roles
                    ?.map((r) => r[0].toUpperCase() + r.substring(1))
                    .join(', ') ??
                'No Roles',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: isSmallScreen ? 18 : 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              'Pengaturan Akun',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1F),
              ),
            ),
          ),
          _buildActionItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            isSmallScreen: isSmallScreen,
            onTap: () => _showUpdatePasswordDialog(context),
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          _buildActionItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            isSmallScreen: isSmallScreen,
            onTap: () => _navigateToEditProfile(context),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: isSmallScreen ? 20 : 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1D1F),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Color(0xFF6F767E)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isSmallScreen) {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Logout',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms)
        .slideY(begin: 0.4, duration: 500.ms, curve: Curves.easeOut);
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    final user = await _userFuture;
    if (user == null || user == User.empty()) {
      Get.snackbar('Error', 'Data pengguna tidak tersedia untuk diedit.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );

    if (result == true && mounted) {
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ubah Password',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  _buildPasswordTextField(
                      controller: oldPasswordController,
                      label: 'Password Saat Ini'),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(
                      controller: newPasswordController,
                      label: 'Password Baru'),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(
                      controller: confirmPasswordController,
                      label: 'Konfirmasi Password Baru'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade700)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Client-side validation
                          final newPassword = newPasswordController.text;
                          if (newPassword.length < 8) {
                            Get.snackbar('Error',
                                'Password baru minimal 8 karakter.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                            return;
                          }
                          if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).+$')
                              .hasMatch(newPassword)) {
                            Get.snackbar('Error',
                                'Password baru harus mengandung huruf besar, huruf kecil, dan simbol.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                            return;
                          }
                          if (newPassword != confirmPasswordController.text) {
                            Get.snackbar('Error',
                                'Konfirmasi password baru tidak cocok.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                            return;
                          }

                          try {
                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );
                            await _controller.changePassword(
                              currentPassword: oldPasswordController.text,
                              newPassword: newPasswordController.text,
                            );
                            Get.back(); // Close the loading dialog
                            Navigator.pop(context); // Close the dialog
                            Get.snackbar('Sukses',
                                'Password berhasil diperbarui.',
                                backgroundColor: Colors.green,
                                colorText: Colors.white);
                          } catch (e) {
                            Get.back(); // Close the loading dialog
                            String errorMessage =
                                'Gagal mengubah password: $e';
                            if (e.toString().contains('current_password')) {
                              errorMessage = 'Password saat ini salah.';
                            } else if (e
                                .toString()
                                .contains('new_password')) {
                              errorMessage =
                                  'Password baru tidak memenuhi persyaratan.';
                            }
                            Get.snackbar('Error', errorMessage,
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                          }
                        },
                        child: Text('Simpan',
                            style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn().scale();
      },
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.poppins(color: const Color(0xFF1A1D1F)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
      ),
    );
  }
}