import 'dart:io' show File;
import 'dart:convert' show json;

class Utils {
  /// Database >> DB_PARAMS:
  ///   local_postgres_connection_json: connect to localhost
  ///   remote_postgres_connection_json: connect to public ip (insecure)
  static const String DB_PARAMS = 'remote_postgres_connection_json';

  /// FCM >> FCM_SA_KEY_FILENAME:
  ///   fcm_sa_key_filename_local: uses local sa file downloaded
  ///   fcm_sa_key_filename_remote: uses gcp file uploaded to a secret
  static const FCM_SA_KEY_FILENAME = 'fcm_sa_key_filename_remote';

  /// FCM
  static const FCM_PROJECT_NAME = 'fcm_project_name';

  /// GCP
  static const String GCP_PROJECT_NAME = 'gcp_project_name';

  /// GCP >> GCP_SERVER_LOCATION_FOR_CLIENT
  ///   LOCAL: grpc without sa
  ///   REMOTE: grpc with sa
  static const String GCP_SERVER_LOCATION_FOR_CLIENT = 'REMOTE';

  /// GCP >> indicates the sa json file to authenticate to the remote server from client app
  static const String GCP_SA_FILE_FOR_CLIENT = 'gcp_sa_key_filename';

  /// GCP >> where to read parameters from
  ///   LOCAL: local file env.json
  ///   CLOUD: mounted point
  static const String GCP_ENV_VAR_LOCATION = 'REMOTE';

  /// Logger >> LOGGER_LOCATION
  ///   LOCAL: print on local console
  ///   REMOTE: print on stackdriver
  static const String LOGGER_LOCATION = 'REMOTE';

  static Map readEnvData() {
    late String envJson;
    if (Utils.GCP_ENV_VAR_LOCATION == 'LOCAL') {
      envJson = File('keys/env.json').readAsStringSync();
    } else if (Utils.GCP_ENV_VAR_LOCATION == 'REMOTE') {
      envJson = File('/keys/notification_grpc_secret').readAsStringSync();
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
