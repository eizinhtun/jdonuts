import 'package:flutter/widgets.dart';

abstract final class Motion {
  static const quick = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 360);
  static const entrance = Duration(milliseconds: 720);
  static const carousel = Duration(seconds: 5);
  static const skeletonShimmer = Duration(milliseconds: 1300);
  static const artworkDrift = Duration(seconds: 5);
  static const shake = Duration(milliseconds: 420);
  static const rewardAttention = Duration(milliseconds: 850);
  static const navigationPillHeroTag = 'home-rewards-active-nav-pill';
  static const onboardingHeadlineDelay = Duration(milliseconds: 90);
  static const onboardingButtonDelay = Duration(milliseconds: 160);
  static const onboardingLinksDelay = Duration(milliseconds: 230);
  static const welcomeTileStagger = Duration(milliseconds: 70);
  static const welcomeTitleDelay = Duration(milliseconds: 140);
  static const welcomeButtonDelay = Duration(milliseconds: 220);
  static const homeBannerDelay = Duration(milliseconds: 70);
  static const homeSectionInitialDelay = Duration(milliseconds: 110);
  static const homeSectionStagger = Duration(milliseconds: 60);
  static const homeShopsDelay = Duration(milliseconds: 270);
  static const curve = Curves.easeOutCubic;
  static const softCurve = Curves.easeInOut;
  static const badgePopCurve = Interval(.1, .6, curve: Curves.elasticOut);
  static Duration duration(BuildContext context, Duration value) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;

  static Duration homeSectionDelay(int index) => Duration(
    milliseconds:
        homeSectionInitialDelay.inMilliseconds +
        index * homeSectionStagger.inMilliseconds,
  );
}
