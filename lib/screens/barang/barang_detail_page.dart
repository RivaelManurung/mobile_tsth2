// lib/screens/barang/barang_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';
import 'package:inventory_tsth2/screens/barang/barang_form_page.dart';
import 'package:inventory_tsth2/widget/loading_indicator.dart';


class BarangDetailPage extends StatelessWidget {
  final BarangController _controller = Get.find();

  BarangDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final barangId = Get.arguments as int;
    _controller.fetchBarangById(barangId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _controller.namaController.text =
                  _controller.selectedBarang.value?.barangNama ?? '';
              _controller.hargaController.text =
                  _controller.selectedBarang.value?.barangHarga.toString() ?? '';
              _controller.stokController.text =
                  _controller.selectedBarang.value?.stokTersedia.toString() ?? '';
              Get.to(() => BarangFormPage(), arguments: barangId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await Get.dialog(
                AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this item?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await _controller.deleteBarang(barangId);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const LoadingIndicator();
        }
        if (_controller.selectedBarang.value == null) {
          return const Center(child: Text('Item not found'));
        }
        final barang = _controller.selectedBarang.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    barang.barangNama.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 40, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Name', barang.barangNama),
              _buildDetailRow('Price', '\$${barang.barangHarga}'),
              _buildDetailRow('Available Stock', barang.stokTersedia.toString()),
              _buildDetailRow('Slug', barang.barangSlug),
              _buildDetailRow('Created At',
                  '${barang.createdAt.day}/${barang.createdAt.month}/${barang.createdAt.year}'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}