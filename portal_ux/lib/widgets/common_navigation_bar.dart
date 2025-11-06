import 'package:flutter/material.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
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
              icon: Icon(Icons.trending_up),
              label: 'Stocks',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance),
              label: 'ETFs',
            ),
            NavigationDestination(
              icon: Icon(Icons.monetization_on),
              label: 'Bonds',
            ),
            NavigationDestination(
              icon: Icon(Icons.currency_bitcoin),
              label: 'Crypto',
            ),
            NavigationDestination(
              icon: Icon(Icons.grain),
              label: 'Commodities',
            ),
            if (isMobileViewPort(context))
              NavigationDestination(
                icon: Icon(Icons.chat),
                label: AppLocalizations.of(context)!.aiAssistantNav,
              ),
          ],
          selectedIndex: navigationIndex,
          onDestinationSelected: (int value) {
            if (value != StateNotifiers.commonNavigationIndex.value) {
              // For AI chat use push, for others - update index
              bool isAIChat = isMobileViewPort(context) && value == 5;

              if (isAIChat) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AIChatPage()),
                );
              } else {
                StateNotifiers.commonNavigationIndex.value = value;
              }
            }
          },
        );
      },
    );
  }
}
