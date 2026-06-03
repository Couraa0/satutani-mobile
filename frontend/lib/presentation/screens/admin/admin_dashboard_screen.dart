import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/splash', (_) => false);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Analytics — Coming Soon', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
