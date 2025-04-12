import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/TransactionType/transaction_type_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_detail_page.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_form_page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionTypeListPage extends StatelessWidget {
  final TransactionTypeController _controller =
      Get.put(TransactionTypeController());
  final RefreshController _refreshController = RefreshController();
  final AuthController _authController = Get.find<AuthController>();

  TransactionTypeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Transaction Type Management',
          style: TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4E6AFF)),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _refreshData,
        header: const ClassicHeader(
          idleText: 'Pull to refresh',
          releaseText: 'Release to refresh',
          refreshingText: 'Refreshing...',
          completeText: 'Refresh complete',
          failedText: 'Refresh failed',
          textStyle: TextStyle(color: Color(0xFF6F767E)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller.searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search transaction types...',
                    hintStyle: TextStyle(color: Color(0xFF6F767E)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6F767E)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => _controller.update(),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
                    ),
                  );
                }
                if (_controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        if (_controller.errorMessage.value
                            .contains('No token found'))
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E6AFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  Get.offAllNamed(RoutesName.login),
                              child: const Text('Go to Login'),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                if (_controller.filteredTransactionType.isEmpty) {
                  return const Center(
                    child: Text(
                      'No transaction types found',
                      style: TextStyle(
                        color: Color(0xFF6F767E),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: _controller.filteredTransactionType.length,
                  itemBuilder: (context, index) {
                    final transactionType =
                        _controller.filteredTransactionType[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4E6AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                transactionType.name
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF4E6AFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            transactionType.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D1F),
                            ),
                          ),
                          subtitle: Text(
                            'Slug: ${transactionType.slug}',
                            style: const TextStyle(color: Color(0xFF6F767E)),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFF6F767E),
                          ),
                          onTap: () {
                            Get.to(() => TransactionTypeDetailPage(),
                                arguments: transactionType.id);
                          },
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4E6AFF),
        onPressed: () {
          _controller.clearForm();
          Get.to(() => TransactionTypeFormPage());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      await _controller.fetchAllTransactionType();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }
}
