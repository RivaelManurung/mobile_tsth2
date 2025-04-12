import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/transaction_type_service.dart';

class TransactionTypeController extends GetxController {
  final TransactionTypeService _service;

  // Reactive state variables
  final RxList<TransactionType> transactionTypeList = <TransactionType>[].obs;
  final RxList<TransactionType> filteredTransactionType = <TransactionType>[].obs;
  final Rx<TransactionType?> selectedTransactionType = Rx<TransactionType?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  TransactionTypeController({TransactionTypeService? service})
      : _service = service ?? TransactionTypeService();

  @override
  void onInit() {
    super.onInit();
    fetchAllTransactionType();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterTransactionType(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    super.onClose();
  }

  Future<void> fetchAllTransactionType() async {
    try {
      print('Fetching transaction types...');
      isLoading(true);
      errorMessage('');
      final transactionTypes = await _service.getAllTransactionType();
      transactionTypeList.assignAll(transactionTypes);
      filterTransactionType();
      print('Transaction types fetched successfully');
    } catch (e) {
      print('Error fetching transaction types: $e');
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        print('Redirecting to login...');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getTransactionTypeById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final transactionType = await _service.getTransactionTypeById(id);
      selectedTransactionType(transactionType);
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createTransactionType() async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
      };
      final newTransactionType = await _service.createTransactionType(data);
      transactionTypeList.add(newTransactionType);
      filterTransactionType();
      Get.back();
      Get.snackbar('Success', 'Transaction type created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'name': nameController.text.trim(),
      };
      final updatedTransactionType = await _service.updateTransactionType(id, data);
      final index = transactionTypeList.indexWhere((item) => item.id == id);
      if (index != -1) {
        transactionTypeList[index] = updatedTransactionType;
        filterTransactionType();
      }
      selectedTransactionType(updatedTransactionType);
      Get.back();
      Get.snackbar('Success', 'Transaction type updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.deleteTransactionType(id);
      if (success) {
        transactionTypeList.removeWhere((item) => item.id == id);
        filterTransactionType();
        Get.back();
        Get.snackbar('Success', 'Transaction type deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> restoreTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final restoredTransactionType = await _service.restoreTransactionType(id);
      final index = transactionTypeList.indexWhere((item) => item.id == id);
      if (index != -1) {
        transactionTypeList[index] = restoredTransactionType;
        filterTransactionType();
      }
      selectedTransactionType(restoredTransactionType);
      Get.snackbar('Success', 'Transaction type restored successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> forceDeleteTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final success = await _service.forceDeleteTransactionType(id);
      if (success) {
        transactionTypeList.removeWhere((item) => item.id == id);
        filterTransactionType();
        Get.back();
        Get.snackbar('Success', 'Transaction type permanently deleted',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterTransactionType() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredTransactionType.assignAll(transactionTypeList);
    } else {
      filteredTransactionType.assignAll(
        transactionTypeList.where((item) =>
            item.name.toLowerCase().contains(query)),
      );
    }
  }

  void clearForm() {
    nameController.clear();
    searchController.clear();
    searchQuery.value = '';
    errorMessage('');
    selectedTransactionType(null);
  }
}