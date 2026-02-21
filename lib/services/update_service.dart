import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ammas_kitchen/config/app_config.dart';

class UpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.downloadUrl,
    required this.changelog,
    this.forceUpdate = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latest_version'] as String,
      latestVersionCode: json['latest_version_code'] as int,
      downloadUrl: json['download_url'] as String,
      changelog: json['changelog'] as String? ?? '',
      forceUpdate: json['force_update'] as bool? ?? false,
    );
  }
}

class UpdateService {
  static final UpdateService instance = UpdateService._init();
  UpdateService._init();

  /// Check if a newer version is available.
  /// Returns [UpdateInfo] if an update is available, null otherwise.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.updateCheckUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final updateInfo = UpdateInfo.fromJson(json);

      if (updateInfo.latestVersionCode > AppConfig.currentVersionCode) {
        return updateInfo;
      }

      return null;
    } catch (e) {
      // Silently fail — don't bother amma with network errors
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Download the APK to a temporary location.
  /// Returns the file path, or null if download failed.
  /// [onProgress] reports download progress from 0.0 to 1.0.
  Future<String?> downloadUpdate(
    String downloadUrl, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        client.close();
        return null;
      }

      final contentLength = response.contentLength ?? 0;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/ammas_kitchen_update.apk';
      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }

      await sink.close();
      client.close();
      return filePath;
    } catch (e) {
      debugPrint('Download failed: $e');
      return null;
    }
  }

  /// Show the update dialog to the user.
  Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo updateInfo,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (ctx) => _UpdateDialog(updateInfo: updateInfo),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const _UpdateDialog({required this.updateInfo});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Expanded(child: Text('Update Available!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${widget.updateInfo.latestVersion} is ready.',
            style: const TextStyle(fontSize: 16),
          ),
          if (widget.updateInfo.changelog.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "What's new:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.updateInfo.changelog,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toInt()}% downloaded...',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        if (!widget.updateInfo.forceUpdate && !_isDownloading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
        if (!_isDownloading)
          FilledButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
          ),
      ],
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0;
    });

    final filePath = await UpdateService.instance.downloadUpdate(
      widget.updateInfo.downloadUrl,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      },
    );

    if (!mounted) return;

    if (filePath != null) {
      // Trigger APK install via Android intent
      await _installApk(filePath);
    } else {
      setState(() {
        _isDownloading = false;
        _error = 'Download failed. Please try again.';
      });
    }
  }

  Future<void> _installApk(String filePath) async {
    // We'll use a platform channel to trigger the Android install intent
    // For now, show a message directing to the file
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Update downloaded! Opening installer...',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Trigger install via platform channel
    await _triggerInstall(filePath);
  }

  Future<void> _triggerInstall(String filePath) async {
    // This will be handled by the native Android side
    // Using the install_plugin or manual platform channel
    try {
      await InstallHelper.installApk(filePath);
    } catch (e) {
      debugPrint('Install trigger failed: $e');
    }
  }
}

/// Helper to trigger APK installation on Android via platform channel.
class InstallHelper {
  static const _channel =
      MethodChannel('com.ammas.kitchen/install');

  static Future<void> installApk(String filePath) async {
    try {
      await _channel.invokeMethod('installApk', {'filePath': filePath});
    } catch (e) {
      debugPrint('Platform channel install failed: $e');
    }
  }
}
