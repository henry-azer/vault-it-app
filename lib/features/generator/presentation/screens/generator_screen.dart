import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/generator/presentation/providers/generator_provider.dart';
import 'package:provider/provider.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>().generatePassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _buildContent(isDark, screenWidth),
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                  Icons.vpn_key_rounded,
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
                      AppStrings.passwordGenerator.tr,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
              _buildHeaderActions(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isDark) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        final bool hasHistory = provider.hasHistory;

        return _buildActionButton(
          icon: Icons.history_outlined,
          onPressed: _showPasswordHistory,
          isDark: isDark,
          isActive: hasHistory,
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildContent(bool isDark, double screenWidth) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildPasswordCard(provider, isDark, screenWidth),
              SizedBox(height: screenWidth * 0.03),
              _buildLengthCard(provider, isDark, screenWidth),
              SizedBox(height: screenWidth * 0.03),
              _buildCharacterOptionsCard(provider, isDark, screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordCard(
      GeneratorProvider provider, bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.password_rounded,
                        size: 16, color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    AppStrings.password.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 16, color: AppColors.success),
                      onPressed: () => _copyPassword(provider),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.key_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        provider.generatePassword();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.025),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              provider.generatedPassword.isNotEmpty
                  ? provider.generatedPassword
                  : AppStrings.clickGenerateToCreate.tr,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: provider.generatedPassword.isNotEmpty
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          _buildStrengthIndicator(provider, isDark, screenWidth),
        ],
      ),
    );
  }

  Widget _buildLengthCard(
      GeneratorProvider provider, bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.straighten_rounded,
                    size: 16, color: AppColors.info),
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                AppStrings.passwordLength.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.passwordLength} ${AppStrings.characters.tr}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.030,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.025),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              trackHeight: 4,
              thumbColor: Theme.of(context).colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: provider.passwordLength.toDouble(),
              min: 4,
              max: 22,
              divisions: 18,
              onChanged: (value) {
                provider.setPasswordLength(value.toInt());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('4',
                    style: TextStyle(color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled, fontSize: 11)),
                Text('13',
                    style: TextStyle(color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled, fontSize: 11)),
                Text('22',
                    style: TextStyle(color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOptionsCard(
      GeneratorProvider provider, bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.tune_rounded,
                    size: 16, color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                AppStrings.characterOptions.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCharacterOption(
            AppStrings.uppercaseLetters.tr,
            'A-Z',
            provider.includeUppercase,
            (value) {
              provider.setIncludeUppercase(value);
              provider.generatePassword();
            },
            Icons.text_fields,
            AppColors.error,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.lowercaseLetters.tr,
            'a-z',
            provider.includeLowercase,
            (value) {
              provider.setIncludeLowercase(value);
              provider.generatePassword();
            },
            Icons.text_fields,
            AppColors.warning,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.numbers.tr,
            '0-9',
            provider.includeNumbers,
            (value) {
              provider.setIncludeNumbers(value);
              provider.generatePassword();
            },
            Icons.numbers,
            AppColors.success,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.specialCharacters.tr,
            '!@#\$%^&*',
            provider.includeSymbols,
            (value) {
              provider.setIncludeSymbols(value);
              provider.generatePassword();
            },
            Icons.tag,
            AppColors.info,
            isDark,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOption(
    String title,
    String example,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    Color color,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.008),
      decoration: BoxDecoration(
        color: value
            ? color.withOpacity(0.1)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? color.withOpacity(0.3)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: 1.5,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.1) : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: value ? color : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          example,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.6,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }

  Widget _buildStrengthIndicator(
      GeneratorProvider provider, bool isDark, double screenWidth) {
    final color = provider.getPasswordStrengthColor();
    final strengthValue = provider.calculatePasswordStrength();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: strengthValue,
            backgroundColor:
                isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  void _copyPassword(GeneratorProvider provider) {
    if (provider.generatedPassword.isNotEmpty) {
      provider.copyToClipboard();
      HapticFeedback.lightImpact();
      SnackBarHelper.showSuccess(
        context,
        AppStrings.passwordCopied.tr,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void _showPasswordHistory() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, Routes.generatorHistory);
  }
}
