import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:portal_ux/views/tickets_view.dart';

void redirectToMainPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => TicketsView()),
  );
}

void openURL({required String url, bool newTab = true}) {
  final anchor = web.HTMLAnchorElement();
  if (newTab) {
    anchor.target = "_blank";
  }

  anchor.href = url;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
