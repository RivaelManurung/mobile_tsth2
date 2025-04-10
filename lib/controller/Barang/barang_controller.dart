import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangController extends GetxController {
  final BarangService _barangService;
  final RxList<Barang> barangList = <Barang>[].obs;
  final Rx<Barang?> selectedBarang = Rx<Barang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  BarangController({BarangService? barangService})
      : _barangService = barangService ?? BarangService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllBarang();
    super.onInit();
  }

  Future<void> fetchAllBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final barang = await _barangService.getAllBarang();
      barangList.assignAll(barang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBarangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final barang = await _barangService.getBarangById(id);
      selectedBarang(barang);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load barang details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final newBarang = await _barangService.createBarang({
        'barang_nama': namaController.text,
        'barang_harga': int.parse(hargaController.text),
        'stok_tersedia': int.parse(stokController.text),
        'gudang_id': 1, // Default warehouse, can be changed
      });
      barangList.add(newBarang);
      Get.back();
      Get.snackbar('Success', 'Barang created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final updatedBarang = await _barangService.updateBarang(id, {
        'barang_nama': namaController.text,
        'barang_harga': int.parse(hargaController.text),
        'stok_tersedia': int.parse(stokController.text),
      });
      final index = barangList.indexWhere((barang) => barang.id == id);
      if (index != -1) {
        barangList[index] = updatedBarang;
      }
      Get.back();
      Get.snackbar('Success', 'Barang updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _barangService.deleteBarang(id);
      barangList.removeWhere((barang) => barang.id == id);
      Get.back();
      Get.snackbar('Success', 'Barang deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete barang: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    namaController.clear();
    hargaController.clear();
    stokController.clear();
    selectedBarang(null);
  }

  List<Barang> get filteredBarang {
    if (searchController.text.isEmpty) {
      return barangList;
    } else {
      return barangList.where((barang) {
        return barang.barangNama
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}