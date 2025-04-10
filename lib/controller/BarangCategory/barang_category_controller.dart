import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_category_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangCategoryController extends GetxController {
  final BarangCategoryService _barangCategoryService;
  final RxList<BarangCategory> barangCategoryList = <BarangCategory>[].obs;
  final Rx<BarangCategory?> selectedBarangCategory = Rx<BarangCategory?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  BarangCategoryController({BarangCategoryService? barangCategoryService})
      : _barangCategoryService = barangCategoryService ?? BarangCategoryService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllBarangCategory();
    super.onInit();
  }

  Future<void> fetchAllBarangCategory() async {
    try {
      isLoading(true);
      errorMessage('');
      final barangCategories = await _barangCategoryService.getAllBarangCategory();
      barangCategoryList.assignAll(barangCategories);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load barang categories: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBarangCategoryById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final barangCategory = await _barangCategoryService.getBarangCategoryById(id);
      selectedBarangCategory(barangCategory);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load barang category details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBarangCategory() async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      final newBarangCategory = await _barangCategoryService.createBarangCategory({
        'name': nameController.text,
      });
      barangCategoryList.add(newBarangCategory);
      Get.back();
      Get.snackbar('Success', 'Barang category created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create barang category: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      final updatedBarangCategory = await _barangCategoryService.updateBarangCategory(id, {
        'name': nameController.text,
      });
      final index = barangCategoryList.indexWhere((category) => category.id == id);
      if (index != -1) {
        barangCategoryList[index] = updatedBarangCategory;
      }
      Get.back();
      Get.snackbar('Success', 'Barang category updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update barang category: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _barangCategoryService.deleteBarangCategory(id);
      barangCategoryList.removeWhere((category) => category.id == id);
      Get.back();
      Get.snackbar('Success', 'Barang category deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete barang category: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    selectedBarangCategory(null);
  }

  List<BarangCategory> get filteredBarangCategory {
    if (searchController.text.isEmpty) {
      return barangCategoryList;
    } else {
      return barangCategoryList.where((category) {
        return category.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}