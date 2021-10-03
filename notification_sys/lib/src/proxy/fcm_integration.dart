import 'dart:io' show File;

import 'package:googleapis/fcm/v1.dart' as fcm;
import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:notification_sys/src/helper/utils.dart';

mixin FCMIntegration {
  _dispatchSingleFCMMessage(
      String recipient, String title, String message) async {
    // Push payload template
    final Map<dynamic, dynamic> json = {
      "token": recipient,
      "notification": fcm.Notification(title: title, body: message).toJson(),
      "data": {"title": title, "body": message},
      "android": {"priority": "high"},
      "apns": {
        "payload": {
          "aps": {"contentAvailable": true}
        }
      },
      "content-available": "true"
    };

    // Handler to run under a context
    final handler = (cli) async {
      final envData = Utils.readEnvData();
      var message = fcm.Message.fromJson(json);
      var sendMessageRequest = fcm.SendMessageRequest(message: message);
      var instance = fcm.FirebaseCloudMessagingApi(cli);
      await instance.projects.messages
          .send(sendMessageRequest, envData['firebase_project_name']);
    };

    // Execute under a context
    try {
      await _executeFunctionWithContext(handler, 'firebase_sa_key_filename');
    } catch (e) {
      Utils.log('ERROR: ${e}');
      throw e;
    }
  }

  dispatchFCMMessage(
      List<String> recipients, String title, String message) async {
    for (var recipient in recipients) {
      _dispatchSingleFCMMessage(recipient, title, message);
    }
  }

  _executeFunctionWithContext(Function handler, String key) async {
    final envData = Utils.readEnvData();
    final saKeyJson = File(envData[key]).readAsStringSync();
    final saCredentials = gauth.ServiceAccountCredentials.fromJson(saKeyJson);
    final scopes = [fcm.FirebaseCloudMessagingApi.firebaseMessagingScope];

    var client = await gauth.clientViaServiceAccount(saCredentials, scopes);
    try {
      await handler(client);
    } finally {
      client.close();
    }
  }
}
