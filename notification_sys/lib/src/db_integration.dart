import 'package:notification_sys/src/utils.dart';
import 'package:postgres/postgres.dart';

import 'generated/sm.pb.dart';

const String DB_ENV = 'local_postgres_connection_json'; // Local
// const String DB_ENV = 'remote_postgres_connection_json'; // Remote

mixin DbIntegration {
  insertDevice(Device device) async {
    // Handler that perform db change
    final handler = (PostgreSQLConnection conn) async {
      await conn.transaction((ctx) async {
        await ctx.query(
          " insert into client.user_device (user_id, fcm_token, platform) " +
              " values (@user_id, @fcm_token, @platform) ",
          substitutionValues: {
            'user_id': device.user.userId,
            'fcm_token': device.fcmid,
            'platform': 'android' //TODO: change proto
          },
        );
      });
    };

    // Execute under a context
    try {
      await _executeFunctionWithContext(handler, DB_ENV);
    } catch (e) {
      //TODO: log on stackdriver
      print('ERROR: ${e}');
      throw e;
    }
  }

  _executeFunctionWithContext(Function handler, String key) async {
    final envData = Utils.readEnvData();
    final connVars = envData[key];

    var connection = PostgreSQLConnection(
      connVars['host'].toString(),
      int.parse(connVars['port'].toString()),
      connVars['database'].toString(),
      username: connVars['username'].toString(),
      password: connVars['password'].toString(),
    );

    try {
      await connection.open();
      await handler(connection);
    } finally {
      await connection.close();
    }
  }
}

class UserDevice {
  UserDevice(
      {required this.id,
      required this.UserId,
      required this.fcmToken,
      required this.platform,
      required this.updatedAt});
  int id;
  String UserId;
  String fcmToken;
  String platform;
  String updatedAt;
}
