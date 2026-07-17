import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/app_images.dart';
import '../../core/primary_button.dart';
import 'auth_controller.dart';
import 'auth_layout.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      imageAsset: AppImages.loginHeroAsset,
      topTitle: 'Welcome',
      child: Form(
        key: controller.loginKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back !',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to your account',
              style: TextStyle(color: AppColors.textMuted, fontSize: 17),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: controller.loginEmail,
              validator: controller.emailValidator,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'Email Address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => TextFormField(
                controller: controller.loginPassword,
                validator: controller.passwordValidator,
                obscureText: controller.hideLoginPassword.value,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => controller.login(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: controller.hideLoginPassword.toggle,
                    icon: Icon(
                      controller.hideLoginPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Transform.scale(
                  scale: 0.82,
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => Switch.adaptive(
                      value: controller.remember.value,
                      onChanged: (value) => controller.remember.value = value,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Remember me',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => PrimaryButton(
                label: 'Login',
                loading: controller.loading.value,
                onPressed: controller.login,
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    "Don't have an account ? ",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signup),
                    child: const Text(
                      'Sign up',
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
