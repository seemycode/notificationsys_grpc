import 'package:notification_sys/src/generated/google/protobuf/timestamp.pb.dart'
    as ts;
import 'package:postgres/postgres.dart';
import 'package:notification_sys/src/generated/sm.pb.dart';
import 'package:notification_sys/src/helper/utils.dart';

mixin DbIntegration {
  Future<void> upsertDevice(Device device) async {
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

  Future<void> deleteDevice(Token token) async {
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

  Future<void> cleanUpInvalidTokens(List<String> tokensToDelete) async {
    // Clean up staled tokens in a list
    for (var fcmId in tokensToDelete) {
      print('Cleaning up token ${fcmId}');
      var token = Token(fcmId: fcmId);
      await deleteDevice(token);
    }
  }

  Future<void> cleanUpFCMTokens() async {
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

  // ===============================
  Future<Notifications> getAllNotificationFromSingleUser(UserId userId) async {
    // Handler that perform db change
    final handler = (PostgreSQLConnection conn) async {
      var notifications = Notifications();
      await conn.transaction(
        (connection) async {
          PostgreSQLResult res = await connection.query(
              " select id, title, message, sender_id, recipient_id, created_at, is_read, read_at from client_schema.notification where recipient_id = @user_id ",
              substitutionValues: {'user_id': userId.id});
          notifications.items.addAll(res.map((e) => NotificationItem(
                id: int.parse(e[0].toString()),
                title: e[1],
                message: e[2],
                senderId: e[3],
                recipientId: e[4],
                createdAt: ts.Timestamp.fromDateTime(e[5]),
                isRead: bool.fromEnvironment(e[6].toString().toLowerCase(),
                    defaultValue: false),
                readAt: e[7] != null ? ts.Timestamp.fromDateTime(e[7]) : null,
              )));
        },
      );
      return notifications;
    };

    // Execute under a context
    try {
      return await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  Future<void> markSingleNotificationAsRead(
      NotificationId notificationId) async {
    // Handler that performs db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Mark as read
        await connection.query(
            " update client_schema.notification set is_read = true where id = @id ",
            substitutionValues: {'id': notificationId.id});
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

  Future<UnreadNotification> countUnreadNotificationOfAUser(
      UserId userId) async {
    // Handler that performs db change
    final handler = (PostgreSQLConnection conn) async {
      var count = UnreadNotification();
      await conn.transaction(
        (connection) async {
          PostgreSQLResult res = await connection.query(
              " select count(id) as count from client_schema.notification where recipient_id = @recipient_id and is_read = false ",
              substitutionValues: {'recipient_id': userId.id});
          try {
            print(res[0].first);
            count.count = int.parse(res[0].first.toString());
          } on Exception catch (_) {
            count.count = 0;
          }
        },
      );
      return count;
    };

    // Execute under a context
    try {
      return await _executeFunctionWithContext(handler);
    } catch (e) {
      Utils.log(e);
      throw e;
    }
  }

  Future<void> deleteSingleNotification(NotificationId notificationId) async {
    // Handler that performs db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Delete device
        await connection.query(
            " delete from client_schema.notification where id = @id ",
            substitutionValues: {'id': notificationId.id});
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

  Future<void> createNotification(Message message) async {
    // Handler that perform db change
    final handler = (PostgreSQLConnection connection) async {
      await connection.transaction((connection) async {
        // Add or update device received
        for (var recipient in message.recipients) {
          await connection.query(
            " insert into client_schema.notification (title, message, sender_id, recipient_id, created_at, is_read) " +
                " values (@title, @message, @sender_id, @recipient_id, now(), false) ",
            substitutionValues: {
              'title': message.title,
              'message': message.message,
              'sender_id': message.senderId,
              'recipient_id': recipient
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
