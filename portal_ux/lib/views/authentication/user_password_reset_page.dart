import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/authentication/password_reset_widget.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/views/authentication/auth_app_bar.dart';

class UserPasswordResetPage extends StatelessWidget {
  const UserPasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: AppLocalizations.of(context)!.resetPasswordPageTitle), 
      body: Center(child: PasswordResetWidget())
    );
  }
}
