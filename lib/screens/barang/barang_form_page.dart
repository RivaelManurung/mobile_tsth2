// lib/screens/barang/barang_form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';
import 'package:inventory_tsth2/widget/loading_indicator.dart';


class BarangFormPage extends StatelessWidget {
  final BarangController _controller = Get.find();

  BarangFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = Get.arguments != null;
    if (isEdit) {
      _controller.getBarangById(Get.arguments as int);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'Add New Item'),
      ),
      body: Obx(() {
        if (isEdit && _controller.isLoading.value) {
          return const LoadingIndicator();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _controller.namaController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller.hargaController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller.stokController,
                decoration: const InputDecoration(
                  labelText: 'Available Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isEdit) {
                      await _controller.updateBarang(Get.arguments as int);
                    } else {
                      await _controller.createBarang();
                    }
                  },
                  child: _controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(isEdit ? 'Update Item' : 'Save Item'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}