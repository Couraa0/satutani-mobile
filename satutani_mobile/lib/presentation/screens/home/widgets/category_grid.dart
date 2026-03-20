import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CategoryGrid extends StatelessWidget {
  final VoidCallback? onViewAll;
  final Function(String)? onCategoryTap;

  const CategoryGrid({super.key, this.onViewAll, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'grain', 'label': 'Biji-bijian', 'icon': Icons.grass_rounded},
      {'id': 'vegetable', 'label': 'Sayuran', 'icon': Icons.eco_rounded},
      {'id': 'fruit', 'label': 'Buah-buahan', 'icon': Icons.apple_rounded},
      {'id': 'processed', 'label': 'Olahan', 'icon': Icons.restaurant_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Kategori Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text('Lihat Semua',
                        style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(2, (rowIdx) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowIdx < 1 ? 8 : 0),
              child: Row(
                children: List.generate(2, (colIdx) {
                  final cat = categories[rowIdx * 2 + colIdx];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: colIdx > 0 ? 8 : 0),
                      child: _CategoryItem(
                        id: cat['id'] as String,
                        label: cat['label'] as String,
                        icon: cat['icon'] as IconData,
                        onTap: onCategoryTap,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final Function(String)? onTap;

  const _CategoryItem({required this.id, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
