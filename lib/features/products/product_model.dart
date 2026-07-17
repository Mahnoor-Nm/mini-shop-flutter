class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.thumbnail,
    required this.images,
    this.brand,
    this.sku,
    this.weight,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String thumbnail;
  final List<String> images;
  final String? brand;
  final String? sku;
  final double? weight;

  String get name => title;
  String get imageUrl => thumbnail;
  bool get isOutOfStock => stock <= 0;

  double get originalPrice =>
      discountPercentage <= 0 ? price : price / (1 - discountPercentage / 100);

  String? get discountLabel =>
      discountPercentage <= 0 ? null : '-${discountPercentage.round()}%';

  String get unit {
    if (weight != null && weight! > 0) {
      return '${_formatNumber(weight!)} kg';
    }
    if (tags.isNotEmpty) {
      return tags.first;
    }
    return category;
  }

  String get _classificationText =>
      '$title ${tags.join(' ')} ${brand ?? ''}'.toLowerCase();

  String get searchableText =>
      '$title $description ${tags.join(' ')} $shopCategory'.toLowerCase();

  /// DummyJSON's grocery collection includes pet food. The assignment is a
  /// human grocery shop, so those two records are intentionally excluded.
  bool get isHumanGrocery {
    final value = _classificationText;
    return category.toLowerCase() == 'groceries' &&
        !_containsAny(value, const <String>[
          'cat food',
          'dog food',
          'pet food',
        ]);
  }

  String get shopCategory {
    final value = _classificationText;

    // Dairy must be checked before beverages because milk is a dairy product.
    if (_containsAny(value, _dairyKeywords)) {
      return 'Dairy & Eggs';
    }
    if (_containsAny(value, _meatKeywords)) {
      return 'Meat & Chicken';
    }
    if (_containsAny(value, _beverageKeywords)) {
      return 'Beverages';
    }
    if (_containsAny(value, _fruitKeywords)) {
      return 'Fruits';
    }
    if (_containsAny(value, _vegetableKeywords)) {
      return 'Vegetables';
    }
    return 'Pantry';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _asInt(json['id']),
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString()
          : 'Untitled product',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'groceries',
      price: _asDouble(json['price']),
      discountPercentage: _asDouble(json['discountPercentage']),
      rating: _asDouble(json['rating']),
      stock: _asInt(json['stock']),
      tags: _asStringList(json['tags']),
      thumbnail: json['thumbnail']?.toString() ?? '',
      images: _asStringList(json['images']),
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString(),
      weight: json['weight'] == null ? null : _asDouble(json['weight']),
    );
  }

  static bool _containsAny(String value, List<String> keywords) {
    return keywords.any((keyword) => _containsWholeKeyword(value, keyword));
  }

  static bool _containsWholeKeyword(String value, String keyword) {
    final escaped = RegExp.escape(keyword);
    return RegExp('(^|[^a-z0-9])$escaped([^a-z0-9]|\$)').hasMatch(value);
  }

  static const List<String> _fruitKeywords = <String>[
    'apple',
    'banana',
    'berry',
    'berries',
    'cherry',
    'coconut',
    'fruit',
    'grape',
    'kiwi',
    'lemon',
    'lime',
    'mango',
    'melon',
    'mulberries',
    'mulberry',
    'orange',
    'papaya',
    'peach',
    'pear',
    'pineapple',
    'plum',
    'pomegranate',
    'strawberry',
    'watermelon',
  ];

  static const List<String> _vegetableKeywords = <String>[
    'asparagus',
    'beet',
    'broccoli',
    'cabbage',
    'carrot',
    'cauliflower',
    'celery',
    'chili',
    'corn',
    'cucumber',
    'eggplant',
    'garlic',
    'lettuce',
    'onion',
    'peas',
    'pepper',
    'potato',
    'potatoes',
    'pumpkin',
    'radish',
    'spinach',
    'tomato',
    'vegetable',
    'zucchini',
  ];

  static const List<String> _beverageKeywords = <String>[
    'beverage',
    'cappuccino',
    'coffee',
    'cola',
    'drink',
    'drinks',
    'espresso',
    'juice',
    'latte',
    'lemonade',
    'soda',
    'smoothie',
    'soft drink',
    'tea',
    'water',
  ];

  static const List<String> _meatKeywords = <String>[
    'beef',
    'chicken',
    'fish',
    'meat',
    'mutton',
    'salmon',
    'steak',
    'tuna',
    'turkey',
  ];

  static const List<String> _dairyKeywords = <String>[
    'butter',
    'cheese',
    'cream',
    'egg',
    'eggs',
    'ice cream',
    'milk',
    'yogurt',
    'yoghurt',
  ];

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value.map((item) => item.toString()).toList(growable: false);
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = rawProducts is List
        ? rawProducts
              .whereType<Map>()
              .map(
                (item) =>
                    ProductModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <ProductModel>[];

    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ProductPage(
      products: products,
      total: parseInt(json['total']),
      skip: parseInt(json['skip']),
      limit: parseInt(json['limit']),
    );
  }
}
