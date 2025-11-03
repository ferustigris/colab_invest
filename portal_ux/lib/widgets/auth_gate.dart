import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/views/authentication/sign_in_page.dart';
import 'package:portal_ux/views/authentication/verify_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.page
  });

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInPage();
        } else {
          StateNotifiers.user.value = snapshot.data!;
          if (snapshot.data!.emailVerified) {
            return page;
          } else {
            return VerifyEmailPage();
          }

        }
      },
    );
  }
}
