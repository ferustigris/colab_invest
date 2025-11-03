import 'package:flutter/material.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/views/authentication/auth_app_bar.dart';
import 'package:portal_ux/widgets/authentication/verify_email_widget.dart';

class VerifyEmailPage extends StatelessWidget {
  VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: AppLocalizations.of(context)!.emailVerificationCTA),
      body: Center(
        child: VerifyEmailWidget(),
      ),
    );
  }
}