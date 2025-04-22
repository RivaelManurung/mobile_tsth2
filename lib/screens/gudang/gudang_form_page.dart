// lib/screens/gudang/gudang_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/gudang_controller.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';

class GudangFormPage extends StatelessWidget {
  final bool isEdit;
  final int? gudangId;

  GudangFormPage({super.key, this.isEdit = false, this.gudangId});

  final GudangController _controller = Get.find<GudangController>();

  void _showSnackbar(String title, String message, {required bool isSuccess}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Gudang' : 'Tambah Gudang',
          style: const TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
          onPressed: () {
            _controller.clearForm();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Formulir
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Field Nama Gudang
                    TextField(
                      controller: _controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Gudang',
                        labelStyle: const TextStyle(color: Color(0xFF6F767E)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    // Field Deskripsi
                    TextField(
                      controller: _controller.descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        labelStyle: const TextStyle(color: Color(0xFF6F767E)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      maxLines: 3,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    // Dropdown Operator
                    Obx(() => DropdownButtonFormField<User>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Operator',
                            labelStyle: const TextStyle(color: Color(0xFF6F767E)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          value: _controller.selectedUser.value,
                          items: _controller.userList.map((User user) {
                            return DropdownMenuItem<User>(
                              value: user,
                              child: Row(
                                children: [
                                  Text(user.name),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${user.email})',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList().cast<DropdownMenuItem<User>>(),
                          onChanged: (User? newUser) {
                            _controller.selectedUser.value = newUser;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Pengguna operator wajib dipilih';
                            }
                            return null;
                          },
                        )).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            // Tombol Simpan/Perbarui
            Obx(() => ElevatedButton(
                  onPressed: _controller.isLoading.value
                      ? null
                      : () async {
                          // Validasi input
                          if (_controller.nameController.text.trim().isEmpty) {
                            _showSnackbar(
                              'Gagal',
                              'Nama gudang tidak boleh kosong',
                              isSuccess: false,
                            );
                            return;
                          }
                          if (_controller.selectedUser.value == null) {
                            _showSnackbar(
                              'Gagal',
                              'Pengguna operator wajib dipilih',
                              isSuccess: false,
                            );
                            return;
                          }

                          try {
                            if (isEdit && gudangId != null) {
                              await _controller.updateGudang(gudangId!);
                              if (_controller.errorMessage.value.isEmpty) {
                                Get.offNamed(RoutesName.gudangList, arguments: {
                                  'success': true,
                                  'message': 'Gudang berhasil diperbarui',
                                });
                              } else {
                                _showSnackbar(
                                  'Gagal',
                                  _controller.errorMessage.value,
                                  isSuccess: false,
                                );
                              }
                            } else {
                              await _controller.createGudang();
                              if (_controller.errorMessage.value.isEmpty) {
                                Get.offNamed(RoutesName.gudangList, arguments: {
                                  'success': true,
                                  'message': 'Gudang berhasil dibuat',
                                });
                              } else {
                                _showSnackbar(
                                  'Gagal',
                                  _controller.errorMessage.value,
                                  isSuccess: false,
                                );
                              }
                            }
                          } catch (e) {
                            _showSnackbar(
                              'Gagal',
                              e.toString(),
                              isSuccess: false,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Gudang',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2),
            // Tampilkan Pesan Error jika Ada
            Obx(() => _controller.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 300.ms),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}