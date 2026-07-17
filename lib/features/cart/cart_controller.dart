import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../products/product_model.dart';
import 'cart_api_service.dart';

class CartEntry {
  CartEntry({required this.product, required this.quantity});

  final ProductModel product;
  int quantity;

  double get subtotal => product.price * quantity;

  CartEntry copy() => CartEntry(product: product, quantity: quantity);
}

class CartController extends GetxController {
  CartController({CartApiService? api}) : _api = api ?? CartApiService();

  final CartApiService _api;
  final entries = <int, CartEntry>{}.obs;
  final updatingIds = <int>{}.obs;
  final isCheckoutLoading = false.obs;
  final errorMessage = ''.obs;

  List<CartEntry> get items => entries.values.toList(growable: false);
  int quantityFor(int id) => entries[id]?.quantity ?? 0;
  bool isUpdating(int id) => updatingIds.contains(id);
  int get itemCount =>
      entries.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      entries.values.fold(0.0, (sum, item) => sum + item.subtotal);
  double get delivery => 0;
  double get total => subtotal + delivery;

  Future<void> add(ProductModel product) async {
    if (product.isOutOfStock || isUpdating(product.id)) return;
    final backup = _snapshot();
    final existing = entries[product.id];
    if (existing == null) {
      entries[product.id] = CartEntry(product: product, quantity: 1);
    } else {
      existing.quantity += 1;
      entries.refresh();
    }
    await _syncOrRollback(product.id, backup);
  }

  Future<void> increment(int id) async {
    final entry = entries[id];
    if (entry == null || isUpdating(id)) return;
    final backup = _snapshot();
    entry.quantity += 1;
    entries.refresh();
    await _syncOrRollback(id, backup);
  }

  Future<void> decrement(int id) async {
    final entry = entries[id];
    if (entry == null || isUpdating(id)) return;
    if (entry.quantity <= 1) {
      await remove(id);
      return;
    }
    final backup = _snapshot();
    entry.quantity -= 1;
    entries.refresh();
    await _syncOrRollback(id, backup);
  }

  Future<void> remove(int id) async {
    final removed = entries[id];
    if (removed == null || isUpdating(id)) return;
    final backup = _snapshot();
    entries.remove(id);
    updatingIds.add(id);
    try {
      await _api.deleteCart();
      if (entries.isNotEmpty) await _api.updateCart(_payload());
      errorMessage.value = '';
    } on ApiException catch (error) {
      _restore(backup);
      _showError(error.message);
    } catch (_) {
      _restore(backup);
      _showError('The item could not be removed.');
    } finally {
      updatingIds.remove(id);
    }
  }

  Future<void> clearRemote() async {
    if (entries.isEmpty) return;
    try {
      await _api.deleteCart();
      entries.clear();
      errorMessage.value = '';
    } on ApiException catch (error) {
      _showError(error.message);
    }
  }

  void clearLocal() => entries.clear();

  Future<bool> prepareCheckout() async {
    if (entries.isEmpty) return false;
    isCheckoutLoading.value = true;
    try {
      await _api.updateCart(_payload());
      errorMessage.value = '';
      return true;
    } on ApiException catch (error) {
      _showError(error.message);
      return false;
    } catch (_) {
      _showError('Checkout could not be started.');
      return false;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  Future<void> _syncOrRollback(int id, Map<int, CartEntry> backup) async {
    updatingIds.add(id);
    try {
      await _api.updateCart(_payload());
      errorMessage.value = '';
    } on ApiException catch (error) {
      _restore(backup);
      _showError(error.message);
    } catch (_) {
      _restore(backup);
      _showError('The cart could not be updated.');
    } finally {
      updatingIds.remove(id);
    }
  }

  List<Map<String, int>> _payload() => entries.values
      .map((entry) => {'id': entry.product.id, 'quantity': entry.quantity})
      .toList(growable: false);

  Map<int, CartEntry> _snapshot() => {
    for (final item in entries.entries) item.key: item.value.copy(),
  };

  void _restore(Map<int, CartEntry> snapshot) {
    entries.assignAll(snapshot);
  }

  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Cart update failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
