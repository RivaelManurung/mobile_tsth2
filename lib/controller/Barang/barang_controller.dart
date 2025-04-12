import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_service.dart';

class BarangController extends GetxController {
  final BarangService _service;

  // Reactive state variables
  final RxList<Barang> barangList = <Barang>[].obs;
  final RxList<Barang> filteredBarang = <Barang>[].obs;
  final Rx<Barang?> selectedBarang = Rx<Barang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  BarangController({BarangService? service})
      : _service = service ?? BarangService();

  @override
  void onInit() {
    super.onInit();
    fetchAllBarang();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterBarang(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    super.onClose();
  }

  Future<void> fetchAllBarang() async {
    try {
      print('Fetching barang...');
      isLoading(true);
      errorMessage('');
      final barang = await _service.getAllBarang();
      barangList.assignAll(barang);
      filterBarang();
      print('Barang fetched successfully');
    } catch (e) {
      print('Error fetching barang: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

// lib/controllers/barang_controller.dart (hanya bagian relevan)
  Future<void> getBarangById(int id) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    final barang = await _service.getBarangById(id);
    selectedBarang.value = barang;
    print('Barang fetched: ${barang.barangNama}, ID: ${barang.id}, Stok: ${barang.stokTersedia}');
  } catch (e) {
    print('Error fetching barang: $e');
    errorMessage.value = e.toString();
    if (errorMessage.value.contains('No token found')) {
      Get.offAllNamed(RoutesName.login);
    }
  } finally {
    isLoading.value = false;
  }
}

  Future<void> createBarang() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {
        'barang_nama': namaController.text.trim(),
        'barang_harga': double.parse(hargaController.text),
        'stok_tersedia':
            int.parse(stokController.text), // Kirim ke gudang via API
        'gudang_id': 1, // Sesuaikan dengan logika backend
      };
      final newBarang = await _service.createBarang(data);
      barangList.add(newBarang);
      filterBarang();
      Get.back();
      Get.snackbar('Success', 'Barang created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBarang(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {
        'barang_nama': namaController.text.trim(),
        'barang_harga': double.parse(hargaController.text),
        'stok_tersedia': int.parse(stokController.text),
      };
      final updatedBarang = await _service.updateBarang(id, data);
      final index = barangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangList[index] = updatedBarang;
        filterBarang();
      }
      selectedBarang.value = updatedBarang;
      Get.back();
      Get.snackbar('Success', 'Barang updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteBarang(id);
      if (success) {
        barangList.removeWhere((item) => item.id == id);
        filterBarang();
        Get.back();
        Get.snackbar('Success', 'Barang deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredBarang = await _service.restoreBarang(id);
      final index = barangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangList[index] = restoredBarang;
        filterBarang();
      }
      selectedBarang(restoredBarang);
      Get.snackbar('Success', 'Barang restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.forceDeleteBarang(id);
      if (success) {
        barangList.removeWhere((item) => item.id == id);
        filterBarang();
        Get.back();
        Get.snackbar('Success', 'Barang permanently deleted',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterBarang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBarang.assignAll(barangList);
    } else {
      filteredBarang.assignAll(
        barangList
            .where((item) => item.barangNama.toLowerCase().contains(query)),
      );
    }
  }

  void clearForm() {
    namaController.clear();
    hargaController.clear();
    stokController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedBarang(null);
  }
}
