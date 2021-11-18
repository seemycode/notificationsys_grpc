import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/generated/google/protobuf/empty.pb.dart';
import 'package:notification_sys/src/proxy/db_integration.dart';
import 'package:notification_sys/src/proxy/grpc_integration.dart';
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmClient with GRPCIntegration, DbIntegration {
  late ClientChannel channel;
  late SimpleMessageClient stub;

  Future<void> main(List<String> args) async {
    try {
      // Get stub
      var stub = getStub();

      // Get data
      // var data = getData(DbLocation.Mock);

      // Log a device
      // var device1 = Device();
      // device1.userId = 'RECIPIENT_001';
      // device1.fcmId = 'FCM_TOKEN';
      // device1.platform = 'android';
      // var logDevice1Response = await stub.logDevice(device1);
      // print(logDevice1Response);

      // Send simple message
      // var userId = 'RECIPIENT_001';
      // var message = Message();
      // message.recipients.addAll([userId]);
      // message.message = "Lorem ipsum dolor sit amet, ei hinc verear vel.";
      // message.senderId = 'SENDER_002';
      // var sendMessageResponse = await stub.sendMessage(message);
      // print(sendMessageResponse);

      // Log out device
      // var token = Token();
      // token.fcmId = 'FCM_TOKEN';
      // var logOutDeviceResponse = await stub.unregisterDevice(token);
      // print(logOutDeviceResponse);

      // Clean up staled FCM tokens
      // var cleanUpStaledRecordsResponse =
      //     await stub.cleanUpStaledRecords(Empty());
      // print(cleanUpStaledRecordsResponse);

      // Get all notification
      // var notificationUserId = UserId();
      // notificationUserId.id = 'RECIPIENT_001';
      // var listNotifications = await stub.listNotifications(notificationUserId);
      // print(listNotifications);

      // Mark a notification as read
      // var notificationId = NotificationId();
      // notificationId.id = '3';
      // var markNotificationAsRead =
      //     await stub.markNotificationAsRead(notificationId);
      // print(markNotificationAsRead);

      // Get unread notification count
      // var notificationUserId = UserId();
      // notificationUserId.id = 'RECIPIENT_001';
      // var counter = await stub.countUnreadNotificationCount(notificationUserId);
      // print(counter);

      // Delete a notification
      // var notificationId = NotificationId();
      // notificationId.id = '4';
      // var deleteNotification = await stub.deleteNotification(notificationId);
      // print(deleteNotification);

      //..
    } catch (e) {
      print(e);
    } finally {
      await closeChannel();
    }
  }
}
