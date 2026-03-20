import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/mock/orders_mock.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final double fontSize;
  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  Color get _bg {
    switch (status) {
      case OrderStatus.menunggu: return AppColors.statusMenungguBg;
      case OrderStatus.dikonfirmasi: return AppColors.statusDikonfirmasiBg;
      case OrderStatus.dipanen: return AppColors.statusDipanenBg;
      case OrderStatus.dikirim: return AppColors.statusDikirimBg;
      case OrderStatus.selesai: return AppColors.statusSelesaiBg;
      case OrderStatus.dibatalkan: return AppColors.statusDibatalkanBg;
    }
  }

  Color get _text {
    switch (status) {
      case OrderStatus.menunggu: return AppColors.statusMenungguText;
      case OrderStatus.dikonfirmasi: return AppColors.statusDikonfirmasiText;
      case OrderStatus.dipanen: return AppColors.statusDipanenText;
      case OrderStatus.dikirim: return AppColors.statusDikirimText;
      case OrderStatus.selesai: return AppColors.statusSelesaiText;
      case OrderStatus.dibatalkan: return AppColors.statusDibatalkanText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: _text, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    );
  }
}
