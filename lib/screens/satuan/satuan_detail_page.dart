import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Satuan/Satuan_controller.dart';
import 'package:inventory_tsth2/screens/satuan/satuan_form_page.dart';

class SatuanDetailPage extends StatelessWidget {
  SatuanDetailPage({super.key});

  final SatuanController _controller = Get.find<SatuanController>();

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments as int;
    _controller.fetchSatuanById(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Unit Details',
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
        final satuan = _controller.selectedSatuan.value;
        if (satuan == null) {
          return const Center(
            child: Text(
              'Unit not found',
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
                satuan.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description: ${satuan.description ?? 'No description'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Slug: ${satuan.slug}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Created by User ID: ${satuan.userId}',
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
                      _controller.nameController.text = satuan.name;
                      _controller.descriptionController.text = satuan.description ?? '';
                      Get.to(() => SatuanFormPage(), arguments: satuan.id);
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
                        title: 'Delete Unit',
                        middleText: 'Are you sure you want to delete ${satuan.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.deleteSatuan(satuan.id);
                        },
                      );
                    },
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Restore Unit',
                        middleText: 'Are you sure you want to restore ${satuan.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.restoreSatuan(satuan.id);
                        },
                      );
                    },
                    child: const Text('Restore'),
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