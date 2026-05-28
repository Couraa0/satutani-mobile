import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/farmer_model.dart';

class FarmerCard extends StatelessWidget {
  final FarmerModel farmer;
  final VoidCallback? onTap;

  const FarmerCard({super.key, required this.farmer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: farmer.avatarUrl.isNotEmpty ? NetworkImage(farmer.avatarUrl) : null,
                  backgroundColor: AppColors.primaryLight,
                  child: farmer.avatarUrl.isEmpty
                      ? Text(farmer.name[0],
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${farmer.location}, ${farmer.province}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (farmer.isVerified)
                        Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 11, color: AppColors.info),
                            const SizedBox(width: 3),
                            const Text('Terverifikasi',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                    5,
                    (i) => Icon(
                          i < farmer.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 13,
                          color: AppColors.secondary,
                        )),
                const SizedBox(width: 4),
                Text(farmer.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Text(' (${farmer.reviewCount})',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(farmer.specialty,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
