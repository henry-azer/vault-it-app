// import 'dart:convert';
// import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as gdrive;
// import 'package:http/src/client.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../data/entities/password.dart';
//
// class GoogleSyncService {
//   static const String _syncFileName = 'passvault_sync_backup.json';
//   static const String _folderId = 'PassVault-It-Sync';
//   static const List<String> _scopes = [gdrive.DriveApi.driveFileScope];
//
//   static GoogleSignIn? _googleSignIn;
//   static gdrive.DriveApi? _driveApi;
//
//   static GoogleSignIn get _signIn {
//     _googleSignIn ??= GoogleSignIn(scopes: _scopes);
//     return _googleSignIn!;
//   }
//
//   /// Initialize Google Sync Service
//   static Future<void> initialize() async {
//     try {
//       _googleSignIn = GoogleSignIn(scopes: _scopes);
//     } catch (e) {
//       debugPrint('Google Sync initialization error: $e');
//     }
//   }
//
//   /// Check if user is signed in
//   static Future<bool> isSignedIn() async {
//     try {
//       final account = await _signIn.signInSilently();
//       return account != null;
//     } catch (e) {
//       debugPrint('Sign-in check error: $e');
//       return false;
//     }
//   }
//
//   /// Get current signed-in user account
//   static Future<GoogleSignInAccount?> getCurrentUser() async {
//     try {
//       return await _signIn.signInSilently();
//     } catch (e) {
//       debugPrint('Get current user error: $e');
//       return null;
//     }
//   }
//
//   /// Sign in to Google account
//   static Future<GoogleSyncResult> signIn() async {
//     try {
//       final account = await _signIn.signIn();
//       if (account == null) {
//         return GoogleSyncResult(
//           success: false,
//           message: 'Sign-in was cancelled',
//         );
//       }
//
//       // Initialize Drive API
//       final authClient = await account.authentication;
//       _driveApi = gdrive.DriveApi(authClient as Client);
//
//       // Save last sync info
//       await _saveLastSyncInfo();
//
//       return GoogleSyncResult(
//         success: true,
//         message: 'Successfully signed in as ${account.email}',
//         userEmail: account.email,
//       );
//     } catch (e) {
//       debugPrint('Google sign-in error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Sign-in failed: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Sign out from Google account
//   static Future<GoogleSyncResult> signOut() async {
//     try {
//       await _signIn.signOut();
//       _driveApi = null;
//
//       // Clear sync preferences
//       await _clearSyncPreferences();
//
//       return GoogleSyncResult(
//         success: true,
//         message: 'Successfully signed out',
//       );
//     } catch (e) {
//       debugPrint('Sign-out error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Sign-out failed: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Upload backup to Google Drive
//   static Future<GoogleSyncResult> uploadBackup(List<Password> passwords) async {
//     try {
//       final account = await getCurrentUser();
//       if (account == null) {
//         return GoogleSyncResult(
//           success: false,
//           message: 'Not signed in to Google account',
//         );
//       }
//
//       if (_driveApi == null) {
//         final authClient = await account.authentication;
//         _driveApi = gdrive.DriveApi(authClient as Client);
//       }
//
//       // Generate backup data
//       final backupData = _generateSyncBackup(passwords);
//       final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
//
//       // Check if backup file already exists
//       final existingFile = await _findSyncFile();
//
//       if (existingFile != null) {
//         // Update existing file
//         final media = gdrive.Media(
//           Stream.value(utf8.encode(jsonString)),
//           utf8.encode(jsonString).length,
//           contentType: 'application/json',
//         );
//
//         await _driveApi!.files.update(
//           gdrive.File(),
//           existingFile.id!,
//           uploadMedia: media,
//         );
//       } else {
//         // Create new file
//         final file = gdrive.File()
//           ..name = _syncFileName
//           ..parents = [await _getOrCreateAppFolder()];
//
//         final media = gdrive.Media(
//           Stream.value(utf8.encode(jsonString)),
//           utf8.encode(jsonString).length,
//           contentType: 'application/json',
//         );
//
//         await _driveApi!.files.create(file, uploadMedia: media);
//       }
//
//       // Update last sync time
//       await _saveLastSyncInfo();
//
//       return GoogleSyncResult(
//         success: true,
//         message: 'Backup uploaded successfully',
//         lastSyncTime: DateTime.now(),
//       );
//     } catch (e) {
//       debugPrint('Upload backup error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Upload failed: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Download backup from Google Drive
//   static Future<GoogleSyncResult> downloadBackup() async {
//     try {
//       final account = await getCurrentUser();
//       if (account == null) {
//         return GoogleSyncResult(
//           success: false,
//           message: 'Not signed in to Google account',
//         );
//       }
//
//       if (_driveApi == null) {
//         final authClient = await account.authentication;
//         _driveApi = gdrive.DriveApi(authClient as Client);
//       }
//
//       // Find sync file
//       final syncFile = await _findSyncFile();
//       if (syncFile == null) {
//         return GoogleSyncResult(
//           success: false,
//           message: 'No backup found in Google Drive',
//         );
//       }
//
//       // Download file content
//       final media = await _driveApi!.files.get(
//         syncFile.id!,
//         downloadOptions: gdrive.DownloadOptions.fullMedia,
//       ) as gdrive.Media;
//
//       final dataBytes = <int>[];
//       await for (final chunk in media.stream) {
//         dataBytes.addAll(chunk);
//       }
//
//       final jsonString = utf8.decode(dataBytes);
//       final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
//
//       // Parse passwords
//       final passwordsData = backupData['passwords'] as List<dynamic>;
//       final passwords = passwordsData
//           .map((data) => Password.fromMap(data as Map<String, dynamic>))
//           .toList();
//
//       // Update last sync time
//       await _saveLastSyncInfo();
//
//       return GoogleSyncResult(
//         success: true,
//         message: 'Backup downloaded successfully',
//         passwords: passwords,
//         backupInfo: SyncBackupInfo(
//           appName: backupData['app_name'] as String,
//           version: backupData['version'] as String,
//           syncDate: DateTime.parse(backupData['sync_date'] as String),
//           passwordCount: backupData['password_count'] as int,
//           deviceId: backupData['device_id'] as String?,
//         ),
//         lastSyncTime: DateTime.now(),
//       );
//     } catch (e) {
//       debugPrint('Download backup error: $e');
//       return GoogleSyncResult(
//         success: false,
//         message: 'Download failed: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Get sync status and last sync time
//   static Future<SyncStatus> getSyncStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final lastSyncString = prefs.getString('google_last_sync');
//       final lastSyncTime = lastSyncString != null
//           ? DateTime.tryParse(lastSyncString)
//           : null;
//
//       final isSignedIn = await GoogleSyncService.isSignedIn();
//       final currentUser = await getCurrentUser();
//
//       return SyncStatus(
//         isSignedIn: isSignedIn,
//         userEmail: currentUser?.email,
//         lastSyncTime: lastSyncTime,
//         hasCloudBackup: isSignedIn ? await _hasCloudBackup() : false,
//       );
//     } catch (e) {
//       debugPrint('Get sync status error: $e');
//       return SyncStatus(
//         isSignedIn: false,
//         userEmail: null,
//         lastSyncTime: null,
//         hasCloudBackup: false,
//       );
//     }
//   }
//
//   /// Check if there's a backup in Google Drive
//   static Future<bool> _hasCloudBackup() async {
//     try {
//       final syncFile = await _findSyncFile();
//       return syncFile != null;
//     } catch (e) {
//       debugPrint('Check cloud backup error: $e');
//       return false;
//     }
//   }
//
//   /// Find sync backup file in Google Drive
//   static Future<gdrive.File?> _findSyncFile() async {
//     try {
//       if (_driveApi == null) return null;
//
//       final folderId = await _getOrCreateAppFolder();
//       final response = await _driveApi!.files.list(
//         q: "name='$_syncFileName' and parents in '$folderId' and trashed=false",
//         spaces: 'drive',
//       );
//
//       return response.files?.isNotEmpty == true
//           ? response.files!.first
//           : null;
//     } catch (e) {
//       debugPrint('Find sync file error: $e');
//       return null;
//     }
//   }
//
//   /// Get or create app folder in Google Drive
//   static Future<String> _getOrCreateAppFolder() async {
//     try {
//       // Check if folder exists
//       final response = await _driveApi!.files.list(
//         q: "name='$_folderId' and mimeType='application/vnd.google-apps.folder' and trashed=false",
//         spaces: 'drive',
//       );
//
//       if (response.files?.isNotEmpty == true) {
//         return response.files!.first.id!;
//       }
//
//       // Create folder
//       final folder = gdrive.File()
//         ..name = _folderId
//         ..mimeType = 'application/vnd.google-apps.folder';
//
//       final createdFolder = await _driveApi!.files.create(folder);
//       return createdFolder.id!;
//     } catch (e) {
//       debugPrint('Get/Create app folder error: $e');
//       throw Exception('Failed to access Google Drive folder');
//     }
//   }
//
//   /// Generate sync backup data
//   static Map<String, dynamic> _generateSyncBackup(List<Password> passwords) {
//     return {
//       'app_name': 'PassVault-It',
//       'version': '1.0.0',
//       'sync_date': DateTime.now().toIso8601String(),
//       'password_count': passwords.length,
//       'device_id': _getDeviceId(),
//       'passwords': passwords.map((p) => p.toMap()).toList(),
//     };
//   }
//
//   /// Get device identifier
//   static String _getDeviceId() {
//     return Platform.isAndroid ? 'Android' : 'iOS';
//   }
//
//   /// Save last sync information
//   static Future<void> _saveLastSyncInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('google_last_sync', DateTime.now().toIso8601String());
//     } catch (e) {
//       debugPrint('Save sync info error: $e');
//     }
//   }
//
//   /// Clear sync preferences
//   static Future<void> _clearSyncPreferences() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('google_last_sync');
//     } catch (e) {
//       debugPrint('Clear sync preferences error: $e');
//     }
//   }
// }
//
// /// Google Sync Result
// class GoogleSyncResult {
//   final bool success;
//   final String message;
//   final String? userEmail;
//   final List<Password>? passwords;
//   final SyncBackupInfo? backupInfo;
//   final DateTime? lastSyncTime;
//
//   GoogleSyncResult({
//     required this.success,
//     required this.message,
//     this.userEmail,
//     this.passwords,
//     this.backupInfo,
//     this.lastSyncTime,
//   });
// }
//
// /// Sync Status
// class SyncStatus {
//   final bool isSignedIn;
//   final String? userEmail;
//   final DateTime? lastSyncTime;
//   final bool hasCloudBackup;
//
//   SyncStatus({
//     required this.isSignedIn,
//     this.userEmail,
//     this.lastSyncTime,
//     required this.hasCloudBackup,
//   });
//
//   String get formattedLastSync {
//     if (lastSyncTime == null) return 'Never';
//
//     final now = DateTime.now();
//     final difference = now.difference(lastSyncTime!);
//
//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes} minutes ago';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours} hours ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${(difference.inDays / 7).floor()} weeks ago';
//     }
//   }
// }
//
// /// Sync Backup Information
// class SyncBackupInfo {
//   final String appName;
//   final String version;
//   final DateTime syncDate;
//   final int passwordCount;
//   final String? deviceId;
//
//   SyncBackupInfo({
//     required this.appName,
//     required this.version,
//     required this.syncDate,
//     required this.passwordCount,
//     this.deviceId,
//   });
//
//   String get formattedSyncDate {
//     return '${syncDate.day}/${syncDate.month}/${syncDate.year}';
//   }
// }
