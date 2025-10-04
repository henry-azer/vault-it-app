import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/routes/app_routes.dart';
import 'package:pass_vault_it/core/utils/app_colors.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/features/generator/presentation/providers/generator_provider.dart';
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
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Consumer<GeneratorProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.passwordGenerator.tr,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.createStrongPasswords.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildHeaderActions(isDark),
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
        color: (isDark ? Colors.grey[800] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.grey[700]! : Colors.grey[200]!),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: (isDark ? Colors.grey[200] : Colors.grey[700]),
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
              SizedBox(height: screenWidth * 0.03),
              _buildActionButtons(provider, isDark, screenWidth),
              SizedBox(height: screenWidth * 0.03),
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
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 16, color: Colors.green),
                      onPressed: () => _copyPassword(provider),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
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
              color: isDark ? Colors.grey[800] : Colors.grey[100],
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
                    ? null
                    : Colors.grey[500],
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
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.straighten_rounded,
                    size: 16, color: Colors.blue),
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
              inactiveTrackColor: Colors.grey[300],
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
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                Text('13',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                Text('22',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
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
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded,
                    size: 16, color: Colors.purple),
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
          SizedBox(height: screenWidth * 0.015),
          _buildCharacterOption(
            AppStrings.uppercaseLetters.tr,
            provider.includeUppercase,
            (value) {
              provider.setIncludeUppercase(value);
            },
            Icons.text_fields_rounded,
            Colors.red,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.lowercaseLetters.tr,
            provider.includeLowercase,
            (value) {
              provider.setIncludeLowercase(value);
            },
            Icons.text_fields_rounded,
            Colors.orange,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.numbers.tr,
            provider.includeNumbers,
            (value) {
              provider.setIncludeNumbers(value);
            },
            Icons.numbers_rounded,
            Colors.green,
            isDark,
            screenWidth,
          ),
          _buildCharacterOption(
            AppStrings.specialCharacters.tr,
            provider.includeSymbols,
            (value) {
              provider.setIncludeSymbols(value);
            },
            Icons.tag_rounded,
            Colors.blue,
            isDark,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOption(
    String title,
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
            : (isDark ? Colors.grey[850] : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? color.withOpacity(0.3)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
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
            color: value ? color.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: value ? color : Colors.grey[500]),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.035,
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
                isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      GeneratorProvider provider, bool isDark, double screenWidth) {
    return ElevatedButton.icon(
      onPressed: () => _showPasswordHistory(),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.grey[800],
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        minimumSize: const Size(double.infinity, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
      ),
      icon: const Icon(Icons.history_rounded),
      label: Text(
        provider.hasHistory
            ? '${AppStrings.history.tr} (${provider.passwordHistory.length})'
            : AppStrings.history.tr,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _copyPassword(GeneratorProvider provider) {
    if (provider.generatedPassword.isNotEmpty) {
      provider.copyToClipboard();
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.passwordCopied.tr),
          backgroundColor: AppColors.snackbarSuccess,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showPasswordHistory() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, Routes.generatorHistory);
  }
}
