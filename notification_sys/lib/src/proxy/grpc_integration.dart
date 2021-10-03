import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';
import 'package:notification_sys/src/helper/utils.dart';

enum StubLocation { Local, Remote }

mixin GRPCIntegration {
  late final ClientChannel channel;

  SimpleMessageClient getStub(StubLocation stubLocation) {
    if (stubLocation == StubLocation.Local) {
      /// Local
      channel = ClientChannel(
        'localhost',
        port: 50050,
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()),
      );
      final stub = SimpleMessageClient(channel,
          options: CallOptions(timeout: Duration(seconds: 30)));
      return stub;
    } else if (stubLocation == StubLocation.Remote) {
      /// Remote
      /// Using the same server service account for simplicity)
      /// Check https://pub.dev/packages/googleapis_auth for better options
      final envData = Utils.readEnvData();
      channel = ClientChannel(envData['gcp_project_name']);
      final serviceAccountJson =
          File(envData['gcp_sa_key_filename']).readAsStringSync();
      final credentials = JwtServiceAccountAuthenticator(serviceAccountJson);
      final stub =
          SimpleMessageClient(channel, options: credentials.toCallOptions);
      return stub;
    } else {
      Utils.log('ERROR: Invalid Stub Location');
      throw Exception('Invalid Stub Location');
    }
  }

  closeChannel() async {
    await channel.shutdown();
  }
}
