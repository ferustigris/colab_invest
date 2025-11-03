import 'package:flutter/material.dart';
import 'package:portal_ux/data/state_notifiers.dart';

class ActionNavigationButton extends StatelessWidget {
  const ActionNavigationButton({
    super.key,
    required this.targetPage,
    required this.targetPageName, // to be compared with StateNotifiers.currentPage for render variants
    required this.icon, 
    required this.label
  });

  final Widget targetPage;
  final String targetPageName;
  final Icon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (Set states){
            return StateNotifiers.currentPage.value == targetPageName
            ? Theme.of(context).disabledColor
            : null;
          }
        )
      ),
      onPressed: (){
        if (StateNotifiers.currentPage.value != targetPageName) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return targetPage;
              }
            )
          );
        }
      },
      icon: icon,
      label: Text(label),
    );
  }
}