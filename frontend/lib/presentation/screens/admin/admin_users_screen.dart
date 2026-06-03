import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola User')),
      body: const Center(
        child: Text('User list — Coming Soon', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
