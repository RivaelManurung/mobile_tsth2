import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Barang/barang_controller.dart';
import 'package:inventory_tsth2/screens/barang/barang_form_page.dart';

class BarangListPage extends StatelessWidget {
  final BarangController _controller = Get.put(BarangController());

  BarangListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _controller.clearForm();
              Get.to(() => BarangFormPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.selectedBarang.value != null) {
          return _buildDetailView();
        }

        return _buildListView();
      }),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller.searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _controller.filteredBarang.length,
            itemBuilder: (context, index) {
              final barang = _controller.filteredBarang[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _buildItemImage(barang.barangGambar),
                  title: Text(barang.barangNama),
                  subtitle: Text('Kode: ${barang.barangKode} - Harga: Rp${barang.barangHarga}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _controller.getBarangById(barang.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final barang = _controller.selectedBarang.value!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                barang.barangNama,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _controller.selectedBarang.value = null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Item Image
          Center(
            child: _buildDetailImage(barang.barangGambar),
          ),
          
          const SizedBox(height: 16),
          Text('Kode: ${barang.barangKode}'),
          const SizedBox(height: 8),
          Text('Harga: Rp${barang.barangHarga}'),
          const SizedBox(height: 8),
          Text('Jenis Barang ID: ${barang.jenisbarangId}'),
          const SizedBox(height: 8),
          Text('Satuan ID: ${barang.satuanId}'),
          const SizedBox(height: 8),
          Text('Kategori ID: ${barang.barangcategoryId}'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Get.to(() => BarangFormPage(isEdit: true, barangId: barang.id)),
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () => _showDeleteDialog(barang.id),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.inventory, size: 40);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );
  }

  Widget _buildDetailImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Column(
        children: [
          Icon(Icons.inventory, size: 100),
          Text('No Image Available'),
        ],
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100),
    );
  }

  void _showDeleteDialog(int id) {
    Get.defaultDialog(
      title: 'Delete Barang',
      middleText: 'Are you sure you want to delete this item?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        _controller.deleteBarang(id);
        Get.back();
      },
    );
  }
}