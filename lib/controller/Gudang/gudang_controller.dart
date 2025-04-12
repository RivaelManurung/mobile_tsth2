import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/gudang_service.dart';

class GudangController extends GetxController {
  final GudangService _service;

  // Reactive state variables
  final RxList<Gudang> gudangList = <Gudang>[].obs;
  final RxList<Gudang> filteredGudang = <Gudang>[].obs;
  final Rx<Gudang?> selectedGudang = Rx<Gudang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  GudangController({GudangService? service})
      : _service = service ?? GudangService();

  @override
  void onInit() {
    super.onInit();
    fetchAllGudang();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterGudang(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchAllGudang() async {
    try {
      print('Fetching gudang...');
      isLoading(true);
      errorMessage('');
      final gudang = await _service.getAllGudang();
      gudangList.assignAll(gudang);
      filterGudang();
      print('Gudang fetched successfully');
    } catch (e) {
      print('Error fetching gudang: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getGudangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final gudang = await _service.getGudangById(id);
      selectedGudang(gudang);
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createGudang() async {
    try {
      isLoading(true);
      errorMessage('');

      // Validasi input
      final name = nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Nama gudang tidak boleh kosong');
      }
      final description = descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null;

      final data = {
        'name': name,
        if (description != null) 'description': description,
      };

      final newGudang = await _service.createGudang(data);
      gudangList.add(newGudang);
      filterGudang();

      Get.snackbar(
        'Berhasil',
        'Gudang berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      print('Error creating gudang: $e');
      errorMessage(e.toString());
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateGudang(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      // Validasi input
      final name = nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Nama gudang tidak boleh kosong');
      }
      final description = descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null;

      final data = {
        'name': name,
        if (description != null) 'description': description,
      };

      final updatedGudang = await _service.updateGudang(id, data);
      final index = gudangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        gudangList[index] = updatedGudang;
        filterGudang();
      }
      selectedGudang(updatedGudang);

      Get.snackbar(
        'Berhasil',
        'Gudang berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      print('Error updating gudang: $e');
      errorMessage(e.toString());
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteGudang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteGudang(id);
      if (success) {
        gudangList.removeWhere((item) => item.id == id);
        filterGudang();
        Get.snackbar(
          'Berhasil',
          'Gudang berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('Error deleting gudang: $e');
      errorMessage(e.toString());
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading(false);
    }
  }

  void filterGudang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredGudang.assignAll(gudangList);
    } else {
      filteredGudang.assignAll(
        gudangList.where((item) =>
            item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false)),
      );
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedGudang(null);
  }
}