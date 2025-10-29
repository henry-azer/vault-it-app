import 'package:flutter/material.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/core/utils/app_assets_manager.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:vault_it/features/settings/presentation/providers/biometric_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger biometric authentication after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _attemptBiometricLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppStrings.login.tr.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w300,
              ),
            ),
          )),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Image.asset(
                    AppImageAssets.signin,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    AppStrings.loginSubtitle.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: authProvider.obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.password.tr,
                        suffixIcon: IconButton(
                          icon: Icon(authProvider.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: authProvider.togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.validationPasswordRequired.tr;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final formState = Form.of(context);
                        formState.validate();
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppStrings.login.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: Colors.white),
                              ),
                      );
                    },
                  ),
                  Consumer<BiometricProvider>(
                    builder: (context, biometricProvider, child) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      if (!biometricProvider.isBiometricAvailable ||
                          !biometricProvider.isBiometricEnabled) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.darkTextSecondary.withOpacity(0.3)
                                      : AppColors.lightTextSecondary.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  AppStrings.or.tr,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.darkTextSecondary.withOpacity(0.3)
                                      : AppColors.lightTextSecondary.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _attemptBiometricLogin,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fingerprint,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        AppStrings.useBiometric.tr.replaceAll(
                                          '{type}',
                                          biometricProvider.biometricTypeLabel,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(_passwordController.text);

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, Routes.app);
      } else {
        SnackBarHelper.showError(
          context,
          AppStrings.validationPasswordInvalid.tr,
        );
      }
    }
  }

  Future<void> _attemptBiometricLogin() async {
    final biometricProvider = Provider.of<BiometricProvider>(context, listen: false);
    
    if (!biometricProvider.isBiometricAvailable || 
        !biometricProvider.isBiometricEnabled) {
      return;
    }

    final authenticated = await biometricProvider.authenticate(
      reason: AppStrings.authenticateToUnlock.tr,
    );

    if (authenticated && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Get stored password and login
      final success = await authProvider.loginWithBiometric();
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, Routes.app);
      } else if (mounted) {
        SnackBarHelper.showError(
          context,
          AppStrings.biometricAuthFailed.tr,
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
