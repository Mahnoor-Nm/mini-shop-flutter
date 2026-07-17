import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../cart/cart_controller.dart';
import '../products/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.productDetails,
          parameters: {'id': '${product.id}'},
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEFEA),
                              shape: BoxShape.circle,
                            ),
                          ),
                          CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, _, _) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textMuted,
                              size: 42,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (product.discountLabel != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        color: const Color(0xFFFFE5E5),
                        child: Text(
                          product.discountLabel!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Column(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.lime,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 48,
              child: Obx(() {
                final quantity = cart.quantityFor(product.id);
                final updating = cart.isUpdating(product.id);

                if (updating) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (quantity == 0) {
                  return InkWell(
                    onTap: product.isOutOfStock
                        ? null
                        : () => cart.add(product),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.isOutOfStock
                                ? Icons.block_rounded
                                : Icons.shopping_bag_outlined,
                            color: product.isOutOfStock
                                ? AppColors.textMuted
                                : AppColors.lime,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.isOutOfStock
                                ? 'Out of stock'
                                : 'Add to cart',
                            style: TextStyle(
                              color: product.isOutOfStock
                                  ? AppColors.textMuted
                                  : AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => cart.decrement(product.id),
                      icon: const Icon(Icons.remove_rounded),
                      color: AppColors.lime,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => cart.increment(product.id),
                      icon: const Icon(Icons.add_rounded),
                      color: AppColors.lime,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
