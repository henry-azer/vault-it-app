import 'package:flutter/material.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/core/utils/app_colors.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/core/utils/snackbar_helper.dart';
import 'package:pass_vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFieldKey = GlobalKey<FormFieldState>();
  final _currentPasswordFieldKey = GlobalKey<FormFieldState>();
  final _newPasswordFieldKey = GlobalKey<FormFieldState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState>();
  
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController.text = authProvider.currentUser?.username ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.updateUserProfile(
        newUsername: _usernameController.text.trim(),
        currentPassword: _changePassword ? _currentPasswordController.text : null,
        newPassword: _changePassword ? _newPasswordController.text : null,
      );

      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(
            context,
            AppStrings.profileUpdatedSuccess.tr,
          );
          Navigator.pop(context);
        } else {
          SnackBarHelper.showError(
            context,
            _changePassword 
                ? AppStrings.currentPasswordIncorrect.tr 
                : AppStrings.failedUpdateProfile.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          '${AppStrings.error.tr}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUsernameField(isDark),
                      const SizedBox(height: 24),
                      _buildPasswordSection(isDark),
                      const SizedBox(height: 32),
                      _buildSaveButton(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkHeaderStart, AppColors.darkHeaderEnd]
              : [AppColors.lightHeaderStart, AppColors.lightHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.editProfile.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.username.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: _usernameFieldKey,
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: AppStrings.enterUsernameEmail.tr,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkSnackbarError : AppColors.lightSnackbarError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkSnackbarError : AppColors.lightSnackbarError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLength: 18,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.validationUsernameEmpty.tr;
            }
            if (value.trim().length < 3) {
              return AppStrings.validationUsernameMinLength.tr;
            }
            return null;
          },
          onChanged: (value) {
            _usernameFieldKey.currentState?.validate();
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _changePassword,
              onChanged: (value) {
                setState(() {
                  _changePassword = value ?? false;
                  if (!_changePassword) {
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  }
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            Text(
              AppStrings.changePassword.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        if (_changePassword) ...[
          const SizedBox(height: 16),
          _buildPasswordField(
            fieldKey: _currentPasswordFieldKey,
            controller: _currentPasswordController,
            label: AppStrings.currentPassword.tr,
            hint: AppStrings.enterPassword.tr,
            obscure: _obscureCurrentPassword,
            onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
            validator: (value) {
              if (_changePassword && (value == null || value.isEmpty)) {
                return AppStrings.validationPasswordRequired.tr;
              }
              return null;
            },
            isDark: isDark,
            onChanged: (value) {
              _currentPasswordFieldKey.currentState?.validate();
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            fieldKey: _newPasswordFieldKey,
            controller: _newPasswordController,
            label: AppStrings.newPassword.tr,
            hint: AppStrings.enterPassword.tr,
            obscure: _obscureNewPassword,
            onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            validator: (value) {
              if (_changePassword && (value == null || value.isEmpty)) {
                return AppStrings.validationPasswordRequired.tr;
              }
              if (_changePassword && value!.length < 4) {
                return AppStrings.validationPasswordMinLength.tr;
              }
              return null;
            },
            onChanged: (value) {
              _newPasswordFieldKey.currentState?.validate();
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            fieldKey: _confirmPasswordFieldKey,
            controller: _confirmPasswordController,
            label: AppStrings.confirmPassword.tr,
            hint: AppStrings.enterPassword.tr,
            obscure: _obscureConfirmPassword,
            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            validator: (value) {
              if (_changePassword && (value == null || value.isEmpty)) {
                return AppStrings.validationPasswordRequired.tr;
              }
              if (_changePassword && value != _newPasswordController.text) {
                return AppStrings.validationPasswordsNotMatch.tr;
              }
              return null;
            },
            isDark: isDark,
            onChanged: (value) {
              _confirmPasswordFieldKey.currentState?.validate();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    GlobalKey<FormFieldState>? fieldKey,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required void Function(dynamic) onChanged,
    required String? Function(String?) validator,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: fieldKey,
          controller: controller,
          obscureText: obscure,
          maxLength: 22,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkSnackbarError : AppColors.lightSnackbarError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkSnackbarError : AppColors.lightSnackbarError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppStrings.saveChanges.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
