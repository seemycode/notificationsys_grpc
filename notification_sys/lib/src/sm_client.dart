import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/sm_mockdata.dart';
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmClient {
  late ClientChannel channel;
  late SimpleMessageClient stub;

  Map _readEnvData() {
    final envJson = File('keys/env.json').readAsStringSync();
    var map = json.decode(envJson) as Map;
    return map;
  }

  Future<void> main(List<String> args) async {
    var envData = _readEnvData();

    /// Local
    // var channel = ClientChannel(
    //   'localhost',
    //   port: 50050,
    //   options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    // );
    // final stub = SimpleMessageClient(channel,
    //     options: CallOptions(timeout: Duration(seconds: 30)));

    /// Remote
    final channel = ClientChannel(envData['gcp_project_name']);
    final serviceAccountJson =
        File(envData['gcp_sa_key_filename']).readAsStringSync();
    final credentials = JwtServiceAccountAuthenticator(serviceAccountJson);
    final stub =
        SimpleMessageClient(channel, options: credentials.toCallOptions);

    try {
      var mockData = MockData();

      // Log a device
      var device1 = Device();
      device1.fcmid = mockData.generateFCMToken();
      var logDevice1Response = await stub.logDevice(device1);
      print(logDevice1Response);

      var device2 = Device();
      device2.fcmid = mockData.generateFCMToken();
      var logDevice2Response = await stub.logDevice(device2);
      print(logDevice2Response);

      // Send simple message
      var message = Message();
      message.recipients.addAll(mockData.generateRecipients());
      message.message = "Hi there!";
      var sendMessageResponse = await stub.sendMessage(message);
      print(sendMessageResponse);

      // Log out device
      var logOutDeviceResponse = await stub.logOutDevice(device2);
      print(logOutDeviceResponse);

      //..
    } catch (e) {
      print('ERROR in SmClient: ${e}');
    }

    await channel.shutdown();
  }
}
