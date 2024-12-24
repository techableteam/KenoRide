import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/mainpage.dart';
import 'package:localstorage/localstorage.dart';
import 'firebase_options.dart';
import 'package:kenorider_driver/views/splashpage.dart';
import 'package:kenorider_driver/view_models/driver_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:logger/logger.dart';
// import 'package:localstorage/localstorage.dart';

final logger = Logger();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.i("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();    
    if (Platform.isAndroid) {
    await Firebase.initializeApp(
      name: 'uber',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      name: 'uber',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  logger.i("User granted permission: ${settings.authorizationStatus}");
  final fcmToken = await messaging.getToken();
  await initLocalStorage();
  String? driverName = localStorage.getItem('driverName');
  logger.i("fcm=>$fcmToken");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverViewModel()),
        ChangeNotifierProvider(create: (_) => RequestViewModel()), // Add RequestModel
      ],
      child: MyApp(fcmToken: fcmToken,initialRoute: driverName != null ? '/userMain' : '/splash'),
    ),
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    logger.i('Got a message whilst in the foreground! ${message.data}');

      final driverViewModel = navigatorKey.currentContext!.read<DriverViewModel>();
      
      final requestModel = navigatorKey.currentContext!.read<RequestViewModel>();
      if(message.data.containsKey("decline")){
        GlobalVariables.flag = false;
      }
      if(GlobalVariables.flag == false && GlobalVariables.progress == 0){
        GlobalVariables.flag = true;
      requestModel.setData(message.data);
      if(message.data.containsKey("riderLat")){
        GlobalVariables.riderLat = double.parse(message.data['riderLat']);
      }
      if(message.data.containsKey("riderLng")){
        GlobalVariables.riderLng = double.parse(message.data['riderLng']);
      }
      if(message.data.containsKey("desLat")){
        if(message.data['desLat'] != null && message.data['desLat'].isNotEmpty){
          GlobalVariables.desLat = double.parse(message.data['desLat']);
        }
      }
      if(message.data.containsKey("desLng")){
        if(message.data['desLng'] != null && message.data['desLng'].isNotEmpty){
          GlobalVariables.desLat = double.parse(message.data['desLng']);
        }
      }
      driverViewModel.setFlag(true);
    }
      // logger.i("Firebase request Data : ${message.data}");
    if (message.notification != null) {
      logger.i('Message also contained a notification: ${message.notification}');
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String? fcmToken;
  final String initialRoute;
  const MyApp({super.key, this.fcmToken, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    if (fcmToken != null) {
      GlobalVariables.deviceToken = fcmToken;
    }
    return MaterialApp(
      initialRoute: initialRoute,
      navigatorKey: navigatorKey,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/userMain': (context) => const MainPage(), // Ensure this page is correctly implemented
      },// En/ Set HomePage as the initial screen
    );
  }
}