// Mengambil dan mengelola data kategori barang dalam aplikasi Flutter menggunakan GetX.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_category_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_category_service.dart';

class BarangCategoryController extends GetxController {
  final BarangCategoryService _service;

  // Daftar reaktif untuk kategori, hasil filter, dan status
  final RxList<BarangCategory> barangCategoryList = <BarangCategory>[].obs; // Menyimpan semua kategori
  final RxList<BarangCategory> filteredBarangCategory = <BarangCategory>[].obs; // Menyimpan kategori yang difilter
  final Rx<BarangCategory?> selectedBarangCategory = Rx<BarangCategory?>(null); // Melacak kategori yang dipilih
  final RxBool isLoading = false.obs; // Status loading
  final RxString errorMessage = ''.obs; // Pesan error
  final RxString searchQuery = ''.obs; // Input pencarian

  // Controller untuk form input
  final TextEditingController nameController = TextEditingController(); // Input nama kategori
  final TextEditingController slugController = TextEditingController(); // Input slug kategori
  final TextEditingController searchController = TextEditingController(); // Input pencarian

  // Konstruktor, default ke BarangCategoryService
  BarangCategoryController({BarangCategoryService? service})
      : _service = service ?? BarangCategoryService();

  @override
  void onInit() {
    super.onInit();
    fetchAllBarangCategory(); // Memuat semua kategori saat inisialisasi
    _setupSearchListener(); // Mengatur listener pencarian
  }

  // Mengatur listener pencarian dengan debounce
  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    debounce(searchQuery, (_) => filterBarangCategory(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    // Membersihkan controller
    searchController.dispose();
    nameController.dispose();
    slugController.dispose();
    super.onClose();
  }

  // Mengambil semua kategori
  Future<void> fetchAllBarangCategory() async {
    try {
      isLoading(true);
      errorMessage('');
      final categories = await _service.getAllBarangCategory();
      barangCategoryList.assignAll(categories);
      filterBarangCategory();
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  // Mengambil kategori berdasarkan ID
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

  // Memfilter kategori berdasarkan pencarian
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

  // Membersihkan input form
  void clearForm() {
    nameController.clear();
    slugController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedBarangCategory(null);
  }
}