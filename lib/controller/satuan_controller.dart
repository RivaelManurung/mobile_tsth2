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
  final RxString errorMessage = ''.obs; // General error message
  final RxString listErrorMessage =
      ''.obs; // Error message specific to list fetching
  final RxString searchQuery = ''.obs;

  // Form controllers
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
    super.onClose();
  }

  void resetErrorForListPage() {
    errorMessage('');
    listErrorMessage('');
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterSatuan();
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
}
