import 'package:flutter/material.dart';
import 'package:portal_ux/views/device_registration_view.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/widgets/language_toggle_button.dart';
import 'package:portal_ux/deployment_info.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(page: UserSettingsContent());
  }
}

class UserSettingsContent extends StatelessWidget {
  const UserSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppLocalizations.of(context)!.userSettingsPageTitle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              Row(
                children: [
                  Icon(Icons.build_circle),
                  SizedBox(width: AppStyles.horizontalSeparatorWidth),
                  Text(AppLocalizations.of(context)!.userSettingsLanguageLabel),
                  SizedBox(width: AppStyles.horizontalSeparatorWidth),
                  LanguageToggle(),
                ]
              ),
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              Row(
                children: [
                  Icon(Icons.build_circle),
                  SizedBox(width: AppStyles.horizontalSeparatorWidth),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceRegistrationView()
                        )
                      );
                    },
                    child:(Text (AppLocalizations.of(context)!.deviceRegistrationPageNavigationLabel)) 
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    deploymentInfo,
                    style: AppStyles.systemInfoTextStyle
                  ),
                ),
              )
            ]
          ),
        )
      )
    );
  }
}