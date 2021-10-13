import 'dart:convert';
import 'dart:io' show File;

import 'package:googleapis/fcm/v1.dart' as fcm;
import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:notification_sys/src/helper/utils.dart';

mixin FCMIntegration {
  _executeFunctionWithContext(Function handler) async {
    final envData = Utils.readEnvData();
    final saKeyJson =
        File(envData[Utils.FCM_SA_KEY_FILENAME]).readAsStringSync();
    final saCredentials = gauth.ServiceAccountCredentials.fromJson(saKeyJson);
    final scopes = [fcm.FirebaseCloudMessagingApi.firebaseMessagingScope];

    var client = await gauth.clientViaServiceAccount(saCredentials, scopes);
    try {
      await handler(client);
    } finally {
      client.close();
    }
  }

  _dispatchSingleFCMMessage(String fcmId, String title, String message) async {
    // Push payload template
    final Map<dynamic, dynamic> json = {
      "token": fcmId,
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
          .send(sendMessageRequest, envData[Utils.FCM_PROJECT_NAME]);
    };

    // Execute under a context
    await _executeFunctionWithContext(handler);
  }

  Future<List<InvalidFCMToken>> dispatchFCMMessage(
      List<String> fcmIds, String title, String message) async {
    bool hasApiRequestError = false;
    List<InvalidFCMToken> invalidFCMTokens = [];
    for (var fcmId in fcmIds) {
      try {
        // Send each message
        await _dispatchSingleFCMMessage(fcmId, title, message);
      } on fcm.DetailedApiRequestError catch (e) {
        // Cath all invalid tokens
        hasApiRequestError = true;
        var invalidFCMToken = InvalidFCMToken(e.toString(), fcmId);
        invalidFCMTokens.add(invalidFCMToken);
      } catch (e) {
        // Log not API errors
        Utils.log(e);
        throw e;
      }
    }
    if (hasApiRequestError) {
      // Log API request errors at once
      Utils.log(
          'Message NOT sent to these tokens:\n${jsonEncode(invalidFCMTokens)}');
    }
    return invalidFCMTokens;
  }
}

class InvalidFCMToken {
  String error;
  String fcmId;
  InvalidFCMToken(this.error, this.fcmId);
  Map toJson() => {'fcmId': fcmId, 'error': error};
}
