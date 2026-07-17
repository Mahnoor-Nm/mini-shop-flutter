import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/app_images.dart';
import '../../core/primary_button.dart';
import 'auth_controller.dart';
import 'auth_layout.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      imageAsset: AppImages.signupHeroAsset,
      topTitle: 'Join Mini Shop',
      child: Form(
        key: controller.signupKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create account',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join Mini Shop for fresh groceries delivered to your doorstep.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: controller.signupName,
              validator: (value) =>
                  controller.requiredValidator(value, 'Full name'),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.signupEmail,
              validator: controller.emailValidator,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.signupPhone,
              validator: controller.phoneValidator,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Phone number',
                prefixIcon: Icon(Icons.call_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                controller: controller.signupPassword,
                validator: controller.passwordValidator,
                obscureText: controller.hideSignupPassword.value,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: controller.hideSignupPassword.toggle,
                    icon: Icon(
                      controller.hideSignupPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                controller: controller.signupConfirmPassword,
                validator: controller.confirmPasswordValidator,
                obscureText: controller.hideConfirmPassword.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.signup(),
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    onPressed: controller.hideConfirmPassword.toggle,
                    icon: Icon(
                      controller.hideConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Checkbox(
                    value: controller.acceptTerms.value,
                    onChanged: (value) =>
                        controller.acceptTerms.value = value ?? false,
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => PrimaryButton(
                label: 'Create account',
                loading: controller.loading.value,
                onPressed: controller.signup,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.login),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
