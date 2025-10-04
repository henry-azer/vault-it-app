import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:vault_it/data/entities/account.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GoogleDriveSyncService {
  static const List<String> _scopes = [drive.DriveApi.driveAppdataScope];
  static const String _backupFileName = 'vault_it_backup.json';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;

  /// Initialize and check if user is already signed in
  Future<bool> init() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initDriveApi();
      }
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign in to Google account
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        await _initDriveApi();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Sign out from Google account
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  /// Initialize Drive API
  Future<void> _initDriveApi() async {
    final httpClient = (await _googleSignIn.authenticatedClient())!;
    _driveApi = drive.DriveApi(httpClient);
  }

  /// Upload backup to Google Drive
  Future<bool> uploadBackup(List<Account> accounts) async {
    if (_driveApi == null) return false;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      final backupData = {
        'backup_info': {
          'app_name': 'Vault It',
          'version': packageInfo.version,
          'export_date': DateTime.now().toIso8601String(),
          'account_count': accounts.length,
          'device_id': 'google_drive',
        },
        'accounts': accounts.map((account) => account.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final bytes = utf8.encode(jsonString);

      // Check if backup file exists
      final existingFile = await _findBackupFile();
      
      if (existingFile != null) {
        // Update existing file
        final media = drive.Media(Stream.value(bytes), bytes.length);
        await _driveApi!.files.update(
          drive.File(),
          existingFile.id!,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        final media = drive.Media(Stream.value(bytes), bytes.length);
        await _driveApi!.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download backup from Google Drive
  Future<List<Account>?> downloadBackup() async {
    if (_driveApi == null) return null;

    try {
      final backupFile = await _findBackupFile();
      if (backupFile == null) return null;

      final media = await _driveApi!.files.get(
        backupFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _readMedia(media);
      final jsonString = utf8.decode(bytes);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!backupData.containsKey('accounts')) return null;

      final List<dynamic> accountsList = backupData['accounts'];
      return accountsList.map((accountMap) => Account.fromMap(accountMap)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Get backup metadata
  Future<Map<String, dynamic>?> getBackupMetadata() async {
    if (_driveApi == null) return null;

    try {
      final backupFile = await _findBackupFile();
      if (backupFile == null) return null;

      final media = await _driveApi!.files.get(
        backupFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _readMedia(media);
      final jsonString = utf8.decode(bytes);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      return backupData['backup_info'];
    } catch (e) {
      return null;
    }
  }

  /// Check if backup exists on Google Drive
  Future<bool> hasBackup() async {
    if (_driveApi == null) return false;
    final file = await _findBackupFile();
    return file != null;
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup() async {
    if (_driveApi == null) return false;

    try {
      final backupFile = await _findBackupFile();
      if (backupFile == null) return false;

      await _driveApi!.files.delete(backupFile.id!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Find backup file in Google Drive
  Future<drive.File?> _findBackupFile() async {
    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
        $fields: 'files(id, name, modifiedTime, size)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Read media stream to bytes
  Future<List<int>> _readMedia(drive.Media media) async {
    final bytes = <int>[];
    await for (var chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }
}
