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
  final RxString errorMessage = ''.obs; // General error message
  final RxString listErrorMessage =
      ''.obs; // Error message specific to list fetching
  final RxList<User> userList = <User>[].obs;
  final Rx<User?> selectedUser = Rx<User?>(null);
  final RxString searchQuery = ''.obs;

  // Form controllers
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
    fetchAllUsers();
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
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterGudang();
  }

  Future<void> fetchAllUsers() async {
    try {
      print('Fetching users...');
      isLoading(true);
      listErrorMessage('');
      final users = await _userService.getAllUsers();
      userList.assignAll(users);
      print('Users fetched successfully: ${userList.length} users');
    } catch (e) {
      print('Error fetching users: $e');
      listErrorMessage(e.toString());
      if (listErrorMessage.value.contains('No token found') ||
          listErrorMessage.value
              .contains('User doesn\'t have any permission')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllGudang() async {
    try {
      print('Fetching gudang...');
      isLoading(true);
      listErrorMessage('');
      final gudang = await _service.getAllGudang();
      gudangList.assignAll(gudang);
      filterGudang();
      print('Gudang fetched successfully');
    } catch (e) {
      print('Error fetching gudang: $e');
      listErrorMessage(e.toString());
      if (listErrorMessage.value.contains('No token found') ||
          listErrorMessage.value
              .contains('User doesn\'t have any permission')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getGudangById(int id) async {
    try {
      print('Fetching gudang by ID: $id');
      isLoading(true);
      errorMessage('');
      final gudang = await _service.getGudangById(id);
      selectedGudang(gudang);
      if (gudang.userId != null) {
        selectedUser.value =
            userList.firstWhereOrNull((user) => user.id == gudang.userId);
      } else {
        selectedUser.value = null;
      }
    } catch (e) {
      print('Error fetching gudang by id: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found') ||
          errorMessage.value.contains('User doesn\'t have any permission')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
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

  void resetErrorForListPage() {
    errorMessage('');
    listErrorMessage('');
  }
}
