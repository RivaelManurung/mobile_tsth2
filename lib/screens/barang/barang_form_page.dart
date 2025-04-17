import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';

class BarangFormPage extends StatelessWidget {
  final BarangController _controller = Get.find();
  final bool isEdit;
  final int? barangId;

  BarangFormPage({this.isEdit = false, this.barangId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEdit && barangId != null) {
      _controller.getBarangById(barangId!);
    }

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
                // Add dropdowns for jenisbarang, satuan, and category
                // Example for jenisbarang dropdown:
                // DropdownButtonFormField<int>(
                //   value: _controller.selectedJenisBarangId.value,
                //   items: jenisBarangList.map((jenis) {
                //     return DropdownMenuItem(
                //       value: jenis.id,
                //       child: Text(jenis.nama),
                //     );
                //   }).toList(),
                //   onChanged: (value) => _controller.selectedJenisBarangId.value = value!,
                //   decoration: InputDecoration(labelText: 'Jenis Barang'),
                // ),
                const SizedBox(height: 16),
                // Image picker
                if (_controller.imagePath.isNotEmpty)
                  Image.network(_controller.imagePath.value),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      _controller.imagePath.value = pickedFile.path;
                    }
                  },
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 24),
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