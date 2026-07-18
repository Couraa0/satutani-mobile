import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      if (AuthService.isLoggedIn) {
        final role = await AuthService.resolveRole();
        if (!mounted) return;
        final route = role == 'farmer'
            ? '/farmer-home'
            : role == 'admin'
                ? '/admin-home'
                : '/';
        Navigator.pushReplacementNamed(context, route);
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryMid,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glow lembut untuk kedalaman
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.3,
              child: _glow(size.width * 0.9, Colors.white, 0.06),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              left: -size.width * 0.3,
              child: _glow(size.width, const Color(0xFF4ADE80), 0.10),
            ),
            // Pola daun samar
            Positioned(
              top: 60,
              left: 24,
              child: _leaf(0.10, 40, -0.4),
            ),
            Positioned(
              top: 140,
              right: 40,
              child: _leaf(0.08, 28, 0.6),
            ),
            Positioned(
              bottom: 160,
              right: 28,
              child: _leaf(0.10, 36, 0.3),
            ),
            Positioned(
              bottom: 220,
              left: 44,
              child: _leaf(0.07, 24, -0.7),
            ),

            // Konten tengah
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo di kartu kaca
                  Container(
                    width: 128,
                    height: 128,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5),
                    ),
                    child: Image.asset(
                      'assets/images/logo putih.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Text('🌾', style: TextStyle(fontSize: 52))),
                    ),
                  )
                      .animate()
                      .scale(
                          duration: 600.ms,
                          begin: const Offset(0.6, 0.6),
                          curve: Curves.easeOutBack)
                      .fadeIn(duration: 400.ms)
                      .then(delay: 400.ms)
                      .shimmer(
                          duration: 1200.ms,
                          color: Colors.white.withValues(alpha: 0.35)),
                  const SizedBox(height: 28),
                  const Text(
                    'SatuTani',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOut),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🌱 Dari Kebun Langsung ke Mejamu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  )
                      .animate(delay: 450.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.4, curve: Curves.easeOut),
                ],
              ),
            ),

            // Loading indicator bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Column(
                children: [
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menghubungkan petani & pembeli',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color, double opacity) {
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
        ),
      ),
    );
  }

  Widget _leaf(double opacity, double size, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.eco_rounded,
        size: size,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
