import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/account/account_controller.dart';
import '../features/account/account_view.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/forgot_password_view.dart';
import '../features/auth/login_view.dart';
import '../features/auth/signup_view.dart';
import '../features/cart/cart_controller.dart';
import '../features/cart/cart_view.dart';
import '../features/checkout/checkout_controller.dart';
import '../features/checkout/checkout_view.dart';
import '../features/home/home_controller.dart';
import '../features/home/home_view.dart';
import '../features/orders/order_store.dart';
import '../features/orders/orders_controller.dart';
import '../features/orders/orders_view.dart';
import '../features/products/detail/product_details_controller.dart';
import '../features/products/detail/product_details_view.dart';
import '../features/products/products_controller.dart';
import '../features/products/products_view.dart';
import '../features/splash/splash_view.dart';
import '../features/success/success_view.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class GroceryMartApp extends StatelessWidget {
  const GroceryMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mini Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashView()),
        GetPage(name: AppRoutes.login, page: () => const LoginView()),
        GetPage(name: AppRoutes.signup, page: () => const SignupView()),
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordView(),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<HomeController>(HomeController.new, fenix: true),
          ),
        ),
        GetPage(name: AppRoutes.products, page: () => const ProductsView()),
        GetPage(
          name: AppRoutes.productDetails,
          page: () => const ProductDetailsView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<ProductDetailsController>(
              ProductDetailsController.new,
            ),
          ),
        ),
        GetPage(name: AppRoutes.cart, page: () => const CartView()),
        GetPage(
          name: AppRoutes.checkout,
          page: () => const CheckoutView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<CheckoutController>(CheckoutController.new),
          ),
        ),
        GetPage(
          name: AppRoutes.account,
          page: () => const AccountView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<AccountController>(
              AccountController.new,
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: AppRoutes.orders,
          page: () => const OrdersView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<OrdersController>(OrdersController.new),
          ),
        ),
        GetPage(name: AppRoutes.success, page: () => const SuccessView()),
      ],
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(AuthController.new, fenix: true);
    Get.put<ProductsController>(ProductsController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<OrderStore>(OrderStore(), permanent: true);
  }
}
