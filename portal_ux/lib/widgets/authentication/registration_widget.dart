import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/common_acknowledge_widget.dart';
import 'package:portal_ux/utils/navigation_utils.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class RegistrationWidget extends StatefulWidget {
  const RegistrationWidget({super.key});

  @override
  State<RegistrationWidget> createState() => RegistrationWidgetState();
}

class RegistrationWidgetState<T extends RegistrationWidget> extends State<T> {
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  ValueNotifier<String> errorMessage = ValueNotifier("");
  
  bool success = false;

  @override
  initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    
    return success
    ? CommonAcknowledgeWidget(
        ackButtonLabel: AppLocalizations.of(context)!.goToHomePageAckButtonLabel,
        ackCallback: () => redirectToMainPage(context)
      )
    : SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ...specialActionsBuilder(),
          ...inputsBuilder(),
          ValueListenableBuilder(
            valueListenable: errorMessage,
            builder: (context, message, child) {
              return Text(message,
                style: AppStyles.errorMessageTextStyle
              );
            }
          ),
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          ...actionsBuilder()
        ]
      )
    );
  }

  List<Widget> specialActionsBuilder() {
    return [];
  }

  List<Widget> inputsBuilder() {
    return [
      TextField(
        controller: emailFieldController,
        focusNode: emailFocusNode,
        onSubmitted: (value) => checkAndSubmit(),
        autofillHints: [AutofillHints.email],
        decoration: AppStyles.generalInputStyle.copyWith(
          hintText: "your@email.com",
          helperText: "email"
        ),
      ),
      SizedBox(height: AppStyles.verticalSeparatorHeight),
      TextField(
        controller: passwordFieldController,
        focusNode: passwordFocusNode,
        onSubmitted: (value) => checkAndSubmit(),
        decoration: AppStyles.generalInputStyle.copyWith(
          hintText: "********",
          helperText: AppLocalizations.of(context)!.passwordInputPlaceholder
        ),
        obscureText: true
      )
    ];
  }

  List<Widget> actionsBuilder() {
    return [
      ElevatedButton(
        onPressed: () {
          checkAndSubmit();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.registrationButtonLabel), 
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
            onPressed: () => redirectToMainPage(context),
            child: Text(
              AppLocalizations.of(context)!.cancelButtonLabel,
              style: AppStyles.subtleTextStyle
            )
          ),
        ],
      ),
    ];
  }

  void checkAndSubmit() {
    if (emailFieldController.text.isEmpty) {
      emailFocusNode.requestFocus();
      return;
    }
    if (passwordFieldController.text.isEmpty) {
      passwordFocusNode.requestFocus();
      return;
    }
    submit();
  }

  void submit() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailFieldController.text, password: passwordFieldController.text);
      FirebaseAuth.instance.signOut();
    }
    catch(e) {
      setState(() => errorMessage.value = e.toString());
      return;
    }

    setState( (){success = true;} );
  }

}