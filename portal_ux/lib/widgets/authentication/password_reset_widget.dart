import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/common_acknowledge_widget.dart';
import 'package:portal_ux/utils/navigation_utils.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class PasswordResetWidget extends StatefulWidget {
  const PasswordResetWidget({super.key});

  @override
  State<PasswordResetWidget> createState() => PasswordResetWidgetState();
}

class PasswordResetWidgetState<T extends PasswordResetWidget> extends State<T> {
  final TextEditingController emailFieldController = TextEditingController();
  late FocusNode emailFocusNode;

  ValueNotifier<String> errorMessage = ValueNotifier("");
  
  bool success = false;

  @override
  initState() {
    super.initState();
    emailFocusNode = FocusNode();
  }

  @override
  dispose() {
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    
    return success
    ? CommonAcknowledgeWidget(
        message: AppLocalizations.of(context)!.passwordResetMailSentMessage, 
        ackButtonLabel: AppLocalizations.of(context)!.goToHomePageAckButtonLabel,
        ackCallback: () => redirectToMainPage(context)
      )
    : SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ...inputsBuilder(),
          SizedBox(
            height: AppStyles.verticalSeparatorHeight
          ),
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
            Text(AppLocalizations.of(context)!.resetPasswordButtonLabel),
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
    submit();
  }

  void submit() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailFieldController.text);
      FirebaseAuth.instance.signOut();
    }
    catch(e) {
      setState(() => errorMessage.value = e.toString());
      return;
    }

    setState( (){success = true;} );
  }

}