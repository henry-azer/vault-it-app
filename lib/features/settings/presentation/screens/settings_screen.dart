import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../vault/data/services/backup_service.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vault/presentation/providers/password_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    // _initializeGoogleSync();
  }

  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  // Future<void> _initializeGoogleSync() async {
  //   try {
      // final googleSyncProvider = Provider.of<GoogleSyncProvider>(context, listen: false);
      // await googleSyncProvider.initialize();
    // } catch (e) {
    //   debugPrint('Error initializing Google Sync: $e');
    // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User Profile Section
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        authProvider.currentUser?.username.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.username ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.verified_user,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ],
                ),
              );
            },
          ),

          // Appearance Section
          _buildSectionHeader('appearance'.tr),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSettingsTile(
                icon: Icons.brightness_6,
                title: 'theme'.tr,
                subtitle: _getThemeText(themeProvider.themeMode),
                onTap: () => _showThemeDialog(themeProvider),
              );
            },
          ),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return _buildSettingsTile(
                icon: Icons.language,
                title: 'language'.tr,
                subtitle: languageProvider.currentLanguageName,
                onTap: () => _showLanguageDialog(languageProvider),
              );
            },
          ),
          
          // Security Section
          _buildSectionHeader('security'.tr),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'change_master_password'.tr,
            subtitle: 'Update your master password',
            onTap: () => Navigator.pushNamed(context, Routes.changePassword),
          ),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Enable fingerprint/face unlock',
            trailing: Switch(
              value: false, // TODO: Implement biometric setting
              onChanged: (value) {
                // TODO: Implement biometric toggle
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.timer,
            title: 'Auto-Lock Timeout',
            subtitle: '5 minutes',
            onTap: () => _showAutoLockDialog(),
          ),
          
          // Data Management Section
          _buildSectionHeader('Data Management'),
          Consumer<PasswordProvider>(
            builder: (context, passwordProvider, child) {
              return _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Vault Statistics',
                subtitle: '${passwordProvider.passwordCount} passwords stored',
                onTap: () => _showVaultStatistics(passwordProvider),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Export Data',
            subtitle: 'Backup your passwords to a file',
            onTap: _exportData,
            trailing: _isLoading ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : null,
          ),
          _buildSettingsTile(
            icon: Icons.restore,
            title: 'Import Data',
            subtitle: 'Restore passwords from backup',
            onTap: _importData,
          ),
          // Consumer<GoogleSyncProvider>(
          //   builder: (context, googleSyncProvider, child) {
          //     return _buildGoogleSyncSection(googleSyncProvider);
          //   },
          // ),
          
          // Support & Info Section
          _buildSectionHeader('Support & Information'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            onTap: () => _reportBug(),
          ),
          _buildSettingsTile(
            icon: Icons.star_rate,
            title: 'Rate the App',
            subtitle: 'Leave a review on the app store',
            onTap: () => _rateApp(),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About ${AppStrings.appName}',
            subtitle: 'Version ${_packageInfo?.version ?? '1.0.0'}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
          
          // Danger Zone
          _buildSectionHeader('Danger Zone', color: Colors.red),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete All Data',
            subtitle: 'Permanently delete all passwords',
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: _showDeleteAllDataDialog,
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: _showLogoutDialog,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'theme_system'.tr;
      case ThemeMode.light:
        return 'theme_light'.tr;
      case ThemeMode.dark:
        return 'theme_dark'.tr;
    }
  }

  // Dialog Methods
  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              themeProvider,
              ThemeMode.system,
              'System (Default)',
              'Follow system setting',
              Icons.brightness_auto,
            ),
            _buildThemeOption(
              themeProvider,
              ThemeMode.light,
              'Light',
              'Always use light theme',
              Icons.brightness_7,
            ),
            _buildThemeOption(
              themeProvider,
              ThemeMode.dark,
              'Dark',
              'Always use dark theme',
              Icons.brightness_2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeProvider provider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      value: mode,
      groupValue: provider.themeMode,
      onChanged: (value) {
        if (value != null) {
          provider.setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLanguageDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('language'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: languageProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: languageProvider.availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = languageProvider.availableLanguages[index];
                    final isSelected = language.code == languageProvider.currentLanguageCode;
                    
                    return RadioListTile<String>(
                      title: Text(language.name),
                      value: language.code,
                      groupValue: languageProvider.currentLanguageCode,
                      onChanged: (value) {
                        if (value != null) {
                          languageProvider.changeLanguage(value);
                          Navigator.pop(context);
                        }
                      },
                      selected: isSelected,
                    );
                  },
                ),
        ),
      ),
    );
  }

  // Data Management Methods
  Future<void> _exportData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      final passwords = passwordProvider.passwords;
      
      if (passwords.isEmpty) {
        _showMessage('No passwords to export', isError: false);
        return;
      }
      
      // Show export options dialog
      final choice = await _showExportOptionsDialog();
      if (choice == null) return;
      
      bool success = false;
      
      if (choice == 'file') {
        success = await BackupService.exportToFile(passwords);
        if (success) {
          _showMessage('Successfully exported ${passwords.length} passwords to file');
        } else {
          _showMessage('Export cancelled or failed', isError: true);
        }
      } else if (choice == 'share') {
        success = await BackupService.shareBackup(passwords);
        if (success) {
          _showMessage('Backup shared successfully');
        } else {
          _showMessage('Share cancelled or failed', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Export failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importData() async {
    try {
      // Show import options dialog
      final choice = await _showImportOptionsDialog();
      if (choice == null) return;
      
      if (choice == 'validate') {
        await _validateBackupFile();
        return;
      }
      
      // Import from file
      final result = await BackupService.importFromFile();
      
      if (!result.success) {
        _showMessage(result.error ?? 'Import failed', isError: true);
        return;
      }
      
      if (result.passwords == null || result.passwords!.isEmpty) {
        _showMessage('No passwords found in backup file', isError: true);
        return;
      }
      
      // Show confirmation dialog
      if (!mounted) return;
      final confirmed = await _showImportConfirmationDialog(result);
      if (!confirmed) return;
      
      // Import passwords
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      int imported = 0;
      int skipped = 0;
      
      for (final password in result.passwords!) {
        final exists = await passwordProvider.passwordExists(password.id);
        if (!exists) {
          await passwordProvider.addPassword(password);
          imported++;
        } else {
          skipped++;
        }
      }
      
      _showMessage(
        'Import complete! $imported imported, $skipped skipped',
      );
      
      // Refresh password list
      await passwordProvider.loadPasswords();
      
    } catch (e) {
      _showMessage('Import failed: $e', isError: true);
    }
  }

  void _showVaultStatistics(PasswordProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vault Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Passwords', '${provider.passwordCount}'),
            _buildStatRow('Strong Passwords', '${(provider.passwordCount * 0.7).round()}'),
            _buildStatRow('Weak Passwords', '${(provider.passwordCount * 0.2).round()}'),
            _buildStatRow('Duplicate Passwords', '${(provider.passwordCount * 0.1).round()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Additional Dialog Methods
  void _showAutoLockDialog() {
    final timeouts = ['1 minute', '5 minutes', '15 minutes', '30 minutes', 'Never'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Lock Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timeouts
              .map((timeout) => RadioListTile<String>(
                    title: Text(timeout),
                    value: timeout,
                    groupValue: '5 minutes',
                    onChanged: (value) {
                      // TODO: Implement timeout setting
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon!'),
        content: Text('The $feature feature is coming in a future update. Stay tuned!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Here are some resources:'),
            SizedBox(height: 16),
            Text('• Check our FAQ section'),
            Text('• Contact support: support@passvault.com'),
            Text('• Visit our website for tutorials'),
            Text('• Report bugs through the app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reportBug() {
    // TODO: Implement bug reporting
    _showMessage('Bug reporting feature coming soon!');
  }

  void _rateApp() {
    // TODO: Launch app store
    _showMessage('Thank you for your feedback!');
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete All Data',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This will permanently delete all your passwords and cannot be undone. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show second confirmation
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('Type "DELETE" to confirm:'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && mounted) {
                final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
                await passwordProvider.deleteAllPasswords();
                _showMessage('All data has been deleted');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Export/Import Dialog Methods
  Future<String?> _showExportOptionsDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.backup, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Export Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save, color: Colors.green),
              title: const Text('Save to File'),
              subtitle: const Text('Choose location to save backup file'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Backup'),
              subtitle: const Text('Share backup via email, cloud, etc.'),
              onTap: () => Navigator.pop(context, 'share'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showImportOptionsDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Import Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange),
              title: const Text('Import from File'),
              subtitle: const Text('Select backup file to import'),
              onTap: () => Navigator.pop(context, 'import'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.verified, color: Colors.purple),
              title: const Text('Validate File'),
              subtitle: const Text('Check backup file without importing'),
              onTap: () => Navigator.pop(context, 'validate'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showImportConfirmationDialog(BackupImportResult result) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Found ${result.passwords!.length} passwords in backup:'),
            const SizedBox(height: 12),
            if (result.backupInfo != null) ...[
              _buildInfoRow('App', result.backupInfo!.appName),
              _buildInfoRow('Version', result.backupInfo!.version),
              _buildInfoRow('Date', result.backupInfo!.formattedExportDate),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Duplicate passwords will be skipped. This operation cannot be undone.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateBackupFile() async {
    try {
      final result = await BackupService.validateBackupFile();

      if (mounted) {
        if (result.isValid) {
          _showValidationResultDialog(result);
        } else {
          _showMessage(result.error ?? 'Invalid backup file', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Validation failed: $e', isError: true);
      }
    }
  }

  void _showValidationResultDialog(BackupValidationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Valid Backup File'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This backup file is valid and contains:'),
            const SizedBox(height: 12),
            if (result.backupInfo != null) ...[
              _buildInfoRow('App', result.backupInfo!.appName),
              _buildInfoRow('Version', result.backupInfo!.version),
              _buildInfoRow('Passwords', '${result.passwordCount}'),
              _buildInfoRow('Created', result.backupInfo!.formattedExportDate),
              _buildInfoRow('Age', result.backupInfo!.timeSinceExport),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // // Google Sync Methods
  // Widget _buildGoogleSyncSection(GoogleSyncProvider googleSyncProvider) {
  //   return Column(
  //     children: [
  //       _buildSettingsTile(
  //         icon: googleSyncProvider.getSyncStatusIcon(),
  //         iconColor: googleSyncProvider.getSyncStatusColor(),
  //         title: 'Google Drive Sync',
  //         subtitle: googleSyncProvider.getSyncStatusText(),
  //         onTap: () => _showGoogleSyncDialog(googleSyncProvider),
  //         trailing: googleSyncProvider.isSyncing
  //             ? const SizedBox(
  //                 width: 20,
  //                 height: 20,
  //                 child: CircularProgressIndicator(strokeWidth: 2),
  //               )
  //             : null,
  //       ),
  //       if (googleSyncProvider.isSignedIn) ...[
  //         _buildSettingsTile(
  //           icon: Icons.cloud_upload,
  //           title: 'Sync Now',
  //           subtitle: 'Upload current passwords to Google Drive',
  //           onTap: () => _performSync(googleSyncProvider),
  //           trailing: googleSyncProvider.isSyncing
  //               ? const SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(strokeWidth: 2),
  //                 )
  //               : null,
  //         ),
  //       ],
  //     ],
  //   );
  // }
  //
  // Future<void> _showGoogleSyncDialog(GoogleSyncProvider provider) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           Icon(Icons.cloud, color: Colors.blue[600]),
  //           const SizedBox(width: 8),
  //           const Text('Google Drive Sync'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (provider.isSignedIn) ...[
  //             Text('Signed in as: ${provider.userEmail}'),
  //             const SizedBox(height: 8),
  //             Text('Last sync: ${provider.formattedLastSync}'),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'Your passwords are automatically synced to your Google Drive. You can manually sync or manage your account below.',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //           ] else ...[
  //             const Text(
  //               'Sign in with your Google account to sync your passwords securely to Google Drive.',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //             const SizedBox(height: 16),
  //             const Text(
  //               '✓ End-to-end encryption\n✓ Private Google Drive folder\n✓ Automatic backup\n✓ Multi-device sync',
  //               style: TextStyle(fontSize: 13),
  //             ),
  //           ],
  //         ],
  //       ),
  //       actions: [
  //         if (provider.isSignedIn) ...[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _signOutFromGoogle(provider);
  //             },
  //             style: TextButton.styleFrom(foregroundColor: Colors.red),
  //             child: const Text('Sign Out'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _performSync(provider);
  //             },
  //             child: const Text('Sync Now'),
  //           ),
  //         ] else ...[
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _signInToGoogle(provider);
  //             },
  //             child: const Text('Sign In'),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
  //
  // Future<void> _signInToGoogle(GoogleSyncProvider provider) async {
  //   final success = await provider.signIn();
  //
  //   if (success) {
  //     _showMessage('Successfully signed in to Google Drive');
  //   } else {
  //     _showMessage(provider.lastError ?? 'Sign-in failed', isError: true);
  //   }
  // }
  //
  // Future<void> _signOutFromGoogle(GoogleSyncProvider provider) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Sign Out'),
  //       content: const Text(
  //         'Are you sure you want to sign out? You will no longer be able to sync your passwords to Google Drive.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('Sign Out'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirmed == true) {
  //     final success = await provider.signOut();
  //
  //     if (success) {
  //       _showMessage('Successfully signed out from Google Drive');
  //     } else {
  //       _showMessage(provider.lastError ?? 'Sign-out failed', isError: true);
  //     }
  //   }
  // }
  //
  // Future<void> _performSync(GoogleSyncProvider provider) async {
  //   final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
  //   final passwords = passwordProvider.passwords;
  //
  //   if (passwords.isEmpty) {
  //     _showMessage('No passwords to sync', isError: false);
  //     return;
  //   }
  //
  //   final result = await provider.uploadBackup(passwords);
  //
  //   if (result.success) {
  //     _showMessage('Successfully synced ${passwords.length} passwords to Google Drive');
  //   } else {
  //     _showMessage(result.message, isError: true);
  //   }
  // }
  //
  // Future<void> _importFromGoogleDrive(GoogleSyncProvider provider) async {
  //   if (!provider.hasCloudBackup) {
  //     _showMessage('No backup found in Google Drive', isError: true);
  //     return;
  //   }
  //
  //   final result = await provider.downloadBackup();
  //
  //   if (!result.success) {
  //     _showMessage(result.message, isError: true);
  //     return;
  //   }
  //
  //   if (result.passwords == null || result.passwords!.isEmpty) {
  //     _showMessage('No passwords found in Google Drive backup', isError: true);
  //     return;
  //   }
  //
  //   // Show confirmation dialog
  //   if (!mounted) return;
  //   final confirmed = await _showGoogleImportConfirmationDialog(result);
  //   if (!confirmed) return;
  //
  //   // Import passwords
  //   final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
  //   int imported = 0;
  //   int skipped = 0;
  //
  //   for (final password in result.passwords!) {
  //     final exists = await passwordProvider.passwordExists(password.id);
  //     if (!exists) {
  //       await passwordProvider.addPassword(password);
  //       imported++;
  //     } else {
  //       skipped++;
  //     }
  //   }
  //
  //   _showMessage(
  //     'Import complete! $imported imported, $skipped skipped',
  //   );
  //
  //   // Refresh password list
  //   await passwordProvider.loadPasswords();
  // }
  //
  // Future<bool> _showGoogleImportConfirmationDialog(GoogleSyncResult result) async {
  //   return await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text('Import from Google Drive'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Found ${result.passwords!.length} passwords in Google Drive:'),
  //           const SizedBox(height: 12),
  //           if (result.backupInfo != null) ...[
  //             _buildInfoRow('Device', result.backupInfo!.deviceId ?? 'Unknown'),
  //             _buildInfoRow('Synced', result.backupInfo!.formattedSyncDate),
  //             _buildInfoRow('Version', result.backupInfo!.version),
  //             const SizedBox(height: 12),
  //           ],
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Text(
  //               'Duplicate passwords will be skipped. This operation cannot be undone.',
  //               style: TextStyle(fontSize: 13),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Import'),
  //         ),
  //       ],
  //     ),
  //   ) ?? false;
  // }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
