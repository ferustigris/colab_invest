import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/authentication/registration_widget.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/views/authentication/auth_app_bar.dart';

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: AppLocalizations.of(context)!.userRegistrationPageTitle), 
      body: Center(child: RegistrationWidget())
    );
  }
}
