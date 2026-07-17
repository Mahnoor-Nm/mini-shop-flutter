import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/primary_button.dart';
import '../../core/widgets/app_state_view.dart';
import 'checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (controller.cart.items.isEmpty) {
          return AppStateView(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: 'Add groceries before continuing to checkout.',
            actionLabel: 'Browse products',
            onAction: () => Get.offNamed(AppRoutes.products),
          );
        }

        if (controller.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          top: false,
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const Text(
                  'Delivery details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Confirm where we should deliver your groceries.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            controller.requiredValidator(value, 'Full name'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: controller.phoneValidator,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.addressController,
                        keyboardType: TextInputType.streetAddress,
                        minLines: 3,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Delivery address',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) => controller.requiredValidator(
                          value,
                          'Delivery address',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const _SectionCard(
                  child: Row(
                    children: [
                      _PaymentIcon(),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash on delivery',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Pay with cash when your order arrives.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Items amount',
                        value:
                            '\$${controller.originalAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Discount',
                        value: controller.discount > 0
                            ? '-\$${controller.discount.toStringAsFixed(2)}'
                            : '\$0.00',
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Delivery',
                        value: controller.delivery == 0
                            ? 'FREE'
                            : '\$${controller.delivery.toStringAsFixed(2)}',
                        valueColor: AppColors.primary,
                      ),
                      const Divider(height: 28),
                      _SummaryRow(
                        label: 'Amount to pay',
                        value: '\$${controller.total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Place order',
                  icon: Icons.arrow_forward_rounded,
                  loading:
                      controller.isPlacingOrder.value ||
                      controller.cart.isCheckoutLoading.value,
                  onPressed: controller.placeOrder,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.limeSoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.payments_outlined, color: AppColors.primary),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isTotal ? AppColors.primary : AppColors.text),
            fontSize: isTotal ? 22 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
