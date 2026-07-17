import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final loginKey = GlobalKey<FormState>();
  final signupKey = GlobalKey<FormState>();
  final forgotPasswordKey = GlobalKey<FormState>();

  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();
  final signupName = TextEditingController();
  final signupEmail = TextEditingController();
  final signupPhone = TextEditingController();
  final signupPassword = TextEditingController();
  final signupConfirmPassword = TextEditingController();
  final resetEmail = TextEditingController();

  final loading = false.obs;
  final resetLoading = false.obs;
  final resetSent = false.obs;
  final remember = false.obs;
  final acceptTerms = false.obs;
  final hideLoginPassword = true.obs;
  final hideSignupPassword = true.obs;
  final hideConfirmPassword = true.obs;

  String? requiredValidator(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? emailValidator(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(input)) return 'Enter a valid email address';
    return null;
  }

  String? phoneValidator(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Phone number is required';
    }
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? passwordValidator(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required';
    if (input.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    final error = passwordValidator(value);
    if (error != null) return error;
    if (value != signupPassword.text) return 'Passwords do not match';
    return null;
  }

  Future<void> login() async {
    if (!(loginKey.currentState?.validate() ?? false)) return;
    await _runAuth(
      () => _auth.signInWithEmailAndPassword(
        email: loginEmail.text.trim(),
        password: loginPassword.text,
      ),
    );
  }

  Future<void> signup() async {
    if (!(signupKey.currentState?.validate() ?? false)) return;
    if (!acceptTerms.value) {
      Get.snackbar(
        'Terms required',
        'Please accept the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    loading.value = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: signupEmail.text.trim(),
        password: signupPassword.text,
      );
      final user = credential.user;
      if (user == null) throw StateError('Firebase did not return a user.');

      await user.updateDisplayName(signupName.text.trim());
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': signupName.text.trim(),
          'email': signupEmail.text.trim(),
          'phone': signupPhone.text.trim(),
          'address': '',
          'walletBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Authentication remains valid even when optional profile storage fails.
      }
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (error) {
      _showAuthError(error.code);
    } catch (_) {
      Get.snackbar(
        'Signup failed',
        'The account could not be created.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> sendPasswordReset() async {
    if (!(forgotPasswordKey.currentState?.validate() ?? false)) return;
    resetLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: resetEmail.text.trim());
      resetSent.value = true;
    } on FirebaseAuthException catch (error) {
      _showAuthError(error.code);
    } finally {
      resetLoading.value = false;
    }
  }

  Future<void> _runAuth(Future<UserCredential> Function() action) async {
    loading.value = true;
    try {
      await action();
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (error) {
      _showAuthError(error.code);
    } finally {
      loading.value = false;
    }
  }

  void _showAuthError(String code) {
    Get.snackbar(
      'Authentication failed',
      _message(code),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return 'Authentication could not be completed.';
    }
  }

  @override
  void onClose() {
    loginEmail.dispose();
    loginPassword.dispose();
    signupName.dispose();
    signupEmail.dispose();
    signupPhone.dispose();
    signupPassword.dispose();
    signupConfirmPassword.dispose();
    resetEmail.dispose();
    super.onClose();
  }
}
