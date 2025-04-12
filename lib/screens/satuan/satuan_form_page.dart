import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Satuan/satuan_controller.dart';

class SatuanFormPage extends StatelessWidget {
  final bool isEdit;
  final int? satuanId;

  SatuanFormPage({super.key, required this.isEdit, this.satuanId});

  final SatuanController _controller = Get.find<SatuanController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Satuan' : 'Tambah Satuan',
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
          onPressed: () => Get.back(),
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
                    // Field Nama Satuan
                    TextField(
                      controller: _controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Satuan',
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
                        labelText: 'Deskripsi',
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
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            // Tombol Simpan
            Obx(() => ElevatedButton(
                  onPressed: _controller.isLoading.value
                      ? null
                      : () async {
                          if (isEdit && satuanId != null) {
                            await _controller.updateSatuan(satuanId!);
                            if (_controller.errorMessage.value.isEmpty) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'Satuan berhasil diperbarui',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } else {
                              Get.snackbar(
                                'Gagal',
                                _controller.errorMessage.value,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            }
                          } else {
                            await _controller.createSatuan();
                            if (_controller.errorMessage.value.isEmpty) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'Satuan berhasil ditambahkan',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } else {
                              Get.snackbar(
                                'Gagal',
                                _controller.errorMessage.value,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            }
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
                          isEdit ? 'Simpan Perubahan' : 'Tambah Satuan',
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