import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'J’Donuts'**
  String get appTitle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @rewardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsLabel;

  /// No description provided for @rewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get rewardLabel;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @welcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the world of J’Donuts'**
  String get welcomeLabel;

  /// No description provided for @exploreLabel.
  ///
  /// In en, this message translates to:
  /// **'Let’s explore'**
  String get exploreLabel;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Round food for every mood'**
  String get onboardingHeadline;

  /// No description provided for @accountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get accountPrompt;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginAction;

  /// No description provided for @onboardingLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you acknowledge that you have read and agree to our '**
  String get onboardingLegalPrefix;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalAnd;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'LET’S GET STARTED'**
  String get getStarted;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get loginLink;

  /// No description provided for @googleLabel.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleLabel;

  /// No description provided for @appleLabel.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get appleLabel;

  /// No description provided for @facebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebookLabel;

  /// No description provided for @termsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsLabel;

  /// No description provided for @privacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLabel;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the world of J’Donuts'**
  String get welcomeTitle;

  /// No description provided for @exploreButton.
  ///
  /// In en, this message translates to:
  /// **'LET’S EXPLORE'**
  String get exploreButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutLabel;

  /// No description provided for @phoneRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneRegisterTitle;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get phoneLoginTitle;

  /// No description provided for @phoneDescription.
  ///
  /// In en, this message translates to:
  /// **'We’ll send you a code to verify your number.'**
  String get phoneDescription;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Myanmar mobile number.'**
  String get phoneInvalid;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to +95 {phone}'**
  String otpDescription(Object phone);

  /// No description provided for @registerOtpDescription.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent 6 digit OTP to +95{phone}'**
  String registerOtpDescription(Object phone);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits.'**
  String get otpInvalid;

  /// No description provided for @otpIncorrect.
  ///
  /// In en, this message translates to:
  /// **'That code is incorrect.'**
  String get otpIncorrect;

  /// No description provided for @otpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Resend the code when the timer ends.'**
  String get otpLocked;

  /// No description provided for @unknownNumber.
  ///
  /// In en, this message translates to:
  /// **'This number is new. Register to continue.'**
  String get unknownNumber;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This number is already registered. Log in instead.'**
  String get alreadyRegistered;

  /// No description provided for @registerInstead.
  ///
  /// In en, this message translates to:
  /// **'Register with this number'**
  String get registerInstead;

  /// No description provided for @resendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {minutes}:{seconds}'**
  String resendCountdown(Object minutes, Object seconds);

  /// No description provided for @resendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive a code?'**
  String get resendPrompt;

  /// No description provided for @registerResendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the code?'**
  String get registerResendPrompt;

  /// No description provided for @resendCountdownPrefix.
  ///
  /// In en, this message translates to:
  /// **'resend in '**
  String get resendCountdownPrefix;

  /// No description provided for @resendCountdownSuffix.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get resendCountdownSuffix;

  /// No description provided for @resendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendButton;

  /// No description provided for @demoCode.
  ///
  /// In en, this message translates to:
  /// **'Demo verification code: 123456'**
  String get demoCode;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s your name?'**
  String get nameTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get firstNameRequired;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Use up to 50 letters and spaces.'**
  String get invalidName;

  /// No description provided for @birthTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s your date of birth?'**
  String get birthTitle;

  /// No description provided for @legalAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get legalAcknowledgement;

  /// No description provided for @andLabel.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andLabel;

  /// No description provided for @ageRequirement.
  ///
  /// In en, this message translates to:
  /// **'You must be 13 or older to join.'**
  String get ageRequirement;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectBirthDate;

  /// No description provided for @birthMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get birthMonthHint;

  /// No description provided for @birthDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get birthDayHint;

  /// No description provided for @birthYearHint.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get birthYearHint;

  /// No description provided for @invalidBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a real calendar date.'**
  String get invalidBirthDate;

  /// No description provided for @birthDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your date of birth.'**
  String get birthDateRequired;

  /// No description provided for @futureBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the future.'**
  String get futureBirthDate;

  /// No description provided for @underage.
  ///
  /// In en, this message translates to:
  /// **'You must be at least {age} years old.'**
  String underage(Object age);

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your home'**
  String get homeLoadError;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Product unavailable'**
  String get productUnavailable;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'You’re offline — showing saved items'**
  String get offlineNotice;

  /// No description provided for @internetStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Internet availability couldn’t be checked.'**
  String get internetStatusUnknown;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is coming soon.'**
  String get comingSoon;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addedLabel.
  ///
  /// In en, this message translates to:
  /// **'ADDED'**
  String get addedLabel;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @whatsThis.
  ///
  /// In en, this message translates to:
  /// **'What’s this?'**
  String get whatsThis;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// No description provided for @eatMoreEarnMore.
  ///
  /// In en, this message translates to:
  /// **'Eat more earn more'**
  String get eatMoreEarnMore;

  /// No description provided for @giftLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get giftLabel;

  /// No description provided for @rewardsBadge.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsBadge;

  /// No description provided for @silverTier.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silverTier;

  /// No description provided for @goldTier.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get goldTier;

  /// No description provided for @platinumTier.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get platinumTier;

  /// No description provided for @currentTier.
  ///
  /// In en, this message translates to:
  /// **'You’re here now'**
  String get currentTier;

  /// No description provided for @pointsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{points} pts Remaining to become Gold'**
  String pointsRemaining(Object points);

  /// No description provided for @futureTier.
  ///
  /// In en, this message translates to:
  /// **'You’ll be here soon'**
  String get futureTier;

  /// No description provided for @earnLabel.
  ///
  /// In en, this message translates to:
  /// **'EARN'**
  String get earnLabel;

  /// No description provided for @earnPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String earnPoints(Object points);

  /// No description provided for @giftChallenge.
  ///
  /// In en, this message translates to:
  /// **'Gift a treat to a friend'**
  String get giftChallenge;

  /// No description provided for @notificationCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String notificationCount(Object count);

  /// No description provided for @shopsNear.
  ///
  /// In en, this message translates to:
  /// **'There are {count} J’Donut shops near you. 😊'**
  String shopsNear(Object count);

  /// No description provided for @exploreNow.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE NOW'**
  String get exploreNow;

  /// No description provided for @orderOnline.
  ///
  /// In en, this message translates to:
  /// **'Order Online'**
  String get orderOnline;

  /// No description provided for @noNearbyShops.
  ///
  /// In en, this message translates to:
  /// **'No nearby shops found.'**
  String get noNearbyShops;

  /// No description provided for @shopRegion.
  ///
  /// In en, this message translates to:
  /// **'Yangon, Myanmar'**
  String get shopRegion;

  /// No description provided for @socialPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{feature} is not connected in this demo.'**
  String socialPlaceholder(Object feature);

  /// No description provided for @emptyProducts.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get emptyProducts;

  /// No description provided for @sectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section couldn’t load.'**
  String get sectionUnavailable;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @sectionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section is temporarily unavailable.'**
  String get sectionsUnavailable;

  /// No description provided for @offersLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offersLabel;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @newShopLabel.
  ///
  /// In en, this message translates to:
  /// **'New shop'**
  String get newShopLabel;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String discountLabel(Object percent);

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Myanmar mobile number'**
  String get phoneHint;

  /// No description provided for @otpResendInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending a new code…'**
  String get otpResendInProgress;

  /// No description provided for @productCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Product code'**
  String get productCodeLabel;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'{action} · {total}'**
  String cartTotal(Object action, Object total);

  /// No description provided for @challengeCount.
  ///
  /// In en, this message translates to:
  /// **'{progress}/{target}'**
  String challengeCount(Object progress, Object target);

  /// No description provided for @tierProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress to {tier}'**
  String tierProgress(Object tier);

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'J’ Donuts Rewards'**
  String get rewardsTitle;

  /// No description provided for @memberTierLabel.
  ///
  /// In en, this message translates to:
  /// **'{tier} member'**
  String memberTierLabel(Object tier);

  /// No description provided for @homeGoldProgress.
  ///
  /// In en, this message translates to:
  /// **'{points} points left to become Gold Member'**
  String homeGoldProgress(Object points);

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verifyButton;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @rewardsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rewards are unavailable'**
  String get rewardsUnavailable;

  /// No description provided for @rewardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges available yet.'**
  String get rewardsEmpty;

  /// No description provided for @tierCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tier completed'**
  String get tierCompleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
