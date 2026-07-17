import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_mart/features/products/product_model.dart';

void main() {
  test('ProductModel parses DummyJSON product data', () {
    final product = ProductModel.fromJson({
      'id': 16,
      'title': 'Apple',
      'description': 'Fresh apple',
      'category': 'groceries',
      'price': 2.5,
      'discountPercentage': 10,
      'rating': 4.7,
      'stock': 20,
      'tags': ['fruits'],
      'thumbnail': 'https://example.com/apple.png',
      'images': ['https://example.com/apple.png'],
      'weight': 1,
    });

    expect(product.id, 16);
    expect(product.title, 'Apple');
    expect(product.price, 2.5);
    expect(product.unit, '1 kg');
  });
}
