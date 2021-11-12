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
      var device1 = Device();
      device1.userId = '<USER_ID>';
      device1.fcmId = '<FCM_TOKEN>';
      device1.platform = 'android';
      var logDevice1Response = await stub.logDevice(device1);
      print(logDevice1Response);

      // Send simple message
      var userId = '<USER_ID>';
      var message = Message();
      message.recipients.addAll([userId]);
      message.message = "Lorem ipsum dolor sit amet, ei hinc verear vel.";
      var sendMessageResponse = await stub.sendMessage(message);
      print(sendMessageResponse);

      // Log out device
      var token = Token();
      token.fcmId = '<FCM_TOKEN>';
      var logOutDeviceResponse = await stub.unregisterDevice(token);
      print(logOutDeviceResponse);

      // Clean up staled FCM tokens
      var cleanUpStaledRecordsResponse =
          await stub.cleanUpStaledRecords(Empty());
      print(cleanUpStaledRecordsResponse);

      //..
    } catch (e) {
      print(e);
    } finally {
      await closeChannel();
    }
  }
}
