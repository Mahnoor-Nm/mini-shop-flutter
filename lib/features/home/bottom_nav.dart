import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../cart/cart_controller.dart';

class GroceryBottomNav extends StatelessWidget {
  const GroceryBottomNav({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(
      () => NavigationBar(
        selectedIndex: index,
        height: 72,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.limeSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) {
          if (value == index) return;
          switch (value) {
            case 0:
              Get.offAllNamed(AppRoutes.home);
              return;
            case 1:
              Get.toNamed(AppRoutes.products);
              return;
            case 2:
              Get.toNamed(AppRoutes.cart);
              return;
            case 3:
              Get.toNamed(AppRoutes.account);
              return;
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
