import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LocalEnv {
  ///Local ENV info.
  static late final Map data;

  ///Load the lolcal enviroments.
  static Future<void> readData() async {
    data = jsonDecode(await rootBundle.loadString('local.env'));
  }
}
