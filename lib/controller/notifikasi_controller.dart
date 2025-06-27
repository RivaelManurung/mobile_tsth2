import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/services/notifikasi_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService;

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  NotificationController({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // Fetch all unread notifications
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _notificationService.getNotifications();

      if (response['success']) {
        notifications.assignAll(List<Map<String, dynamic>>.from(response['data']));
      } else {
        errorMessage(response['message']);
        Get.snackbar('Error', response['message'], snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _notificationService.markAsRead(id);

      if (response['success']) {
        // Update the notification list by removing or marking the notification as read
        notifications.removeWhere((notification) => notification['id'] == id);
        Get.snackbar('Success', response['message'], snackPosition: SnackPosition.BOTTOM);
      } else {
        errorMessage(response['message']);
        Get.snackbar('Error', response['message'], snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _notificationService.markAllAsRead();

      if (response['success']) {
        notifications.clear();
        Get.snackbar('Success', response['message'], snackPosition: SnackPosition.BOTTOM);
      } else {
        errorMessage(response['message']);
        Get.snackbar('Error', response['message'], snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }
}