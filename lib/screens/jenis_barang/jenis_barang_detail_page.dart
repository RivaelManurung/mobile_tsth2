import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/JenisBarang/jenisbarang_controller.dart';
import 'package:inventory_tsth2/screens/jenis_barang/jenis_barang_form_page.dart';

class JenisBarangDetailPage extends StatelessWidget {
  JenisBarangDetailPage({super.key});

  final JenisBarangController _controller = Get.find<JenisBarangController>();

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments as int;
    _controller.fetchJenisBarangById(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Item Type Details',
          style: TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
            ),
          );
        }
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              _controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
        final jenisBarang = _controller.selectedJenisBarang.value;
        if (jenisBarang == null) {
          return const Center(
            child: Text(
              'Item type not found',
              style: TextStyle(
                color: Color(0xFF6F767E),
                fontSize: 16,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jenisBarang.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description: ${jenisBarang.description ?? 'No description'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Slug: ${jenisBarang.slug}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Created by User ID: ${jenisBarang.userId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E6AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _controller.nameController.text = jenisBarang.name;
                      _controller.descriptionController.text = jenisBarang.description ?? '';
                      Get.to(() => JenisBarangFormPage(), arguments: jenisBarang.id);
                    },
                    child: const Text('Edit'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Delete Item Type',
                        middleText: 'Are you sure you want to delete ${jenisBarang.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.deleteJenisBarang(jenisBarang.id);
                        },
                      );
                    },
                    child: const Text('Delete'),
                  ),
                  // Optional: Add buttons for restore and force delete
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Restore Item Type',
                        middleText: 'Are you sure you want to restore ${jenisBarang.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.restoreJenisBarang(jenisBarang.id);
                        },
                      );
                    },
                    child: const Text('Restore'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Force Delete Item Type',
                        middleText: 'Are you sure you want to permanently delete ${jenisBarang.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.forceDeleteJenisBarang(jenisBarang.id);
                        },
                      );
                    },
                    child: const Text('Force Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}