import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/jenis_barang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/jenis_barang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JenisBarangController extends GetxController {
  final JenisBarangService _jenisBarangService;
  final RxList<JenisBarang> jenisBarangList = <JenisBarang>[].obs;
  final Rx<JenisBarang?> selectedJenisBarang = Rx<JenisBarang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  JenisBarangController({JenisBarangService? jenisBarangService})
      : _jenisBarangService = jenisBarangService ?? JenisBarangService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllJenisBarang();
    super.onInit();
  }

  Future<void> fetchAllJenisBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final jenisBarang = await _jenisBarangService.getAllJenisBarang();
      jenisBarangList.assignAll(jenisBarang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchJenisBarangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final jenisBarang = await _jenisBarangService.getJenisBarangById(id);
      selectedJenisBarang(jenisBarang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load jenis barang details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createJenisBarang() async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Item type name cannot be empty');
      }

      final newJenisBarang = await _jenisBarangService.createJenisBarang({
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      jenisBarangList.add(newJenisBarang);
      Get.back();
      Get.snackbar('Success', 'Jenis barang created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Item type name cannot be empty');
      }

      final updatedJenisBarang = await _jenisBarangService.updateJenisBarang(id, {
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      final index = jenisBarangList.indexWhere((jenisBarang) => jenisBarang.id == id);
      if (index != -1) {
        jenisBarangList[index] = updatedJenisBarang;
      }
      Get.back();
      Get.snackbar('Success', 'Jenis barang updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _jenisBarangService.deleteJenisBarang(id);
      jenisBarangList.removeWhere((jenisBarang) => jenisBarang.id == id);
      Get.back();
      Get.snackbar('Success', 'Jenis barang deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredJenisBarang = await _jenisBarangService.restoreJenisBarang(id);
      jenisBarangList.add(restoredJenisBarang);
      Get.snackbar('Success', 'Jenis barang restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to restore jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteJenisBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _jenisBarangService.forceDeleteJenisBarang(id);
      jenisBarangList.removeWhere((jenisBarang) => jenisBarang.id == id);
      Get.snackbar('Success', 'Jenis barang permanently deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to force delete jenis barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedJenisBarang(null);
  }

  List<JenisBarang> get filteredJenisBarang {
    if (searchController.text.isEmpty) {
      return jenisBarangList;
    } else {
      return jenisBarangList.where((jenisBarang) {
        return jenisBarang.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}