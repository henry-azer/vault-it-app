// import 'package:flutter/material.dart';
// import '../../data/services/google_sync_service.dart';
// import '../../../../data/entities/password.dart';
//
// class GoogleSyncProvider extends ChangeNotifier {
//   SyncStatus _syncStatus = SyncStatus(
//     isSignedIn: false,
//     userEmail: null,
//     lastSyncTime: null,
//     hasCloudBackup: false,
//   );
//
//   bool _isLoading = false;
//   bool _isSyncing = false;
//   String? _lastError;
//
//   // Getters
//   SyncStatus get syncStatus => _syncStatus;
//   bool get isLoading => _isLoading;
//   bool get isSyncing => _isSyncing;
//   String? get lastError => _lastError;
//   bool get isSignedIn => _syncStatus.isSignedIn;
//   String? get userEmail => _syncStatus.userEmail;
//   DateTime? get lastSyncTime => _syncStatus.lastSyncTime;
//   String get formattedLastSync => _syncStatus.formattedLastSync;
//   bool get hasCloudBackup => _syncStatus.hasCloudBackup;
//
//   /// Initialize the provider
//   Future<void> initialize() async {
//     await GoogleSyncService.initialize();
//     await refreshSyncStatus();
//   }
//
//   /// Refresh sync status
//   Future<void> refreshSyncStatus() async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();
//
//     try {
//       _syncStatus = await GoogleSyncService.getSyncStatus();
//     } catch (e) {
//       _lastError = 'Failed to refresh sync status: ${e.toString()}';
//       debugPrint('Refresh sync status error: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Sign in to Google account
//   Future<bool> signIn() async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();
//
//     try {
//       final result = await GoogleSyncService.signIn();
//
//       if (result.success) {
//         await refreshSyncStatus();
//         return true;
//       } else {
//         _lastError = result.message;
//         return false;
//       }
//     } catch (e) {
//       _lastError = 'Sign-in failed: ${e.toString()}';
//       debugPrint('Sign-in error: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Sign out from Google account
//   Future<bool> signOut() async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();
//
//     try {
//       final result = await GoogleSyncService.signOut();
//
//       if (result.success) {
//         await refreshSyncStatus();
//         return true;
//       } else {
//         _lastError = result.message;
//         return false;
//       }
//     } catch (e) {
//       _lastError = 'Sign-out failed: ${e.toString()}';
//       debugPrint('Sign-out error: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Upload backup to Google Drive
//   Future<GoogleSyncResult> uploadBackup(List<Password> passwords) async {
//     _isSyncing = true;
//     _lastError = null;
//     notifyListeners();
//
//     try {
//       final result = await GoogleSyncService.uploadBackup(passwords);
//
//       if (result.success) {
//         await refreshSyncStatus();
//       } else {
//         _lastError = result.message;
//       }
//
//       return result;
//     } catch (e) {
//       _lastError = 'Upload failed: ${e.toString()}';
//       debugPrint('Upload backup error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Upload failed: ${e.toString()}',
//       );
//     } finally {
//       _isSyncing = false;
//       notifyListeners();
//     }
//   }
//
//   /// Download backup from Google Drive
//   Future<GoogleSyncResult> downloadBackup() async {
//     _isSyncing = true;
//     _lastError = null;
//     notifyListeners();
//
//     try {
//       final result = await GoogleSyncService.downloadBackup();
//
//       if (result.success) {
//         await refreshSyncStatus();
//       } else {
//         _lastError = result.message;
//       }
//
//       return result;
//     } catch (e) {
//       _lastError = 'Download failed: ${e.toString()}';
//       debugPrint('Download backup error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Download failed: ${e.toString()}',
//       );
//     } finally {
//       _isSyncing = false;
//       notifyListeners();
//     }
//   }
//
//   /// Perform full sync (upload current passwords)
//   Future<bool> performSync(List<Password> passwords) async {
//     if (!isSignedIn) {
//       _lastError = 'Not signed in to Google account';
//       notifyListeners();
//       return false;
//     }
//
//     final result = await uploadBackup(passwords);
//     return result.success;
//   }
//
//   /// Clear last error
//   void clearError() {
//     _lastError = null;
//     notifyListeners();
//   }
//
//   /// Get sync status summary for UI
//   String getSyncStatusText() {
//     if (_isSyncing) {
//       return 'Syncing...';
//     }
//
//     if (!isSignedIn) {
//       return 'Sign in to enable sync';
//     }
//
//     if (_lastError != null) {
//       return 'Sync error occurred';
//     }
//
//     if (lastSyncTime == null) {
//       return 'Ready to sync';
//     }
//
//     return 'Last sync: $formattedLastSync';
//   }
//
//   /// Get sync status color for UI
//   Color getSyncStatusColor() {
//     if (_isSyncing) {
//       return Colors.blue;
//     }
//
//     if (!isSignedIn) {
//       return Colors.grey;
//     }
//
//     if (_lastError != null) {
//       return Colors.red;
//     }
//
//     if (lastSyncTime == null) {
//       return Colors.orange;
//     }
//
//     return Colors.green;
//   }
//
//   /// Get sync status icon for UI
//   IconData getSyncStatusIcon() {
//     if (_isSyncing) {
//       return Icons.sync;
//     }
//
//     if (!isSignedIn) {
//       return Icons.cloud_off;
//     }
//
//     if (_lastError != null) {
//       return Icons.error;
//     }
//
//     if (lastSyncTime == null) {
//       return Icons.cloud_upload;
//     }
//
//     return Icons.cloud_done;
//   }
// }
