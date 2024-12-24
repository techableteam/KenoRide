import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class FirebaseAuthentication {
  static Future<String?> generateToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    try {
      await messaging.deleteToken();
      await Future.delayed(Duration(seconds: 1));
      String? newToken = await messaging.getToken();
      if (newToken != null) {
        print("New FCM Token: $newToken");
      } else {
        print("Failed to generate new FCM token.");
      }
      return newToken;
    } catch (e) {
      print("Error regenerating FCM token: $e");
      return null;
    }
  }
}