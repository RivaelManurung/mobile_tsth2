import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';

class BarangFormPage extends StatelessWidget {
  final BarangController _controller = Get.find();
  final bool isEdit;
  final int? barangId;

  BarangFormPage({this.isEdit = false, this.barangId, Key? key}) : super(key: key) {
    if (isEdit && barangId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.getBarangById(barangId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Create Barang'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: _controller.namaController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller.hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller.kodeController,
                  decoration: const InputDecoration(labelText: 'Kode Barang'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                // Image Picker
                if (_controller.imagePath.isNotEmpty)
                  Image.file(
                    File(_controller.imagePath.value),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ElevatedButton(
                  onPressed: _controller.pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEdit) {
                        _controller.updateBarang(barangId!);
                      } else {
                        _controller.createBarang();
                      }
                    },
                    child: Text(isEdit ? 'Update' : 'Create'),
                  ),
                ),
                
                // Error Message
                if (_controller.errorMessage.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}