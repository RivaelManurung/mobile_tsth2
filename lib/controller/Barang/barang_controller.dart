import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  // Form controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Dropdown values
  final RxInt selectedJenisBarangId = 0.obs;
  final RxInt selectedSatuanId = 0.obs;
  final RxInt selectedCategoryId = 0.obs;
  final RxString imagePath = ''.obs;

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
      isLoading(true);
      errorMessage('');
      final barang = await _service.getAllBarang();
      barangList.assignAll(barang);
      filterBarang();
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('Unauthenticated')) {
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
      imagePath(barang.barangGambar ?? '');
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imagePath.value = pickedFile.path;
      }
    } catch (e) {
      errorMessage('Failed to pick image: $e');
    }
  }

  Future<void> createBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final barang = Barang(
        id: 0,
        barangNama: namaController.text.trim(),
        barangSlug: '',
        barangHarga: double.parse(hargaController.text),
        barangGambar: imagePath.value,
        barangKode: kodeController.text.trim(),
        jenisbarangId: selectedJenisBarangId.value,
        satuanId: selectedSatuanId.value,
        barangcategoryId: selectedCategoryId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newBarang = await _service.createBarang(barang);
      barangList.add(newBarang);
      filterBarang();
      
      Get.back();
      Get.snackbar('Success', 'Barang created successfully');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      
      final barang = Barang(
        id: id,
        barangNama: namaController.text.trim(),
        barangSlug: '',
        barangHarga: double.parse(hargaController.text),
        barangGambar: imagePath.value,
        barangKode: kodeController.text.trim(),
        jenisbarangId: selectedJenisBarangId.value,
        satuanId: selectedSatuanId.value,
        barangcategoryId: selectedCategoryId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedBarang = await _service.updateBarang(id, barang);
      final index = barangList.indexWhere((item) => item.id == id);
      if (index != -1) {
        barangList[index] = updatedBarang;
      }
      
      Get.back();
      Get.snackbar('Success', 'Barang updated successfully');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBarang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      
      await _service.deleteBarang(id);
      barangList.removeWhere((item) => item.id == id);
      filterBarang();
      
      Get.back();
      Get.snackbar('Success', 'Barang deleted successfully');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void filterBarang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBarang.assignAll(barangList);
    } else {
      filteredBarang.assignAll(
        barangList.where((item) => 
          item.barangNama.toLowerCase().contains(query) ||
          item.barangKode.toLowerCase().contains(query)
        ),
      );
    }
  }

  void clearForm() {
    namaController.clear();
    hargaController.clear();
    kodeController.clear();
    searchController.clear();
    selectedJenisBarangId(0);
    selectedSatuanId(0);
    selectedCategoryId(0);
    imagePath('');
    errorMessage('');
    selectedBarang(null);
  }
}