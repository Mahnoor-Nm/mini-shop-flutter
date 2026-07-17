import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/app_images.dart';
import '../../core/widgets/app_state_view.dart';
import '../products/products_controller.dart';
import 'bottom_nav.dart';
import 'home_controller.dart';
import 'product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final products = Get.find<ProductsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const GroceryBottomNav(index: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: products.loadProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.asset(
                          AppImages.splashAsset,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BigCart',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Fresh groceries, delivered',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.account),
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: TextField(
                    onChanged: controller.search,
                    onSubmitted: (_) => Get.toNamed(AppRoutes.products),
                    decoration: const InputDecoration(
                      hintText: 'Search keywords…',
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AspectRatio(
                      aspectRatio: 1.35,
                      child: Image.asset(
                        AppImages.bannerAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          products.clearFilters();
                          Get.toNamed(AppRoutes.products);
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 108,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final tag in products.tags.skip(1)) ...[
                          _CategoryButton(
                            label: tag,
                            onTap: () {
                              products.openCategory(tag);
                              Get.toNamed(AppRoutes.products);
                            },
                          ),
                          if (tag != products.tags.last)
                            const SizedBox(width: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Featured products',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          products.clearFilters();
                          Get.toNamed(AppRoutes.products);
                        },
                        label: const Text('See all'),
                        icon: const Icon(Icons.chevron_right_rounded),
                        iconAlignment: IconAlignment.end,
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (products.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: ProductGridSkeleton(itemCount: 8),
                    ),
                  );
                }

                if (products.errorMessage.value.isNotEmpty &&
                    products.products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateView(
                      icon: Icons.wifi_off_rounded,
                      title: 'Could not load groceries',
                      message: products.errorMessage.value,
                      actionLabel: 'Retry',
                      onAction: products.loadProducts,
                    ),
                  );
                }

                final items = products.homeProducts
                    .take(12)
                    .toList(growable: false);
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateView(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products available',
                      message: 'Pull down to refresh the grocery catalog.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: items[index]),
                      childCount: items.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.69,
                        ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = switch (label) {
      'Fruits' => (
        icon: Icons.apple_rounded,
        background: const Color(0xFFFFE5DF),
        foreground: const Color(0xFFFF694F),
      ),
      'Vegetables' => (
        icon: Icons.eco_rounded,
        background: const Color(0xFFE4F5E9),
        foreground: const Color(0xFF21A95B),
      ),
      'Beverages' => (
        icon: Icons.local_drink_rounded,
        background: const Color(0xFFFFF0CE),
        foreground: const Color(0xFFFFB321),
      ),
      'Meat & Chicken' => (
        icon: Icons.restaurant_rounded,
        background: const Color(0xFFFFE4E4),
        foreground: const Color(0xFFCF4E4E),
      ),
      'Dairy & Eggs' => (
        icon: Icons.egg_alt_rounded,
        background: const Color(0xFFE5F3FF),
        foreground: const Color(0xFF4187C5),
      ),
      _ => (
        icon: Icons.shopping_basket_rounded,
        background: const Color(0xFFECE4FF),
        foreground: const Color(0xFF8D61E8),
      ),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: style.background,
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.foreground, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
