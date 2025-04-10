import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/BarangCategory/barang_category_controller.dart';
import 'package:inventory_tsth2/screens/barang_category/barang_category_form_page.dart';

class BarangCategoryDetailPage extends StatelessWidget {
  BarangCategoryDetailPage({super.key});

  final BarangCategoryController _controller = Get.find<BarangCategoryController>();

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments as int;
    _controller.fetchBarangCategoryById(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Item Category Details',
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
        final category = _controller.selectedBarangCategory.value;
        if (category == null) {
          return const Center(
            child: Text(
              'Category not found',
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
                category.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Slug: ${category.slug}',
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
                      _controller.nameController.text = category.name;
                      Get.to(() => BarangCategoryFormPage(), arguments: category.id);
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
                        title: 'Delete Category',
                        middleText: 'Are you sure you want to delete ${category.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.deleteBarangCategory(category.id);
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