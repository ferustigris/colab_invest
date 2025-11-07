import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portal_ux/data/preference_names.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key});
  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  @override
  Widget build(BuildContext context) {
    String languageCode = StateNotifiers.appLocale.value.toLanguageTag();
    return SegmentedButton(
      segments:
          AppLocalizations.supportedLocales
              .map(
                (aLocale) => ButtonSegment<String>(
                  value: aLocale.toLanguageTag(),
                  label: Text(aLocale.toLanguageTag()),
                ),
              )
              .toList(),
      selected: {languageCode},
      onSelectionChanged: (Set<String> newSelection) async {
        setState(() {
          languageCode = newSelection.first;
        });
        StateNotifiers.appLocale.value = Locale(languageCode);
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        await preferences.setString(PreferenceNames.languageCode, languageCode);
      },
    );
  }
}
