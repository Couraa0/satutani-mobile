import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a horizontal product card
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 80, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 130, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 100, color: Colors.white),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Colors.white),
                      const SizedBox(width: 6),
                      Container(height: 10, width: 70, color: Colors.white),
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

/// Shimmer skeleton for a horizontal farmer card
class FarmerCardShimmer extends StatelessWidget {
  const FarmerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, backgroundColor: Colors.white),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 14, width: 90, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 10, width: 70, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 10, width: 80, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-page shimmer list
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const LoadingShimmer(width: double.infinity, height: 160, borderRadius: 16),
            const SizedBox(height: 24),
            const LoadingShimmer(width: 140, height: 20, borderRadius: 6),
            const SizedBox(height: 12),
            const LoadingShimmer(width: double.infinity, height: 52, borderRadius: 12),
            const SizedBox(height: 8),
            const LoadingShimmer(width: double.infinity, height: 52, borderRadius: 12),
            const SizedBox(height: 24),
            const LoadingShimmer(width: 140, height: 20, borderRadius: 6),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: ProductCardShimmer(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
