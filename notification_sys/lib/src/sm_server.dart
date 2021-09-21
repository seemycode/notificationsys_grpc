import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;
import 'package:notification_sys/src/generated/sm.pbgrpc.dart';

class SmService extends SimpleMessageServiceBase {
  @override
  Future<StandardResponse> logDevice(
      grpc.ServiceCall call, Device request) async {
    var response = StandardResponse();
    response.status = "Added ${request.fcmid}";
    return response;
  }

  @override
  Future<StandardResponse> sendMessage(
      grpc.ServiceCall call, Message request) async {
    var response = StandardResponse();
    response.status = "Send this message: ${request.message}";
    return response;
  }

  @override
  Future<StandardResponse> logOutDevice(
      grpc.ServiceCall call, Device request) async {
    var response = StandardResponse();
    response.status = "Device logged out ${request.fcmid}";
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
    print('SM Server listening on port ${server.port}');
  }
}
