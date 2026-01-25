import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, debugPrint, kDebugMode;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AttService {
  static bool get isSupported => defaultTargetPlatform == TargetPlatform.iOS;

  /// Requests Apple's App Tracking Transparency authorization (iOS 14+).
  ///
  /// Safe to call on non-iOS platforms (no-op).
  static Future<void> requestAuthorizationIfNeeded() async {
    if (!isSupported) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (kDebugMode) {
        debugPrint('ATT: current status=$status');
      }

      // Only prompt if it has not been determined yet.
      if (status == TrackingStatus.notDetermined) {
        final newStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        if (kDebugMode) {
          debugPrint('ATT: new status=$newStatus');
        }
      }
    } catch (e) {
      // Never block app startup/ads on ATT errors.
      if (kDebugMode) {
        debugPrint('ATT: request failed: $e');
      }
    }
  }
}
