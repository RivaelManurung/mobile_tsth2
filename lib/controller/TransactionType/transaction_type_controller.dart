import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/transaction_type_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionTypeController extends GetxController {
  final TransactionTypeService _transactionTypeService;
  final RxList<TransactionType> transactionTypeList = <TransactionType>[].obs;
  final Rx<TransactionType?> selectedTransactionType = Rx<TransactionType?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  TransactionTypeController({TransactionTypeService? transactionTypeService})
      : _transactionTypeService = transactionTypeService ?? TransactionTypeService(prefs: Get.find<SharedPreferences>());

  @override
  void onInit() {
    fetchAllTransactionType();
    super.onInit();
  }

  Future<void> fetchAllTransactionType() async {
    try {
      isLoading(true);
      errorMessage('');
      final transactionTypes = await _transactionTypeService.getAllTransactionType();
      transactionTypeList.assignAll(transactionTypes);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load transaction types: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTransactionTypeById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final transactionType = await _transactionTypeService.getTransactionTypeById(id);
      selectedTransactionType(transactionType);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to load transaction type details: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createTransactionType() async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Transaction type name cannot be empty');
      }

      final newTransactionType = await _transactionTypeService.createTransactionType({
        'name': nameController.text,
      });
      transactionTypeList.add(newTransactionType);
      Get.back();
      Get.snackbar('Success', 'Transaction type created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to create transaction type: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        throw Exception('Transaction type name cannot be empty');
      }

      final updatedTransactionType = await _transactionTypeService.updateTransactionType(id, {
        'name': nameController.text,
      });
      final index = transactionTypeList.indexWhere((type) => type.id == id);
      if (index != -1) {
        transactionTypeList[index] = updatedTransactionType;
      }
      Get.back();
      Get.snackbar('Success', 'Transaction type updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to update transaction type: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransactionType(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _transactionTypeService.deleteTransactionType(id);
      transactionTypeList.removeWhere((type) => type.id == id);
      Get.back();
      Get.snackbar('Success', 'Transaction type deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage(e.toString());
      if (e.toString().contains('No token found')) {
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Error', 'Failed to delete transaction type: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    selectedTransactionType(null);
  }

  List<TransactionType> get filteredTransactionType {
    if (searchController.text.isEmpty) {
      return transactionTypeList;
    } else {
      return transactionTypeList.where((type) {
        return type.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
  }
}