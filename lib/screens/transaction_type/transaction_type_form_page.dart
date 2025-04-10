import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/TransactionType/transaction_type_controller.dart';

class TransactionTypeFormPage extends StatelessWidget {
  TransactionTypeFormPage({super.key});

  final TransactionTypeController _controller = Get.find<TransactionTypeController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final int? id = Get.arguments as int?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          id == null ? 'Create Transaction Type' : 'Update Transaction Type',
          style: const TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Color(0xFF6F767E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Obx(() {
                return _controller.isLoading.value
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E6AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (id == null) {
                              _controller.createTransactionType();
                            } else {
                              _controller.updateTransactionType(id);
                            }
                          }
                        },
                        child: Text(id == null ? 'Create' : 'Update'),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}