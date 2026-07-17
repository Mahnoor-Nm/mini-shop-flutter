import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import 'product_model.dart';
import 'products_repository.dart';

class ProductsController extends GetxController {
  ProductsController({ProductsRepository? repository})
    : _repository = repository ?? ProductsRepository();

  final ProductsRepository _repository;

  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final query = ''.obs;
  final searchInput = ''.obs;
  final selectedTag = 'All'.obs;

  Worker? _searchWorker;

  List<String> get tags => const <String>[
    'All',
    'Fruits',
    'Vegetables',
    'Beverages',
    'Meat & Chicken',
    'Dairy & Eggs',
    'Pantry',
  ];

  List<ProductModel> get filteredProducts {
    final search = query.value.trim().toLowerCase();
    final category = selectedTag.value.toLowerCase();

    return products
        .where((product) {
          final matchesSearch =
              search.isEmpty || product.searchableText.contains(search);
          final matchesCategory =
              category == 'all' ||
              product.shopCategory.toLowerCase() == category;
          return matchesSearch && matchesCategory;
        })
        .toList(growable: false);
  }

  List<ProductModel> get homeProducts {
    final search = query.value.trim().toLowerCase();
    return products
        .where(
          (product) =>
              search.isEmpty || product.searchableText.contains(search),
        )
        .toList(growable: false);
  }

  int countFor(String category) {
    if (category == 'All') {
      return products.length;
    }
    return products.where((product) => product.shopCategory == category).length;
  }

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(
      searchInput,
      (value) => query.value = value.trim(),
      time: const Duration(milliseconds: 220),
    );
    loadProducts();
  }

  Future<void> loadProducts({bool reset = true}) async {
    if (!reset || (isLoading.value && products.isNotEmpty)) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final page = await _repository.getCatalog();
      products.assignAll(page.products);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong while loading products.';
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchInput.value = value;
    if (value.trim().isEmpty) {
      query.value = '';
    }
  }

  void selectTag(String value) {
    selectedTag.value = value;
  }

  void openCategory(String value) {
    query.value = '';
    searchInput.value = '';
    selectedTag.value = value;
  }

  void clearFilters() {
    searchInput.value = '';
    query.value = '';
    selectedTag.value = 'All';
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }
}
