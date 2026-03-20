import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // Background Radial Blob Gradient (Variasi Splash Screen)
          Positioned.fill(
            child: Stack(
              children: [
                // Blob 1 - Kiri Atas: Hijau Solid Kuat
                Positioned(
                  top: -80,
                  left: -80,
                  child: _blob(380, const Color(0xFF2D7D46), 0.7),
                ),
                // Blob 2 - Kanan Bawah: Hijau Medium Terang
                Positioned(
                  bottom: -100,
                  right: -50,
                  child: _blob(320, const Color(0xFF4CAF50), 0.5),
                ),
                // Blob 3 - Tengah Kanan: Hijau Tua Leaf
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  right: -120,
                  child: _blob(300, const Color(0xFF1B5E20), 0.6),
                ),
                // Blob 4 - Kiri Bawah: Hijau Muda
                Positioned(
                  bottom: 50,
                  left: -50,
                  child: _blob(250, const Color(0xFF81C784), 0.4),
                ),
                // Blob 5 - Atas Tengah: Overlay naturalness
                Positioned(
                  top: 100,
                  right: 100,
                  child: _blob(200, const Color(0xFFA5D6A7), 0.35),
                ),
              ],
            ),
          ),
          // Floating produce decorations (top-left cluster)
          Positioned(
            top: 30,
            left: -20,
            child: _FloatingEmoji(emoji: '🫐', size: 70, delay: 0),
          ),
          Positioned(
            top: 80,
            left: 60,
            child: _FloatingEmoji(emoji: '🥑', size: 55, delay: 200),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: _FloatingEmoji(emoji: '🍓', size: 65, delay: 100),
          ),
          Positioned(
            top: 100,
            right: 60,
            child: _FloatingEmoji(emoji: '🥕', size: 50, delay: 300),
          ),
          Positioned(
            top: 170,
            left: 10,
            child: _FloatingEmoji(emoji: '🌿', size: 48, delay: 400),
          ),
          // Bottom cluster
          Positioned(
            bottom: 80,
            left: 20,
            child: _FloatingEmoji(emoji: '🍅', size: 58, delay: 150),
          ),
          Positioned(
            bottom: 140,
            left: 80,
            child: _FloatingEmoji(emoji: '🥦', size: 45, delay: 350),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: _FloatingEmoji(emoji: '🌽', size: 62, delay: 250),
          ),
          Positioned(
            bottom: 150,
            right: 70,
            child: _FloatingEmoji(emoji: '🍋', size: 50, delay: 450),
          ),
          // Center logo
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo container – glassmorphism style di atas gradient hijau
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌾', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SatuTani',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dari Kebun Langsung ke Mejamu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function untuk menggambar blob radial gradient
  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class _FloatingEmoji extends StatefulWidget {
  final String emoji;
  final double size;
  final int delay;

  const _FloatingEmoji({
    required this.emoji,
    required this.size,
    required this.delay,
  });

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Text(widget.emoji,
          style: TextStyle(fontSize: widget.size)),
    );
  }
}
