import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'home_screen.dart';
import '../services/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  double _progress = 0.0;
  late AppConfig _config;
  bool _configLoaded = false;
  bool _showDialogue = false;
  bool _typingComplete = false;
  String _displayedText = '';
  final String _fullText = 'Preparing your amazing adventure! Loading game assets, characters, and magical worlds just for you...';
  int _currentCharIndex = 0;
  Timer? _typingTimer;
  Timer? _loadingTimer;
  int duration = 5;
  late AnimationController _dialogueController;
  late Animation<Offset> _dialogueSlideAnimation;
  late Animation<double> _dialogueFadeAnimation;
  late AnimationController _progressFadeController;
  late Animation<double> _progressOpacityAnimation;
  late AnimationController _imageBlinkController;
  late Animation<double> _imageBlinkAnimation;
  late AnimationController _buttonClickController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _dialogueController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dialogueSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dialogueController,
      curve: Curves.easeOutBack,
    ));
    _dialogueFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogueController,
      curve: Curves.easeIn,
    ));
    
    _progressFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressFadeController,
      curve: Curves.easeOut,
    ));
    
    _imageBlinkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _imageBlinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _imageBlinkController,
      curve: Curves.easeInOut,
    ));
    
    _buttonClickController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_buttonClickController);
    
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    _config = await AppConfig.getInstance();
    setState(() {
      _configLoaded = true;
    });
    _startLoading();
  }

  void _startLoading() {
    // Update progress smoothly over 12 seconds
    final totalDuration = duration * 1000; // 12 seconds in milliseconds
    const updateInterval = 50; // Update every 50ms for smooth animation
    final increment = 1.0 / (totalDuration / updateInterval);
    
    _loadingTimer = Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress += increment;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          // Wait 1 second then hide progress bar
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _progressFadeController.forward();
            }
          });
          // Show dialogue and start typing animation
          _showDialogue = true;
          _dialogueController.forward();
          _startTypingAnimation();
        }
      });
    });
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_currentCharIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentCharIndex];
          _currentCharIndex++;
        });
      } else {
        timer.cancel();
        // Blink animation then show play button
        _imageBlinkController.forward().then((_) {
          setState(() {
            _typingComplete = true;
          });
          _imageBlinkController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _loadingTimer?.cancel();
    _dialogueController.dispose();
    _progressFadeController.dispose();
    _imageBlinkController.dispose();
    _buttonClickController.dispose();
    super.dispose();
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
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  _config.splashBackgroundImage,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Content
          Stack(
          children: [
            // Segmented Circular Progress Bar above dialogue
            Positioned(
              bottom: MediaQuery.of(context).size.width * 0.7 * (9 / 50) + 60, // Above dialogue
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Segmented progress bar
                      AnimatedBuilder(
                        animation: _progressOpacityAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _progressOpacityAnimation.value,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            painter: SegmentedCircularProgressPainter(
                              progress: _progress,
                              segmentCount: duration * 2,
                              // segmentColor: _config.primaryColor,
                              segmentColor: Color.fromARGB(255, 133, 66, 15),
                              backgroundColor: Color.fromARGB(255, 133, 66, 15).withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                      // Center image - grows with progress
                      Container(
                        width: 110 + (_progress * 8), // Grows from 110 to 150
                        height: 110 + (_progress * 8), // Grows from 110 to 150
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color.fromARGB(255, 133, 66, 15).withOpacity(0),
                                width: 0,
                              ),
                            ),
                          child: GestureDetector(
                            onTap: _typingComplete ? () {
                              _buttonClickController.forward().then((_) {
                                _buttonClickController.reset();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                );
                              });
                            } : null,
                            child: ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: AnimatedBuilder(
                              animation: _imageBlinkAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _imageBlinkAnimation.value,
                                  child: child,
                                );
                              },
                              child: ClipOval(
                                child: Image.asset(
                                  _typingComplete ? 'assets/pack/play.png' : 'assets/pack/appicon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.gamepad,
                                      size: 50,
                                      color: _config.primaryColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom - Dialogue Box with Typing Animation (only shown after progress completes)
            if (_showDialogue)
              SlideTransition(
                position: _dialogueSlideAnimation,
                child: FadeTransition(
                  opacity: _dialogueFadeAnimation,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7 * (9 / 50), // 50:9 aspect ratio
                      margin: const EdgeInsets.only(bottom: 30, top: 0, left: 20, right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/pack/dialogue.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon(
                          //   Icons.chat_bubble_outline,
                          //   color: Colors.white,
                          //   size: 24,
                          // ),
                          // const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _displayedText,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 133, 66, 15),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.7,
                                fontFamily: 'Comic Sans MS',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Blinking cursor
                          // if (_currentCharIndex < _fullText.length)
                          //   Container(
                          //     width: 2,
                          //     height: 20,
                          //     color: Color.fromARGB(88, 133, 66, 15),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for segmented circular progress indicator
class SegmentedCircularProgressPainter extends CustomPainter {
  final double progress;
  final int segmentCount;
  final Color segmentColor;
  final Color backgroundColor;

  SegmentedCircularProgressPainter({
    required this.progress,
    required this.segmentCount,
    required this.segmentColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final segmentAngle = (2 * 3.14159) / segmentCount;
    final gapAngle = segmentAngle * 0.4; // 40% gap between segments

    // Draw background segments
    for (int i = 0; i < segmentCount; i++) {
      final startAngle = i * segmentAngle - 3.14159 / 2;
      final sweepAngle = segmentAngle - gapAngle;

      final paint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw progress segments
    final filledSegments = (progress * segmentCount).floor();
    final partialProgress = (progress * segmentCount) - filledSegments;

    for (int i = 0; i < filledSegments; i++) {
      final startAngle = i * segmentAngle - 3.14159 / 2;
      final sweepAngle = segmentAngle - gapAngle;

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw partial segment if needed
    if (partialProgress > 0 && filledSegments < segmentCount) {
      final startAngle = filledSegments * segmentAngle - 3.14159 / 2;
      final sweepAngle = (segmentAngle - gapAngle) * partialProgress;

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SegmentedCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
