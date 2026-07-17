import '../../core/network/api_client.dart';

class CartApiService {
  CartApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  static const int cartId = 1;

  Future<Map<String, dynamic>> updateCart(List<Map<String, int>> products) {
    return _client.putJson('/carts/$cartId', {
      'merge': false,
      'products': products,
    });
  }

  Future<Map<String, dynamic>> deleteCart() {
    return _client.deleteJson('/carts/$cartId');
  }

  Future<Map<String, dynamic>> getUserCarts({int userId = 1}) {
    return _client.getJson('/carts/user/$userId');
  }
}
