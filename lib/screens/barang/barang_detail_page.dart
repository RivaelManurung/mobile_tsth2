import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';
import 'package:inventory_tsth2/screens/barang/barang_form_page.dart';

class BarangDetailPage extends StatelessWidget {
  final BarangController _controller = Get.find();

  BarangDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barangId = Get.arguments as int;
    _controller.getBarangById(barangId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.to(
              () => BarangFormPage(isEdit: true, barangId: barangId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, barangId),
          ),
        ],
      ),
      body: Obx(() {
        final barang = _controller.selectedBarang.value;
        if (barang == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (barang.barangGambar != null)
                Center(
                  child: Image.network(
                    barang.barangGambar!,
                    height: 200,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Nama: ${barang.barangNama}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Kode: ${barang.barangKode}'),
              const SizedBox(height: 8),
              Text('Harga: Rp ${barang.barangHarga}'),
              const SizedBox(height: 8),
              Text('Jenis Barang ID: ${barang.jenisbarangId}'),
              const SizedBox(height: 8),
              Text('Satuan ID: ${barang.satuanId}'),
              const SizedBox(height: 8),
              Text('Kategori ID: ${barang.barangcategoryId}'),
              const SizedBox(height: 8),
              Text('Dibuat: ${barang.createdAt}'),
              const SizedBox(height: 8),
              Text('Diupdate: ${barang.updatedAt}'),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: const Text('Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _controller.deleteBarang(id);
              Get.back();
              Get.back();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}