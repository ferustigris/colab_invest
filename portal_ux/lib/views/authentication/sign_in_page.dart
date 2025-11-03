import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/authentication/sign_in_widget.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/views/authentication/auth_app_bar.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: AppLocalizations.of(context)!.generalWelcomeTitle),
      body: Center(
        child: SignInWidget()
      ),
    );
  }
}