import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/authentication/registration_widget.dart';
import 'package:portal_ux/views/authentication/user_registration_page.dart';
import 'package:portal_ux/views/authentication/user_password_reset_page.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class SignInWidget extends RegistrationWidget {
  const SignInWidget({super.key});

  @override
  RegistrationWidgetState<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends RegistrationWidgetState<SignInWidget> {

  @override 
  List<Widget> specialActionsBuilder() {
    return [
      ElevatedButton(
        onPressed:() => googleSignIn(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_sign_in_logo.png',
              width:AppStyles.generalIconImageSize
            ),
            SizedBox(width: AppStyles.inButtonSeparatorWidth),
            Text(AppLocalizations.of(context)!.googleSignInButtonLabel), 
          ],
        )
      ),
      SizedBox(height: AppStyles.verticalSeparatorHeight),
      Divider(),
      SizedBox(height: AppStyles.verticalSeparatorHeight),
      Text(AppLocalizations.of(context)!.emailSignInOptionEmailCTALabel),
      SizedBox(height: AppStyles.verticalSeparatorHeight),
    ];
  }


  @override
  List<Widget> actionsBuilder() {
    return [
      ElevatedButton(
        onPressed: () {
          checkAndSubmit();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login),
            SizedBox(width: AppStyles.inButtonSeparatorWidth),
            Text(AppLocalizations.of(context)!.signInButtonLabel),
          ],
        )
      ),
      SizedBox(
        height: AppStyles.verticalSeparatorHeight
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPasswordResetPage()
                )
              );
            },
            child: Text(
              AppLocalizations.of(context)!.resetPasswordButtonLabel, 
              style: AppStyles.subtleTextStyle
            )
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserRegistrationPage()
                )
              );
            },
            child: Text(
              AppLocalizations.of(context)!.registrationButtonLabel,
              style: AppStyles.subtleTextStyle
            )
          ),
        ],
      ),
      SizedBox(height: AppStyles.verticalSeparatorHeight),
    ];
  }

  @override
  void submit() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailFieldController.text, password: passwordFieldController.text);
    }
    catch(e) {
      setState(() => errorMessage.value = e.toString());
    }
  }

  void googleSignIn() async {

    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.setCustomParameters({
      'prompt':'select_account'
    });
    await FirebaseAuth.instance.signInWithPopup(authProvider);
  }


}