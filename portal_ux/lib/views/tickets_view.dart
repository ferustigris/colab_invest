import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/common_navigation_bar.dart';
import 'package:portal_ux/widgets/ai_popup_chat.dart';
import 'package:portal_ux/widgets/tickets_table.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class TicketsView extends StatelessWidget {
  const TicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page:
          isMobileViewPort(context)
              ? TicketsScreen()
              : Stack(children: [TicketsScreen(), AIPopUpChat()]),
    );
  }
}

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppLocalizations.of(context)!.ticketsPageTitle,
      ),
      body: const TicketsTable(),
      bottomNavigationBar:
          isMobileViewPort(context) ? CommonNavigationBar() : null,
    );
  }
}
