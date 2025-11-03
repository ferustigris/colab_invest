import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/preference_names.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

MaterialBanner haCredentialsBanner(BuildContext context) {
    return MaterialBanner(
            content: Text(AppLocalizations.of(context)!.haCredentialsNotificationLabel),
            padding: EdgeInsets.all(10),
            actions: <Widget>[
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: Text(AppLocalizations.of(context)!.dismissLabel), 
              ),
              FilledButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  StateNotifiers.showHACredentialsBanner.value = false;
                  final SharedPreferences preferences = await SharedPreferences.getInstance();
                  preferences.setBool(PreferenceNames.showHACredentialsBanner, StateNotifiers.showHACredentialsBanner.value);
                },
                child: Text(AppLocalizations.of(context)!.dontShowAgainLabel), 
              )
            ]

          );
  }