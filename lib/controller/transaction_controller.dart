import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/services/barang_service.dart';
import 'package:inventory_tsth2/services/transaction_service.dart';
import 'package:inventory_tsth2/services/transaction_type_service.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure_storage;

class TransactionController extends GetxController {
  final TransactionService _transactionService;
  final TransactionTypeService _transactionTypeService;
  final BarangService _barangService;
  final secure_storage.FlutterSecureStorage _storage;

  // Reactive state variables
  final RxList<Transaction> transactionList = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactionList = <Transaction>[].obs;
  final Rx<Transaction?> selectedTransaction = Rx<Transaction?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<TransactionType> transactionTypes = <TransactionType>[].obs;
  final RxList<Barang> barangs = <Barang>[].obs;
  final RxString scannedBarcode = ''.obs;
  final RxInt selectedTransactionTypeId = 0.obs;
  final RxList<Map<String, dynamic>> scannedItems = <Map<String, dynamic>>[].obs;
  final RxBool isScanningAllowed = true.obs;
  final TextEditingController quantityController = TextEditingController(text: '1');
  final RxString userRole = ''.obs;

  // Form controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateStartController = TextEditingController();
  final TextEditingController dateEndController = TextEditingController();

  TransactionController({
    TransactionService? transactionService,
    TransactionTypeService? transactionTypeService,
    BarangService? barangService,
    secure_storage.FlutterSecureStorage? storage,
  })  : _transactionService = transactionService ?? TransactionService(),
        _transactionTypeService = transactionTypeService ?? TransactionTypeService(),
        _barangService = barangService ?? BarangService(),
        _storage = storage ?? const secure_storage.FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    // Fetch data immediately on initialization
    loadUserData();
    fetchAllTransactions();
    fetchTransactionTypes();
    fetchBarangs();

    // Listen to route changes for additional refreshes
    ever(Get.currentRoute.obs, (route) {
      if (route == RoutesName.dashboard) {
        print('Route changed to dashboard, reloading user data');
        loadUserData();
        fetchAllTransactions();
        fetchTransactionTypes();
        fetchBarangs();
      }
    });
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (_) => filterTransactions(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    dateStartController.dispose();
    dateEndController.dispose();
    super.onClose();
  }

  // Print transaction types for debugging
  void printTransactionTypes() {
    if (transactionTypes.isEmpty) {
      print('No transaction types available');
    } else {
      print('Transaction Types:');
      for (var type in transactionTypes) {
        print('ID: ${type.id}, Name: ${type.name ?? "Unknown"}');
      }
    }
  }

