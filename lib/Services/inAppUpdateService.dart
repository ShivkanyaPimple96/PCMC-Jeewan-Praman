import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pcmc_jeevan_praman/splash_screen.dart';

import 'package:url_launcher/url_launcher.dart';

/// Service for handling in-app updates with fallback to Play Store
///
/// This service provides both automatic in-app updates and manual Play Store updates.
/// When in-app updates are not available or fail, users can be directed to the Play Store.
///
/// Usage:
/// ```dart
/// final updateService = InAppUpdateService();
///
/// // Check for updates with automatic handling
/// await updateService.handleAppUpdate(context);
///
/// // Manual update check that opens Play Store directly
/// await updateService.manualUpdateCheckWithPlayStore(context);
///
/// // Open Play Store directly
/// await updateService.openPlayStore(context);
/// ```
class InAppUpdateService {
  static const Duration _checkInterval = Duration(hours: 24);
  DateTime? _lastCheckTime;

  // Singleton pattern
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  bool _isUpdating = false;
  Timer? _updateCheckTimer;

  Future<AppUpdateInfo?> checkForUpdate({bool forceCheck = false}) async {
    try {
      if (!forceCheck && _shouldSkipAutomaticCheck()) {
        return null;
      }

      final info = await InAppUpdate.checkForUpdate();
      _lastCheckTime = DateTime.now();
      return info;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      rethrow;
    }
  }

  bool _shouldSkipAutomaticCheck() {
    if (_lastCheckTime == null) return false;
    return DateTime.now().difference(_lastCheckTime!) < _checkInterval;
  }

  Future<void> startFlexibleUpdate(BuildContext context) async {
    if (_isUpdating) {
      _showSnackBar(context, 'Update already in progress...');
      return;
    }

    try {
      _isUpdating = true;
      final result = await InAppUpdate.startFlexibleUpdate();
      debugPrint('Flexible update started: $result');

      if (result == AppUpdateResult.success) {
        if (context.mounted) {
          _showSnackBar(context, 'Update downloaded. Installing...');
        }
        // Complete the update immediately after download
        if (context.mounted) {
          await completeFlexibleUpdate(context);
        }
      } else {
        _isUpdating = false;
        if (context.mounted) {
          _showSnackBar(context, 'Update download failed');
        }
      }
    } catch (e) {
      _isUpdating = false;
      debugPrint('Error starting flexible update: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to start update download');
      }
      rethrow;
    }
  }

  Future<void> completeFlexibleUpdate(BuildContext context) async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
      _isUpdating = false;

      // This will restart the app with the new version
      if (context.mounted) {
        _showSnackBar(context, 'App will restart with the new version...');
        // Add a small delay to ensure message is visible
        await Future.delayed(const Duration(seconds: 2));
        // Force restart the app to ensure new version loads
        if (context.mounted) {
          _restartApp(context);
        }
      }
    } catch (e) {
      _isUpdating = false;
      debugPrint('Error completing flexible update: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to install update. Please restart the app.',
        );
      }
      rethrow;
    }
  }

  void _restartApp(BuildContext context) {
    // This is a simple way to restart the app - you might need a more robust solution
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> startImmediateUpdate(BuildContext context) async {
    if (_isUpdating) {
      _showSnackBar(context, 'Update already in progress...');
      return;
    }

    try {
      _isUpdating = true;
      final result = await InAppUpdate.performImmediateUpdate();

      if (result == AppUpdateResult.success) {
        if (context.mounted) {
          _showSnackBar(context, 'Update completed successfully!');
        }
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Update failed. Please try again.');
        }
      }
    } catch (e) {
      debugPrint('Error performing immediate update: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to perform immediate update');
      }
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> handleAppUpdate(
    BuildContext context, {
    bool forceMandatory = false,
    bool showNoUpdateMessage = false,
    bool forceCheck = false,
  }) async {
    if (!context.mounted) return;

    try {
      final updateInfo = await checkForUpdate(forceCheck: forceCheck);

      if (updateInfo == null) {
        if (showNoUpdateMessage && context.mounted) {
          _showSnackBar(context, 'No new updates available.');
        }
        return;
      }

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Use immediate update if available
          if (context.mounted) {
            await startImmediateUpdate(context);
          }
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Show dialog for flexible update
          if (context.mounted) {
            _showUpdateDialog(context);
          }
        } else {
          // If no in-app update is available, offer manual update
          if (context.mounted) {
            _showManualUpdateDialog(context);
          }
        }
      } else {
        if (showNoUpdateMessage && context.mounted) {
          _showSnackBar(context, 'No updates available.');
        }
      }
    } catch (e) {
      debugPrint('Error handling app update: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Unable to check for updates');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> manualUpdateCheck(BuildContext context) async {
    if (!context.mounted) return;

    _showSnackBar(context, 'Checking for updates...');
    await handleAppUpdate(context, showNoUpdateMessage: true, forceCheck: true);
  }

  /// Manual update check that opens Play Store directly
  Future<void> manualUpdateCheckWithPlayStore(BuildContext context) async {
    if (!context.mounted) return;

    _showSnackBar(context, 'Opening Play Store for manual update...');
    await openPlayStore(context);
  }

  void dispose() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = null;
  }

  /// Opens the Play Store page for the app
  Future<void> openPlayStore(BuildContext context) async {
    try {
      // Android Play Store URL for PMC Life Certificate app
      const String packageName = 'com.altwise.jeevanpraman';
      const String playStoreUrl =
          'https://play.google.com/store/apps/details?id=$packageName';

      final Uri url = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          _showSnackBar(context, 'Opening Play Store...');
        }
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Could not open Play Store');
        }
      }
    } catch (e) {
      debugPrint('Error opening Play Store: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to open Play Store');
      }
    }
  }

  /// Shows a dialog with options for automatic or manual update
  void _showUpdateDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
            'A new version of the app is available. Choose how you would like to update:',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openPlayStore(context);
              },
              child: const Text('Manual Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                startFlexibleUpdate(context);
              },
              child: const Text('Auto Update'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for manual update when in-app updates are not available
  void _showManualUpdateDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
            'A new version of the app is available. Please update manually from the Play Store.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openPlayStore(context);
              },
              child: const Text('Open Play Store'),
            ),
          ],
        );
      },
    );
  }
}
