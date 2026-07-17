import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../orders/order_model.dart';
import '../orders/order_store.dart';

class CheckoutController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartController cart = Get.find<CartController>();
  final OrderStore orderStore = Get.find<OrderStore>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final isLoadingProfile = true.obs;
  final isPlacingOrder = false.obs;

  double get originalAmount => cart.items.fold(
    0.0,
    (totalValue, entry) =>
        totalValue + (entry.product.originalPrice * entry.quantity),
  );

  double get discount => cart.items.fold(
    0.0,
    (totalValue, entry) =>
        totalValue +
        ((entry.product.originalPrice - entry.product.price) * entry.quantity),
  );

  double get delivery => cart.delivery;
  double get total => cart.total;

  @override
  void onInit() {
    super.onInit();
    _loadDeliveryDetails();
  }

  String? requiredValidator(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Phone number is required';
    }
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _loadDeliveryDetails() async {
    final user = _auth.currentUser;
    if (user == null) {
      isLoadingProfile.value = false;
      return;
    }

    nameController.text = user.displayName?.trim() ?? '';
    phoneController.text = user.phoneNumber?.trim() ?? '';

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      final data = snapshot.data();

      if (data != null) {
        final savedName = data['name']?.toString().trim() ?? '';
        final savedPhone = data['phone']?.toString().trim() ?? '';
        final savedAddress = data['address']?.toString().trim() ?? '';

        if (savedName.isNotEmpty) {
          nameController.text = savedName;
        }
        if (savedPhone.isNotEmpty) {
          phoneController.text = savedPhone;
        }

        addressController.text = savedAddress;
      }
    } catch (_) {
      // Checkout remains usable even if optional profile loading fails.
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> placeOrder() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (cart.items.isEmpty || isPlacingOrder.value) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Sign in required',
        'Please sign in before placing an order.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isPlacingOrder.value = true;

    try {
      final ready = await cart.prepareCheckout();
      if (!ready) {
        return;
      }

      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();
      final orderNumber = id.substring(id.length - 8).toUpperCase();

      final order = OrderModel(
        id: id,
        orderNumber: orderNumber,
        createdAt: now,
        status: 'Placed',
        paymentMethod: 'Cash on delivery',
        originalAmount: originalAmount,
        discount: discount,
        delivery: delivery,
        total: total,
        deliveryName: nameController.text.trim(),
        deliveryPhone: phoneController.text.trim(),
        deliveryAddress: addressController.text.trim(),
        items: cart.items
            .map(
              (entry) => OrderItemModel(
                productId: entry.product.id,
                title: entry.product.title,
                quantity: entry.quantity,
                price: entry.product.price,
                thumbnail: entry.product.thumbnail,
              ),
            )
            .toList(growable: false),
      );

      // Makes the order visible immediately in this app session.
      orderStore.add(order);

      // Firestore persistence is best-effort and must not block success.
      await _saveToFirestoreBestEffort(user, order);

      Get.offNamed(
        AppRoutes.success,
        arguments: <String, String>{'orderNumber': orderNumber},
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> _saveToFirestoreBestEffort(User user, OrderModel order) async {
    try {
      final userReference = _firestore.collection('users').doc(user.uid);
      final orderReference = userReference.collection('orders').doc(order.id);
      final batch = _firestore.batch();

      batch.set(userReference, <String, dynamic>{
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'email': user.email ?? '',
      }, SetOptions(merge: true));
      batch.set(orderReference, order.toFirestore());

      await batch.commit();
    } on FirebaseException catch (error) {
      debugPrint('Order history sync skipped: ${error.code} ${error.message}');
    } catch (error) {
      debugPrint('Order history sync skipped: $error');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
