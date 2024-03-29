import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';
import 'package:notification_sys/src/helper/utils.dart';

mixin GRPCIntegration {
  late final ClientChannel channel;

  SimpleMessageClient getStub() {
    if (Utils.GCP_SERVER_LOCATION_FOR_CLIENT == 'LOCAL') {
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
    } else if (Utils.GCP_SERVER_LOCATION_FOR_CLIENT == 'REMOTE') {
      /// Remote
      final envData = Utils.readEnvData();
      channel = ClientChannel(envData[Utils.GCP_PROJECT_NAME]);
      final serviceAccountJson =
          File(envData[Utils.GCP_SA_FILE_FOR_CLIENT]).readAsStringSync();
      final credentials = JwtServiceAccountAuthenticator(serviceAccountJson);
      final stub =
          SimpleMessageClient(channel, options: credentials.toCallOptions);
      return stub;
    } else {
      Utils.log('Invalid DB_PARAMS');
      throw Exception('Invalid DB_PARAMS');
    }
  }

  closeChannel() async {
    await channel.shutdown();
  }
}
