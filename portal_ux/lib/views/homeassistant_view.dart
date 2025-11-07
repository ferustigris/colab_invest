import 'package:flutter/material.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/widgets/auth_gate.dart';
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/widgets/common_navigation_bar.dart';
import 'package:portal_ux/widgets/ai_popup_chat.dart';
import 'package:portal_ux/widgets/tickets_table.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class HomeAssistantView extends StatelessWidget {
  static const homePage = "home";
  static const videoGalleryPage = "videoGallery";

  const HomeAssistantView({
    super.key,
    required this.page, // = HomeAssistantView.homePage
  });

  final String page;

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      page:
          isMobileViewPort(context)
              ? HomeAssistantScreen(page: page)
              : Stack(
                children: [HomeAssistantScreen(page: page), AIPopUpChat()],
              ),
    );
  }
}

class HomeAssistantScreen extends StatefulWidget {
  const HomeAssistantScreen({
    super.key,
    this.page = HomeAssistantView.homePage,
  });

  final String page;

  @override
  State<HomeAssistantScreen> createState() => _HomeAssistantScreenState();
}

class _HomeAssistantScreenState extends State<HomeAssistantScreen> {
  @override
  Widget build(BuildContext context) {
    StateNotifiers.currentPage.value = widget.page;

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
