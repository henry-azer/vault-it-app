import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/routes/app_routes.dart';
import 'package:pass_vault_it/core/constants/popular_websites.dart';
import 'package:pass_vault_it/core/enums/vault_enums.dart';
import 'package:pass_vault_it/core/utils/app_colors.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/data/entities/account.dart';
import 'package:pass_vault_it/features/generator/presentation/providers/generator_provider.dart';
import 'package:pass_vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  final Account? accountToEdit;

  const AccountScreen({super.key, this.accountToEdit});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _titleKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _usernameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isFavorite = false;
  PopularWebsite? _selectedWebsite;
  String? _faviconUrl;
  double _passwordStrength = 0.0;

  bool get isEditing => widget.accountToEdit != null;

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;

    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  Color _getPasswordStrengthColor() {
    final strength = PasswordStrength.fromValue(_passwordStrength);
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red[700]!;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow[700]!;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final url = _urlController.text.trim();
    setState(() {
      if (url.isNotEmpty) {
        _faviconUrl = PopularWebsites.getFaviconUrl(url);
      } else {
        _faviconUrl = null;
      }
    });
  }

  void _populateFields() {
    final account = widget.accountToEdit!;

    _selectedWebsite = PopularWebsites.getByName(account.title);
    if (_selectedWebsite == null && account.url != null) {
      _selectedWebsite =
          PopularWebsites.websites.cast<PopularWebsite?>().firstWhere(
                (w) => w?.url == account.url,
                orElse: () => null,
              );
    }

    _selectedWebsite ??= PopularWebsites.createCustom(account.title);
    _titleController.text = account.title;
    _usernameController.text = account.username;
    _passwordController.text = account.password;
    _urlController.text = account.url ?? '';
    _notesController.text = account.notes ?? '';
    _isFavorite = account.isFavorite;
    _passwordStrength = _calculatePasswordStrength(account.password);

    if (account.url != null && account.url!.isNotEmpty) {
      _faviconUrl = PopularWebsites.getFaviconUrl(account.url!);
    }
  }

  void _selectPopularWebsite(String websiteName) {
    setState(() {
      _selectedWebsite = PopularWebsites.getByName(websiteName);

      if (_selectedWebsite != null) {
        _urlController.text = _selectedWebsite!.url;
        _faviconUrl = _selectedWebsite!.faviconUrl;
      } else {
        _selectedWebsite = PopularWebsites.createCustom(websiteName);
        _urlController.text = _selectedWebsite!.url;
        _faviconUrl = PopularWebsites.getFaviconUrl(websiteName);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _copyPassword() {
    if (_passwordController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _passwordController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.copiedToClipboard.tr),
          backgroundColor: AppColors.snackbarSuccess,
          duration: const Duration(seconds: 1),
        ),
      );
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: _buildContent(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
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
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? AppStrings.editAccount.tr
                      : AppStrings.addAccount.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _isFavorite
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    size: 18,
                    color: _isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
              if (isEditing) ...[
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    onPressed: _showDeleteConfirmation,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildSearchWebsites(isDark),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildTextField(
                key: _titleKey,
                controller: _titleController,
                label: AppStrings.titleRequired.tr,
                hint: AppStrings.enterTitle.tr,
                icon: Icons.label_outline,
                isDark: isDark,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.validationTitleEmpty.tr;
                  }
                  return null;
                },
                onChanged: (value) {
                  _titleKey.currentState?.validate();
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildTextField(
                key: _usernameKey,
                controller: _usernameController,
                label: AppStrings.usernameEmailRequired.tr,
                hint: AppStrings.enterUsernameEmail.tr,
                icon: Icons.person_outline,
                isDark: isDark,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.validationUsernameEmpty.tr;
                  }
                  return null;
                },
                onChanged: (value) {
                  _usernameKey.currentState?.validate();
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildPasswordField(isDark),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildTextField(
                controller: _notesController,
                label: AppStrings.notesOptional.tr,
                hint: AppStrings.addNotes.tr,
                icon: Icons.note_outlined,
                isDark: isDark,
                maxLines: 3,
                maxLength: 200,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              _buildActionButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWebsites(bool isDark) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            initialValue: TextEditingValue(
              text: _selectedWebsite != null ? _selectedWebsite!.name : "",
            ),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return PopularWebsites.websites.map((w) => w.name);
              }
              final results = PopularWebsites.search(textEditingValue.text);
              return results.map((w) => w.name);
            },
            onSelected: _selectPopularWebsite,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: AppStrings.searchWebsitesHint.tr,
                  prefixIcon: _faviconUrl == null
                      ? Icon(
                          Icons.language_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: _faviconUrl!,
                                fit: BoxFit.cover,
                                width: 10,
                                height: 10,
                                placeholder: (context, url) =>
                                    _buildSkeletonLoader(),
                                errorWidget: (context, url, error) =>
                                    _buildFallbackIcon(),
                              )),
                        ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            setState(() {
                              _faviconUrl = null;
                            });
                            controller.clear();
                            focusNode.unfocus();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _selectPopularWebsite(value);
                    onSubmitted();
                  }
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final website = PopularWebsites.getByName(option);

                        return InkWell(
                          onTap: () => onSelected(option),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.012,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: website != null
                                        ? Image.network(
                                            website.faviconUrl,
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  option[0].toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Text(
                                              option[0].toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (website != null)
                                        Text(
                                          website.domain,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                                fontSize: 11,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.grey[800]!,
                  Colors.grey[700]!,
                  Colors.grey[800]!,
                ]
              : [
                  Colors.grey[200]!,
                  Colors.grey[100]!,
                  Colors.grey[200]!,
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: isDark ? Colors.grey[600] : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.language_rounded,
      color: Theme.of(context).colorScheme.primary,
      size: 24,
    );
  }

  void _generatePassword() {
    final generatorProvider = context.read<GeneratorProvider>();
    generatorProvider.generatePassword();
    setState(() {
      _passwordController.text = generatorProvider.generatedPassword;
      _passwordStrength = _calculatePasswordStrength(_passwordController.text);
    });
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final accountProvider = context.read<AccountProvider>();

      final account = Account(
        id: isEditing
            ? widget.accountToEdit!.id
            : accountProvider.generateAccountId(),
        title: _titleController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        addedDate: isEditing ? widget.accountToEdit!.addedDate : DateTime.now(),
        lastModified: DateTime.now(),
        isFavorite: _isFavorite,
        passwordHistory: isEditing ? widget.accountToEdit!.passwordHistory : [],
      );

      bool success;
      if (isEditing) {
        success = await accountProvider.updateAccount(account);
      } else {
        success = await accountProvider.addAccount(account);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? AppStrings.accountUpdatedSuccess.tr
                    : AppStrings.accountSavedSuccess.tr,
              ),
              backgroundColor: AppColors.snackbarSuccess,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.failedSaveAccount.tr),
              backgroundColor: AppColors.snackbarError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error.tr}: $e'),
            backgroundColor: AppColors.snackbarError,
          ),
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

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context
          .read<AccountProvider>()
          .deleteAccount(widget.accountToEdit!.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.accountDeletedSuccess.tr),
              backgroundColor: AppColors.snackbarSuccess,
            ),
          );
          Navigator.pushReplacementNamed(context, Routes.vault);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.failedDeleteAccount.tr),
              backgroundColor: AppColors.snackbarError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error.tr}: $e'),
            backgroundColor: AppColors.snackbarError,
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    GlobalKey<FormFieldState>? key,
    bool isRequired = false,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int maxLength = 18,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        key: key,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        readOnly: readOnly,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            key: _passwordKey,
            controller: _passwordController,
            obscureText: _obscurePassword,
            maxLength: 22,
            onChanged: (value) {
              _passwordKey.currentState?.validate();
              setState(() {
                _passwordStrength = _calculatePasswordStrength(value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.validationPasswordEmpty.tr;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: AppStrings.passwordRequiredField.tr,
              hintText: AppStrings.enterPassword.tr,
              prefixIcon: Container(
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(2),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _copyPassword,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 16,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.key_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          _generatePassword();
                          _passwordKey.currentState?.validate();
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
          if (_passwordController.text.isNotEmpty)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 4,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPasswordStrengthColor(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAccount,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEditing
                      ? AppStrings.updateAccountBtn.tr
                      : AppStrings.saveAccountBtn.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[600], size: 28),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(AppStrings.deleteAccountConfirmation.tr),
          ],
        ),
        content: Text(
          AppStrings.deleteAccountMessage.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              AppStrings.delete.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
