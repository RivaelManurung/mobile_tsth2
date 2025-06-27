import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/edit_profile_controler.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileController _controller;
  late User _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUpdatingAvatar = false;
  File? _selectedImage;
  final AuthController _authController = Get.find<AuthController>();

  final Color primaryColor = const Color(0xFF4F46E5);
  final Color backgroundColor = const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      setState(() {
        _controller = EditProfileController(user: _currentUser);
        _isLoading = false;
      });
      // Log initial avatar URL
      print('Initial avatar URL: ${_controller.getPhotoUrl(_currentUser.photoUrl)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _updateAvatar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _updateAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUpdatingAvatar = true;
    });

    try {
      final updatedUser = await _controller.updateAvatar(_selectedImage!);
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
          _controller.nameController.text = _currentUser.name;
          _controller.emailController.text = _currentUser.email;
          _controller.phoneController.text = _currentUser.phoneNumber ?? '';
          _controller.addressController.text = _currentUser.address ?? '';
          _selectedImage = null;
        });
        _authController.updateUser(updatedUser);
        if (_currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty) {
          final avatarUrl = _controller.getPhotoUrl(_currentUser.photoUrl!);
          print('Clearing cache for: $avatarUrl');
          await CachedNetworkImage.evictFromCache(avatarUrl);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar berhasil diperbarui', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui avatar: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
    }
  }

  Future<void> _deleteAvatar() async {
    setState(() {
      _isUpdatingAvatar = true;
    });

    try {
      final updatedUser = await _controller.deleteAvatar();
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
          _controller.nameController.text = _currentUser.name;
          _controller.emailController.text = _currentUser.email;
          _controller.phoneController.text = _currentUser.phoneNumber ?? '';
          _controller.addressController.text = _currentUser.address ?? '';
        });
        _authController.updateUser(updatedUser);
        if (_currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty) {
          final avatarUrl = _controller.getPhotoUrl(_currentUser.photoUrl!);
          print('Clearing cache for: $avatarUrl');
          await CachedNetworkImage.evictFromCache(avatarUrl);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar berhasil dihapus', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus avatar: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_controller.formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = User(
        id: _currentUser.id,
        name: _controller.nameController.text,
        email: _controller.emailController.text,
        phoneNumber: _controller.phoneController.text.isEmpty
            ? null
            : _controller.phoneController.text,
        address: _controller.addressController.text.isEmpty
            ? null
            : _controller.addressController.text,
        photoUrl: _currentUser.photoUrl,
        roles: _currentUser.roles,
        createdAt: _currentUser.createdAt,
      );

      final savedUser = await _controller.saveProfile(updatedUser);
      if (mounted) {
        setState(() {
          _currentUser = savedUser;
        });
        _authController.updateUser(savedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!_isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: primaryColor,
                    size: 28,
                  ),
                  onPressed: _saveProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildFormSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Hero(
          tag: 'profile-avatar',
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.5), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image.file error: $error');
                        return _buildInitialsAvatar();
                      },
                    )
                  : (_currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _controller.getPhotoUrl(_currentUser.photoUrl!),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            print('EditProfile avatar load error: $error, URL: $url');
                            return _buildInitialsAvatar();
                          },
                          cacheKey: '${_currentUser.photoUrl}_${_currentUser.id}',
                        )
                      : _buildInitialsAvatar()),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isUpdatingAvatar ? null : _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isUpdatingAvatar
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: primaryColor,
                        size: 24,
                      ),
              ),
            ),
            if (_currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty)
              const SizedBox(height: 8),
            if (_currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty)
              GestureDetector(
                onTap: _isUpdatingAvatar ? null : _deleteAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _controller.formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _controller.nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              validator: _controller.validateName,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _controller.emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _controller.validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _controller.phoneController,
              label: 'Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _controller.validatePhone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _controller.addressController,
              label: 'Alamat',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              validator: _controller.validateAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: const Color(0xFF1A1D1F)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'Simpan Perubahan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF4338CA)],
        ),
      ),
      child: Center(
        child: Text(
          _currentUser.getInitials(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}