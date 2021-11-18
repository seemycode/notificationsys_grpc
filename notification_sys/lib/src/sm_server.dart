import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart' as grpc;
import 'package:notification_sys/src/generated/google/protobuf/empty.pb.dart';
import 'package:notification_sys/src/proxy/db_integration.dart';
import 'package:notification_sys/src/proxy/fcm_integration.dart';

import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmService extends SimpleMessageServiceBase
    with FCMIntegration, DbIntegration {
  @override
  Future<StandardResponse> logDevice(
      grpc.ServiceCall call, Device request) async {
    // Default message
    var status =
        'Added or updated \x1B[36m${request.userId}\x1B[0m with \x1B[36m${request.fcmId}\x1B[0m  successfully';

    try {
      // Update or insert device to db
      await upsertDevice(request);
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<StandardResponse> sendMessage(
      grpc.ServiceCall call, Message request) async {
    // Default message
    var status =
        'Triggerd FCM successfully with this message: \x1B[33m${request.message}\x1B[0m';
    List<InvalidFCMToken> tokensToDelete = [];

    try {
      // Look up FCM tokens of each recipient
      var fcmIds = await lookUpFCMTokens(request.recipients);

      if (fcmIds.length == 0) {
        // No recipient tokens found
        status =
            'No recipient token has been found for none of recipients ${request.recipients}';
      } else {
        // Send message to all recipients
        var title = request.message;
        var message = request.message;
        tokensToDelete = await dispatchFCMMessage(fcmIds, title, message);

        // Record every each message as one notification
        await createNotification(request);
      }
    } catch (e) {
      status = e.toString();
    }

    // Delete invalid tokens
    if (tokensToDelete.length > 0) {
      var listOfTokens = tokensToDelete.map((e) => e.fcmId).toList();
      await cleanUpInvalidTokens(listOfTokens);
      status +=
          ' However, some invalid tokens were excluded from sending and wiped from db: ${jsonEncode(tokensToDelete)}';
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<StandardResponse> unregisterDevice(
      grpc.ServiceCall call, Token request) async {
    var status =
        'Device unregistered \x1B[36m${request.fcmId}\x1B[0m, if exists';

    try {
      // Delete device
      await deleteDevice(request);
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<StandardResponse> cleanUpStaledRecords(
      grpc.ServiceCall call, Empty request) async {
    var status = 'Staled FCM tokens has been cleaned up';

    try {
      // Delete devices
      await cleanUpFCMTokens();
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<Notifications> listNotifications(
      grpc.ServiceCall call, UserId request) async {
    var status =
        'Retrieved notifications successfully for \x1B[36m${request.id}\x1B[0m';
    var notifications = Notifications();

    try {
      // Get all notifications of a user
      notifications = await getAllNotificationFromSingleUser(request);
    } catch (e) {
      status = e.toString();
    }

    // Build client response
    var response = StandardResponse();
    response.status = status;

    // Wrap the response into the messages object
    notifications.response = response;
    return notifications;
  }

  @override
  Future<StandardResponse> markNotificationAsRead(
      grpc.ServiceCall call, NotificationId request) async {
    var status = 'Marked the notification \x1B[36m${request.id}\x1B[0m as read';

    try {
      // Mark a notification as read
      await markSingleNotificationAsRead(request);
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<UnreadNotification> countUnreadNotificationCount(
      grpc.ServiceCall call, UserId request) async {
    var status = 'Got unread notifications for \x1B[36m${request.id}\x1B[0m';
    var unreadNotification = UnreadNotification();

    try {
      // Get all notifications of a user
      unreadNotification = await countUnreadNotificationOfAUser(request);
    } catch (e) {
      status = e.toString();
    }

    // Build client response
    var response = StandardResponse();
    response.status = status;

    // Wrap the response into the messages object
    unreadNotification.response = response;
    return unreadNotification;
  }

  @override
  Future<StandardResponse> deleteNotification(
      grpc.ServiceCall call, NotificationId request) async {
    var status =
        'Notification \x1B[36m${request.id}\x1B[0m deleted successfully';

    try {
      // Delete a notification
      await deleteSingleNotification(request);
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }
}

class SmServer {
  Future<void> main(List<String> args) async {
    final server = grpc.Server(
      [SmService()],
      const <grpc.Interceptor>[],
      grpc.CodecRegistry(
        codecs: const [grpc.GzipCodec(), grpc.IdentityCodec()],
      ),
    );
    await server.serve(port: 50050);
    print('Server listening on port ${server.port}');
  }
}
