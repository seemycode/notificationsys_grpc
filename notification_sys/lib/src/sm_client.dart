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
      device1.userId = '0001';
      device1.fcmId = '<<FCM_TOKEN>>';
      // device1.platform = 'android';
      var logDevice1Response = await stub.logDevice(device1);
      print(logDevice1Response);

      // Send simple message
      var recipient = '<<FCM_TOKEN>>';
      var message = Message();
      message.recipients.addAll([recipient]);
      message.message = "Hi there!";
      var sendMessageResponse = await stub.sendMessage(message);
      print(sendMessageResponse);

      // Log out device
      var logOutDeviceResponse = await stub.logOutDevice(device1);
      print(logOutDeviceResponse);

      //..
    } catch (e) {
      Utils.log('ERROR on Client: ${e}');
    } finally {
      await closeChannel();
    }
  }
}
