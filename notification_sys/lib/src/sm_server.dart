import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;
import 'package:notification_sys/src/helper/utils.dart';
import 'package:notification_sys/src/proxy/db_integration.dart';
import 'package:notification_sys/src/proxy/fcm_integration.dart';

import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmService extends SimpleMessageServiceBase
    with FCMIntegration, DbIntegration {
  @override
  Future<StandardResponse> logDevice(
      grpc.ServiceCall call, Device request) async {
    // Default message
    var status = 'Added ${request.fcmId} with credential';

    try {
      // Insert device to db
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
    var status = 'Sent this message: ${request.message}';

    try {
      // Send message
      var recipients = request.recipients;
      var title = request.message;
      var message = request.message;
      await dispatchFCMMessage(recipients, title, message);
    } catch (e) {
      status = e.toString();
    }

    // Send client response
    var response = StandardResponse();
    response.status = status;
    return response;
  }

  @override
  Future<StandardResponse> logOutDevice(
      grpc.ServiceCall call, Device request) async {
    var status = 'Device logged out ${request.fcmId}';

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
    Utils.log('ERROR: Server listening on port ${server.port}');
  }
}
