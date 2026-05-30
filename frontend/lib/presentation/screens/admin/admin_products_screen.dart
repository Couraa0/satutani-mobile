import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola Produk')),
      body: const Center(
        child: Text('Product management — Coming Soon', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
