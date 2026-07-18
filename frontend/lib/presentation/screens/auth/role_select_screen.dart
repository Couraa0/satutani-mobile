import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              SizedBox(
                height: 80,
                child: Image.asset(
                  'assets/images/logo ijo gelap.png',
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.eco_rounded, size: 70, color: AppColors.primary),
                ),
              ).animate().scale(
                  duration: 450.ms,
                  begin: const Offset(0.7, 0.7),
                  curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              const Text(
                AppStrings.appName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const Text(
                AppStrings.selectRole,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              // Farmer Card
              _RoleCard(
                emoji: '🌾',
                title: AppStrings.roleFarmer,
                subtitle: AppStrings.roleFarmerSub,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/register', arguments: {'role': 'farmer'}),
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: -0.1, curve: Curves.easeOut),
              const SizedBox(height: 16),
              // Consumer Card
              _RoleCard(
                emoji: '🛒',
                title: AppStrings.roleConsumer,
                subtitle: AppStrings.roleConsSub,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, '/register', arguments: {'role': 'consumer'}),
              )
                  .animate(delay: 280.ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.1, curve: Curves.easeOut),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  'Sudah punya akun? Masuk',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _RoleCard({
    required this.emoji, required this.title, required this.subtitle,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
