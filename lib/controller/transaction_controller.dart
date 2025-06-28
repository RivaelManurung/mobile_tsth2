import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/services/barang_service.dart';
import 'package:inventory_tsth2/services/transaction_service.dart';
import 'package:inventory_tsth2/services/transaction_type_service.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:inventory_tsth2/widget/date_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure_storage;
import 'package:intl/intl.dart';

class TransactionController extends GetxService {
  final TransactionService _transactionService;
  final TransactionTypeService _transactionTypeService;
  final BarangService _barangService;
  final secure_storage.FlutterSecureStorage _storage;

  // Reactive state variables
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxList<Transaction> transactionList = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactionList = <Transaction>[].obs;
  final Rx<Transaction?> selectedTransaction = Rx<Transaction?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<TransactionType> transactionTypes = <TransactionType>[].obs;
  final RxList<Barang> barangs = <Barang>[].obs;
  final RxList<BarangGudang> barangGudangs = <BarangGudang>[].obs;
  final RxString scannedBarcode = ''.obs;
  final RxInt selectedTransactionTypeId = 0.obs;
  final RxList<Map<String, dynamic>> scannedItems = <Map<String, dynamic>>[].obs;
  final RxBool isScanningAllowed = true.obs;
  final TextEditingController quantityController = TextEditingController(text: '1');
  final RxString userRole = ''.obs;
  final RxString selectedDateRange = 'Semua'.obs;
  final FocusNode searchFocusNode = FocusNode();

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
    loadUserData();
    fetchAllTransactions(); // Fetch all transactions without date filter
    fetchTransactionTypes();
    fetchBarangs();
    fetchBarangGudangs();

    searchFocusNode.addListener(() {
      print('Search FocusNode: hasFocus=${searchFocusNode.hasFocus}');
    });

