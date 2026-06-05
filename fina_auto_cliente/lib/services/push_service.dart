import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

class PushService {
  PushService({PushTokenService? tokenService})
      : _tokenService = tokenService ?? PushTokenService();

  final PushTokenService _tokenService;

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) {
      await _tokenService.salvarToken(token);
    }

    messaging.onTokenRefresh.listen(_tokenService.salvarToken);

    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('FCM foreground: ${msg.notification?.title}');
    });
  }
}