  // Load user data from FlutterSecureStorage
  Future<void> loadUserData() async {
    try {
      final userDataString = await _storage.read(key: 'user');
      print('Loaded userDataString from FlutterSecureStorage: $userDataString');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        userRole.value = (userData['roles'] as List<dynamic>?)?.first ?? 'user';
      } else {
        print('No userData found in FlutterSecureStorage, redirecting to login');
        userRole.value = 'user';
        Get.offAllNamed(RoutesName.login);
      }
    } catch (e) {
      print('Gagal memuat data pengguna: $e');
      userRole.value = 'user';
      Get.offAllNamed(RoutesName.login);
    }
  }

  // Save user data to FlutterSecureStorage
  Future<void> saveUserData(Map<String, dynamic> loginResponse) async {
    try {
      final data = loginResponse['data'];
      print('Saving userData to FlutterSecureStorage: $data');
      await _storage.write(key: 'user', value: jsonEncode(data));
      userRole.value = (data['roles'] as List<dynamic>?)?.first ?? 'user';
    } catch (e) {
      print('Gagal menyimpan data pengguna: $e');
    }
  }

  // Show success snackbar
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  // Show error snackbar
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: true,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  Future<void> fetchTransactionTypes() async {
    try {
      isLoading(true);
      errorMessage('');
      final types = await _transactionTypeService.getAllTransactionType();
      transactionTypes.assignAll(types);
      printTransactionTypes(); // Print transaction types for debugging
    } catch (e) {
      errorMessage('Gagal memuat tipe transaksi: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBarangs() async {
    try {
      isLoading(true);
      errorMessage('');
      final items = await _barangService.getAllBarang();
      barangs.assignAll(items);
    } catch (e) {
      errorMessage('Gagal memuat barang: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllTransactions({
    int? transactionTypeId,
    String? transactionCode,
    String? dateStart,
    String? dateEnd,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      final transactions = await _transactionService.getAllTransactions(
        transactionTypeId: transactionTypeId,
        transactionCode: transactionCode,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );
      transactionList.assignAll(transactions);
      filterTransactions();
    } catch (e) {
      errorMessage('Gagal memuat transaksi: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> scanBarcode() async {
    if (!isScanningAllowed.value) return;

    try {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          errorMessage('Izin kamera ditolak');
          showErrorSnackbar('Error', errorMessage.value);
          return;
        }
      }

      isLoading(true);
      errorMessage('');
      isScanningAllowed(false);

      var result = await BarcodeScanner.scan(
        options: const ScanOptions(
          restrictFormat: [
            BarcodeFormat.qr,
            BarcodeFormat.code128,
            BarcodeFormat.ean13
          ],
          useCamera: -1,
          autoEnableFlash: false,
          android: AndroidOptions(useAutoFocus: true),
        ),
      );

      if (result.rawContent.isNotEmpty) {
        scannedBarcode.value = result.rawContent;
        await _checkBarcode(result.rawContent);
      } else {
        errorMessage('Pemindaian dibatalkan atau gagal');
        showErrorSnackbar('Info', errorMessage.value);
      }
    } catch (e) {
      errorMessage('Gagal memindai barcode: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
      Future.delayed(const Duration(milliseconds: 1500), () {
        isScanningAllowed(true);
      });
    }
  }

  Future<void> checkManualBarcode(String code) async {
    if (code.isEmpty) {
      showErrorSnackbar('Error', 'Masukkan kode barcode terlebih dahulu');
      return;
    }
    await _checkBarcode(code);
  }

  Future<void> _checkBarcode(String code) async {
    try {
      isLoading(true);
      final item = await _transactionService.checkBarcode(code);

      Get.defaultDialog(
        title: 'Item Ditemukan',
        content: Column(
          children: [
            Text(item['barang_nama'] ?? 'Item Tidak Diketahui'),
            Text('Stok Tersedia: ${item['stok_tersedia'] ?? 0}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        confirm: ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(quantityController.text) ?? 1;
            _addScannedItem(item, quantity);
            Get.back();
          },
          child: const Text('Tambah'),
        ),
      );
    } catch (e) {
      errorMessage('Gagal memverifikasi barcode: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  void _addScannedItem(Map<String, dynamic> item, int quantity) {
    if (item['barang_kode'] == null || item['barang_kode'].isEmpty) {
      showErrorSnackbar('Error', 'Data barcode tidak valid');
      return;
    }

    final existingIndex = scannedItems.indexWhere(
      (i) => i['barang_kode'] == item['barang_kode'],
    );

    if (existingIndex >= 0) {
      scannedItems[existingIndex]['quantity'] += quantity;
    } else {
      scannedItems.add({
        'barang_kode': item['barang_kode'],
        'barang_nama': item['barang_nama'],
        'quantity': quantity,
      });
    }
    scannedItems.refresh();
    showSuccessSnackbar('Sukses', 'Berhasil menambahkan ${item['barang_nama']}');
  }

  void removeScannedItem(int index) {
    scannedItems.removeAt(index);
  }

  void updateItemQuantity(int index, int quantity) {
    if (quantity > 0) {
      scannedItems[index]['quantity'] = quantity;
    } else {
      scannedItems.removeAt(index);
    }
    scannedItems.refresh();
  }

  Future<void> submitTransaction() async {
    if (selectedTransactionTypeId.value == 0 || scannedItems.isEmpty) {
      showErrorSnackbar('Error', 'Pilih tipe transaksi dan tambahkan barang');
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      final items = scannedItems
          .map((item) => {
                'barang_kode': item['barang_kode'],
                'quantity': item['quantity'],
              })
          .toList();

      final payload = {
        'transaction_type_id': selectedTransactionTypeId.value,
        'items': items,
      };

      print('Payload: ${jsonEncode(payload)}');

      await _transactionService.storeTransaction(
        selectedTransactionTypeId.value,
        items,
      );

      scannedItems.clear();
      scannedBarcode('');
      selectedTransactionTypeId(0);
      quantityController.text = '1';

      await fetchAllTransactions();

      showSuccessSnackbar('Sukses', 'Transaksi berhasil disimpan');
    } catch (e) {
      print('Error saat menyimpan transaksi: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: Transaksi gagal!')) {
        errorMsg = 'Transaksi gagal disimpan. Pastikan semua data valid dan Anda memiliki akses ke gudang ini.';
      }
      errorMessage.value = errorMsg;
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  void filterTransactions() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredTransactionList.assignAll(transactionList);
    } else {
      filteredTransactionList.assignAll(
        transactionList.where((item) =>
            (item.transactionCode?.toLowerCase().contains(query) ?? false) ||
            (item.transactionType?.name?.toLowerCase().contains(query) ?? false)),
      );
    }
  }

  Future<void> applyFilter() async {
    try {
      isLoading(true);
      errorMessage('');

      final transactionTypeId =
          selectedTransactionTypeId.value == 0 ? null : selectedTransactionTypeId.value;
      final dateStart = dateStartController.text.isEmpty ? null : dateStartController.text;
      final dateEnd = dateEndController.text.isEmpty ? null : dateEndController.text;

      await fetchAllTransactions(
        transactionTypeId: transactionTypeId,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );

      showSuccessSnackbar('Sukses', 'Filter berhasil diterapkan');
    } catch (e) {
      errorMessage('Gagal menerapkan filter: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getTransactionById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final transaction = await _transactionService.getTransactionById(id);
      selectedTransaction(transaction);
    } catch (e) {
      errorMessage('Gagal memuat detail transaksi: $e');
      showErrorSnackbar('Error', errorMessage.value);
      if (errorMessage.value.contains('No token found')) {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  void refreshData() {
    fetchAllTransactions();
    fetchTransactionTypes(); // Ensure transaction types are refreshed
    scannedItems.clear();
    scannedBarcode('');
    selectedTransactionTypeId(0);
    quantityController.text = '1';
    dateStartController.clear();
    dateEndController.clear();
  }

  void handleError(dynamic e, String defaultMessage) {
    errorMessage.value = e.toString();
    if (errorMessage.value.contains('No token found')) {
      Get.offAllNamed(RoutesName.login);
    }
    showErrorSnackbar('Error', errorMessage.value);
  }
}