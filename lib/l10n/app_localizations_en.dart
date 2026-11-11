// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J’Donuts';

  @override
  String get continueLabel => 'Continue';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get rewardsLabel => 'Rewards';

  @override
  String get homeLabel => 'Home';

  @override
  String get welcomeLabel => 'Welcome to the world of J’Donuts';

  @override
  String get exploreLabel => 'Let’s explore';

  @override
  String get onboardingHeadline => 'Round food for every mood';

  @override
  String get accountPrompt => 'Already have an account?';

  @override
  String get loginAction => 'Log In';

  @override
  String get onboardingLegalPrefix =>
      'By continuing, you acknowledge that you have read and agree to our ';

  @override
  String get legalAnd => ' and ';

  @override
  String get getStarted => 'LET’S GET STARTED';

  @override
  String get loginLink => 'Already have an account? Log in';

  @override
  String get googleLabel => 'Google';

  @override
  String get appleLabel => 'Apple';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get termsLabel => 'Terms of Use';

  @override
  String get privacyLabel => 'Privacy Policy';

  @override
  String get welcomeTitle => 'Welcome to the world of J’Donuts';

  @override
  String get exploreButton => 'LET’S EXPLORE';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get logoutLabel => 'Log out';

  @override
  String get phoneRegisterTitle => 'Enter your phone number';

  @override
  String get phoneLoginTitle => 'Log in';

  @override
  String get phoneDescription => 'We’ll send you a code to verify your number.';

  @override
  String get phoneInvalid => 'Enter a valid Myanmar mobile number.';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpDescription(Object phone) {
    return 'Enter the 6-digit code sent to +95 $phone';
  }

  @override
  String get otpInvalid => 'Enter all 6 digits.';

  @override
  String get otpIncorrect => 'That code is incorrect.';

  @override
  String get otpLocked =>
      'Too many attempts. Resend the code when the timer ends.';

  @override
  String get unknownNumber => 'This number is new. Register to continue.';

  @override
  String get registerInstead => 'Register with this number';

  @override
  String resendCountdown(Object minutes, Object seconds) {
    return 'Resend code in $minutes:$seconds';
  }

  @override
  String get resendPrompt => 'Didn’t receive a code?';

  @override
  String get resendButton => 'Resend code';

  @override
  String get demoCode => 'Demo verification code: 123456';

  @override
  String get nameTitle => 'What’s your name?';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name (optional)';

  @override
  String get firstNameRequired => 'First name is required.';

  @override
  String get invalidName => 'Use up to 50 letters and spaces.';

  @override
  String get birthTitle => 'What’s your date of birth?';

  @override
  String get legalAcknowledgement => 'By continuing, you agree to our';

  @override
  String get andLabel => 'and';

  @override
  String get ageRequirement => 'You must be 13 or older to join.';

  @override
  String get selectBirthDate => 'Select date of birth';

  @override
  String get birthMonthHint => 'Month';

  @override
  String get birthDayHint => 'Day';

  @override
  String get birthYearHint => 'Year';

  @override
  String get invalidBirthDate => 'Choose a real calendar date.';

  @override
  String get birthDateRequired => 'Choose your date of birth.';

  @override
  String get futureBirthDate => 'Date cannot be in the future.';

  @override
  String underage(Object age) {
    return 'You must be at least $age years old.';
  }

  @override
  String get homeLoadError => 'Couldn’t load your home';

  @override
  String get productUnavailable => 'Product unavailable';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get retryLabel => 'Retry';

  @override
  String get offlineNotice => 'You’re offline — showing saved items';

  @override
  String get comingSoon => 'This section is coming soon.';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get addedLabel => 'ADDED';

  @override
  String get whatsThis => 'What’s this?';

  @override
  String get totalPoints => 'Total points';

  @override
  String get eatMoreEarnMore => 'Eat more earn more';

  @override
  String get giftLabel => 'Gift';

  @override
  String get rewardsBadge => 'Rewards';

  @override
  String get silverTier => 'Silver';

  @override
  String get goldTier => 'Gold';

  @override
  String get platinumTier => 'Platinum';

  @override
  String get currentTier => 'You’re here now';

  @override
  String pointsRemaining(Object points) {
    return '$points pts Remaining to become Gold';
  }

  @override
  String get futureTier => 'You’ll be here soon';

  @override
  String get earnLabel => 'EARN';

  @override
  String earnPoints(Object points) {
    return '$points pts';
  }

  @override
  String get giftChallenge => 'Gift a treat to a friend';

  @override
  String notificationCount(Object count) {
    return '$count';
  }

  @override
  String shopsNear(Object count) {
    return 'There are $count J’Donut shops near you';
  }

  @override
  String socialPlaceholder(Object feature) {
    return '$feature is not connected in this demo.';
  }

  @override
  String get emptyProducts => 'No items yet';

  @override
  String get sectionUnavailable => 'This section couldn’t load.';

  @override
  String get newBadge => 'New';

  @override
  String get sectionsUnavailable => 'This section is temporarily unavailable.';

  @override
  String get offersLabel => 'Offer';

  @override
  String get orderLabel => 'Order';

  @override
  String get profileLabel => 'Profile';

  @override
  String get newShopLabel => 'New shop';

  @override
  String discountLabel(Object percent) {
    return '$percent% off';
  }

  @override
  String get phoneHint => 'Myanmar mobile number';

  @override
  String get otpResendInProgress => 'Sending a new code…';

  @override
  String get productCodeLabel => 'Product code';

  @override
  String cartTotal(Object action, Object total) {
    return '$action · $total';
  }

  @override
  String challengeCount(Object progress, Object target) {
    return '$progress/$target';
  }

  @override
  String tierProgress(Object tier) {
    return 'Progress to $tier';
  }

  @override
  String get rewardsTitle => 'J’ Donuts Rewards';

  @override
  String memberTierLabel(Object tier) {
    return '$tier member';
  }

  @override
  String homeGoldProgress(Object points) {
    return '$points points left to become Gold Member';
  }

  @override
  String get verifyButton => 'VERIFY';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get rewardsUnavailable => 'Rewards are unavailable';

  @override
  String get earnedLabel => 'EARNED';

  @override
  String pointsClaimed(Object points) {
    return 'Challenge reward claimed: $points points';
  }
}
