import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_constants.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';
import 'package:portal_ux/l10n/app_localizations.dart';

class CommonAcknowledgeWidget extends StatelessWidget {
  const CommonAcknowledgeWidget({
    super.key,
    this.message = AppConstants.defaultStringMarker,
    this.ackButtonLabel = AppConstants.defaultStringMarker,
    required this.ackCallback
  });
  
  final String message;
  final String ackButtonLabel;
  final Function ackCallback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isMobileViewPort(context) ? mobileViewMessage(context) : nonMobileViewMessage(context)
    );
  }

  Widget nonMobileViewMessage(context) {
    return Container(
      height: 300,
      color: Theme.of(context).primaryColorLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Image.asset(
              'assets/images/elf.png',
              fit: BoxFit.fitHeight
            ),
          ),
          SizedBox(width: AppStyles.horizontalSeparatorWidth),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              Flexible(
                child: Text(
                  message == AppConstants.defaultStringMarker
                  ? AppLocalizations.of(context)!.defaultActionSuccessAckMessage
                  : message,
                  style: AppStyles.successMessageTextStyle
                ),
              ),
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              Icon(Icons.south),
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              ElevatedButton(
                child: Text(
                  ackButtonLabel == AppConstants.defaultStringMarker
                  ? AppLocalizations.of(context)!.defaultActionSuccessAckButtonLabel
                  : ackButtonLabel,
                ), 
                onPressed: () => ackCallback()
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget mobileViewMessage(context) {
    return Container(
      padding: EdgeInsets.all(AppStyles.verticalSeparatorHeight),
      color: Theme.of(context).primaryColorLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message == AppConstants.defaultStringMarker
            ? AppLocalizations.of(context)!.defaultActionSuccessAckMessage
            : message,
            style: AppStyles.successMessageTextStyle
          ),
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          Icon(Icons.south),
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          ElevatedButton(
            child: Text(
              ackButtonLabel == AppConstants.defaultStringMarker
              ? AppLocalizations.of(context)!.defaultActionSuccessAckButtonLabel
              : ackButtonLabel,
            ), 
            onPressed: () => ackCallback()
          ),
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          FittedBox(
            child: Image.asset(
              'assets/images/elf.png',
              fit: BoxFit.fitHeight
            ),
          ),
        ],
      ),
    );
  }

}