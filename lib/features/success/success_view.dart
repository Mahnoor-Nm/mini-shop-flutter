import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/primary_button.dart';
import '../cart/cart_controller.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final arguments = Get.arguments;
    final orderNumber = arguments is Map
        ? arguments['orderNumber']?.toString() ?? 'NEW'
        : 'NEW';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x8876D32F),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 142,
                      height: 142,
                      decoration: const BoxDecoration(
                        color: AppColors.limeSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 72,
                        color: AppColors.primary,
                      ),
                    ),
                    const Positioned(
                      left: 22,
                      top: 44,
                      child: Icon(Icons.auto_awesome, color: AppColors.lime),
                    ),
                    const Positioned(
                      right: 18,
                      bottom: 48,
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.lime,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Order placed!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Your order #$orderNumber was received successfully. We are preparing your fresh groceries now.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue shopping',
                icon: Icons.arrow_forward,
                onPressed: () {
                  cart.clearLocal();
                  Get.offAllNamed(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
