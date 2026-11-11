import 'package:flutter/material.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/theme/tokens.dart';
import '../../../home/domain/models.dart';

const _memberHeader = Color(0xFFFFEEE0);
const _memberCard = Color(0xFFFFDDBF);

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
    child: SizedBox(
      height: 126,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: ColoredBox(color: _memberHeader)),
          Positioned(
            top: 7,
            right: -18,
            child: Transform.rotate(
              angle: -.42,
              child: Container(
                width: 168,
                height: 102,
                decoration: BoxDecoration(
                  color: _memberCard,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Color(0x12A85A37), blurRadius: 8),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF9D8C7D),
                  size: 42,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.avatarPink,
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: SeedImage(
                            assetName: member.image,
                            semanticsLabel: member.name,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.memberTierLabel(member.tier),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6D6965),
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _NotificationPill(count: member.notifications),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 260),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    context.l10n.homeGoldProgress(member.pointsToGold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF74716F),
                      fontSize: 9,
                      height: 1.1,
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

class _NotificationPill extends StatelessWidget {
  const _NotificationPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.notificationCount(count),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none, size: 17, color: Colors.white),
          const SizedBox(width: 4),
          Container(
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
