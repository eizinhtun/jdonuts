import 'package:flutter/material.dart';
import 'package:jdonuts/core/network/network_reachability.dart';
import 'package:jdonuts/l10n/localization.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class HomeShops extends StatelessWidget {
  const HomeShops({super.key, required this.shops});

  final List<String> shops;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: AppSpace.sectionGap),
    padding: const EdgeInsets.all(AppSpace.sectionGap),
    color: AppColors.cyan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.shopsNear(shops.length),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        for (final shop in shops)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpace.sm),
            padding: const EdgeInsets.all(AppSpace.smPlus),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined),
                const SizedBox(width: AppSpace.cardGap),
                Expanded(child: Text(shop)),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
      ],
    ),
  );
}

class HomeOfflineNotice extends StatelessWidget {
  const HomeOfflineNotice({super.key, required this.status});

  final NetworkStatus status;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpace.sm),
    child: Text(
      status.internetReachability == InternetReachability.unknown
          ? context.l10n.internetStatusUnknown
          : context.l10n.offlineNotice,
      textAlign: TextAlign.center,
      style: AppTypography.caption,
    ),
  );
}

class HomeStateMessage extends StatelessWidget {
  const HomeStateMessage({
    super.key,
    required this.title,
    required this.onRetry,
  });
  final String title;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        TextButton(onPressed: onRetry, child: Text(context.l10n.retryLabel)),
      ],
    ),
  );
}
