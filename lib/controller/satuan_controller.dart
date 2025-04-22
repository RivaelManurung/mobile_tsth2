import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/satuan_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/satuan_service.dart';

class SatuanController extends GetxController {
  final SatuanService _service;

  // Reactive state variables
  final RxList<Satuan> satuanList = <Satuan>[].obs;
  final RxList<Satuan> filteredSatuan = <Satuan>[].obs;
  final Rx<Satuan?> selectedSatuan = Rx<Satuan?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs; // General error message (e.g., for form operations)
  final RxString listErrorMessage = ''.obs; // Error message specific to list fetching
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  SatuanController({SatuanService? service})
      : _service = service ?? SatuanService();

  @override
  void onInit() {
    super.onInit();
    fetchAllSatuan();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterSatuan(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void resetErrorForListPage() {
    errorMessage('');
    listErrorMessage('');
  }

  Future<void> fetchAllSatuan() async {
    try {
      print('Fetching satuan...'); // Debug log
      isLoading(true);
      listErrorMessage('');
      final satuan = await _service.getAllSatuan();
      satuanList.assignAll(satuan);
      filterSatuan();
      print('Satuan fetched successfully'); // Debug log
    } catch (e) {
      print('Error fetching satuan: $e'); // Debug log
      listErrorMessage(e.toString());
      if (listErrorMessage.value.contains('No token found')) {
        print('Redirecting to login...'); // Debug log
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getSatuanById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final satuan = await _service.getSatuanById(id);
      selectedSatuan(satuan);
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createSatuan() async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      final newSatuan = await _service.createSatuan(data);
      satuanList.add(newSatuan);
      filterSatuan();
      Get.back();
      Get.snackbar('Success', 'Unit created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Gagal', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      final updatedSatuan = await _service.updateSatuan(id, data);
      final index = satuanList.indexWhere((item) => item.id == id);
      if (index != -1) {
        satuanList[index] = updatedSatuan;
        filterSatuan();
      }
      selectedSatuan(updatedSatuan);
      Get.back();
      Get.snackbar('Success', 'Unit updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Gagal', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteSatuan(id);
      if (success) {
        satuanList.removeWhere((item) => item.id == id);
        filterSatuan();
        Get.back();
        Get.snackbar('Success', 'Unit deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Gagal', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredSatuan = await _service.restoreSatuan(id);
      final index = satuanList.indexWhere((item) => item.id == id);
      if (index != -1) {
        satuanList[index] = restoredSatuan;
        filterSatuan();
      }
      selectedSatuan(restoredSatuan);
      Get.snackbar('Success', 'Unit restored successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Gagal', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.forceDeleteSatuan(id);
      if (success) {
        satuanList.removeWhere((item) => item.id == id);
        filterSatuan();
        Get.back();
        Get.snackbar('Success', 'Unit permanently deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Gagal', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void filterSatuan() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredSatuan.assignAll(satuanList);
    } else {
      filteredSatuan.assignAll(
        satuanList.where((item) =>
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
    selectedSatuan(null);
  }
}