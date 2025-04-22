import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/transaction_type_controller.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_form_page.dart';

class TransactionTypeDetailPage extends StatelessWidget {
  TransactionTypeDetailPage({super.key});

  final TransactionTypeController _controller = Get.find<TransactionTypeController>();

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments as int;
    _controller.getTransactionTypeById(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Transaction Type Details',
          style: TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
            ),
          );
        }
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              _controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
        final transactionType = _controller.selectedTransactionType.value;
        if (transactionType == null) {
          return const Center(
            child: Text(
              'Transaction type not found',
              style: TextStyle(
                color: Color(0xFF6F767E),
                fontSize: 16,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transactionType.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Slug: ${transactionType.slug}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F767E),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E6AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _controller.nameController.text = transactionType.name;
                      Get.to(() => TransactionTypeFormPage(), arguments: transactionType.id);
                    },
                    child: const Text('Edit'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Delete Transaction Type',
                        middleText: 'Are you sure you want to delete ${transactionType.name}?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          _controller.deleteTransactionType(transactionType.id);
                        },
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}