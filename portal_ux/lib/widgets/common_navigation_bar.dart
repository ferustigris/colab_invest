import 'package:flutter/material.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/views/tickets_view.dart';
import 'package:portal_ux/views/ai_chat_page.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class CommonNavigationBar extends StatelessWidget {
  const CommonNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StateNotifiers.commonNavigationIndex,
      builder: (context, navigationIndex, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.assignment),
              label: AppLocalizations.of(context)!.ticketsNav
            ),
            if (isMobileViewPort(context)) NavigationDestination(
              icon: Icon(Icons.chat),
              label: AppLocalizations.of(context)!.aiAssistantNav
            )
          ],
          selectedIndex: navigationIndex,
          onDestinationSelected: (int value) {
            if (value != StateNotifiers.commonNavigationIndex.value) {
              if (value != 1) { 
                StateNotifiers.commonNavigationIndex.value = value;
              }
              switch (value) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TicketsView();
                      }
                    )
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AIChatPage();
                      }
                    )
                  );
                  break;
              }
            }
          }
        );
      }
    );
  }
}
