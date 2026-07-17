import '../../core/network/api_client.dart';
import 'product_model.dart';

class ProductsRepository {
  ProductsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<ProductPage> getGroceries({int limit = 30, int skip = 0}) async {
    final json = await _client.getJson(
      '/products/category/groceries?limit=$limit&skip=$skip',
    );
    return ProductPage.fromJson(json);
  }

  /// Uses the exact grocery endpoint from the internship Postman collection.
  /// One request keeps startup fast while still returning more than twenty
  /// human grocery products across produce, drinks, meat, dairy and pantry.
  Future<ProductPage> getCatalog() async {
    final page = await getGroceries(limit: 30, skip: 0);
    final products = page.products
        .where((product) => product.isHumanGrocery)
        .toList(growable: false);

    return ProductPage(
      products: products,
      total: products.length,
      skip: 0,
      limit: products.length,
    );
  }

  Future<ProductModel> getProduct(int id) async {
    final json = await _client.getJson('/products/$id');
    return ProductModel.fromJson(json);
  }
}
