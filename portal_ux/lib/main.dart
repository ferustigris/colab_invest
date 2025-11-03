import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portal_ux/utils/two_listenables.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/firebase_options.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/preference_names.dart';
import 'package:portal_ux/data/app_constants.dart';
import 'package:portal_ux/views/tickets_view.dart';
import 'package:portal_ux/views/device_registration_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Проверяем, не инициализирован ли Firebase уже
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Map<String, String> params = Uri.base.queryParameters;
  String token =
      params[AppConstants.userDeviceTokenName] ?? AppConstants.emptyTokenValue;

  StateNotifiers.userDeviceTokenData.value =
      (token == AppConstants.emptyTokenValue)
          ? UserDeviceTokenData()
          : UserDeviceTokenData(isRegistrationPending: true, token: token);

  if (StateNotifiers.userDeviceTokenData.value.isRegistrationPending) {
    final urlStrategy = PathUrlStrategy();
    final urlState = urlStrategy.getState();
    urlStrategy.replaceState(urlState, "", "/");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<bool, Locale>(
      valueListenable1: StateNotifiers.isLightMode,
      valueListenable2: StateNotifiers.appLocale,
      builder: (context, isLightMode, theAppLocale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Solvía Tech Vigilance Portal',
          locale: theAppLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: isLightMode ? Brightness.light : Brightness.dark,
            ),
          ),
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
    readLocalSettings();
  }

  void readLocalSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    StateNotifiers.isLightMode.value =
        preferences.getBool(PreferenceNames.isLightMode) ?? true;
    StateNotifiers.appLocale.value = Locale(
      preferences.getString(PreferenceNames.languageCode) ?? "en",
    );
    StateNotifiers.showHACredentialsBanner.value =
        preferences.getBool(PreferenceNames.showHACredentialsBanner) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return (StateNotifiers.userDeviceTokenData.value.isRegistrationPending ||
            StateNotifiers.userDeviceTokenData.value.isRegAckPending)
        ? DeviceRegistrationView()
        : TicketsView();
  }
}
