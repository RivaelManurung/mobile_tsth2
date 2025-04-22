import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/controller/transaction_controller.dart';
import 'package:intl/intl.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildAppBar(controller, isSmallScreen),
          _buildFilterSection(controller, isSmallScreen),
          _buildMainContent(controller, isSmallScreen),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4E6AFF),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => const AddTransactionPage());
            },
            label: const Text('Tambah Transaksi'),
            icon: const Icon(Icons.add),
            backgroundColor: const Color(0xFF4E6AFF),
            elevation: 0,
            highlightElevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            splashColor: Colors.white.withOpacity(0.3),
            foregroundColor: Colors.white,
            extendedTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(TransactionController controller, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 120 : 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: () => controller.refreshData(),
            tooltip: 'Segarkan Data',
          ).animate().fadeIn(delay: 300.ms).scale(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A82FB), Color(0xFF4C60DB)],
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
                      const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 28,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Daftar Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(1, 1),
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
                    'Kelola transaksi Anda dengan mudah',
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

  SliverToBoxAdapter _buildFilterSection(TransactionController controller, bool isSmallScreen) {
    final TextEditingController searchController = TextEditingController();

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: const TextStyle(color: Color(0xFF6F767E)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4E6AFF)),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D1F)),
                  onChanged: (value) {
                    // Implement search logic here
                  },
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.bottomSheet(
                    _buildFilterBottomSheet(controller),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.filter_list, color: Color(0xFF4E6AFF)),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet(TransactionController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF6F767E)),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tipe Transaksi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: controller.selectedTransactionTypeId.value == 0
                    ? null
                    : controller.selectedTransactionTypeId.value,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Semua Tipe'),
                  ),
                  ...controller.transactionTypes
                      .map((type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.name ?? 'Tidak Diketahui'),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  controller.selectedTransactionTypeId.value = value ?? 0;
                  // Implement filter logic here
                },
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Apply filter logic
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4E6AFF),
              ),
              child: const Center(
                child: Text(
                  'Terapkan Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildMainContent(TransactionController controller, bool isSmallScreen) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 16,
      ),
      sliver: SliverToBoxAdapter(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return ErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.refreshData,
            );
          }

          if (controller.transactionList.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, bottom: 8),
                child: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 17 : 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
              ),
              ...controller.transactionList.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                return _buildTransactionCard(transaction, index, isSmallScreen);
              }).toList(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah transaksi baru untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTransactionCard(Transaction transaction, int index, bool isSmallScreen) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final transactionDate = DateTime.parse(transaction.transactionDate!);
    final formattedDate = dateFormat.format(transactionDate);

    return GestureDetector(
      onTap: () {
        // Implement detail view navigation
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.transactionCode ?? 'Unknown',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4E6AFF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E6AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      size: 16,
                      color: Color(0xFF4E6AFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tipe: ${transaction.transactionType.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E6AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Color(0xFF4E6AFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Operator: ${transaction.user.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 12),
              ...transaction.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.barang.barangNama,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1D1F),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kode: ${item.barang.barangKode}',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: const Color(0xFF6F767E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Gudang: ${item.gudang.name}',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: const Color(0xFF6F767E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E6AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Jumlah: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4E6AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Implement detail view navigation
                  },
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E6AFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.2, duration: 400.ms);
  }
}

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildAppBar(isSmallScreen),
          _buildMainContent(controller, isSmallScreen),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 120 : 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A82FB), Color(0xFF4C60DB)],
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
                  Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 4),
                  Text(
                    'Pindai barang untuk membuat transaksi baru',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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

  SliverPadding _buildMainContent(TransactionController controller, bool isSmallScreen) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 16,
      ),
      sliver: SliverToBoxAdapter(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return ErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.refreshData,
            );
          }

          return Column(
            children: [
              _buildScannerSection(controller, isSmallScreen),
              _buildItemsSection(controller, isSmallScreen),
              _buildSubmitSection(controller, isSmallScreen),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScannerSection(TransactionController controller, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            icon: Icons.qr_code_scanner,
            title: 'SCAN BARANG',
            color: const Color(0xFF4E6AFF),
            isSmallScreen: isSmallScreen,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBarcodeField(controller, isSmallScreen),
                const SizedBox(height: 16),
                _buildTransactionTypeDropdown(controller, isSmallScreen),
                const SizedBox(height: 16),
                _buildScanButton(controller, isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms);
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeField(TransactionController controller, bool isSmallScreen) {
    return Obx(() => TextFormField(
          controller: TextEditingController(text: controller.scannedBarcode.value),
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Barcode yang Dipindai',
            labelStyle: const TextStyle(
              color: Color(0xFF6F767E),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: controller.scannedBarcode.value.isNotEmpty
                ? const Color(0xFF4E6AFF).withOpacity(0.05)
                : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: controller.scannedBarcode.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF4E6AFF)),
                    onPressed: () {
                      controller.scannedBarcode.value = '';
                      controller.quantityController.text = '1';
                    },
                  )
                : null,
            prefixIcon: Icon(
              Icons.qr_code,
              color: controller.scannedBarcode.value.isNotEmpty
                  ? const Color(0xFF4E6AFF)
                  : const Color(0xFF6F767E),
            ),
          ),
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: const Color(0xFF1A1D1F),
          ),
        ));
  }

  Widget _buildTransactionTypeDropdown(TransactionController controller, bool isSmallScreen) {
    return Obx(() => DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Tipe Transaksi',
            labelStyle: const TextStyle(
              color: Color(0xFF6F767E),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.swap_horiz, color: Color(0xFF4E6AFF)),
          ),
          value: controller.selectedTransactionTypeId.value == 0
              ? null
              : controller.selectedTransactionTypeId.value,
          items: controller.transactionTypes
              .map((type) => DropdownMenuItem(
                    value: type.id,
                    child: Text(type.name ?? 'Tidak Diketahui'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedTransactionTypeId.value = value;
            }
          },
          validator: (value) => value == null ? 'Wajib dipilih' : null,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: const Color(0xFF1A1D1F),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4E6AFF)),
        ));
  }

  Widget _buildScanButton(TransactionController controller, bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.scanBarcode,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.all(4), // Reduced padding to create space around the colored area
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white, // Background color to create the white border effect
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
          ).copyWith(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white;
              }
              if (states.contains(MaterialState.disabled)) {
                return Colors.white;
              }
              return Colors.white;
            }),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: controller.isLoading.value ? Colors.grey : const Color(0xFF4E6AFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    controller.isLoading.value ? 'MEMPROSES...' : 'PINDAI BARCODE',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildItemsSection(TransactionController controller, bool isSmallScreen) {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          _buildSectionHeader(
            icon: Icons.list_alt,
            title: 'BARANG YANG DIPINDAI (${controller.scannedItems.length})',
            color: const Color(0xFF4E6AFF),
            isSmallScreen: isSmallScreen,
          ),
          Expanded(
            child: controller.scannedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada barang yang dipindai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pindai barcode untuk menambahkan barang',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildItemsList(controller, isSmallScreen),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms);
  }

  Widget _buildItemsList(TransactionController controller, bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: controller.scannedItems.length,
      itemBuilder: (context, index) {
        final item = controller.scannedItems[index];
        return _buildItemCard(controller, index, item, isSmallScreen);
      },
    );
  }

  Widget _buildItemCard(TransactionController controller, int index, Map<String, dynamic> item, bool isSmallScreen) {
    return Dismissible(
      key: Key(item['barang_kode']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.removeScannedItem(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF4E6AFF).withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF4E6AFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['barang_nama'] ?? 'Tidak Diketahui',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kode: ${item['barang_kode']}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF6F767E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildQuantityControls(controller, index, item, isSmallScreen),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideX(begin: 0.2, duration: 400.ms);
  }

  Widget _buildQuantityControls(
      TransactionController controller, int index, Map<String, dynamic> item, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20, color: Color(0xFF4E6AFF)),
            onPressed: () {
              final newQty = item['quantity'] - 1;
              controller.updateItemQuantity(index, newQty);
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Text(
            item['quantity'].toString(),
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1F),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20, color: Color(0xFF4E6AFF)),
            onPressed: () {
              final newQty = item['quantity'] + 1;
              controller.updateItemQuantity(index, newQty);
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection(TransactionController controller, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: controller.submitTransaction,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.all(4), // Reduced padding to create space around the colored area
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white, // Background color to create the white border effect
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return Colors.white;
          }),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4E6AFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MEMPROSES...',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              }
              return Text(
                'SIMPAN TRANSAKSI',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms);
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallScreen ? 40 : 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF1A1D1F),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                elevation: 2,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4E6AFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
  }
}