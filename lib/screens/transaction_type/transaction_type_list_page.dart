import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/transaction_type_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_detail_page.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_form_page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionTypeListPage extends StatelessWidget {
  TransactionTypeListPage({super.key});

  final TransactionTypeController _controller = Get.put(TransactionTypeController());
  final AuthController _authController = Get.find<AuthController>();
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _refreshData,
        enablePullDown: true,
        header: const ClassicHeader(
          idleText: 'Pull to refresh',
          releaseText: 'Release to refresh',
          refreshingText: 'Refreshing...',
          completeText: 'Refresh complete',
          failedText: 'Refresh failed',
          textStyle: TextStyle(color: Color(0xFF6F767E)),
        ),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _buildAppBar(isSmallScreen),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
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
                        controller: _controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search transaction types...',
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
                        onChanged: (value) => _controller.update(),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 16),
                    child: Obx(() {
                      if (_controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
                          ),
                        ).animate().fadeIn(delay: 200.ms);
                      }
                      if (_controller.errorMessage.value.isNotEmpty) {
                        return Container(
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
                                _controller.errorMessage.value.contains('No token found')
                                    ? 'Your session has expired. Please log in again.'
                                    : _controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: const Color(0xFF1A1D1F),
                                ),
                              ),
                              if (_controller.errorMessage.value.contains('No token found'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4E6AFF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    onPressed: () => Get.offAllNamed(RoutesName.login),
                                    child: Text(
                                      'Go to Login',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
                      }
                      if (_controller.filteredTransactionType.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transaction types found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a new transaction type to start',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, bottom: 8),
                            child: Text(
                              'Transaction Types',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 17 : 19,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1D1F),
                              ),
                            ),
                          ),
                          ..._controller.filteredTransactionType.asMap().entries.map((entry) {
                            final index = entry.key;
                            final transactionType = entry.value;
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => TransactionTypeDetailPage(), arguments: transactionType.id);
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
                                  child: Semantics(
                                    label: 'Transaction Type ${transactionType.name}',
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(0xFF4E6AFF).withOpacity(0.1),
                                          radius: 24,
                                          child: Text(
                                            transactionType.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF4E6AFF),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transactionType.name,
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 16 : 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF1A1D1F),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                transactionType.slug ?? 'No slug',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 12 : 13,
                                                  color: const Color(0xFF6F767E),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF6F767E),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(
                                  begin: 0.2,
                                  duration: 400.ms,
                                );
                          }).toList(),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 80), // Prevent FAB overlap
                ],
              ),
            ),
          ],
        ),
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
              _controller.clearForm();
              Get.to(() => TransactionTypeFormPage());
            },
            label: const Text('Add Transaction Type'),
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
          tooltip: 'Back',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh Data',
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
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 28,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transaction Type Management',
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
                    'Manage your transaction types with ease',
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

  Future<void> _refreshData() async {
    try {
      await _controller.fetchAllTransactionType();
      _refreshController.refreshCompleted();
      Get.snackbar(
        'Success',
        'Transaction types updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      _refreshController.refreshFailed();
      Get.snackbar(
        'Failed',
        'Failed to update transaction types',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}