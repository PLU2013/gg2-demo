import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LocalEnv {
  static late final Map data;

  static Future<void> readData() async {
    data = jsonDecode(await rootBundle.loadString('local.env'));
  }
}
