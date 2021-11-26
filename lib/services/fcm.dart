import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FCMNotification {
  GetStorage getStorage = GetStorage();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String?> updateDeviceToken() async {
    if (!getStorage.hasData('adminDeviceToken')) {
      String? token = await messaging.getToken();
      getStorage.write('adminDeviceToken', token);
      return token;
    } else {
      String? token = getStorage.read('adminDeviceToken');
      return token;
    }
  }

  Future<NotificationSettings> checkNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings;
  }

  Future<void> createNotification(
      String token, String title, String body) async {
    final data = await http.post(
        Uri.parse('https://womena.herokuapp.com/notification'),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode({"token": token, "body": body, "title": title}));
    print('Code : ${data.reasonPhrase}');
  }
}
