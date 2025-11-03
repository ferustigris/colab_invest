import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portal_ux/data/preference_names.dart';
import 'package:portal_ux/data/state_notifiers.dart';

class ThemeSwitchAction extends StatelessWidget {
  const ThemeSwitchAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StateNotifiers.isLightMode,
      builder: (context, isLightMode, child) {
        return IconButton(
          onPressed: () async {
            StateNotifiers.isLightMode.value = !StateNotifiers.isLightMode.value;
            final SharedPreferences preferences = await SharedPreferences.getInstance();
            await preferences.setBool(PreferenceNames.isLightMode, StateNotifiers.isLightMode.value);
          },
          icon: Icon(isLightMode ? Icons.dark_mode : Icons.light_mode)
        );
      }
    );
  }
}