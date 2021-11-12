import 'package:postgres/postgres.dart';
import 'package:notification_sys/src/generated/sm.pb.dart';
import 'package:notification_sys/src/helper/utils.dart';

mixin DbIntegration {
  upsertDevice(Device device) async {
    // Handler that perform db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Check device existance
        var result = await connection.query(
            "select count(*) from client_schema.user_device where fcm_token = @fcm_token",
            substitutionValues: {'fcm_token': device.fcmId});

        // Add or update device received
        if (result.last[0] == 0) {
          await connection.query(
            " insert into client_schema.user_device (user_id, fcm_token, platform) " +
                " values (@user_id, @fcm_token, @platform) ",
            substitutionValues: {
              'user_id': device.userId,
              'fcm_token': device.fcmId,
              'platform': device.platform
            },
          );
        } else {
          await connection.query(
            " update client_schema.user_device set user_id = @user_id, platform = @platform where fcm_token = @fcm_token ",
            substitutionValues: {
              'user_id': device.userId,
              'fcm_token': device.fcmId,
              'platform': device.platform
            },
          );
        }
      });
    };

    // Execute under a context
    try {
      await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  deleteDevice(Token token) async {
    // Handler that performs db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Delete device
        await connection.query(
            "delete from client_schema.user_device where fcm_token = @fcm_token",
            substitutionValues: {'fcm_token': token.fcmId});
      });
    };

    // Execute under a context
    try {
      await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  cleanUpInvalidTokens(List<String> tokensToDelete) async {
    // Clean up staled tokens in a list
    for (var fcmId in tokensToDelete) {
      print('Cleaning up token ${fcmId}');
      var token = Token(fcmId: fcmId);
      await deleteDevice(token);
    }
  }

  cleanUpFCMTokens() async {
    // Handler that performs db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Delete device
        await connection.query(
            "delete from client_schema.user_device where updated_at < now() - interval '60 days'");
      });
    };

    // Execute under a context
    try {
      await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  Future<List<String>> lookUpFCMTokens(List<String> userIds) async {
    // Handler that perform db change
    final handler = (PostgreSQLConnection conn) async {
      List<String> result = [];
      await conn.transaction((connection) async {
        // Get all recipient FCM tokens
        for (var userId in userIds) {
          PostgreSQLResult res = await connection.query(
              "select fcm_token from client_schema.user_device where user_id = @user_id",
              substitutionValues: {'user_id': userId});
          result.addAll(res.map((e) => e[0]));
        }
      });
      return result;
    };

    // Execute under a context
    try {
      return await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  _executeFunctionWithContext(Function handler) async {
    final envData = Utils.readEnvData();
    final connVars = envData[Utils.DB_PARAMS];

    var connection = PostgreSQLConnection(
      // "/cloudsql/notification-grpc:southamerica-east1:notification-grpc-db-instance",
      connVars['host'].toString(),
      int.parse(connVars['port'].toString()),
      connVars['database'].toString(),
      username: connVars['username'].toString(),
      password: connVars['password'].toString(),
      // isUnixSocket: true,
    );

    try {
      await connection.open();
      return await handler(connection);
    } finally {
      await connection.close();
    }
  }
}
