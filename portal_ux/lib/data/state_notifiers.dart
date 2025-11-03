import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:portal_ux/data/app_constants.dart';

class StateNotifiers {
  static ValueNotifier<bool> isLightMode = ValueNotifier(true);
  static ValueNotifier<int> commonNavigationIndex = ValueNotifier(0);

  static ValueNotifier<User?> user = ValueNotifier(null);

  static ValueNotifier<Locale> appLocale = ValueNotifier(Locale('en'));

  static ValueNotifier<UserDeviceTokenData> userDeviceTokenData = ValueNotifier(UserDeviceTokenData());

  static ValueNotifier<String> currentPage = ValueNotifier('/');

  static ValueNotifier<bool> showHACredentialsBanner = ValueNotifier(true);
}

class UserDeviceTokenData {
  UserDeviceTokenData({
    this.isRegistrationPending = false,
    this.isRegAckPending = false,
    this.token = AppConstants.emptyTokenValue
  });
  bool isRegistrationPending;
  bool isRegAckPending; // isRegistrationAcknowledgmentPending
  String token;

}