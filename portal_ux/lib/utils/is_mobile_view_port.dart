import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:portal_ux/data/app_constants.dart';

bool isMobileViewPort(context) {
  return (!kIsWeb || MediaQuery.of(context).size.width < AppConstants.minWidthNonMobileView);
}