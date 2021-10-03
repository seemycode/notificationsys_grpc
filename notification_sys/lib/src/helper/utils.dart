import 'dart:io' show File;
import 'dart:convert' show json;

class Utils {
  // Default variables. It can be {LOCAL, REMOTE}
  static const String DATABASE_LOCATION = "LOCAL";
  static const String ENDPOINT_LOCATION = "LOCAL";
  static const String LOGGER_LOCATION = "LOCAL";

  static Map readEnvData() {
    final envJson = File('keys/env.json').readAsStringSync();
    var map = json.decode(envJson) as Map;
    return map;
  }

  static log(dynamic message) {
    switch (LOGGER_LOCATION) {
      case "LOCAL":
        print('ERROR: ${message}');
        break;
      case "REMOTE":
        //TODO: log on stackdriver
        break;
      default:
        throw Exception('ERROR: method not implemented');
    }
  }
}
