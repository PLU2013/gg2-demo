import 'package:flutter/material.dart';

class Commons {
  /// Returns a common appBar for the proyect
  static AppBar commonAppBar(
      {required bool backBtn, required context, backResult}) {
    Widget? backIcon;
    bool showBackBtn = true;

    if (backResult is String) {
      showBackBtn = backResult == 'notShowIcon' ? false : true;
    }

    if (backBtn) {
      backIcon = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, backResult);
          });
    }

    return AppBar(
      automaticallyImplyLeading: showBackBtn,
      leading: backIcon,
      title: const Text(
        '🍅GreenGrocery!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