    ever(Get.currentRoute.obs, (route) {
      if (route == RoutesName.dashboard) {
        print('Route changed to dashboard, reloading user data');
        loadUserData();
        fetchAllTransactions();
        fetchTransactionTypes();
        fetchBarangs();
        fetchBarangGudangs();
      }
    });
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      if (searchQuery.value != searchController.text) {
        searchQuery.value = searchController.text;
      }
    });

    debounce(searchQuery, (_) => searchItems(searchQuery.value),
        time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    dateStartController.dispose();
    dateEndController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  Map<String, String?> getDateRange(String range) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    switch (range) {
      case 'Hari Ini':
        return {
          'date_start': formatter.format(now),
          'date_end': formatter.format(now),
        };
      case 'Minggu Ini':
        final startDate = now.subtract(Duration(days: now.weekday - 1));
        return {
          'date_start': formatter.format(startDate),
          'date_end': formatter.format(now),
        };
      case 'Bulan Ini':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return {
          'date_start': formatter.format(startOfMonth),
          'date_end': formatter.format(now),
        };
      case 'Custom':
        if (dateStartController.text.isEmpty || dateEndController.text.isEmpty) {
          print('Warning: Custom date range selected but one or both dates are empty');
          return {'date_start': null, 'date_end': null};
        }
        try {
          final startDate = DateTime.parse(dateStartController.text);
          final endDate = DateTime.parse(dateEndController.text);
          print('Parsed custom dates: start=${formatter.format(startDate)}, end=${formatter.format(endDate)}');
          return {
            'date_start': formatter.format(startDate),
            'date_end': formatter.format(endDate),
          };
        } catch (e) {
          print('Error parsing custom dates: $e');
          return {'date_start': null, 'date_end': null};
        }
      default:
        return {'date_start': null, 'date_end': null};
    }
  }

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

  void showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[600],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
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
      printTransactionTypes();
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

  Future<void> fetchBarangGudangs() async {
    try {
      isLoading(true);
      errorMessage('');
      final items = await _barangService.getAllBarangWithGudangs();
      print('Raw data from getAllBarangWithGudangs: $items');
      final barangGudangList = items is List<BarangGudang>
          ? items
          : items.map((item) => BarangGudang.fromJson(item as Map<String, dynamic>)).toList();
      print('Parsed BarangGudang list: ${barangGudangList.map((bg) => bg.toJson()).toList()}');
      barangGudangs.assignAll(barangGudangList);
    } catch (e) {
      errorMessage('Gagal memuat data barang gudang: $e');
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
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      final transactions = await _transactionService.getAllTransactions(
        transactionTypeId: transactionTypeId,
        transactionCode: transactionCode,
        // Remove dateStart and dateEnd parameters
      );
      transactionList.assignAll(transactions);
      applyClientSideFilter(); // Apply client-side filter after fetching
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
          restrictFormat: [BarcodeFormat.qr, BarcodeFormat.code128, BarcodeFormat.ean13],
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
        showInfoSnackbar('Info', errorMessage.value);
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
            Text('Kode: ${item['barang_kode'] ?? 'Tidak Diketahui'}'),
            Text('Stok Tersedia: ${item['stok_tersedia'] ?? 0}'),
            Text('Gudang: ${item['gudang_name'] ?? 'Tidak Diketahui'}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (${item['satuan'] ?? 'Unit'})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        confirm: ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(quantityController.text) ?? 1;
            if (quantity <= 0) {
              showErrorSnackbar('Error', 'Jumlah harus lebih dari 0');
              return;
            }
            final transactionType = transactionTypes.firstWhereOrNull(
                (type) => type.id == selectedTransactionTypeId.value);
            if (transactionType?.name?.toLowerCase() != 'barang masuk' &&
                quantity > (item['stok_tersedia'] ?? 0)) {
              showErrorSnackbar('Error', 'Jumlah melebihi stok tersedia');
              return;
            }
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
        'stok_tersedia': item['stok_tersedia'],
        'gudang_name': item['gudang_name'],
        'satuan': item['satuan'],
      });
    }
    scannedItems.refresh();
    showSuccessSnackbar('Sukses', 'Berhasil menambahkan ${item['barang_nama']}');
  }

  void removeScannedItem(int index) {
    scannedItems.removeAt(index);
    scannedItems.refresh();
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
      await fetchBarangs();
      await fetchBarangGudangs();

      showSuccessSnackbar('Sukses', 'Transaksi berhasil disimpan');
    } catch (e) {
      print('Error saat menyimpan transaksi: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: Transaksi gagal!')) {
        errorMsg =
            'Transaksi gagal disimpan. Pastikan semua data valid dan Anda memiliki akses ke gudang ini.';
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
    print('Filtering transactions with query: "${searchQuery.value}"');
    final query = searchQuery.value.toLowerCase();
    filteredTransactionList.assignAll(filteredTransactionList.where((item) {
      final matchesCode = item.transactionCode?.toLowerCase().contains(query) ?? false;
      final matchesType = item.transactionType?.name?.toLowerCase().contains(query) ?? false;
      return matchesCode || matchesType;
    }).toList());
    print('Filtered ${filteredTransactionList.length} transactions');
    filteredTransactionList.refresh();
  }

  void applyClientSideFilter() {
    final dateRange = getDateRange(selectedDateRange.value);
    final startDate = dateRange['date_start'] != null
        ? DateTime.parse(dateRange['date_start']!).toLocal()
        : null;
    final endDate = dateRange['date_end'] != null
        ? DateTime.parse(dateRange['date_end']!).add(const Duration(days: 1)).toLocal()
        : null;

    final filtered = transactionList.where((transaction) {
      if (startDate == null || endDate == null) return true; // No filter if null
      final transactionDate = DateTime.parse(transaction.transactionDate!).toLocal();
      print('Checking transaction ${transaction.transactionCode}: '
          'date=$transactionDate, start=$startDate, end=$endDate');
      return transactionDate.isAfter(startDate) && transactionDate.isBefore(endDate);
    }).toList();

    filteredTransactionList.assignAll(filtered);
    print('Client-side filtered transactions: ${filtered.map((t) => t.transactionCode).toList()}');

    filterTransactions(); // Apply search query filter if any

    if (filteredTransactionList.isEmpty) {
      showInfoSnackbar('Info', 'Tidak ada transaksi untuk filter yang dipilih');
    } else {
      showSuccessSnackbar('Sukses', 'Filter berhasil diterapkan');
    }
  }

  Future<void> applyFilter() async {
    try {
      isLoading(true);
      errorMessage('');

      final transactionTypeId = selectedTransactionTypeId.value == 0
          ? null
          : selectedTransactionTypeId.value;

      // Fetch all transactions without date parameters
      await fetchAllTransactions(
        transactionTypeId: transactionTypeId,
      );

      // Apply client-side filter
      applyClientSideFilter();
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

  void searchItems(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();
    searchResults.assignAll(
      barangs
          .where((barang) =>
              (barang.barangNama?.toLowerCase().contains(lowerQuery) ?? false) ||
              (barang.barangKode?.toLowerCase().contains(lowerQuery) ?? false))
          .map((barang) {
            final barangGudang = barangGudangs.firstWhere(
              (bg) => bg.barangId == barang.id,
              orElse: () => BarangGudang(
                barangId: barang.id,
                gudangId: 0,
                stokTersedia: 0,
                stokDipinjam: 0,
                stokMaintenance: 0,
              ),
            );
            print('Mapping barang: ${barang.barangNama}, gudang: ${barangGudang.gudang?.name}, stok: ${barangGudang.stokTersedia}');
            return {
              'barang_kode': barang.barangKode,
              'barang_nama': barang.barangNama,
              'stok_tersedia': barangGudang.stokTersedia,
              'gudang_name': barangGudang.gudang?.name ?? 'Tidak Diketahui',
              'satuan': barang.satuanNama ?? 'Unit',
            };
          }).toList(),
    );
  }

  void addSearchResultToScannedItems(Map<String, dynamic> item) {
    if (item['barang_kode'] == null || item['barang_kode'].isEmpty) {
      showErrorSnackbar('Error', 'Data barang tidak valid');
      return;
    }

    Get.defaultDialog(
      title: 'Tambah Barang',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item['barang_nama'] ?? 'Item Tidak Diketahui'),
          Text('Kode: ${item['barang_kode'] ?? 'Tidak Diketahui'}'),
          Text('Stok Tersedia: ${item['stok_tersedia'] ?? 0}'),
          Text('Gudang: ${item['gudang_name'] ?? 'Tidak Diketahui'}'),
          const SizedBox(height: 16),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah (${item['satuan'] ?? 'Unit'})',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Batal'),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          final quantity = int.tryParse(quantityController.text) ?? 1;
          if (quantity <= 0) {
            showErrorSnackbar('Error', 'Jumlah harus lebih dari 0');
            return;
          }
          final transactionType = transactionTypes.firstWhereOrNull(
              (type) => type.id == selectedTransactionTypeId.value);
          if (transactionType?.name?.toLowerCase() != 'barang masuk' &&
              quantity > (item['stok_tersedia'] ?? 0)) {
            showErrorSnackbar('Error', 'Jumlah melebihi stok tersedia');
            return;
          }
          _addScannedItem(item, quantity);
          searchResults.clear();
          searchQuery.value = '';
          Get.back();
        },
        child: const Text('Tambah'),
      ),
    );
  }

  void refreshData() {
    selectedDateRange('Semua');
    dateStartController.clear();
    dateEndController.clear();
    fetchAllTransactions();
    fetchTransactionTypes();
    scannedItems.clear();
    scannedBarcode('');
    selectedTransactionTypeId(0);
    quantityController.text = '1';
  }

  void handleError(dynamic e, String defaultMessage) {
    errorMessage.value = e.toString();
    if (errorMessage.value.contains('No token found')) {
      Get.offAllNamed(RoutesName.login);
    }
    showErrorSnackbar('Error', errorMessage.value);
  }
}