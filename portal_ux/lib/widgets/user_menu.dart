import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/app_constants.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:portal_ux/views/user_settings_page.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/utils/navigation_utils.dart';
import 'package:portal_ux/views/client_camera_poc.dart';


class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.account_circle),
      iconColor: StateNotifiers.isLightMode.value ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorLight,
      itemBuilder: (context) => [
          PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                trailing: const Icon(Icons.close),
                onTap: () {Navigator.of(context).pop();}
              ),
            )
          ),
          PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text(StateNotifiers.user.value!.email!),
                // onTap: () {}
              ),
            )
          ),
          // PopupMenuItem(
          //   child: PointerInterceptor(
          //     child: ListTile(
          //       leading: const Icon(Icons.card_membership),
          //       title: const Text('Subscription: 183 days left'),
          //       onTap: () {print('pew!!');}
          //     ),
          //   )
          // ),
            PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.userMenuItemSettings),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return UserSettingsPage();
                      }
                    )
                  );
                }
              ),
            )
          ),
          PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.help),
                title: Text(AppLocalizations.of(context)!.userManualLabel),
                onTap: () {
                  openURL(url: AppConstants.userManualUrlMap[StateNotifiers.appLocale.value.languageCode]!);
                  Navigator.of(context).pop();
                }
              ),
            )
          ),
          if (testers.contains(StateNotifiers.user.value!.email!)) PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.construction),
                title: Text("Run my phone camera"),
                onTap: () async {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => CameraPoc()                      
                    )
                  );
                }
              ),
            )
          ),
          if (testers.contains(StateNotifiers.user.value!.email!)) PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.construction),
                title: Text("View my phone camera"),
                onTap: () async {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => CameraViewerWidget()                      
                    )
                  );
                }
              ),
            )
          ),
          PopupMenuItem(
            child: PointerInterceptor(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.userMenuItemLogOut),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                }
              ),
            )
          ),
        ]
    );
  }
}
