import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/db_integration.dart';
import 'package:notification_sys/src/grpc_integration.dart';
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
      var user1 = User();
      user1.userId = 'USR_0001';
      device1.user = user1;
      device1.fcmid = "<<<TOKEN>>>";
      // device1.platform = 'android';
      var logDevice1Response = await stub.logDevice(device1);
      print(logDevice1Response);

      // // Log a device
      // var device1 = Device();
      // device1.fcmid = data.generateFCMToken();
      // var logDevice1Response = await stub.logDevice(device1);
      // print(logDevice1Response);

      // var device2 = Device();
      // device2.fcmid = data.generateFCMToken();
      // var logDevice2Response = await stub.logDevice(device2);
      // print(logDevice2Response);

      // // Send simple message
      // var message = Message();
      // message.recipients.addAll(data.generateRecipients());
      // message.message = "Hi there!";
      // var sendMessageResponse = await stub.sendMessage(message);
      // print(sendMessageResponse);

      // // Log out device
      // var logOutDeviceResponse = await stub.logOutDevice(device2);
      // print(logOutDeviceResponse);

      //..
    } catch (e) {
      print('ERROR on Client: ${e}');
    } finally {
      await closeChannel();
    }
  }
}
