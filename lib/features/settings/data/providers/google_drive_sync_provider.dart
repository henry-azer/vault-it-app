import 'package:flutter/material.dart';
import 'package:vault_it/core/services/google_drive_sync_service.dart';
import 'package:vault_it/data/entities/account.dart';

enum SyncStatus {
  idle,
  signingIn,
  uploading,
  downloading,
  success,
  error,
}

class GoogleDriveSyncProvider with ChangeNotifier {
  final GoogleDriveSyncService _syncService;

  SyncStatus _status = SyncStatus.idle;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  Map<String, dynamic>? _backupMetadata;

  GoogleDriveSyncProvider(this._syncService);

  SyncStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  Map<String, dynamic>? get backupMetadata => _backupMetadata;
  bool get isSignedIn => _syncService.isSignedIn;
  String? get userEmail => _syncService.userEmail;
  String? get userName => _syncService.userName;
  bool get isProcessing => _status == SyncStatus.uploading || 
                          _status == SyncStatus.downloading ||
                          _status == SyncStatus.signingIn;

  /// Initialize sync service
  Future<void> init() async {
    await _syncService.init();
    if (isSignedIn) {
      await refreshBackupMetadata();
    }
    notifyListeners();
  }

  /// Sign in to Google Drive
  Future<bool> signIn() async {
    _status = SyncStatus.signingIn;
    _errorMessage = null;
    notifyListeners();

    final success = await _syncService.signIn();
    
    if (success) {
      _status = SyncStatus.success;
      await refreshBackupMetadata();
    } else {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to sign in to Google Drive';
    }
    
    notifyListeners();
    return success;
  }

  /// Sign out from Google Drive
  Future<void> signOut() async {
    await _syncService.signOut();
    _status = SyncStatus.idle;
    _errorMessage = null;
    _lastSyncTime = null;
    _backupMetadata = null;
    notifyListeners();
  }

  /// Upload backup to Google Drive
  Future<bool> uploadBackup(List<Account> accounts) async {
    if (!isSignedIn) {
      _errorMessage = 'Please sign in to Google Drive first';
      return false;
    }

    _status = SyncStatus.uploading;
    _errorMessage = null;
    notifyListeners();

    final success = await _syncService.uploadBackup(accounts);
    
    if (success) {
      _status = SyncStatus.success;
      _lastSyncTime = DateTime.now();
      await refreshBackupMetadata();
    } else {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to upload backup to Google Drive';
    }
    
    notifyListeners();
    return success;
  }

  /// Download backup from Google Drive
  Future<List<Account>?> downloadBackup() async {
    if (!isSignedIn) {
      _errorMessage = 'Please sign in to Google Drive first';
      return null;
    }

    _status = SyncStatus.downloading;
    _errorMessage = null;
    notifyListeners();

    final accounts = await _syncService.downloadBackup();
    
    if (accounts != null) {
      _status = SyncStatus.success;
      _lastSyncTime = DateTime.now();
    } else {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to download backup from Google Drive';
    }
    
    notifyListeners();
    return accounts;
  }

  /// Check if backup exists on Google Drive
  Future<bool> hasBackup() async {
    if (!isSignedIn) return false;
    return await _syncService.hasBackup();
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup() async {
    if (!isSignedIn) return false;

    final success = await _syncService.deleteBackup();
    
    if (success) {
      _backupMetadata = null;
      notifyListeners();
    }
    
    return success;
  }

  /// Refresh backup metadata
  Future<void> refreshBackupMetadata() async {
    if (!isSignedIn) return;

    _backupMetadata = await _syncService.getBackupMetadata();
    notifyListeners();
  }

  /// Reset status to idle
  void resetStatus() {
    _status = SyncStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
