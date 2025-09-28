import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/entities/password.dart';

class BackupService {
  static const String _backupVersion = '1.0.0';
  static const String _appName = 'PassVault-It';

  /// Export passwords to JSON file with user-selected location
  static Future<bool> exportToFile(List<Password> passwords, {String? fileName}) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          return false;
        }
      }

      // Generate backup data
      final backupData = _generateBackupData(passwords);
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Generate filename with timestamp if not provided
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final defaultFileName = fileName ?? 'passvault_backup_$timestamp.json';

      // Let user choose save location
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Password Backup',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (filePath == null) {
        return false; // User cancelled
      }

      // Ensure .json extension
      if (!filePath.endsWith('.json')) {
        filePath = '$filePath.json';
      }

      // Write file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Share backup file via share dialog
  static Future<bool> shareBackup(List<Password> passwords) async {
    try {
      // Generate backup data
      final backupData = _generateBackupData(passwords);
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final fileName = 'passvault_backup_$timestamp.json';
      final tempFile = File('${tempDir.path}/$fileName');
      
      await tempFile.writeAsString(jsonString);

      // Share file
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'PassVault-It Password Backup',
        text: 'Password backup created on ${DateTime.now().toString().split(' ')[0]}',
      );

      return true;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }

  /// Import passwords from user-selected JSON file
  static Future<BackupImportResult> importFromFile() async {
    try {
      // Let user pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Password Backup File',
      );

      if (result == null || result.files.isEmpty) {
        return BackupImportResult(
          success: false,
          error: 'No file selected',
        );
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      return _parseBackupFile(jsonString);
    } catch (e) {
      debugPrint('Import error: $e');
      return BackupImportResult(
        success: false,
        error: 'Failed to read backup file: ${e.toString()}',
      );
    }
  }

  /// Import from JSON string (for testing or other integrations)
  static BackupImportResult importFromJson(String jsonString) {
    return _parseBackupFile(jsonString);
  }

  /// Validate backup file format
  static Future<BackupValidationResult> validateBackupFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File to Validate',
      );

      if (result == null || result.files.isEmpty) {
        return BackupValidationResult(
          isValid: false,
          error: 'No file selected',
        );
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final importResult = _parseBackupFile(jsonString);

      return BackupValidationResult(
        isValid: importResult.success,
        error: importResult.error,
        passwordCount: importResult.passwords?.length ?? 0,
        backupInfo: importResult.backupInfo,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        error: 'Failed to validate file: ${e.toString()}',
      );
    }
  }

  // Private helper methods

  static Map<String, dynamic> _generateBackupData(List<Password> passwords) {
    return {
      'app_name': _appName,
      'backup_version': _backupVersion,
      'export_date': DateTime.now().toIso8601String(),
      'password_count': passwords.length,
      'passwords': passwords.map((password) => {
        'id': password.id,
        'title': password.title,
        'url': password.url,
        'username': password.username,
        'password': password.password,
        'notes': password.notes,
        'added_date': password.addedDate.toIso8601String(),
      }).toList(),
    };
  }

  static BackupImportResult _parseBackupFile(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      // Validate required fields
      if (!data.containsKey('passwords')) {
        return BackupImportResult(
          success: false,
          error: 'Invalid backup file format: missing passwords data',
        );
      }

      // Extract backup info
      final backupInfo = BackupInfo(
        appName: data['app_name'] ?? 'Unknown',
        version: data['backup_version'] ?? 'Unknown',
        exportDate: data['export_date'] != null 
            ? DateTime.tryParse(data['export_date']) ?? DateTime.now()
            : DateTime.now(),
        passwordCount: data['password_count'] ?? 0,
      );

      // Parse passwords
      final List<dynamic> passwordsData = data['passwords'];
      final List<Password> passwords = [];

      for (final passwordData in passwordsData) {
        try {
          final password = Password(
            id: passwordData['id']?.toString() ?? '',
            title: passwordData['title']?.toString() ?? '',
            url: passwordData['url']?.toString(),
            username: passwordData['username']?.toString() ?? '',
            password: passwordData['password']?.toString() ?? '',
            notes: passwordData['notes']?.toString(),
            addedDate: passwordData['added_date'] != null
                ? DateTime.tryParse(passwordData['added_date']) ?? DateTime.now()
                : DateTime.now(),
          );
          passwords.add(password);
        } catch (e) {
          debugPrint('Error parsing password: $e');
          // Continue with other passwords
        }
      }

      return BackupImportResult(
        success: true,
        passwords: passwords,
        backupInfo: backupInfo,
      );
    } catch (e) {
      return BackupImportResult(
        success: false,
        error: 'Invalid JSON format: ${e.toString()}',
      );
    }
  }
}

class BackupImportResult {
  final bool success;
  final List<Password>? passwords;
  final BackupInfo? backupInfo;
  final String? error;

  BackupImportResult({
    required this.success,
    this.passwords,
    this.backupInfo,
    this.error,
  });
}

class BackupValidationResult {
  final bool isValid;
  final String? error;
  final int passwordCount;
  final BackupInfo? backupInfo;

  BackupValidationResult({
    required this.isValid,
    this.error,
    this.passwordCount = 0,
    this.backupInfo,
  });
}

class BackupInfo {
  final String appName;
  final String version;
  final DateTime exportDate;
  final int passwordCount;

  BackupInfo({
    required this.appName,
    required this.version,
    required this.exportDate,
    required this.passwordCount,
  });

  String get formattedExportDate {
    return '${exportDate.day}/${exportDate.month}/${exportDate.year}';
  }

  String get timeSinceExport {
    final now = DateTime.now();
    final difference = now.difference(exportDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
