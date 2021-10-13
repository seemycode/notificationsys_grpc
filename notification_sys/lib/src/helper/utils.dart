import 'dart:io' show File;
import 'dart:convert' show json;

class Utils {
  /// Database
  static const String DB_PARAMS = 'local_postgres_connection_json'; // Local
  // static const String DB_PARAMS = 'remote_postgres_connection_json'; // Remote

  /// FCM
  static const FCM_PROJECT_NAME = 'fcm_project_name';
  static const FCM_SA_KEY_FILENAME = 'fcm_sa_key_filename_local'; // Local
  // static const FCM_SA_KEY_FILENAME = 'fcm_sa_key_filename_remote'; // Remote

  /// GCP
  static const String GCP_ENV_VAR_LOCATION =
      'LOCAL'; // change to REMOTE when deplpying
  static const String GCP_SERVER_LOCATION_FOR_CLIENT = 'LOCAL';
  static const String GCP_PROJECT_NAME = 'gcp_project_name';
  static const String GCP_SA_KEY_FILENAME = 'gcp_sa_key_filename';

  /// Logger
  static const String LOGGER_LOCATION =
      'LOCAL'; // change to REMOTE when deploying

  static Map readEnvData() {
    late String envJson;
    if (Utils.GCP_ENV_VAR_LOCATION == 'LOCAL') {
      envJson = File('keys/env.json').readAsStringSync();
    } else if (Utils.GCP_ENV_VAR_LOCATION == 'REMOTE') {
      envJson = File('/keys/notification_sys_secret').readAsStringSync();
    }
    var map = json.decode(envJson) as Map;
    return map;
  }

  static log(dynamic message) {
    switch (LOGGER_LOCATION) {
      case 'LOCAL':
        print('ERROR: ${message}');
        break;
      case 'REMOTE':
        print('PNS: ${message}');
        break;
      default:
        throw Exception('ERROR: method not implemented');
    }
  }
}
