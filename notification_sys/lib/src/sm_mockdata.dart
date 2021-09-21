import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:notification_sys/src/generated/sm.pb.dart';

class MockData {
  String _generateRandomString({int len = 100}) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  String generateFCMToken() {
    var bytes = utf8.encode(_generateRandomString());
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  List<Recipient> generateRecipients() {
    var recipients = List<Recipient>.generate(2, (i) {
      var r = Recipient();
      r.userId = _generateRandomString();
      return r;
    });
    return recipients;
  }
}
