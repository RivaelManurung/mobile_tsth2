import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/transaction_controller.dart';

class TransactionCreatePage extends StatefulWidget {
  const TransactionCreatePage({super.key});

  @override
  _TransactionCreatePageState createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends State<TransactionCreatePage> {
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Use a late final to ensure it's initialized before use in build,
  // relying on Get.find() in initState.
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = Get.find<TransactionController>();
      print('TransactionController initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing TransactionController: $e');
      print(stackTrace);
      // Post a frame callback to ensure the snackbar is shown after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Failed to initialize controller: $e',
            snackPosition: SnackPosition.BOTTOM);
      });
      // Optionally, you might want to return early or show a persistent error state
      // if the controller is absolutely critical and can't be initialized.
      return; // Exit initState if controller couldn't be found
    }

    // Sync TextEditingController with searchController initially.
    // The local controller's text should reflect the GetX controller's state.
    _searchTextController.text = _controller.searchQuery.value;

    // Listen to changes from the local TextEditingController and update the GetX controller's RxString.
    // This is the primary way the UI input flows to the controller's search state.
    _searchTextController.addListener(() {
      // Only update if the text is genuinely different to avoid unnecessary rebuilds or loops.
      if (_searchTextController.text != _controller.searchQuery.value) {
        _controller.searchQuery.value = _searchTextController.text;
        print('TextController listener: text=${_searchTextController.text}');
      }
    });

    // Observe changes from the GetX controller's searchController.text.
    // This allows the local _searchTextController to react to changes made by the GetX controller
    // (e.g., after a barcode scan populates _controller.searchController.text).
    // Ensure that TransactionController.searchController is a TextEditingController and its changes
    // are meant to be reflected in this UI's search field.
    _controller.searchController.addListener(() {
      if (_searchTextController.text != _controller.searchController.text) {
        _searchTextController.text = _controller.searchController.text;
        // Move cursor to the end of the text if it was updated programmatically
        _searchTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchTextController.text.length),
        );
        print('Controller listener updated text to: ${_controller.searchController.text}');
      }
    });

    _searchFocusNode.addListener(() {
      print(
          'Search FocusNode: hasFocus=${_searchFocusNode.hasFocus}, hasPrimaryFocus=${_searchFocusNode.hasPrimaryFocus}');
      if (_searchFocusNode.hasFocus) {
        print('Search field gained focus');
      } else {
        print('Search field lost focus');
      }
    });
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers and FocusNodes to prevent memory leaks.
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    // No need to dispose _controller if it's managed by GetX
    // and will be disposed by Get.delete() or when its scope ends.
    super.dispose();
  }

  Color _getTransactionTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'barang masuk':
        return const Color(0xFF4CAF50);
      case 'peminjaman':
        return const Color(0xFFFFC107);
      case 'barang keluar':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF6F767E);
    }
  }

  String _getTransactionTypeName(int? typeId) {
    if (typeId == null || typeId == 0) return 'Pilih Tipe';
    // Use safe access with firstWhereOrNull and null check
    final type = _controller.transactionTypes
        .firstWhereOrNull((t) => t.id == typeId)
        ?.name;
    return type ?? 'Tidak Diketahui';
  }

  @override
  Widget build(BuildContext context) {
    // This check acts as a safeguard in case initState didn't return immediately
    // or if the controller somehow became null (which shouldn't happen with `late final`).
    // If it still reaches here and _controller is null, something went very wrong.
    try {
      _controller; // Simply access it to trigger a potential error if null
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: Controller not initialized. Please restart the app.',
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows the body to resize when keyboard appears
      backgroundColor: const Color(0xFFF8FAFF),
      body: GestureDetector(
        onTap: () {
          // Unfocus the search field when tapping outside of it.
          // This prevents the keyboard from staying open.
          if (_searchFocusNode.hasFocus) {
            FocusScope.of(context).unfocus();
            print('Tapped outside, unfocusing search field');
          }
        },
        behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(), // Prevents excessive scrolling bounce
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual, // Control keyboard dismissal manually
          slivers: [
            _buildAppBar(isSmallScreen),
            _buildAddTransactionView(isSmallScreen),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 120 : 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent, // Background handled by FlexibleSpaceBar
      surfaceTintColor: Colors.transparent, // Prevents default tinting
      shadowColor: Colors.black.withOpacity(0.1), // Subtle shadow
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(), // Animations for a polished look
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax, // Parallax effect on scroll
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5A67D8), Color(0xFF4C51BF)], // Gradient for AppBar
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Buat Transaksi Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan transaksi baru dengan mudah',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAddTransactionView(bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Buat Transaksi Baru',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF6F767E),
              thickness: 1,
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Cari barang berdasarkan nama atau kode barcode.',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  color: const Color(0xFF6F767E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(isSmallScreen),
                    const SizedBox(height: 24),
                    _buildItemsSection(isSmallScreen: isSmallScreen),
                    const SizedBox(height: 24),
                    _buildSubmitSection(isSmallScreen),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cari Barang',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchField(isSmallScreen),
          const SizedBox(height: 16),
          _buildTransactionTypeDropdown(isSmallScreen),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildManualCheckButton(isSmallScreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScanButton(isSmallScreen),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchResults(isSmallScreen),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSearchField(bool isSmallScreen) {
    return Obx(
      () => TextFormField(
        controller: _searchTextController,
        focusNode: _searchFocusNode,
        autofocus: false, // Set to true if you want it focused on page load
        decoration: InputDecoration(
          labelText: 'Cari Nama Barang atau Kode Barcode',
          labelStyle: TextStyle(
            color: const Color(0xFF6F767E),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 15,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controller.searchQuery.value.isEmpty
                  ? Colors.grey.withOpacity(0.5)
                  : const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          suffixIcon: _controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  onPressed: () {
                    try {
                      _searchTextController.clear();
                      _controller.searchController
                          .clear(); // Clear controller's internal text as well
                      _controller.searchQuery.value = ''; // Reset reactive query
                      _controller.searchResults.clear(); // Clear search results
                      _searchFocusNode.unfocus(); // Dismiss keyboard
                      print('Clear button pressed, cleared text and unfocused');
                    } catch (e, stackTrace) {
                      print('Error in clear button: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Failed to clear search: $e');
                    }
                  },
                )
              : const SizedBox.shrink(),
          prefixIcon: Icon(
            Icons.search,
            color: _controller.searchQuery.value.isNotEmpty
                ? const Color(0xFF4CAF50)
                : const Color(0xFF6F767E),
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          color: const Color(0xFF1A1D1F),
        ),
        textInputAction: TextInputAction.search, // Keyboard action button
        keyboardType: TextInputType.text,
        onTap: () {
          print('TextFormField tapped, requesting focus');
          _searchFocusNode.requestFocus(); // Ensure focus when tapped
        },
        onFieldSubmitted: (value) {
          // Trigger search immediately when "Enter" is pressed on the keyboard
          try {
            print('TextFormField onFieldSubmitted: value=$value');
            if (value.isNotEmpty) {
              // The listener already updates searchQuery.value, and _searchSubject debounces it.
              // Explicitly calling searchItems here ensures an immediate search on submission.
              _controller.searchItems(value);
              _searchFocusNode.unfocus(); // Unfocus after submission
              print('Search submitted and unfocused');
            }
          } catch (e, stackTrace) {
            print('Error in onFieldSubmitted: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Failed to submit search: $e');
          }
        },
        // validator: (value) => value == null || value.isEmpty
        //     ? 'Masukkan kode atau nama barang' // Uncomment if you want immediate validation feedback
        //     : null,
      ),
    );
  }

  Widget _buildTransactionTypeDropdown(bool isSmallScreen) {
    return Obx(
      () => DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Tipe Transaksi',
          hintText: 'Pilih Tipe Transaksi',
          labelStyle: TextStyle(
            color: const Color(0xFF6F767E),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 15,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controller.selectedTransactionTypeId.value == 0
                  ? Colors.grey.withOpacity(0.5)
                  : const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          prefixIcon: const Icon(
            Icons.swap_horiz_rounded,
            color: Color(0xFF4CAF50),
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        value: _controller.selectedTransactionTypeId.value == 0
            ? null // If 0 (default), show hint text
            : _controller.selectedTransactionTypeId.value,
        items: _controller.transactionTypes
            .map((type) => DropdownMenuItem(
                  value: type.id,
                  child: Text(type.name ?? 'Tidak Diketahui'),
                ))
            .toList(),
        onChanged: (value) {
          try {
            if (value != null) {
              _controller.selectedTransactionTypeId.value = value;
              _searchFocusNode.unfocus(); // Dismiss keyboard when changing dropdown
              print('Dropdown changed, unfocusing search field');
            }
          } catch (e, stackTrace) {
            print('Error in dropdown onChanged: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Failed to select transaction type: $e');
          }
        },
        validator: (value) =>
            value == null ? 'Tipe Transaksi wajib dipilih' : null,
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          color: const Color(0xFF1A1D1F),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF4CAF50),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildManualCheckButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ||
                  _controller.searchQuery.value
                      .isEmpty // Disable if loading or search query is empty
              ? null
              : () {
                  try {
                    // Call checkManualBarcode with the current search query
                    _controller
                        .checkManualBarcode(_controller.searchQuery.value);
                    _searchFocusNode.unfocus(); // Dismiss keyboard
                    print(
                        'Manual check button pressed, unfocusing search field');
                  } catch (e, stackTrace) {
                    print('Error in manual check button: $e');
                    print(stackTrace);
                    Get.snackbar('Error', 'Failed to check barcode: $e');
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _controller.isLoading.value ||
                      _controller.searchQuery.value.isEmpty
                  ? Colors.grey[400] // Grey out if disabled
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _controller.isLoading.value ? 'MEMPROSES...' : 'TAMBAH BARANG',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildScanButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ||
                  !_controller.isScanningAllowed
                      .value // Disable if loading or scanning is not allowed
              ? null
              : () {
                  try {
                    _controller.scanBarcode();
                    _searchFocusNode.unfocus(); // Dismiss keyboard
                    print('Scan button pressed, unfocusing search field');
                  } catch (e, stackTrace) {
                    print('Error in scan button: $e');
                    print(stackTrace);
                    Get.snackbar('Error', 'Failed to scan barcode: $e');
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF2196F3),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _controller.isLoading.value || !_controller.isScanningAllowed.value
                  ? Colors.grey[400] // Grey out if disabled
                  : const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _controller.isLoading.value
                    ? 'MEMPROSES...'
                    : 'PINDAI BARCODE',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSearchResults(bool isSmallScreen) {
    return Obx(() => _controller.searchResults.isEmpty
        ? const SizedBox.shrink()
        : Container(
            constraints: const BoxConstraints(maxHeight: 200), // Limit height of results list
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
            ),
            child: ListView.builder(
              shrinkWrap: true, // Take only necessary space
              physics: const ClampingScrollPhysics(), // No extra scrolling
              itemCount: _controller.searchResults.length,
              itemBuilder: (context, index) {
                final item = _controller.searchResults[index];
                return ListTile(
                  title: Text(
                    item['barang_nama']?.toString() ?? 'Tidak Diketahui',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF6F767E),
                    ),
                  ),
                  onTap: () {
                    try {
                      _controller.addSearchResultToScannedItems(item); // Add selected item
                      _searchTextController.clear(); // Clear search field
                      _controller.searchController
                          .clear(); // Ensure GetX controller's text is also cleared
                      _controller.searchQuery.value = ''; // Reset search query
                      _controller.searchResults.clear(); // Clear results
                      _searchFocusNode.unfocus(); // Dismiss keyboard
                      print('Search result tapped, unfocusing search field');
                    } catch (e, stackTrace) {
                      print('Error in search result tap: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Failed to add item: $e');
                    }
                  },
                );
              },
            ),
          ));
  }

  Widget _buildItemsSection({required bool isSmallScreen}) {
    return Container(
      height: 300, // Fixed height for the scanned items list
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Daftar Barang (${_controller.scannedItems.length})',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(() {
                  final typeName = _getTransactionTypeName(
                      _controller.selectedTransactionTypeId.value);
                  final typeColor = _getTransactionTypeColor(typeName);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: typeColor, width: 1),
                    ),
                    child: Text(
                      typeName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: Obx(() => _controller.scannedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Ada Barang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F767E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cari atau pindai barang untuk ditambahkan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _buildItemsList(isSmallScreen)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildItemsList(bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _controller.scannedItems.length,
      itemBuilder: (context, index) {
        final item = _controller.scannedItems[index];
        return _buildItemCard(index, item, isSmallScreen);
      },
    );
  }

  Widget _buildItemCard(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final barcode = item['barang_kode']?.toString() ?? 'unknown_${item['barang_id'] ?? index}'; // Better unique key
    return Dismissible(
      key: ValueKey(barcode), // Use ValueKey for efficient list updates
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        try {
          _controller.removeScannedItem(index);
          _searchFocusNode.unfocus(); // Dismiss keyboard
          print('Item dismissed, unfocusing search field');
        } catch (e, stackTrace) {
          print('Error in dismiss item: $e');
          print(stackTrace);
          Get.snackbar('Error', 'Failed to remove item: $e');
        }
      },
      child: GestureDetector(
        onTap: () {
          try {
            _showEditItemDialog(index, item, isSmallScreen);
            _searchFocusNode.unfocus(); // Dismiss keyboard
            print('Item card tapped, unfocusing search field');
          } catch (e, stackTrace) {
            print('Error in item card tap: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Failed to edit item: $e');
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['barang_nama']?.toString() ?? 'Tidak Diketahui',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1D1F),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Gudang: ${item['gudang_name']?.toString() ?? 'Tidak Diketahui'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildQuantityControls(index, item, isSmallScreen),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms);
  }

  void _showEditItemDialog(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final quantityController =
        TextEditingController(text: item['quantity'].toString());
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Barang: ${item['barang_nama']?.toString() ?? 'Tidak Diketahui'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6F767E)),
            ),
            const SizedBox(height: 4),
            Text(
              'Gudang: ${item['gudang_name']?.toString() ?? 'Tidak Diketahui'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6F767E)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah (${item['satuan']?.toString() ?? 'Unit'})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              // Use onEditingComplete instead of onSubmitted if you want to save on "Done" button press.
              onEditingComplete: () {
                try {
                  final newQty = int.tryParse(quantityController.text) ?? item['quantity'] as int;
                  if (newQty > 0) { // Ensure quantity is at least 1
                    _controller.updateItemQuantity(index, newQty);
                    Get.back();
                  } else {
                    Get.snackbar('Peringatan', 'Jumlah harus lebih besar dari 0');
                  }
                  print('Edit dialog submitted, closing dialog');
                } catch (e, stackTrace) {
                  print('Error in edit dialog submit: $e');
                  print(stackTrace);
                  Get.snackbar('Error', 'Failed to update quantity: $e');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              print('Edit dialog cancelled, closing dialog');
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final newQty = int.tryParse(quantityController.text) ??
                    item['quantity'] as int;
                if (newQty > 0) { // Ensure quantity is at least 1
                  _controller.updateItemQuantity(index, newQty);
                  Get.back();
                } else {
                  Get.snackbar('Peringatan', 'Jumlah harus lebih besar dari 0');
                }
                print('Edit dialog saved, closing dialog');
              } catch (e, stackTrace) {
                print('Error in edit dialog save: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Failed to save quantity: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final quantity = item['quantity'] as int? ?? 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            onPressed: () {
              try {
                final newQty = quantity - 1;
                if (newQty > 0) { // Quantity cannot go below 1
                  _controller.updateItemQuantity(index, newQty);
                  _searchFocusNode.unfocus(); // Dismiss keyboard after interaction
                  print('Quantity decreased, unfocusing search field');
                } else {
                  Get.snackbar('Peringatan', 'Jumlah harus lebih besar dari 0');
                }
              } catch (e, stackTrace) {
                print('Error in decrease quantity: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Failed to decrease quantity: $e');
              }
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity ${item['satuan']?.toString() ?? 'Unit'}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D1F),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            onPressed: () {
              try {
                final newQty = quantity + 1;
                _controller.updateItemQuantity(index, newQty);
                _searchFocusNode.unfocus(); // Dismiss keyboard after interaction
                print('Quantity increased, unfocusing search field');
              } catch (e, stackTrace) {
                print('Error in increase quantity: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Failed to increase quantity: $e');
              }
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection(bool isSmallScreen) {
    return Obx(() {
      final isButtonEnabled =
          _controller.selectedTransactionTypeId.value != 0 &&
              _controller.scannedItems.isNotEmpty &&
              !_controller.isLoading.value; // Button disabled if loading
      final typeName =
          _getTransactionTypeName(_controller.selectedTransactionTypeId.value);
      final typeColor = _getTransactionTypeColor(typeName);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: typeColor, width: 1),
            ),
            child: Text(
              'Tipe Transaksi: $typeName',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isButtonEnabled // Only callable if button is enabled
                ? () {
                    try {
                      _searchFocusNode.unfocus(); // Dismiss keyboard before dialog
                      print('Submit button pressed, unfocusing search field');
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text(
                            'Konfirmasi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            'Apakah Anda yakin ingin menyimpan transaksi $typeName ini?',
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFF6F767E)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back(); // Close the confirmation dialog
                                print(
                                    'Submit dialog cancelled, closing dialog');
                              },
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Color(0xFF6F767E)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  Get.back(); // Close the confirmation dialog
                                  _controller.submitTransaction(); // Initiate transaction submission
                                  // Do not call Get.back() again here if submitTransaction
                                  // is meant to navigate away itself or you want to stay on the page.
                                  // If it navigates, this second Get.back() might cause issues.
                                  // If it doesn't navigate, you might want to show a success message.
                                  print(
                                      'Submit dialog confirmed, initiating transaction submission');
                                } catch (e, stackTrace) {
                                  print('Error in submit transaction: $e');
                                  print(stackTrace);
                                  Get.snackbar('Error',
                                      'Failed to submit transaction: $e');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ya, Simpan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e, stackTrace) {
                      print('Error in submit button: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Failed to open submit dialog: $e');
                    }
                  }
                : null, // Button is disabled
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor:
                  isButtonEnabled ? const Color(0xFF4CAF50) : Colors.grey, // Visual feedback for disabled state
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_controller.isLoading.value) ...[ // Show spinner if loading
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[ // Show icon if not loading
                  const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _controller.isLoading.value
                      ? 'MEMPROSES...'
                      : 'SIMPAN TRANSAKSI',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).scale( // Animations for visual appeal
            begin:
                isButtonEnabled ? const Offset(0.98, 0.98) : const Offset(1, 1),
            end:
                isButtonEnabled ? const Offset(1, 1) : const Offset(0.98, 0.98),
            duration: 300.ms,
            curve: Curves.easeInOut,
          );
    });
  }
}