import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Navbar label
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get ticketsNav;

  /// title on the stocks page
  ///
  /// In en, this message translates to:
  /// **'Stock Analysis'**
  String get ticketsPageTitle;

  /// Navbar
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantNav;

  /// title on the app page
  ///
  /// In en, this message translates to:
  /// **'Ask me'**
  String get aiAssistantPageTitle;

  /// title on the app page
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettingsPageTitle;

  /// User menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get userMenuItemSettings;

  /// User menu item
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get userMenuItemLogOut;

  /// user settings item label
  ///
  /// In en, this message translates to:
  /// **'Select the language'**
  String get userSettingsLanguageLabel;

  /// message marker in the chat
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get aiAssistantChatUserMarker;

  /// chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type here, press `Enter` to send.'**
  String get aiAssistantChatInputPlaceholder;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get errorNoDataFound;

  /// Prompt to switch AI model language
  ///
  /// In en, this message translates to:
  /// **'Answer me in English.'**
  String get aiLanguagePrompt;

  /// Message of the gremlin on error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, not my fault!'**
  String get gremlinMessage;

  /// CTA appears when link with device id is followed by the user
  ///
  /// In en, this message translates to:
  /// **'Register your DVR device'**
  String get registerDeviceCTA;

  /// Success message of the user's DVR registration (linking)
  ///
  /// In en, this message translates to:
  /// **'Your device was successfully registered'**
  String get registerDeviceSuccessMessage;

  /// The title of the alert pop up with message on registration attempt result
  ///
  /// In en, this message translates to:
  /// **'Device Registration'**
  String get registerDeviceAlertTitle;

  /// A message to show for user to acknowledge an action success
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get defaultActionSuccessAckMessage;

  /// A label on an acknowledge button for user to acknowledge an action success
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get defaultActionSuccessAckButtonLabel;

  /// Label or placeholder for the device id input
  ///
  /// In en, this message translates to:
  /// **'Enter your device id'**
  String get deviceRegistrationInputCTA;

  /// Label for the device registration button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registrationButtonLabel;

  /// Label for the navigation to the device registration page
  ///
  /// In en, this message translates to:
  /// **'Link a device to my account'**
  String get deviceRegistrationPageNavigationLabel;

  /// Label for the button to acknowledge successful registration
  ///
  /// In en, this message translates to:
  /// **'Understood. Go to Home Page'**
  String get goToHomePageAckButtonLabel;

  /// general Welcome AppBar title
  ///
  /// In en, this message translates to:
  /// **'Investment Portal - Sign In'**
  String get generalWelcomeTitle;

  /// Password text input placeholder
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordInputPlaceholder;

  /// A message to show on successful password reset mail sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset mail sent. Check your email and follow the instructions'**
  String get passwordResetMailSentMessage;

  /// Reset password button label
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButtonLabel;

  /// Sign In by Google button label
  ///
  /// In en, this message translates to:
  /// **'Sign In by Google'**
  String get googleSignInButtonLabel;

  /// label of sign in by Email option CTA
  ///
  /// In en, this message translates to:
  /// **'or by Email'**
  String get emailSignInOptionEmailCTALabel;

  /// Reset password page title
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset password'**
  String get resetPasswordPageTitle;

  /// User registration page title
  ///
  /// In en, this message translates to:
  /// **'Enter your email and set the password'**
  String get userRegistrationPageTitle;

  /// Please verify your email CTA
  ///
  /// In en, this message translates to:
  /// **'Please verify your email'**
  String get emailVerificationCTA;

  /// Send the verification email button title
  ///
  /// In en, this message translates to:
  /// **'Send the verification email'**
  String get verificationEmailSendButtonLabel;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Sign In button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButtonLabel;

  /// User Manual label
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManualLabel;

  /// Dismiss label
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissLabel;

  /// Don't show again label
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgainLabel;

  /// Home Assistant Credentials label
  ///
  /// In en, this message translates to:
  /// **'Home Assistant Credentials\n\nUser: demo\nPassword: demo'**
  String get haCredentialsNotificationLabel;

  /// Verificarion email sent successfully
  ///
  /// In en, this message translates to:
  /// **'Verification email is sent, please check the instructions in your mailbox. \nIf there is no email in your inbox, please check the spam folder.'**
  String get verificationEmailSentMessage;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
