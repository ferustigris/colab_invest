import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/widgets/theme_switch_action.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(AppStyles.preferredAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      title: Text(title, style: TextStyle(overflow: TextOverflow.ellipsis)),
      actions: [
        ThemeSwitchAction(),
        SizedBox(width: AppStyles.horizontalSeparatorWidth),
      ],
    );
  }
}
