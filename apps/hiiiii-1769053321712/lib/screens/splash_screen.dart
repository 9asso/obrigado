import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../config/colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/09bc08a7d219dc4.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Playful pattern background
            ...List.generate(20, (index) {
              return Positioned(
                left: (index % 5) * 80.0,
                top: (index ~/ 5) * 150.0,
                child: Icon(
                  index % 2 == 0 ? Icons.star : Icons.circle,
                  color: Colors.white.withOpacity(0.1),
                  size: 40,
                ),
              );
            }),

            // Top clouds
            Positioned(top: 40, left: 20, child: _buildCloud(120, 60)),
            Positioned(top: 60, right: 40, child: _buildCloud(150, 70)),
            Positioned(top: 100, left: 150, child: _buildCloud(100, 50)),

            // Bottom clouds
            Positioned(bottom: 80, left: 40, child: _buildCloud(130, 65)),
            Positioned(bottom: 100, right: 20, child: _buildCloud(140, 70)),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App title with colorful letters
                  _buildColorfulTitle(),

                  const SizedBox(height: 60),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Container(
                            width: 250,
                            height: 30,
                            decoration: BoxDecoration(
                              color: darkBrown,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [brightYellow, brightOrange],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    width: 242 * _progressAnimation.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: brightOrange,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cloudWhite,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulTitle() {
    const String title = 'KIDS GAMES';
    final List<Color> colors = [
      brightGreen,
      brightYellow,
      brightPurple,
      brightOrange,
      brightTeal,
      brightGreen,
      brightYellow,
      brightPurple,
      brightOrange,
      brightTeal,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(title.length, (index) {
        if (title[index] == ' ') {
          return const SizedBox(width: 20);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            title[index],
            style: GoogleFonts.fredoka(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: colors[index],
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
                Shadow(
                  color: Colors.white,
                  offset: const Offset(-3, -3),
                  blurRadius: 0,
                ),
                Shadow(
                  color: Colors.white,
                  offset: const Offset(3, -3),
                  blurRadius: 0,
                ),
                Shadow(
                  color: Colors.white,
                  offset: const Offset(-3, 3),
                  blurRadius: 0,
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
