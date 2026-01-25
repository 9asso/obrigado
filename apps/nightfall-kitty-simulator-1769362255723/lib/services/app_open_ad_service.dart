import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_config.dart';
import 'iap_service.dart';

class AppOpenAdService with WidgetsBindingObserver {
  static AppOpenAdService? _instance;

  late AppConfig _config;

  AppOpenAd? _appOpenAd;
  bool _isLoading = false;
  bool _isShowing = false;
  bool _isAttached = false;

  DateTime? _lastPausedAt;
  static const Duration _minBackgroundDurationForShow = Duration(seconds: 30);

  DateTime? _lastShownAt;
  DateTime? _lastLoadAttemptAt;

  static const Duration _minShowInterval = Duration(seconds: 25);
  static const Duration _minLoadInterval = Duration(seconds: 10);

  AppOpenAdService._();

  static Future<AppOpenAdService> getInstance() async {
    if (_instance == null) {
      _instance = AppOpenAdService._();
      _instance!._config = await AppConfig.getInstance();
    }
    return _instance!;
  }

  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void attach() {
    if (_isAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;
    WidgetsBinding.instance.removeObserver(this);
    _isAttached = false;
  }

  String _getAppOpenAdUnitId() {
    if (!isSupported) return '';
    if (_config.admobTestMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-3940256099942544/9257395921';
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ca-app-pub-3940256099942544/5575463023';
      }
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _config.androidAppOpenAdUnitId;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _config.iosAppOpenAdUnitId;
    }
    return '';
  }

  Future<bool> _shouldShowAds() async {
    try {
      final iapService = await IAPService.getInstance();
      return !iapService.hasActiveSubscription;
    } catch (e) {
      // Fail open: if subscription check fails, keep ads enabled.
      // This prevents App Open Ads from breaking the app.
      return true;
    }
  }

  Future<void> warmUp() async {
    if (!_config.admobEnabled || !isSupported) return;
    await loadAd();
  }

  Future<void> loadAd() async {
    if (_isLoading) return;
    if (!_config.admobEnabled || !isSupported) return;

    final now = DateTime.now();
    if (_lastLoadAttemptAt != null &&
        now.difference(_lastLoadAttemptAt!) < _minLoadInterval) {
      return;
    }

    final adUnitId = _getAppOpenAdUnitId().trim();
    if (adUnitId.isEmpty) return;

    _isLoading = true;
    _lastLoadAttemptAt = now;

    final completer = Completer<void>();

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          // ignore: avoid_print
          print('AppOpenAd loaded');
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          _isLoading = false;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          // ignore: avoid_print
          print('AppOpenAd failed to load: $error');
          _isLoading = false;
          _appOpenAd = null;
          completer.complete();
        },
      ),
    );

    return completer.future;
  }

  Future<void> showIfAvailable() async {
    if (_isShowing) return;
    if (!_config.admobEnabled || !isSupported) return;

    final shouldShow = await _shouldShowAds();
    if (!shouldShow) return;

    final now = DateTime.now();
    if (_lastShownAt != null &&
        now.difference(_lastShownAt!) < _minShowInterval) {
      return;
    }

    AppOpenAd? ad = _appOpenAd;
    if (ad == null) {
      // ignore: avoid_print
      print('AppOpenAd not ready; loading.');
      await loadAd();
      ad = _appOpenAd;
      if (ad == null) {
        return;
      }
    }

    _isShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastShownAt = DateTime.now();
        // ignore: avoid_print
        print('AppOpenAd showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        // ignore: avoid_print
        print('AppOpenAd dismissed');
        ad.dispose();
        _appOpenAd = null;
        _isShowing = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        // ignore: avoid_print
        print('AppOpenAd failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isShowing = false;
        loadAd();
      },
    );

    try {
      // ignore: avoid_print
      print('AppOpenAd calling show()');
      await ad.show();
      // ignore: avoid_print
      print('AppOpenAd show() returned');
    } catch (e) {
      // ignore: avoid_print
      print('AppOpenAd exception during show: $e');
      _isShowing = false;
      _appOpenAd = null;
      loadAd();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedAt = DateTime.now();
      // Preload for the next foreground.
      loadAd();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      // Only show if we truly went to background (paused) long enough.
      // Interstitial dismissal often triggers resumed without a preceding paused.
      final pausedAt = _lastPausedAt;
      _lastPausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt) >= _minBackgroundDurationForShow) {
        // Fire and forget.
        showIfAvailable();
      } else {
        // Still keep inventory warm.
        loadAd();
      }
    }
  }

  void dispose() {
    detach();
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
