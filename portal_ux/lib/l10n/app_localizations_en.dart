// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ticketsNav => 'Tickets';

  @override
  String get ticketsPageTitle => 'Support Tickets';

  @override
  String get aiAssistantNav => 'AI Assistant';

  @override
  String get aiAssistantPageTitle => 'Ask me';

  @override
  String get userSettingsPageTitle => 'User Settings';

  @override
  String get userMenuItemSettings => 'Settings';

  @override
  String get userMenuItemLogOut => 'Log out';

  @override
  String get userSettingsLanguageLabel => 'Select the language';

  @override
  String get aiAssistantChatUserMarker => 'You';

  @override
  String get aiAssistantChatInputPlaceholder =>
      'Type here, press `Enter` to send.';

  @override
  String get errorNoDataFound => 'No data found';

  @override
  String get aiLanguagePrompt => 'Answer me in English.';

  @override
  String get gremlinMessage => 'Something went wrong, not my fault!';

  @override
  String get registerDeviceCTA => 'Register your DVR device';

  @override
  String get registerDeviceSuccessMessage =>
      'Your device was successfully registered';

  @override
  String get registerDeviceAlertTitle => 'Device Registration';

  @override
  String get defaultActionSuccessAckMessage => 'Success!';

  @override
  String get defaultActionSuccessAckButtonLabel => 'Understood';

  @override
  String get deviceRegistrationInputCTA => 'Enter your device id';

  @override
  String get registrationButtonLabel => 'Register';

  @override
  String get deviceRegistrationPageNavigationLabel =>
      'Link a device to my account';

  @override
  String get goToHomePageAckButtonLabel => 'Understood. Go to Home Page';

  @override
  String get generalWelcomeTitle => 'Welcome to Solvía Tech Vigilance!';

  @override
  String get passwordInputPlaceholder => 'Password';

  @override
  String get passwordResetMailSentMessage =>
      'Password reset mail sent. Check your email and follow the instructions';

  @override
  String get resetPasswordButtonLabel => 'Reset password';

  @override
  String get googleSignInButtonLabel => 'Sign In by Google';

  @override
  String get emailSignInOptionEmailCTALabel => 'or by Email';

  @override
  String get resetPasswordPageTitle => 'Enter your email to reset password';

  @override
  String get userRegistrationPageTitle =>
      'Enter your email and set the password';

  @override
  String get emailVerificationCTA => 'Please verify your email';

  @override
  String get verificationEmailSendButtonLabel => 'Send the verification email';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get signInButtonLabel => 'Sign In';

  @override
  String get userManualLabel => 'User Manual';

  @override
  String get dismissLabel => 'Dismiss';

  @override
  String get dontShowAgainLabel => 'Don\'t show again';

  @override
  String get haCredentialsNotificationLabel =>
      'Home Assistant Credentials\n\nUser: demo\nPassword: demo';

  @override
  String get verificationEmailSentMessage =>
      'Verification email is sent, please check the instructions in your mailbox. \nIf there is no email in your inbox, please check the spam folder.';
}
