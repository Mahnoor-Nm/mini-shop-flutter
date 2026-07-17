import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class AccountController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;
  final walletBalance = 0.0.obs;
  final errorMessage = ''.obs;

  User? get user => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final current = user;
    if (current == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    name.value = current.displayName?.trim() ?? '';
    email.value = current.email ?? '';
    phone.value = current.phoneNumber ?? '';

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(current.uid)
          .get();
      final data = snapshot.data();
      if (data != null) {
        name.value = data['name']?.toString().trim().isNotEmpty == true
            ? data['name'].toString()
            : name.value;
        email.value = data['email']?.toString() ?? email.value;
        phone.value = data['phone']?.toString() ?? phone.value;
        address.value = data['address']?.toString() ?? '';
        final wallet = data['walletBalance'];
        walletBalance.value = wallet is num ? wallet.toDouble() : 0;
      }
    } catch (_) {
      errorMessage.value =
          'Profile details could not be loaded. Pull down to retry.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAddress(String value) async {
    final current = user;
    final cleaned = value.trim();
    if (current == null || cleaned.isEmpty) return false;
    isSaving.value = true;
    try {
      await _firestore.collection('users').doc(current.uid).set({
        'address': cleaned,
        'email': current.email ?? '',
        'name': name.value,
      }, SetOptions(merge: true));
      address.value = cleaned;
      Get.snackbar(
        'Address updated',
        'Your delivery address was saved.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (_) {
      Get.snackbar(
        'Update failed',
        'The delivery address could not be saved.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
