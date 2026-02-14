import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Finish after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onFinish();
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
      backgroundColor: Colors.black, // Black background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Logo - Bigger
                CustomPaint(
                  size: const Size(280, 280),
                  painter: BrandLogoPainter(),
                ),
                const SizedBox(height: 10),
                // App Name - Archivo Black font, smaller, closer
                Text(
                  'Elevate',
                  style: GoogleFonts.archivoBlack(
                    fontSize: 42,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                // const SizedBox(height: 8),
                // const Text(
                //   'TRANSFORM YOUR FITNESS',
                //   style: TextStyle(
                //     fontSize: 11,
                //     color: Colors.white70,
                //     letterSpacing: 2.5,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final scale = size.width / 512;

    // Draw the four bars from the SVG
    // Left bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(153 * scale, 195 * scale, 45 * scale, 122 * scale),
        Radius.circular(15 * scale),
      ),
      paint,
    );

    // Left-center bar (taller)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(205 * scale, 155 * scale, 55 * scale, 202 * scale),
        Radius.circular(15 * scale),
      ),
      paint,
    );

    // Right-center bar (taller)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(275 * scale, 155 * scale, 55 * scale, 202 * scale),
        Radius.circular(15 * scale),
      ),
      paint,
    );

    // Right bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(337 * scale, 195 * scale, 45 * scale, 122 * scale),
        Radius.circular(15 * scale),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
