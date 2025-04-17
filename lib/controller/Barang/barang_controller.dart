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
  var imagePath = ''.obs;

  // Form controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Dropdown values
  final RxInt selectedJenisBarangId = 0.obs;
  final RxInt selectedSatuanId = 0.obs;
  final RxInt selectedCategoryId = 0.obs;

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
    kodeController.dispose();
    super.onClose();
  }

  Future<void> fetchAllBarang() async {
    try {
      print('Fetching barang...'); // Debug log
      isLoading(true);
      errorMessage('');
      final barang = await _service.getAllBarang();
      barangList.assignAll(barang);
      filterBarang();
      print('Barang fetched successfully'); // Debug log
    } catch (e) {
      print('Error fetching barang: $e'); // Debug log
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...'); // Debug log
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getBarangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final barang = await _service.getBarangById(id);
      selectedBarang(barang);

      // Pre-fill form for editing
      namaController.text = barang.barangNama;
      hargaController.text = barang.barangHarga.toString();
      kodeController.text = barang.barangKode;
      selectedJenisBarangId(barang.jenisbarangId ?? 0);
      selectedSatuanId(barang.satuanId ?? 0);
      selectedCategoryId(barang.barangcategoryId ?? 0);
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'barang_nama': namaController.text.trim(),
        'barang_harga': hargaController.text.trim(),
        'barang_kode': kodeController.text.trim(),
        'jenisbarang_id': selectedJenisBarangId.value,
        'satuan_id': selectedSatuanId.value,
        'barangcategory_id': selectedCategoryId.value,
      };
      final barang = Barang(
        id: 0, // Provide a default or appropriate value for 'id'
        barangSlug:
            '', // Provide a default or appropriate value for 'barangSlug'
        createdAt: DateTime
            .now(), // Provide a default or appropriate value for 'createdAt'
        updatedAt: DateTime
            .now(), // Provide a default or appropriate value for 'updatedAt'
        barangNama: data['barang_nama'] as String,
        barangHarga: double.parse(data['barang_harga'] as String),
        barangKode: data['barang_kode'] as String,
        jenisbarangId: data['jenisbarang_id'] as int,
        satuanId: data['satuan_id'] as int,
        barangcategoryId: data['barangcategory_id'] as int,
      );
      final newBarang = await _service.createBarang(barang);
      barangList.add(newBarang);
      filterBarang();
      Get.back();
      Get.snackbar('Success', 'Barang created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'barang_nama': namaController.text.trim(),
        'barang_harga': hargaController.text.trim(),
        'barang_kode': kodeController.text.trim(),
        'jenisbarang_id': selectedJenisBarangId.value,
        'satuan_id': selectedSatuanId.value,
        'barangcategory_id': selectedCategoryId.value,
      };
      final barangToUpdate = Barang(
        id: id,
        barangSlug: selectedBarang.value?.barangSlug ?? '',
        createdAt: selectedBarang.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        barangNama: data['barang_nama'] as String,
        barangHarga: double.parse(data['barang_harga'] as String),
        barangKode: data['barang_kode'] as String,
        jenisbarangId: data['jenisbarang_id'] as int,
        satuanId: data['satuan_id'] as int,
        barangcategoryId: data['barangcategory_id'] as int,
      );
      final updatedBarang = await _service.updateBarang(id, barangToUpdate);
      final index = barangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangList[index] = updatedBarang;
        filterBarang();
      }
      selectedBarang(updatedBarang);
      Get.back();
      Get.snackbar('Success', 'Barang updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
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

  // Future<void> restoreBarang(int id) async {
  //   try {
  //     isLoading(true);
  //     errorMessage('');
  //     final restoredBarang = await _service.restoreBarang(id);
  //     final index = barangList.indexWhere((item) => item.id == id);
  //     if (index != -1) {
  //       barangList[index] = restoredBarang;
  //       filterBarang();
  //     }
  //     selectedBarang(restoredBarang);
  //     Get.snackbar('Success', 'Barang restored successfully',
  //         snackPosition: SnackPosition.BOTTOM);
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Future<void> forceDeleteBarang(int id) async {
  //   try {
  //     isLoading(true);
  //     errorMessage('');
  //     final success = await _service.forceDeleteBarang(id);
  //     if (success) {
  //       barangList.removeWhere((item) => item.id == id);
  //       filterBarang();
  //       Get.back();
  //       Get.snackbar('Success', 'Barang permanently deleted',
  //           snackPosition: SnackPosition.BOTTOM);
  //     }
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  void filterBarang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBarang.assignAll(barangList);
    } else {
      filteredBarang.assignAll(
        barangList.where((item) =>
            item.barangNama.toLowerCase().contains(query) ||
            item.barangKode.toLowerCase().contains(query)),
      );
    }
  }

  void clearForm() {
    namaController.clear();
    hargaController.clear();
    kodeController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedBarang(null);
    selectedJenisBarangId(0);
    selectedSatuanId(0);
    selectedCategoryId(0);
  }
}
