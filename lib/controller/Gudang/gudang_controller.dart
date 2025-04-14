import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/gudang_service.dart';
import 'package:inventory_tsth2/services/user_services.dart';

class GudangController extends GetxController {
  final GudangService _service;
  final UserService _userService;

  // Reactive state variables
  final RxList<Gudang> gudangList = <Gudang>[].obs;
  final RxList<Gudang> filteredGudang = <Gudang>[].obs;
  final Rx<Gudang?> selectedGudang = Rx<Gudang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<User> userList = <User>[].obs; // Daftar pengguna
  final Rx<User?> selectedUser = Rx<User?>(null); // Pengguna yang dipilih untuk form

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  GudangController({
    GudangService? service,
    UserService? userService,
  })  : _service = service ?? GudangService(),
        _userService = userService ?? UserService();

  @override
  void onInit() {
    super.onInit();
    fetchAllGudang();
    fetchAllUsers(); // Ambil daftar pengguna
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterGudang(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchAllUsers() async {
    try {
      print('Fetching users...');
      final users = await _userService.getAllUsers();
      userList.assignAll(users);
      print('Users fetched successfully: ${userList.length} users');
    } catch (e) {
      print('Error fetching users: $e');
      Get.snackbar(
        'Gagal',
        'Gagal memuat daftar pengguna: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> fetchAllGudang() async {
    try {
      print('Fetching gudang...');
      isLoading(true);
      errorMessage('');
      final gudang = await _service.getAllGudang();
      gudangList.assignAll(gudang);
      filterGudang();
      print('Gudang fetched successfully');
    } catch (e) {
      print('Error fetching gudang: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getGudangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final gudang = await _service.getGudangById(id);
      selectedGudang(gudang);
      // Set selectedUser berdasarkan user_id dari gudang
      if (gudang.userId != null) {
        selectedUser.value = userList.firstWhereOrNull((user) => user.id == gudang.userId);
      } else {
        selectedUser.value = null;
      }
    } catch (e) {
      print('Error fetching gudang by id: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createGudang() async {
    try {
      isLoading(true);

      // Validasi input
      final name = nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Nama gudang tidak boleh kosong');
      }
      if (selectedUser.value == null) {
        throw Exception('Pengguna operator wajib dipilih');
      }
      final description = descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null;

      final data = {
        'name': name,
        if (description != null) 'description': description,
        'user_id': selectedUser.value!.id,
      };

      final newGudang = await _service.createGudang(data);
      gudangList.add(newGudang);
      filterGudang();
      clearForm();

      Get.snackbar(
        'Berhasil',
        'Gudang berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error creating gudang: $e');
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateGudang(int id) async {
    try {
      isLoading(true);

      // Validasi input
      final name = nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Nama gudang tidak boleh kosong');
      }
      if (selectedUser.value == null) {
        throw Exception('Pengguna operator wajib dipilih');
      }
      final description = descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null;

      final data = {
        'name': name,
        if (description != null) 'description': description,
        'user_id': selectedUser.value!.id,
      };

      final success = await _service.updateGudang(id, data);
      if (success) {
        // Ambil ulang data terbaru dari server
        final updatedGudang = await _service.getGudangById(id);
        final index = gudangList.indexWhere((item) => item.id == id);
        if (index != -1) {
          gudangList[index] = updatedGudang;
          filterGudang();
        }
        selectedGudang(updatedGudang);
        clearForm();

        Get.snackbar(
          'Berhasil',
          'Gudang berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error updating gudang: $e');
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteGudang(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteGudang(id);
      if (success) {
        gudangList.removeWhere((item) => item.id == id);
        filterGudang();
        clearForm();
        Get.snackbar(
          'Berhasil',
          'Gudang berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error deleting gudang: $e');
      errorMessage(e.toString());
      Get.snackbar(
        'Gagal',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }

  void filterGudang() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredGudang.assignAll(gudangList);
    } else {
      filteredGudang.assignAll(
        gudangList.where((item) =>
            item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false)),
      );
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    searchController.clear();
    searchQuery.value = '';
    selectedGudang(null);
    selectedUser(null); // Reset pengguna yang dipilih
  }

  void resetErrorForListPage() {
    errorMessage('');
  }
}