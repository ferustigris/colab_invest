import 'package:flutter/material.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/views/tickets_view.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/widgets/user_menu.dart';
import 'package:portal_ux/widgets/theme_switch_action.dart';
import 'package:portal_ux/widgets/auth_gate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return AuthGate(page: _buildMainContent());
  }

  Widget _buildMainContent() {
    return ValueListenableBuilder<int>(
      valueListenable: StateNotifiers.commonNavigationIndex,
      builder: (context, selectedIndex, child) {
        Widget currentPage;

        switch (selectedIndex) {
          case 0:
            currentPage = TicketsView(category: 'default');
            break;
          case 1:
            currentPage = TicketsView(category: 'nyse');
            break;
          case 2:
            currentPage = TicketsView(category: 'euro');
            break;
          case 3:
            currentPage = TicketsView(category: 'crypto');
            break;
          case 4:
            currentPage = TicketsView(category: 'commodities');
            break;
          default:
            currentPage = TicketsView(category: 'default');
        }

        if (isMobileViewPort(context)) {
          return currentPage;
        } else {
          // Для десктопа показываем горизонтальную навигацию сверху
          return Scaffold(
            body: Column(
              children: [
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Логотип/название приложения
                      Text(
                        'Investment Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 32),
                      // Горизонтальная навигация
                      Expanded(
                        child: Row(
                          children: [
                            _buildNavButton(
                              context,
                              0,
                              Icons.trending_up,
                              'Stocks',
                            ),
                            _buildNavButton(
                              context,
                              1,
                              Icons.account_balance,
                              'ETFs',
                            ),
                            _buildNavButton(
                              context,
                              2,
                              Icons.monetization_on,
                              'Bonds',
                            ),
                            _buildNavButton(
                              context,
                              3,
                              Icons.currency_bitcoin,
                              'Crypto',
                            ),
                            _buildNavButton(
                              context,
                              4,
                              Icons.grain,
                              'Commodities',
                            ),
                          ],
                        ),
                      ),
                      // Действия справа (как в CommonAppBar)
                      UserMenu(),
                      ThemeSwitchAction(),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(child: currentPage),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = StateNotifiers.commonNavigationIndex.value == index;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            StateNotifiers.commonNavigationIndex.value = index;
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border:
                  isSelected
                      ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      )
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
