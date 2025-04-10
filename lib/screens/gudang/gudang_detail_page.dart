import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/screens/gudang/gudang_form_page.dart';
import 'package:inventory_tsth2/controller/Gudang/gudang_controller.dart';

class GudangDetailPage extends StatelessWidget {
  GudangDetailPage({super.key});

  final GudangController _controller = Get.find<GudangController>();

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments as int;
    _controller.fetchGudangById(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Warehouse Details',
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
        final gudang = _controller.selectedGudang.value;
        if (gudang == null) {
          return const Center(
            child: Text(
              'Warehouse not found',
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
                gudang.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description: ${gudang.description ?? 'No description'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Slug: ${gudang.slug}',
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
                      _controller.nameController.text = gudang.name;
                      _controller.descriptionController.text = gudang.description ?? '';
                      Get.to(() => GudangFormPage(), arguments: gudang.id);
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
                        title: 'Delete Warehouse',
                        middleText: 'Are you sure you want to delete ${gudang.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.deleteGudang(gudang.id);
                        },
                      );
                    },
                    child: const Text('Delete'),
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