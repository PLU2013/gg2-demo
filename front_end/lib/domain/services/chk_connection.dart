import 'dart:io';

import 'package:flutter/foundation.dart';

class InternetConnection {
  ///Check internet connection
  Future<bool> check() async {
    try {
      final List<InternetAddress> res =
          await InternetAddress.lookup('www.google.com');
      return res.isNotEmpty ? true : false;
    } on SocketException catch (err) {
      if (kDebugMode) {
        print(err);
      }
      return false;
    }
  }
}
