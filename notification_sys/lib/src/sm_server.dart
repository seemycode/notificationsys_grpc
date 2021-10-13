import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart' as grpc;
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
      }
    } catch (e) {
      status = e.toString();
    }

    // Delete invalid tokens
    if (tokensToDelete.length > 0) {
      var listOfTokens = tokensToDelete.map((e) => e.fcmId).toList();
      await cleanUpFCMTokens(listOfTokens);
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
