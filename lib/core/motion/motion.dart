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
  static const rewardArtwork = Duration(milliseconds: 520);
  static const otpCountdownTick = Duration(seconds: 1);
  static const authStepTransition = Duration(milliseconds: 360);
  static const authProgressMorph = Duration(milliseconds: 360);
  static const authProgressCheckReveal = .78;
  static const buttonPressScale = .97;
  static const rewardAttentionPeakScale = 1.055;
  static const onboardingArtStagger = Duration(milliseconds: 85);
  static const onboardingHeroDelay = Duration(milliseconds: 255);
  static const onboardingArtDrift = 34.0;
  static const entranceDistance = 22.0;
  static const authStepSlideDistance = .055;
  static const rewardTierStagger = .32;
  static const rewardSilverTierStart = 0.0;
  static const rewardGoldTierStart = .16;
  static const rewardTierSlideDistance = 18.0;
  static const rewardChallengeStagger = .13;
  static const rewardChallengeMaxStagger = .65;
  static const rewardChallengeSlideDistance = 35.0;
  static const rewardTabSlideDistance = .06;
  static const otpShakeFullDistance = 10.0;
  static const otpShakeMediumDistance = 7.0;
  static const otpShakeSmallDistance = 5.0;
  static const rewardAttentionCurve = Curves.easeInOut;
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
  static const authStepCurve = Curves.easeInOutCubic;
  static const buttonCurve = Curves.easeOutCubic;
  static const rewardProgressCurve = Curves.easeOutCubic;
  static const badgePopCurve = Interval(.1, .6, curve: Curves.elasticOut);
  static Duration duration(BuildContext context, Duration value) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;

  static Duration homeSectionDelay(int index) => Duration(
    milliseconds:
        homeSectionInitialDelay.inMilliseconds +
        index * homeSectionStagger.inMilliseconds,
  );
}
