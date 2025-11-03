class AppConstants {
  static const int minWidthNonMobileView = 1100;
  static const String userDeviceTokenName = 'device_id';
  static const String emptyTokenValue = '---NO---TOKEN--- >_< ---';
  static const String defaultStringMarker = '---default---';

  static final String cloudFunctionsBaseUrl =
      'https://europe-west1-colab-invest-helper.cloudfunctions.net';

  static const String googleAuthProviderClientId =
      '547898074704-14856nek3jdvln42cqujh5sj4os0kus7.apps.googleusercontent.com';

  static final String cloudUrlClientCamFunction =
      '$cloudFunctionsBaseUrl/client-cam';
  static final String cloudUrlDeviceRegistration =
      '$cloudFunctionsBaseUrl/set-user-device';
  static final String cloudUrlTickets = '$cloudFunctionsBaseUrl/tickets';
  static final String aiModelEndpointUrl = '$cloudFunctionsBaseUrl/ask-chat';

  static const Map<String, String> userManualUrlMap = {
    "en": "/assets/assets/documents/user_manual.en.pdf",
    "es": "/assets/assets/documents/user_manual.es.pdf",
  };
}
