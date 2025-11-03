import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/ai_chat_widget.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/l10n/app_localizations.dart';


class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page: AIChatPageContent()
    );
  }
}

class AIChatPageContent extends StatelessWidget {
  const AIChatPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppLocalizations.of(context)!.aiAssistantPageTitle),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: AIChatWidget()
      )
    );
  }
}