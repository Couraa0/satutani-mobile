import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Monitor Pesanan')),
      body: const Center(
        child: Text('Order monitoring — Coming Soon', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
