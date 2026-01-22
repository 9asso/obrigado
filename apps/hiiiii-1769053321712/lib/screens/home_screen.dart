import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_card.dart';
import 'game_webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.ibb.co/DfPVhYfZ/964464c06c635b477300d2a52927958d.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildGameCarousel()),
                  const SizedBox(height: 20),
                  _buildBottomBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // game logo + title
          Container(
            padding: const EdgeInsets.only(
              right: 12,
              left: 0,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.network(
                      'https://i.ibb.co/CKD9SX70/53717ee96eb61a6cc4d4b251f1061145.jpg',
                      width: 33,
                      height: 33,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Kids Games',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.only(
              right: 16,
              left: 4,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color.fromARGB(115, 255, 255, 255),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/cottage.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                // const SizedBox(width: 6),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.only(
              right: 16,
              left: 4,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color.fromARGB(115, 255, 255, 255),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/controller.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                // const SizedBox(width: 6),
                Text(
                  'Games',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.only(
              right: 16,
              left: 4,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color.fromARGB(115, 255, 255, 255),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/expensive.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                // const SizedBox(width: 6),
                Text(
                  'Points',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(
              right: 12,
              left: 0,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.25),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/recurring-appointment.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Refresh',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.only(
              right: 12,
              left: 0,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.25),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/settings.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.only(
              right: 12,
              left: 0,
              top: 0,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.25),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Image.network(
                    'https://img.icons8.com/stickers/100/password.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCarousel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card width and height based on screen dimensions
        double cardWidth = constraints.maxWidth * 0.7; // 70% of screen width
        double cardHeight =
            constraints.maxHeight * 0.65; // 85% of available height

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: sampleGames.length,
          separatorBuilder: (context, index) => const SizedBox(width: 20),
          itemBuilder: (context, index) {
            return _buildGameCard(sampleGames[index], cardWidth, cardHeight);
          },
        );
      },
    );
  }

  Widget _buildGameCard(GameCard game, double cardWidth, double cardHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GameWebViewScreen(gameUrl: game.gameUrl, gameTitle: game.title),
          ),
        );
      },
      child: IntrinsicWidth(
        child: Container(
          height: cardHeight,
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.only(top: 3, bottom: 3, left: 3, right: 3),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              255,
              255,
              255,
            ), // light purple background
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: const Color.fromARGB(159, 0, 0, 0),
              strokeWidth: 2,
              dashWidth: 5,
              dashSpace: 3,
              borderRadius: 25,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  // LEFT IMAGE (book/cover style)
                  Flexible(
                    flex: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            game.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // RIGHT TEXT CONTENT
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          game.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F3F4E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Stats
                        Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  'https://img.icons8.com/stickers/100/star.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Levels',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: const Color(0xFF6B6B80),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '5',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3F3F4E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Image.network(
                                  'https://img.icons8.com/stickers/100/expensive.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Points',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: const Color(0xFF6B6B80),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '723',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3F3F4E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Play Button
                        Container(
                          // Flexible(
                          //   flex: 4,
                          //   child: ConstrainedBox(
                          //     constraints: const BoxConstraints(
                          //       maxHeight: 100,
                          //     ),
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(25),
                          //       child: AspectRatio(
                          //         aspectRatio: 1 / 1,
                          //         child: Image.asset(
                          //           game.imageUrl,
                          //           fit: BoxFit.cover,
                          //           errorBuilder: (context, error, stackTrace) {
                          //             return Container(
                          //               color: Colors.grey[300],
                          //               child: const Icon(
                          //                 Icons.image_not_supported,
                          //                 size: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BalloonStringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw two strings
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.8, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        dashPath.addPath(extractPath, Offset.zero);
        distance = nextDistance + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}
