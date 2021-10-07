import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/helper/utils.dart';
import 'package:notification_sys/src/proxy/db_integration.dart';
import 'package:notification_sys/src/proxy/grpc_integration.dart';
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmClient with GRPCIntegration, DbIntegration {
  late ClientChannel channel;
  late SimpleMessageClient stub;

  Future<void> main(List<String> args) async {
    try {
      // Get stub
      var stub = getStub(StubLocation.Local);

      // Get data
      // var data = getData(DbLocation.Mock);

      // Log a device
      var device1 = Device();
      device1.userId = '<<USER_ID>>';
      device1.fcmId = '<<FCM_TOKEN_001>>';
      device1.platform = 'android';
      var logDevice1Response = await stub.logDevice(device1);
      print(logDevice1Response);

      var device2 = Device();
      device2.userId = '<<USER_ID>>';
      device2.fcmId = '<<FCM_TOKEN_002>>';
      device2.platform = 'ios';
      var logDevice2Response = await stub.logDevice(device2);
      print(logDevice2Response);

      // Send simple message
      var userId = '<<USER_ID>>';
      var message = Message();
      message.recipients.addAll([userId]);
      message.message = "Lorem ipsum dolor sit amet, ei hinc verear vel.";
      var sendMessageResponse = await stub.sendMessage(message);
      print(sendMessageResponse);

      // Log out device
      var token = Token();
      token.fcmId = '<<FCM_TOKEN_002>>';
      var logOutDeviceResponse = await stub.unregisterDevice(token);
      print(logOutDeviceResponse);

      //..
    } catch (e) {
      Utils.log('ERROR on Client: ${e}');
    } finally {
      await closeChannel();
    }
  }
}
