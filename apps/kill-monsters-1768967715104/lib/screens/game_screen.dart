import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_config.dart';
import '../services/admob_service.dart';
import '../services/iap_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  WebViewController? _controller;
  late AppConfig _config;
  bool _configLoaded = false;
  // bool _isLoading = true;
  bool _showMenu = false;
  bool _showSplash = false; // Show splash screen after loading
  late AnimationController _menuAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _splashAnimationController;
  late AnimationController _bounceAnimationController;
  Offset _fabPosition = const Offset(20, 20); // Position from bottom-right
  final List<String> _pageHistory = []; // Track all visited pages
  Timer? _interstitialTimer;
  Timer? _loadingTimeoutTimer;
  int _countdown = 0;
  bool _showCountdown = false;
  bool _showSubscriptionPopup = false;

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _splashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )
      ..addListener(() {
        if (!mounted) return;
        if (_showSplash) setState(() {});
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        if (!mounted) return;

        if (_showSplash) {
          setState(() {
            _showSplash = false;
          });
        }

        _startInterstitialTimer();
      });
    _bounceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _loadConfig();
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    _fabAnimationController.dispose();
    _splashAnimationController.dispose();
    _bounceAnimationController.dispose();
    _interstitialTimer?.cancel();
    _loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  Duration get _loaderDuration {
    // If loader is enabled, cap loading UI to that duration.
    // Otherwise, still prevent endless spinners with a sane default.
    final seconds = _config.gameLoaderEnabled ? _config.gameLoaderDuration : 10;
    return Duration(seconds: seconds.clamp(1, 120));
  }

  void _scheduleLoadingTimeout() {
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(_loaderDuration, () {
      if (!mounted) return;

      setState(() {
        // _isLoading = false;
        // If the page never finishes, still show/hide the splash on a timer
        // when game loader is enabled.
        if (_config.gameLoaderEnabled) {
          _showSplash = true;
        }
      });

      if (_config.gameLoaderEnabled) {
        _startSplashProgress();
      } else {
        _startInterstitialTimer();
      }
    });
  }

  void _startSplashProgress() {
    // If the splash countdown already started (e.g., WebView finished late after
    // the watchdog fired), don't restart it and extend the splash.
    if (_splashAnimationController.isAnimating) return;

    _splashAnimationController
      ..stop()
      ..reset();
    _splashAnimationController.duration = _loaderDuration;
    _splashAnimationController.forward();
  }

  Future<void> _loadConfig() async {
    _config = await AppConfig.getInstance();
    setState(() {
      _configLoaded = true;
    });
    _initializeWebView();
  }

  void _startInterstitialTimer() {
    if (!_config.gameInterstitialEnabled) return;
    
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer(Duration(seconds: _config.gameInterstitialInterval), () {
      _showCountdownAndAd();
    });
  }

  void _showCountdownAndAd() async {
    setState(() {
      _countdown = 3;
      _showCountdown = true;
    });

    // Countdown from 3 to 1
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showCountdown = false;
        });
        // Show interstitial ad
        _showInterstitialAd();
      }
    });
  }

  Future<void> _showInterstitialAd() async {
    if (!_config.admobEnabled || !_config.gameInterstitialEnabled || !AdMobService.isSupported) {
      return;
    }

    final adMobService = await AdMobService.getInstance();
    await adMobService.showInterstitialAd(
      onAdDismissed: () {
        // Restart timer after ad is closed
        _startInterstitialTimer();
      },
      onAdFailedToShow: () {
        // Restart timer even if ad failed
        _startInterstitialTimer();
      },
    );
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'FlutterSubscription',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'showSubscription' && _config.subscriptionEnabled) {
            setState(() {
              _showSubscriptionPopup = true;
            });
          }
        },
      )
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        print('🌐 WebView Console: ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Block about:blank (popups)
            if (request.url == 'about:blank' || request.url.startsWith('about:blank')) {
              print('🚫 Blocked popup: ${request.url}');
              return NavigationDecision.prevent;
            }
            // Block requests containing 'games-sdk.playhop.com'
            if (request.url.contains('games-sdk.playhop.com')) {
              print('🚫 Blocked request: ${request.url}');
              return NavigationDecision.prevent;
            }
            // Allow all other navigation requests (including redirects)
            // print('🔗 Navigation requested: ${request.url}');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            // Log page to history
            _pageHistory.add(url);
            // print('📄 Page started: $url');
            // print('📚 History count: ${_pageHistory.length}');
            // print('📋 Full history: $_pageHistory');
            
            // setState(() {
            //   _isLoading = true;
            // });

            // Never allow loading UI to run indefinitely.
            _scheduleLoadingTimeout();
            
            setState(() {
              // _isLoading = false;
              _showSplash = _config.gameLoaderEnabled; // Show splash based on config
            });

            _loadingTimeoutTimer?.cancel();
            
            if (_config.gameLoaderEnabled) {
              _startSplashProgress();
            } else {
              _startInterstitialTimer();
            }
          },
          onPageFinished: (String url) {
            // print('✅ Page finished loading: $url');
            
            // Inject JavaScript to remove unwanted modals
            _injectModalBlocker();
            
            // setState(() {
            //   _isLoading = false;
            //   _showSplash = _config.gameLoaderEnabled; // Show splash based on config
            // });

            // _loadingTimeoutTimer?.cancel();
            
            // if (_config.gameLoaderEnabled) {
            //   _startSplashProgress();
            // } else {
            //   _startInterstitialTimer();
            // }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description}');
            print('Error code: ${error.errorCode}');
            print('Error type: ${error.errorType}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_config.gameUrl));
  }

  void _injectModalBlocker() {
    // Inject JavaScript to hide payment modal content only
    final script = '''
      (function() {
        const processedModals = new Set();
        
        function forceHideElement(element, reason) {
          try {
            element.style.setProperty('display', 'none', 'important');
            element.style.setProperty('visibility', 'hidden', 'important');
            element.style.setProperty('opacity', '0', 'important');
            element.style.setProperty('max-height', '0', 'important');
            element.style.setProperty('overflow', 'hidden', 'important');
            element.style.setProperty('pointer-events', 'none', 'important');
            element.setAttribute('hidden', 'true');
            element.setAttribute('aria-hidden', 'true');
            
            console.log('✅ Hidden:', reason);
            return true;
          } catch (e) {
            console.error('❌ Failed:', e);
            return false;
          }
        }
        
        function makeNonBlocking(element, reason) {
          try {
            // Make overlay non-blocking but keep it in the page
            element.style.setProperty('pointer-events', 'none', 'important');
            console.log('👻 Made non-blocking:', reason);
            return true;
          } catch (e) {
            return false;
          }
        }
        
        function closeModal() {
          let foundNewModal = false;
          
          const paymentModals = document.querySelectorAll('[data-testid="in-app-form"], .inAppForm, [class*="PaymentsModal"], [class*="drawer-critical-module__body"]:not([class*="transparent"])');
          
          if (paymentModals.length > 0) {
            console.log('🔍 Found', paymentModals.length, 'payment modals');
          }
          
          paymentModals.forEach(modal => {
            const isVisible = modal.offsetParent !== null && 
                            window.getComputedStyle(modal).display !== 'none';
            
            if (isVisible && !processedModals.has(modal)) {
              console.log('💰 Hiding modal and showing subscription popup');
              
              processedModals.add(modal);
              foundNewModal = true;
              
              // Immediately hide the modal
              forceHideElement(modal, 'payment modal');
              
              // Find and remove all parent overlays from DOM
              let parent = modal.parentElement;
              let depth = 0;
              while (parent && parent !== document.body && depth < 10) {
                const parentClass = String(parent.className || '').toLowerCase();
                if ((parentClass.includes('overlay') || 
                     parentClass.includes('backdrop') || 
                     parentClass.includes('drawer') ||
                     parentClass.includes('curtain')) && 
                    !parentClass.includes('gdpr')) {
                  try {
                    console.log('�️ Removing overlay:', parentClass);
                    parent.remove();
                    break;
                  } catch (e) {}
                }
                parent = parent.parentElement;
                depth++;
              }
              
              // Force re-enable clicks on document
              setTimeout(() => {
                document.body.style.removeProperty('pointer-events');
                document.documentElement.style.removeProperty('pointer-events');
                console.log('✅ Re-enabled clicks on page');
              }, 100);
              
              // Trigger subscription popup in Flutter
              if (window.FlutterSubscription) {
                window.FlutterSubscription.postMessage('showSubscription');
                console.log('📱 Triggered subscription popup');
              }
            }
          });
          
          if (!window.__popupBlocked) {
            window.open = function() {
              console.log('🚫 Blocked window.open');
              return null;
            };
            window.__popupBlocked = true;
          }
          
          if (foundNewModal) {
            console.log('✅ Modal dismissal attempted');
          }
        }
        
        // DO NOT inject CSS blocker - let modal appear so we can dismiss it properly
        // const style = document.createElement('style');
        // style.textContent = \`
        //   [data-testid="in-app-form"],
        //   .inAppForm,
        //   [class*="PaymentsModal"],
        //   [class*="drawer-critical-module__body"]:not([class*="transparent"]) {
        //     display: none !important;
        //     visibility: hidden !important;
        //     opacity: 0 !important;
        //     max-height: 0 !important;
        //     overflow: hidden !important;
        //     pointer-events: none !important;
        //   }
        // \`;
        // document.head.appendChild(style);
        console.log('🎨 CSS blocker DISABLED - letting modal appear first');
        
        console.log('🚀 Modal blocker started');
        closeModal();
        setInterval(closeModal, 100);
        
        const observer = new MutationObserver((mutations) => {
          const hasNewPaymentModal = mutations.some(m => 
            Array.from(m.addedNodes).some(node => {
              if (node.nodeType !== 1) return false;
              const className = String(node.className || '');
              return (
                node.dataset && node.dataset.testid === 'in-app-form' ||
                className.includes('inAppForm') ||
                className.includes('PaymentsModal') ||
                (className.includes('drawer-critical-module__body') && !className.includes('transparent'))
              );
            })
          );
          if (hasNewPaymentModal) {
            console.log('🔄 Payment modal added');
            closeModal();
          }
        });
        observer.observe(document.body, { childList: true, subtree: true });
      })();
    ''';
    
    _controller?.runJavaScript(script);
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
    if (_showMenu) {
      _menuAnimationController.forward();
    } else {
      _menuAnimationController.reverse();
    }
  }

  void _reloadPage() {
    _controller?.reload();
    _toggleMenu();
  }

  void _exitPage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_configLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          // if (_isLoading)
          //   Positioned.fill(
          //     child: ClipRect(
          //       child: BackdropFilter(
          //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          //         child: Container(
          //           color: Colors.black.withOpacity(0.35),
          //           child: Center(
          //             child: CircularProgressIndicator(
          //               color: Colors.white.withOpacity(0.8),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // Splash screen after loading
          if (_showSplash)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    _config.splashBackgroundImage,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    SizedBox(
                      height: 80,
                      child: ClipRRect(
                        child: Image.asset(
                          _config.splashLoadingTextImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.gamepad,
                              size: 80,
                              color: Colors.deepPurple,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Loading Icon with Progress Bar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Loading Icon
                        SizedBox(
                          width: 350,
                          child: ClipRRect(
                            child: Image.asset(
                              _config.splashLoadingEmptyImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.gamepad,
                                  size: 80,
                                  color: Colors.deepPurple,
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Loading Bar
                        Container(
                          width: _config.splashProgressBarWidth,
                          height: _config.splashProgressBarHeight,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0),
                            borderRadius: BorderRadius.circular(_config.splashProgressBarBorderRadius),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_config.splashProgressBarBorderRadius),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              value: _splashAnimationController.value,
                              valueColor: AlwaysStoppedAnimation<Color>(_config.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Menu overlay
          if (_showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ),
                ),
              ),
            ),
          // Menu dialog
          if (_showMenu)
            Center(
              child: FadeTransition(
                opacity: _menuAnimationController,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _menuAnimationController,
                    curve: Curves.easeOutBack,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuButton(
                          imagePath: _config.gameReloadButtonImage,
                          label: _config.gameReloadButtonLabel,
                          onTap: _reloadPage,
                        ),
                        const SizedBox(width: 15),
                        _buildMenuButton(
                          imagePath: _config.gameExitButtonImage,
                          label: _config.gameExitButtonLabel,
                          onTap: _exitPage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Ad countdown
          if (_showCountdown)
            _buildCountdownWidget(),
          // Draggable FAB
          Positioned(
            right: _fabPosition.dx,
            bottom: _fabPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _fabPosition = Offset(
                    (_fabPosition.dx - details.delta.dx)
                        .clamp(0, MediaQuery.of(context).size.width - 40),
                    (_fabPosition.dy - details.delta.dy)
                        .clamp(0, MediaQuery.of(context).size.height - 40),
                  );
                });
              },
              child: _buildFAB(),
            ),
          ),
          
          // Subscription Popup Overlay
          if (_showSubscriptionPopup)
            Positioned.fill(
              child: Stack(
                children: [
                  // Blurred background barrier
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeSubscriptionPopup,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Container(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Popup content
                  Center(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) {},
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Top Image Stack Section
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Main image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(0),
                                    child: Image.asset(
                                      _config.subscriptionBackgroundImage,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Play button
                                  Positioned(
                                    bottom: 20,
                                    child: GestureDetector(
                                      onTap: _handlePurchase,
                                      child: Image.asset(
                                        _config.subscriptionPriceTagImage,
                                        height: 45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Bottom Action Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _openExternalLink(
                                        label: _config.subscriptionPrivacyText,
                                        url: _config.subscriptionPrivacyUrl,
                                      );
                                    },
                                    child: Text(
                                      _config.subscriptionPrivacyText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),

                                  // Restore Purchase
                                  GestureDetector(
                                    onTap: _handleRestorePurchase,
                                    child: Text(
                                      'Restore Purchase',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      _openExternalLink(
                                        label: _config.subscriptionTermsText,
                                        url: _config.subscriptionTermsUrl,
                                      );
                                    },
                                    child: Text(
                                      _config.subscriptionTermsText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 150,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: _config.primaryColor, size: 24);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB({bool isDragging = false}) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => _fabAnimationController.forward(),
        onTapUp: (_) {
          _fabAnimationController.reverse();
          if (!isDragging) _toggleMenu();
        },
        onTapCancel: () => _fabAnimationController.reverse(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            _config.gameFabImage,
            width: 40,
            height: 40,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_config.primaryColor, _config.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _showMenu ? Icons.close : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    // Determine position based on config
    Widget countdownContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _config.accentColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ad_units, color: _config.accentColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Ad in $_countdown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    // Position based on config
    switch (_config.gameInterstitialCountdownPosition.toLowerCase()) {
      case 'topleft':
        return Positioned(
          top: 50,
          left: 16,
          child: countdownContent,
        );
      case 'topright':
        return Positioned(
          top: 50,
          right: 16,
          child: countdownContent,
        );
      case 'bottomleft':
        return Positioned(
          bottom: 80,
          left: 16,
          child: countdownContent,
        );
      case 'bottomright':
        return Positioned(
          bottom: 80,
          right: 16,
          child: countdownContent,
        );
      case 'center':
      case 'middle':
      default:
        return Center(
          child: countdownContent,
        );
    }
  }

  void _closeSubscriptionPopup() {
    setState(() {
      _showSubscriptionPopup = false;
    });
  }

  Future<void> _handlePurchase() async {
    try {
      final iapService = await IAPService.getInstance();

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    'Processing purchase...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      await iapService.purchaseSubscription(
        type: _config.subscriptionTypes.isNotEmpty 
            ? _config.subscriptionTypes.first 
            : 'weekly',
        onSuccess: () {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            _closeSubscriptionPopup();
            _showSuccessMessage(
                'Subscription activated! Enjoy ad-free experience.');
          }
        },
        onError: (error) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            _showErrorMessage(error);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorMessage('Failed to process purchase: $e');
      }
    }
  }

  Future<void> _handleRestorePurchase() async {
    try {
      final iapService = await IAPService.getInstance();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    'Restoring purchases...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      await iapService.restorePurchases(
        onSuccess: () {
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading dialog
          _closeSubscriptionPopup();
          _showSuccessMessage('Purchases restored! Enjoy ad-free experience.');
        },
        onError: (error) {
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading dialog
          _showErrorMessage(error);
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorMessage('Failed to restore purchases: $e');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openExternalLink({
    required String label,
    required String url,
  }) async {
    if (url.isEmpty) {
      _showErrorMessage('$label link not configured');
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showErrorMessage('Could not open $label');
      }
    }
  }
}
