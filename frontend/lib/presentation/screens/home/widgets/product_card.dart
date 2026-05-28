import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: product.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrls.first,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 110,
                            color: const Color(0xFFE8F5E0),
                            child: const Center(
                              child: Icon(Icons.image_outlined, color: AppColors.primaryLight, size: 32),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 110,
                            color: const Color(0xFFE8F5E0),
                            child: const Center(
                              child: Icon(Icons.eco, color: AppColors.primaryLight, size: 32),
                            ),
                          ),
                        )
                      : Container(
                          height: 110,
                          color: const Color(0xFFE8F5E0),
                          child: const Center(child: Icon(Icons.eco, color: AppColors.primaryLight, size: 32)),
                        ),
                ),
                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.isPreOrder
                          ? AppColors.preOrderPurple
                          : product.isAvailable
                              ? AppColors.successGreen
                              : AppColors.badgeRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.isPreOrder
                          ? AppStrings.preOrder
                          : product.isAvailable
                              ? AppStrings.available
                              : AppStrings.outOfStock,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // AI Price badge
                if (product.isAiPrice)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 9, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            AppStrings.aiPrice,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.starYellow, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${product.reviewCount})',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Price
                  Text(
                    '${CurrencyFormatter.format(product.price)} / ${product.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Farmer
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundImage: product.farmerAvatarUrl.isNotEmpty
                            ? NetworkImage(product.farmerAvatarUrl)
                            : null,
                        backgroundColor: AppColors.primaryLight,
                        child: product.farmerAvatarUrl.isEmpty
                            ? Text(
                                product.farmerName.isNotEmpty ? product.farmerName[0] : 'P',
                                style: const TextStyle(color: Colors.white, fontSize: 9),
                              )
                            : null,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          product.farmerName,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
