import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/theme_switch_action.dart';
import 'package:portal_ux/widgets/language_toggle_button.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/utils/navigation_utils.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/app_constants.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(AppStyles.preferredAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      title: Text(
        title,
        style: TextStyle(overflow: TextOverflow.ellipsis)
      ),
      actions: [
        TextButton(
          onPressed: () => openURL(url: AppConstants.userManualUrlMap[StateNotifiers.appLocale.value.languageCode]!),
          child: Text(AppLocalizations.of(context)!.userManualLabel)
        ),
        ThemeSwitchAction(),
        LanguageToggle(),
        SizedBox(
          width: AppStyles.horizontalSeparatorWidth
        ),
      ]
    );
  }

}
