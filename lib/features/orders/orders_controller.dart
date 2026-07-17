import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'order_model.dart';
import 'order_store.dart';

class OrdersController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderStore _store = Get.find<OrderStore>();

  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  Worker? _localWorker;

  @override
  void onInit() {
    super.onInit();
    _localWorker = ever<List<OrderModel>>(
      _store.orders,
      (_) => _mergeOrders(const <OrderModel>[]),
    );
    loadOrders();
  }

  Future<void> loadOrders() async {
    final user = _auth.currentUser;
    isLoading.value = true;
    errorMessage.value = '';

    if (user == null) {
      _mergeOrders(const <OrderModel>[]);
      isLoading.value = false;
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final remoteOrders = snapshot.docs
          .map(
            (document) => OrderModel.fromDocument(document.id, document.data()),
          )
          .toList(growable: false);
      _mergeOrders(remoteOrders);
    } on FirebaseException catch (error) {
      _mergeOrders(const <OrderModel>[]);
      if (_store.orders.isEmpty) {
        errorMessage.value =
            error.message ?? 'Your orders could not be loaded.';
      }
    } catch (_) {
      _mergeOrders(const <OrderModel>[]);
      if (_store.orders.isEmpty) {
        errorMessage.value = 'Your orders could not be loaded.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _mergeOrders(List<OrderModel> remoteOrders) {
    final merged = <String, OrderModel>{};

    for (final order in remoteOrders) {
      merged[order.id] = order;
    }
    for (final order in _store.orders) {
      merged[order.id] = order;
    }

    final result = merged.values.toList(growable: false)
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    orders.assignAll(result);
  }

  @override
  void onClose() {
    _localWorker?.dispose();
    super.onClose();
  }
}
