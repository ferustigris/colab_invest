import 'package:flutter/material.dart';

class AppStyles {
  static const double preferredAppBarHeight = 56;
  static const double preferredVideoPlayerPlayButtonSize = 48;
  static const double horizontalSeparatorWidth = 32;
  static const double verticalSeparatorHeight = 32;
  static const double inButtonSeparatorWidth = 8;
  static const double generalIconImageSize = 32;
  static const Color preferredVideoPlayerPlayButtonColor = Colors.white;

  static const TextStyle aiUserTextStyle = TextStyle(
    fontWeight: FontWeight.bold
  );
  static const TextStyle aiAssistantTextStyle = TextStyle(
    fontWeight: FontWeight.normal
  );

  static const TextStyle gremlinMessageTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16 
  );

  static const TextStyle errorMessageTextStyle = TextStyle(
    fontWeight: FontWeight.normal,
    color: Colors.red
  );

  static const TextStyle successMessageTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16
  );

  static const TextStyle systemInfoTextStyle = TextStyle(
    fontSize: 6,
    color: Colors.white30
  );
  
  static const TextStyle subtleTextStyle = TextStyle(
    fontSize: 10,
  );

  static const InputDecoration generalInputStyle = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8))
    )
  );

}