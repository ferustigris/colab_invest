import 'package:flutter/material.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/common_navigation_bar.dart';
import 'package:portal_ux/widgets/ai_popup_chat.dart';
import 'package:portal_ux/widgets/tickets_table.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';

class TicketsView extends StatelessWidget {
  final String category;
  const TicketsView({super.key, this.category = 'stocks'});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page:
          isMobileViewPort(context)
              ? TicketsScreen(category: category)
              : Stack(
                children: [TicketsScreen(category: category), AIPopUpChat()],
              ),
    );
  }
}

class TicketsScreen extends StatefulWidget {
  final String category;
  const TicketsScreen({super.key, this.category = 'stocks'});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String get _pageTitle {
    switch (widget.category) {
      case 'default':
        return 'Stocks';
      case 'nyse':
        return 'ETFs';
      case 'euro':
        return 'Bonds';
      case 'crypto':
        return 'Crypto';
      case 'commodities':
        return 'Commodities';
      default:
        return 'Stocks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          isMobileViewPort(context) ? CommonAppBar(title: _pageTitle) : null,
      body: TicketsTable(category: widget.category),
      bottomNavigationBar:
          isMobileViewPort(context) ? CommonNavigationBar() : null,
    );
  }
}
