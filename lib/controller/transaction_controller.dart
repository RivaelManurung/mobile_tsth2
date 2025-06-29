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
import 'package:inventory_tsth2/widget/qr_scanner_page.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:inventory_tsth2/widget/date_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secure_storage;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class TransactionController extends GetxService {
  final TransactionService _transactionService;
  final TransactionTypeService _transactionTypeService;
  final BarangService _barangService;
  final secure_storage.FlutterSecureStorage _storage;

  // Reactive state variables
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
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
  final RxList<Map<String, dynamic>> scannedItems =
      <Map<String, dynamic>>[].obs;
  final RxBool isScanningAllowed = true.obs;
  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final RxString userRole = ''.obs;
  final RxString selectedDateRange = 'Semua'.obs;
  final FocusNode searchFocusNode = FocusNode();

  // Form controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateStartController = TextEditingController();
  final TextEditingController dateEndController = TextEditingController();

  // Debounce stream for search
  final _searchSubject = rxdart.BehaviorSubject<String>();

  TransactionController({
    TransactionService? transactionService,
    TransactionTypeService? transactionTypeService,
    BarangService? barangService,
    secure_storage.FlutterSecureStorage? storage,
  })  : _transactionService = transactionService ?? TransactionService(),
        _transactionTypeService =
            transactionTypeService ?? TransactionTypeService(),
        _barangService = barangService ?? BarangService(),
        _storage = storage ?? const secure_storage.FlutterSecureStorage() {
    // Set up debounced search
    _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) {
      print('Debounced search query: $query');
      searchQuery.value = query;
      searchItems(query);
    });
  }

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    loadUserData();
    fetchAllTransactions();
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
      _searchSubject.add(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    dateStartController.dispose();
    dateEndController.dispose();
    searchFocusNode.dispose();
    _searchSubject.close();
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
        if (dateStartController.text.isEmpty ||
            dateEndController.text.isEmpty) {
          print(
              'Warning: Custom date range selected but one or both dates are empty');
          return {'date_start': null, 'date_end': null};
        }
        try {
          final startDate = DateTime.parse(dateStartController.text);
          final endDate = DateTime.parse(dateEndController.text);
          print(
              'Parsed custom dates: start=${formatter.format(startDate)}, end=${formatter.format(endDate)}');
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
        print(
            'No userData found in FlutterSecureStorage, redirecting to login');
        userRole.value = 'user';
        Get.offAllNamed(RoutesName.login);
      }
    } catch (e, stackTrace) {
      print('Error loading user data: $e');
      print(stackTrace);
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
    } catch (e, stackTrace) {
      print('Error saving user data: $e');
      print(stackTrace);
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
      print('Fetching transaction types...');
      final types = await _transactionTypeService.getAllTransactionType();
      print('Fetched transaction types: ${types.map((t) => t.name).toList()}');
      transactionTypes.assignAll(types);
      printTransactionTypes();
    } catch (e, stackTrace) {
      print('Error in fetchTransactionTypes: $e');
      print(stackTrace);
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
      print('Fetching barangs...');
      final items = await _barangService.getAllBarang();
      print('Fetched barangs: ${items.map((b) => b.barangNama).toList()}');
      barangs.assignAll(items);
    } catch (e, stackTrace) {
      print('Error in fetchBarangs: $e');
      print(stackTrace);
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
      print('Fetching barang gudangs...');
      final items = await _barangService.getAllBarangWithGudangs();
      print('Raw data from getAllBarangWithGudangs: $items');
      final barangGudangList = items is List<BarangGudang>
          ? items
          : items
              .map(
                  (item) => BarangGudang.fromJson(item as Map<String, dynamic>))
              .toList();
      print(
          'Parsed BarangGudang list: ${barangGudangList.map((bg) => bg.toJson()).toList()}');
      barangGudangs.assignAll(barangGudangList);
    } catch (e, stackTrace) {
      print('Error in fetchBarangGudangs: $e');
      print(stackTrace);
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
      print('Fetching all transactions...');
      final transactions = await _transactionService.getAllTransactions(
        transactionTypeId: transactionTypeId,
        transactionCode: transactionCode,
      );
      print(
          'Fetched transactions: ${transactions.map((t) => t.transactionCode).toList()}');
      transactionList.assignAll(transactions);
      applyClientSideFilter();
    } catch (e, stackTrace) {
      print('Error in fetchAllTransactions: $e');
      print(stackTrace);
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

void searchItems(String query) {
    print('Initiating client-side search for query: "$query"');
    if (query.isEmpty) {
      searchResults.clear();
      print('Search query is empty, cleared search results.');
      return;
    }

    final lowerQuery = query.toLowerCase();
    // Filter the all-encompassing 'barangs' list
    final results = barangs
        .where((barang) =>
            (barang.barangNama?.toLowerCase().contains(lowerQuery) ?? false) ||
            (barang.barangKode?.toLowerCase().contains(lowerQuery) ?? false))
        .map((barang) {
      // Find the corresponding BarangGudang to get stock and warehouse info
      final barangGudang = barangGudangs.firstWhere(
        (bg) => bg.barangId == barang.id,
        orElse: () {
          print('Warning: No BarangGudang found for barang ID ${barang.id}. Assigning default values.');
          return BarangGudang(
            barangId: barang.id,
            gudangId: 0,
            stokTersedia: 0,
            stokDipinjam: 0,
            stokMaintenance: 0,
            // You might need to adjust default values or handle nulls in your UI if this happens
          );
        },
      );
      return {
        'barang_id': barang.id, // Include barang_id for better identification if needed
        'barang_kode': barang.barangKode,
        'barang_nama': barang.barangNama,
        'stok_tersedia': barangGudang.stokTersedia,
        'gudang_name': barangGudang.gudang?.name ?? 'Tidak Diketahui',
        'satuan': barang.satuanNama ?? 'Unit',
      };
    }).toList();

    searchResults.assignAll(results);
    print('Client-side search found ${searchResults.length} results.');
    print('Search results: ${searchResults.map((r) => r['barang_nama'])}');
  }

  /// Initiates a barcode scan using the QR scanner page.
  Future<void> scanBarcode() async {
    if (!isScanningAllowed.value) {
      showInfoSnackbar('Info', 'Pemindaian sedang berlangsung atau tidak diizinkan sementara.');
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      isScanningAllowed(false); // Prevent multiple scans at once

      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          errorMessage('Izin kamera ditolak. Tidak dapat memindai barcode.');
          showErrorSnackbar('Error', errorMessage.value);
          return;
        }
      }

      print('Opening QR scanner...');
      final result = await Get.to<String>(
        () => const QRScannerPage(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );

      print('QR scanner result: $result');
      if (result != null && result.isNotEmpty) {
        scannedBarcode.value = result;
        searchController.text = result; // Update the search field with scanned barcode
        await _checkBarcode(result); // Proceed to check barcode details
      } else {
        errorMessage('Pemindaian dibatalkan atau tidak ada hasil.');
        showInfoSnackbar('Info', errorMessage.value);
      }
    } catch (e, stackTrace) {
      _handleAPIError(e, stackTrace, 'Gagal memindai barcode');
    } finally {
      isLoading(false);
      // Re-enable scanning after a short delay to prevent rapid re-scans
      Future.delayed(const Duration(milliseconds: 1500), () {
        isScanningAllowed(true);
      });
    }
  }

  /// Checks a given barcode (either scanned or manually entered) against the API.
  Future<void> checkManualBarcode(String code) async {
    if (code.isEmpty) {
      showErrorSnackbar('Error', 'Masukkan kode barcode terlebih dahulu');
      return;
    }
    await _checkBarcode(code);
  }

  /// Internal helper to check barcode details from API and show dialog.
  Future<void> _checkBarcode(String code) async {
    try {
      isLoading(true);
      print('Checking barcode with API: $code');
      final item = await _transactionService.checkBarcode(code); // This uses your API
      print('Barcode API check result: $item');

      if (item == null || item['barang_kode'] == null) {
        showErrorSnackbar(
            'Error', 'Data barcode tidak valid atau barang tidak ditemukan di sistem.');
        return;
      }

      // Reset quantity controller for the dialog
      quantityController.text = '1';

      Get.defaultDialog(
        title: 'Item Ditemukan',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item['barang_nama'] ?? 'Item Tidak Diketahui', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              onFieldSubmitted: (value) {
                // Handle submission from keyboard "Done" button
                _validateAndAddScannedItem(item, quantityController.text);
                Get.back(); // Close dialog after processing
              },
            ),
          ],
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Batal'),
        ),
        confirm: ElevatedButton(
          onPressed: () {
            _validateAndAddScannedItem(item, quantityController.text);
            Get.back(); // Close dialog after processing
          },
          child: const Text('Tambah'),
        ),
      );
    } catch (e, stackTrace) {
      _handleAPIError(e, stackTrace, 'Gagal memverifikasi barcode');
    } finally {
      isLoading(false);
    }
  }

  /// Validates quantity and adds the item to `scannedItems`.
  void _validateAndAddScannedItem(Map<String, dynamic> item, String quantityText) {
    final quantity = int.tryParse(quantityText) ?? 1;
    if (quantity <= 0) {
      showErrorSnackbar('Error', 'Jumlah harus lebih dari 0');
      return;
    }

    final transactionType = transactionTypes.firstWhereOrNull(
        (type) => type.id == selectedTransactionTypeId.value);

    // If it's not "Barang Masuk" (stock-in), check against available stock
    if (transactionType?.name?.toLowerCase() != 'barang masuk' &&
        quantity > (item['stok_tersedia'] ?? 0)) {
      showErrorSnackbar('Error', 'Jumlah melebihi stok tersedia');
      return;
    }
    _addScannedItem(item, quantity);
  }


  /// Adds an item to the `scannedItems` list, updating quantity if item exists.
  void _addScannedItem(Map<String, dynamic> item, int quantity) {
    if (item['barang_kode'] == null || item['barang_kode'].isEmpty) {
      showErrorSnackbar('Error', 'Data barcode tidak valid');
      return;
    }

    final existingIndex = scannedItems.indexWhere(
      (i) => i['barang_kode'] == item['barang_kode'],
    );

    if (existingIndex >= 0) {
      // If item already exists, just update its quantity
      scannedItems[existingIndex]['quantity'] += quantity;
    } else {
      // Add new item
      scannedItems.add({
        'barang_id': item['barang_id'], // Include barang_id for clearer item tracking
        'barang_kode': item['barang_kode'],
        'barang_nama': item['barang_nama'],
        'quantity': quantity,
        'stok_tersedia': item['stok_tersedia'],
        'gudang_name': item['gudang_name'],
        'satuan': item['satuan'],
      });
    }
    scannedItems.refresh(); // Notify Obx listeners of changes
    showSuccessSnackbar(
        'Sukses', 'Berhasil menambahkan ${item['barang_nama']}');
  }

  /// Removes an item from the `scannedItems` list by index.
  void removeScannedItem(int index) {
    if (index >= 0 && index < scannedItems.length) {
      final removedItemName = scannedItems[index]['barang_nama'];
      scannedItems.removeAt(index);
      scannedItems.refresh();
      showInfoSnackbar('Info', '$removedItemName dihapus dari daftar.');
    } else {
      print('Attempted to remove item at invalid index: $index');
    }
  }

  /// Updates the quantity of an item in `scannedItems`. Removes if quantity is 0 or less.
  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < scannedItems.length) {
      if (quantity > 0) {
        scannedItems[index]['quantity'] = quantity;
        scannedItems.refresh();
      } else {
        removeScannedItem(index); // Remove item if quantity becomes non-positive
      }
    } else {
      print('Attempted to update quantity for item at invalid index: $index');
    }
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

      print('Submitting transaction with payload: ${jsonEncode(payload)}');
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
    } catch (e, stackTrace) {
      print('Error in submitTransaction: $e');
      print(stackTrace);
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
      final matchesCode =
          item.transactionCode?.toLowerCase().contains(query) ?? false;
      final matchesType =
          item.transactionType?.name?.toLowerCase().contains(query) ?? false;
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
        ? DateTime.parse(dateRange['date_end']!)
            .add(const Duration(days: 1))
            .toLocal()
        : null;

    final filtered = transactionList.where((transaction) {
      if (startDate == null || endDate == null) return true;
      final transactionDate =
          DateTime.parse(transaction.transactionDate!).toLocal();
      print('Checking transaction ${transaction.transactionCode}: '
          'date=$transactionDate, start=$startDate, end=$endDate');
      return transactionDate.isAfter(startDate) &&
          transactionDate.isBefore(endDate);
    }).toList();

    filteredTransactionList.assignAll(filtered);
    print(
        'Client-side filtered transactions: ${filtered.map((t) => t.transactionCode).toList()}');

    filterTransactions();

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

      await fetchAllTransactions(
        transactionTypeId: transactionTypeId,
      );

      applyClientSideFilter();
    } catch (e, stackTrace) {
      print('Error in applyFilter: $e');
      print(stackTrace);
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
      print('Fetching transaction by ID: $id');
      final transaction = await _transactionService.getTransactionById(id);
      print('Fetched transaction: ${transaction.transactionCode}');
      selectedTransaction(transaction);
    } catch (e, stackTrace) {
      print('Error in getTransactionById: $e');
      print(stackTrace);
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

  // void searchItems(String query) {
  //   print('Searching for query: $query');
  //   print('Available barangs: ${barangs.map((b) => b.barangNama).toList()}');
  //   if (query.isEmpty) {
  //     searchResults.clear();
  //     return;
  //   }

  //   final lowerQuery = query.toLowerCase();
  //   final results = barangs
  //       .where((barang) =>
  //           (barang.barangNama?.toLowerCase().contains(lowerQuery) ?? false) ||
  //           (barang.barangKode?.toLowerCase().contains(lowerQuery) ?? false))
  //       .map((barang) {
  //     final barangGudang = barangGudangs.firstWhere(
  //       (bg) => bg.barangId == barang.id,
  //       orElse: () => BarangGudang(
  //         barangId: barang.id,
  //         gudangId: 0,
  //         stokTersedia: 0,
  //         stokDipinjam: 0,
  //         stokMaintenance: 0,
  //       ),
  //     );
  //     print(
  //         'Mapping barang: ${barang.barangNama}, gudang: ${barangGudang.gudang?.name}, stok: ${barangGudang.stokTersedia}');
  //     return {
  //       'barang_kode': barang.barangKode,
  //       'barang_nama': barang.barangNama,
  //       'stok_tersedia': barangGudang.stokTersedia,
  //       'gudang_name': barangGudang.gudang?.name ?? 'Tidak Diketahui',
  //       'satuan': barang.satuanNama ?? 'Unit',
  //     };
  //   }).toList();

  //   searchResults.assignAll(results);
  //   print('Search results: ${searchResults.map((r) => r['barang_nama']).toList()}');
  // }

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
        onPressed: () {
          Get.back();
        },
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
    print('Handling error: $e');
    errorMessage.value = e.toString();
    if (errorMessage.value.contains('No token found')) {
      Get.offAllNamed(RoutesName.login);
    }
    showErrorSnackbar('Error',
        errorMessage.value.isEmpty ? defaultMessage : errorMessage.value);
  }

  void _handleAPIError(dynamic e, StackTrace stackTrace, String defaultMessage) {
    print('API Error: $e');
    print(stackTrace);
    errorMessage.value = e.toString();
    showErrorSnackbar('Error', errorMessage.value.isEmpty ? defaultMessage : errorMessage.value);
    if (errorMessage.value.contains('No token found')) {
      _storage.delete(key: 'auth_token');
      _storage.delete(key: 'user');
      Get.offAllNamed(RoutesName.login);
    }
  }
}
