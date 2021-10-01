import 'dart:io' show File;
import 'dart:convert' show json;

class Utils {
  static Map readEnvData() {
    final envJson = File('keys/env.json').readAsStringSync();
    var map = json.decode(envJson) as Map;
    return map;
  }
}
