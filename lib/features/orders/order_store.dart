import 'package:get/get.dart';

import 'order_model.dart';

class OrderStore extends GetxService {
  final orders = <OrderModel>[].obs;

  void add(OrderModel order) {
    orders.removeWhere((existing) => existing.id == order.id);
    orders.insert(0, order);
  }
}
