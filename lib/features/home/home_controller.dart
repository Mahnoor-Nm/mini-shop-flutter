import 'package:get/get.dart';

import '../products/products_controller.dart';

class HomeController extends GetxController {
  ProductsController get products => Get.find<ProductsController>();

  void search(String value) => products.updateSearch(value);
}
