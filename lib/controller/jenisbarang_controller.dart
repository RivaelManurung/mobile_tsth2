import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/jenis_barang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/jenis_barang_service.dart';

class JenisBarangController extends GetxController {
  final JenisBarangService _service;

  // Reactive state variables
  final RxList<JenisBarang> jenisBarangList = <JenisBarang>[].obs;
  final RxList<JenisBarang> filteredJenisBarang = <JenisBarang>[].obs;
  final Rx<JenisBarang?> selectedJenisBarang = Rx<JenisBarang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString listErrorMessage = ''.obs; // Added for list-specific errors
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  JenisBarangController({JenisBarangService? service})
      : _service = service ?? JenisBarangService();

  @override
  void onInit() {
    super.onInit();
    fetchAllJenisBarang();

    // Listen to changes in the searchController and update searchQuery
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Use debounce on the reactive searchQuery
    debounce(searchQuery, (_) => filterJenisBarang(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchAllJenisBarang() async {
    try {
      isLoading(true);
      listErrorMessage(''); // Clear list-specific error
      final jenisBarang = await _service.getAllJenisBarang();
      jenisBarangList.assignAll(jenisBarang);
      filterJenisBarang();
    } catch (e) {
      listErrorMessage(e.toString()); // Set list-specific error
      if (listErrorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getJenisBarangById(int id) async {
    try {
      isLoading(true);
      errorMessage(''); // Clear general error for detail view
      final jenisBarang = await _service.getJenisBarangById(id);
      selectedJenisBarang(jenisBarang);
    } catch (e) {
      errorMessage(e.toString()); // Set general error for detail view
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createJenisBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      final newJenisBarang = await _service.createJenisBarang(data);
      jenisBarangList.add(newJenisBarang);
      filterJenisBarang();
      Get.back();
      Get.snackbar('Success', 'Item type created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      final updatedJenisBarang = await _service.updateJenisBarang(id, data);
      final index = jenisBarangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        jenisBarangList[index] = updatedJenisBarang;
        filterJenisBarang();
      }
      selectedJenisBarang(updatedJenisBarang);
      Get.back();
      Get.snackbar('Success', 'Item type updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteJenisBarang(id);
      if (success) {
        jenisBarangList.removeWhere((item) => item.id == id);
        filterJenisBarang();
        Get.back();
        Get.snackbar('Success', 'Item type deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredJenisBarang = await _service.restoreJenisBarang(id);
      final index = jenisBarangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        jenisBarangList[index] = restoredJenisBarang;
        filterJenisBarang();
      }
      selectedJenisBarang(restoredJenisBarang);
      Get.snackbar('Success', 'Item type restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.forceDeleteJenisBarang(id);
      if (success) {
        jenisBarangList.removeWhere((item) => item.id == id);
        filterJenisBarang();
        Get.back();
        Get.snackbar('Success', 'Item type permanently deleted',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterJenisBarang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredJenisBarang.assignAll(jenisBarangList);
    } else {
      filteredJenisBarang.assignAll(
        jenisBarangList.where((item) =>
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
    selectedJenisBarang(null);
  }

  void resetErrorForListPage() {
    listErrorMessage(''); // Reset list-specific error
  }
}