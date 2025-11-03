import 'package:flutter/material.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';

class CommonErrorWidget extends StatelessWidget {
  const CommonErrorWidget({
    super.key,
    this.message = ""
  });
  
  final String message;

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
              'assets/images/gremlin.png',
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
                  AppLocalizations.of(context)!.gremlinMessage,
                  style: AppStyles.gremlinMessageTextStyle
                ),
              ),
              Icon(
                Icons.error,
                color: Colors.red
              ),
              SizedBox(height: AppStyles.verticalSeparatorHeight),
              Flexible(
                child: Text(
                  message,
                  style: AppStyles.errorMessageTextStyle
                ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          Text(
            AppLocalizations.of(context)!.gremlinMessage,
            style: AppStyles.gremlinMessageTextStyle
          ),
          Icon(
            Icons.error,
            color: Colors.red
          ),
          Text(
            message,
          ),
          SizedBox(height: AppStyles.verticalSeparatorHeight),
          FittedBox(
            child: Image.asset(
              'assets/images/gremlin.png',
              fit: BoxFit.fitHeight
            ),
          ),
        ],
      ),
    );
  }

}