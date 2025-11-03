import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/common_acknowledge_widget.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:firebase_auth/firebase_auth.dart';


class VerifyEmailWidget extends StatefulWidget {
  const VerifyEmailWidget({super.key});

  @override
  State<VerifyEmailWidget> createState() => _VerifyEmailWidgetState();
}

class _VerifyEmailWidgetState extends State<VerifyEmailWidget> {
  bool success = false;
  ValueNotifier<String> errorMessage = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return success
    ? CommonAcknowledgeWidget(
        message: AppLocalizations.of(context)!.verificationEmailSentMessage,
        ackButtonLabel: AppLocalizations.of(context)!.userMenuItemLogOut,
        ackCallback: () => FirebaseAuth.instance.signOut()
      )
    : SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.emailVerificationCTA),
            SizedBox(height: AppStyles.verticalSeparatorHeight),
            ValueListenableBuilder(
              valueListenable: errorMessage,
              builder: (context, message, child) {
                return Text(message,
                  style: AppStyles.errorMessageTextStyle
                );
              }
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  StateNotifiers.user.value!.sendEmailVerification(); 
                } catch(e) {
                  setState((){errorMessage.value = e.toString();});
                  return;
                }
                  setState((){success = true;});
              },
              child: Text(AppLocalizations.of(context)!.verificationEmailSendButtonLabel)
            ),
          ],
        )
      );
  }
}