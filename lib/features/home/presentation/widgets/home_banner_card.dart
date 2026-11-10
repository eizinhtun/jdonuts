import 'package:flutter/material.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';

import '../../../../core/theme/tokens.dart';
import '../../../home/domain/models.dart';

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key, required this.banner});
  final PromoBanner banner;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SeedImage(assetName: banner.image, fit: BoxFit.cover),
          Positioned(
            left: 24,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    banner.subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: 210,
                  child: Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
