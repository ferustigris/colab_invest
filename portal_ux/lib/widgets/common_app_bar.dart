import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/user_menu.dart';
import 'package:portal_ux/widgets/theme_switch_action.dart';
import 'package:portal_ux/widgets/language_toggle_button.dart';
import 'package:portal_ux/widgets/action_navigation_button.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/views/tickets_view.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(AppStyles.preferredAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        // children: [
        //   Text("STV", style: TextStyle(overflow: TextOverflow.clip)),
        //   if (!isMobileViewPort(context)) ...desktopActionsList(context),
        // ],
      ),
      actions: [
        UserMenu(),
        ThemeSwitchAction(),
        if (!isMobileViewPort(context)) LanguageToggle(),
        SizedBox(width: AppStyles.horizontalSeparatorWidth),
      ],
    );
  }

  List<Widget> desktopActionsList(context) {
    return [
      SizedBox(width: AppStyles.horizontalSeparatorWidth),
      ActionNavigationButton(
        targetPage: TicketsView(),
        targetPageName: "tickets",
        icon: Icon(Icons.assignment),
        label: AppLocalizations.of(context)!.ticketsNav,
      ),
      SizedBox(width: AppStyles.horizontalSeparatorWidth),
    ];
  }
}
