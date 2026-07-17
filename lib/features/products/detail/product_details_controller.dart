import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../product_model.dart';
import '../products_repository.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController({ProductsRepository? repository})
    : _repository = repository ?? ProductsRepository();

  final ProductsRepository _repository;
  final product = Rxn<ProductModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  late final int productId;

  @override
  void onInit() {
    super.onInit();
    productId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    loadProduct();
  }

  Future<void> loadProduct() async {
    if (productId <= 0) {
      errorMessage.value = 'Invalid product.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      product.value = await _repository.getProduct(productId);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'The product could not be loaded.';
    } finally {
      isLoading.value = false;
    }
  }
}
