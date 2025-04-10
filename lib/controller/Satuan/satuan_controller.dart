import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/satuan_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/satuan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SatuanController extends GetxController {
  final SatuanService _satuanService;
  final RxList<Satuan> satuanList = <Satuan>[].obs;
  final Rx<Satuan?> selectedSatuan = Rx<Satuan?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  SatuanController({SatuanService? satuanService})
      : _satuanService = satuanService ?? SatuanService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllSatuan();
    super.onInit();
  }

  Future<void> fetchAllSatuan() async {
    try {
      isLoading(true);
      errorMessage('');
      final satuan = await _satuanService.getAllSatuan();
      satuanList.assignAll(satuan);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load satuan: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSatuanById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final satuan = await _satuanService.getSatuanById(id);
      selectedSatuan(satuan);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load satuan details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createSatuan() async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Unit name cannot be empty');
      }

      final newSatuan = await _satuanService.createSatuan({
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      satuanList.add(newSatuan);
      Get.back();
      Get.snackbar('Success', 'Satuan created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create satuan: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Unit name cannot be empty');
      }

      final updatedSatuan = await _satuanService.updateSatuan(id, {
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      final index = satuanList.indexWhere((satuan) => satuan.id == id);
      if (index != -1) {
        satuanList[index] = updatedSatuan;
      }
      Get.back();
      Get.snackbar('Success', 'Satuan updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update satuan: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _satuanService.deleteSatuan(id);
      satuanList.removeWhere((satuan) => satuan.id == id);
      Get.back();
      Get.snackbar('Success', 'Satuan deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete satuan: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreSatuan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredSatuan = await _satuanService.restoreSatuan(id);
      satuanList.add(restoredSatuan);
      Get.snackbar('Success', 'Satuan restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to restore satuan: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedSatuan(null);
  }

  List<Satuan> get filteredSatuan {
    if (searchController.text.isEmpty) {
      return satuanList;
    } else {
      return satuanList.where((satuan) {
        return satuan.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}