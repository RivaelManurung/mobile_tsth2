import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/gudang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GudangController extends GetxController {
  final GudangService _gudangService;
  final RxList<Gudang> gudangList = <Gudang>[].obs;
  final Rx<Gudang?> selectedGudang = Rx<Gudang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  GudangController({GudangService? gudangService})
      : _gudangService = gudangService ?? GudangService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllGudang();
    super.onInit();
  }

  Future<void> fetchAllGudang() async {
    try {
      isLoading(true);
      errorMessage('');
      final gudang = await _gudangService.getAllGudang();
      gudangList.assignAll(gudang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load gudang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchGudangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final gudang = await _gudangService.getGudangById(id);
      selectedGudang(gudang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load gudang details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createGudang() async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Warehouse name cannot be empty');
      }

      final newGudang = await _gudangService.createGudang({
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      gudangList.add(newGudang);
      Get.back();
      Get.snackbar('Success', 'Gudang created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create gudang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateGudang(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Warehouse name cannot be empty');
      }

      final updatedGudang = await _gudangService.updateGudang(id, {
        'name': nameController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
      });
      final index = gudangList.indexWhere((gudang) => gudang.id == id);
      if (index != -1) {
        gudangList[index] = updatedGudang;
      }
      Get.back();
      Get.snackbar('Success', 'Gudang updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update gudang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteGudang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _gudangService.deleteGudang(id);
      gudangList.removeWhere((gudang) => gudang.id == id);
      Get.back();
      Get.snackbar('Success', 'Gudang deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete gudang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedGudang(null);
  }

  List<Gudang> get filteredGudang {
    if (searchController.text.isEmpty) {
      return gudangList;
    } else {
      return gudangList.where((gudang) {
        return gudang.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}