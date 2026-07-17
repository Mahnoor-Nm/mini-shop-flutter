import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_state_view.dart';
import '../home/bottom_nav.dart';
import '../home/product_card.dart';
import 'products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const GroceryBottomNav(index: 1),
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'All Products',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.loadProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: TextField(
                    onChanged: controller.updateSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search products or categories…',
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final selected = controller.selectedTag.value;
                  final count = controller.filteredProducts.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 46,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final tag in controller.tags) ...[
                                ChoiceChip(
                                  selected: selected == tag,
                                  label: Text(tag),
                                  onSelected: (_) => controller.selectTag(tag),
                                  showCheckmark: selected == tag,
                                  checkmarkColor: AppColors.white,
                                  side: BorderSide.none,
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surfaceLow,
                                  labelStyle: TextStyle(
                                    color: selected == tag
                                        ? AppColors.white
                                        : AppColors.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (tag != controller.tags.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                        child: Text(
                          '$count ${count == 1 ? 'product' : 'products'}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: ProductGridSkeleton(itemCount: 8),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateView(
                      icon: Icons.wifi_off_rounded,
                      title: 'Could not load products',
                      message: controller.errorMessage.value,
                      actionLabel: 'Retry',
                      onAction: controller.loadProducts,
                    ),
                  );
                }

                final products = controller.filteredProducts;
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No products found',
                      message: 'Try another search or choose All Products.',
                      actionLabel: 'Show all',
                      onAction: controller.clearFilters,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: products[index]),
                      childCount: products.length,
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
