import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_category_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_category_service.dart';

class BarangCategoryController extends GetxController {
  final BarangCategoryService _service;

  // Reactive state variables
  final RxList<BarangCategory> barangCategoryList = <BarangCategory>[].obs;
  final RxList<BarangCategory> filteredBarangCategory = <BarangCategory>[].obs;
  final Rx<BarangCategory?> selectedBarangCategory = Rx<BarangCategory?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController slugController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  BarangCategoryController({BarangCategoryService? service})
      : _service = service ?? BarangCategoryService();

  @override
  void onInit() {
    super.onInit();
    fetchAllBarangCategory();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterBarangCategory(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    slugController.dispose();
    super.onClose();
  }

  Future<void> fetchAllBarangCategory() async {
    try {
      print('Fetching barang categories...'); // Debug log
      isLoading(true);
      errorMessage('');
      final categories = await _service.getAllBarangCategory();
      barangCategoryList.assignAll(categories);
      filterBarangCategory();
      print('Barang categories fetched successfully'); // Debug log
    } catch (e) {
      print('Error fetching barang categories: $e'); // Debug log
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...'); // Debug log
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getBarangCategoryById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final category = await _service.getBarangCategoryById(id);
      selectedBarangCategory(category);
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBarangCategory() async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'slug': slugController.text.trim(),
      };
      final newCategory = await _service.createBarangCategory(data);
      barangCategoryList.add(newCategory);
      filterBarangCategory();
      Get.back();
      Get.snackbar('Success', 'Category created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
        'slug': slugController.text.trim(),
      };
      final updatedCategory = await _service.updateBarangCategory(id, data);
      final index = barangCategoryList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangCategoryList[index] = updatedCategory;
        filterBarangCategory();
      }
      selectedBarangCategory(updatedCategory);
      Get.back();
      Get.snackbar('Success', 'Category updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteBarangCategory(id);
      if (success) {
        barangCategoryList.removeWhere((item) => item.id == id);
        filterBarangCategory();
        Get.back();
        Get.snackbar('Success', 'Category deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredCategory = await _service.restoreBarangCategory(id);
      final index = barangCategoryList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangCategoryList[index] = restoredCategory;
        filterBarangCategory();
      }
      selectedBarangCategory(restoredCategory);
      Get.snackbar('Success', 'Category restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteBarangCategory(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.forceDeleteBarangCategory(id);
      if (success) {
        barangCategoryList.removeWhere((item) => item.id == id);
        filterBarangCategory();
        Get.back();
        Get.snackbar('Success', 'Category permanently deleted',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterBarangCategory() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBarangCategory.assignAll(barangCategoryList);
    } else {
      filteredBarangCategory.assignAll(
        barangCategoryList.where((item) =>
            item.name.toLowerCase().contains(query) ||
            item.slug.toLowerCase().contains(query)),
      );
    }
  }

  void clearForm() {
    nameController.clear();
    slugController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedBarangCategory(null);
  }
}