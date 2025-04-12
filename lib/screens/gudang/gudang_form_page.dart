import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Gudang/gudang_controller.dart';

class GudangFormPage extends StatelessWidget {
  final bool isEdit;
  final int? gudangId;

  GudangFormPage({super.key, this.isEdit = false, this.gudangId});

  final GudangController _controller = Get.find<GudangController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Gudang' : 'Tambah Gudang'),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _controller.isLoading.value
                      ? null
                      : () async {
                          if (_controller.nameController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Gagal',
                              'Nama gudang tidak boleh kosong',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                            return;
                          }
                          if (isEdit && gudangId != null) {
                            await _controller.updateGudang(gudangId!);
                          } else {
                            await _controller.createGudang();
                          }
                          if (_controller.errorMessage.value.isEmpty) {
                            Get.back();
                          }
                        },
                  child: Text(isEdit ? 'Perbarui' : 'Simpan'),
                )),
          ],
        ),
      ),
    );
  }
}