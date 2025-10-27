import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/data/entities/account.dart';

class BackupInfo {
  final String appName;
  final String version;
  final DateTime exportDate;
  final int accountCount;
  final String deviceId;

  BackupInfo({
    required this.appName,
    required this.version,
    required this.exportDate,
    required this.accountCount,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'app_name': appName,
      'version': version,
      'export_date': exportDate.toIso8601String(),
      'account_count': accountCount,
      'device_id': deviceId,
    };
  }

  factory BackupInfo.fromMap(Map<String, dynamic> map) {
    return BackupInfo(
      appName: map['app_name'] ?? '',
      version: map['version'] ?? '',
      exportDate: DateTime.parse(map['export_date']),
      accountCount: map['account_count'] ?? 0,
      deviceId: map['device_id'] ?? 'unknown',
    );
  }

  String get formattedExportDate {
    final now = DateTime.now();
    final difference = now.difference(exportDate);

    if (difference.inDays == 0) {
      return AppStrings.today.tr;
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday.tr;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AppStrings.daysAgo.tr}';
    } else {
      return '${exportDate.day}/${exportDate.month}/${exportDate.year}';
    }
  }

  String get timeSinceExport {
    final now = DateTime.now();
    final difference = now.difference(exportDate);

    if (difference.inHours < 24) {
      return '${difference.inHours} ${AppStrings.hoursAgo.tr}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${AppStrings.daysAgo.tr}';
    } else {
      return '${(difference.inDays / 30).floor()} ${AppStrings.monthsAgo.tr}';
    }
  }
}

class BackupResult {
  final bool success;
  final String? message;
  final String? filePath;

  BackupResult({
    required this.success,
    this.message,
    this.filePath,
  });
}

class ImportResult {
  final bool success;
  final String? error;
  final List<Account>? accounts;
  final BackupInfo? backupInfo;

  ImportResult({
    required this.success,
    this.error,
    this.accounts,
    this.backupInfo,
  });
}

class LocalBackupProvider with ChangeNotifier {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastBackupPath;
  DateTime? _lastBackupDate;

  bool get isExporting => _isExporting;
  bool get isImporting => _isImporting;
  bool get isProcessing => _isExporting || _isImporting;
  String? get lastBackupPath => _lastBackupPath;
  DateTime? get lastBackupDate => _lastBackupDate;

  Future<BackupResult> exportToFile(List<Account> accounts) async {
    if (accounts.isEmpty) {
      return BackupResult(
        success: false,
        message: AppStrings.noAccountsToExport.tr,
      );
    }

    _isExporting = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      final backupInfo = BackupInfo(
        appName: 'Vault It',
        version: packageInfo.version,
        exportDate: DateTime.now(),
        accountCount: accounts.length,
        deviceId: 'local_device',
      );

      final backupData = {
        'backup_info': backupInfo.toMap(),
        'accounts': accounts.map((account) => account.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        return BackupResult(
          success: false,
          message: AppStrings.couldNotAccessStorage.tr,
        );
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'vault_it_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      _lastBackupPath = file.path;
      _lastBackupDate = DateTime.now();
      
      _isExporting = false;
      notifyListeners();

      return BackupResult(
        success: true,
        message: AppStrings.backupSavedSuccessfully.tr,
        filePath: file.path,
      );
    } catch (e) {
      _isExporting = false;
      notifyListeners();
      
      return BackupResult(
        success: false,
        message: '${AppStrings.exportFailedError.tr}: ${e.toString()}',
      );
    }
  }

  Future<BackupResult> shareBackup(List<Account> accounts) async {
    if (accounts.isEmpty) {
      return BackupResult(
        success: false,
        message: AppStrings.noAccountsToShare.tr,
      );
    }

    _isExporting = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      final backupInfo = BackupInfo(
        appName: 'Vault It',
        version: packageInfo.version,
        exportDate: DateTime.now(),
        accountCount: accounts.length,
        deviceId: 'local_device',
      );

      final backupData = {
        'backup_info': backupInfo.toMap(),
        'accounts': accounts.map((account) => account.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'vault_it_backup_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)]);

      _lastBackupDate = DateTime.now();
      
      _isExporting = false;
      notifyListeners();

      return BackupResult(
        success: true,
        message: AppStrings.backupSharedSuccessfully.tr,
        filePath: file.path,
      );
    } catch (e) {
      _isExporting = false;
      notifyListeners();
      
      return BackupResult(
        success: false,
        message: '${AppStrings.shareFailedError.tr}: ${e.toString()}',
      );
    }
  }

  Future<ImportResult> importFromFile() async {
    _isImporting = true;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _isImporting = false;
        notifyListeners();
        return ImportResult(
          success: false,
          error: AppStrings.noFileSelected.tr,
        );
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        _isImporting = false;
        notifyListeners();
        return ImportResult(
          success: false,
          error: AppStrings.couldNotAccessFile.tr,
        );
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!backupData.containsKey('backup_info') || !backupData.containsKey('accounts')) {
        _isImporting = false;
        notifyListeners();
        return ImportResult(
          success: false,
          error: AppStrings.invalidBackupFormat.tr,
        );
      }

      final backupInfo = BackupInfo.fromMap(backupData['backup_info']);

      final List<dynamic> accountsList = backupData['accounts'];
      final accounts = accountsList.map((accountMap) => Account.fromMap(accountMap)).toList();

      _isImporting = false;
      notifyListeners();

      return ImportResult(
        success: true,
        accounts: accounts,
        backupInfo: backupInfo,
      );
    } catch (e) {
      _isImporting = false;
      notifyListeners();
      
      return ImportResult(
        success: false,
        error: '${AppStrings.importFailedError.tr}: ${e.toString()}',
      );
    }
  }

  Future<ImportResult> validateBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          error: AppStrings.noFileSelected.tr,
        );
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return ImportResult(
          success: false,
          error: AppStrings.couldNotAccessFile.tr,
        );
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!backupData.containsKey('backup_info') || !backupData.containsKey('accounts')) {
        return ImportResult(
          success: false,
          error: AppStrings.invalidBackupFormat.tr,
        );
      }

      final backupInfo = BackupInfo.fromMap(backupData['backup_info']);
      final accountCount = (backupData['accounts'] as List).length;

      return ImportResult(
        success: true,
        backupInfo: backupInfo.copyWith(accountCount: accountCount),
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: '${AppStrings.validationFailedError.tr}: ${e.toString()}',
      );
    }
  }

  void reset() {
    _isExporting = false;
    _isImporting = false;
    _lastBackupPath = null;
    _lastBackupDate = null;
    notifyListeners();
  }
}

extension BackupInfoExtension on BackupInfo {
  BackupInfo copyWith({
    String? appName,
    String? version,
    DateTime? exportDate,
    int? accountCount,
    String? deviceId,
  }) {
    return BackupInfo(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      exportDate: exportDate ?? this.exportDate,
      accountCount: accountCount ?? this.accountCount,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
