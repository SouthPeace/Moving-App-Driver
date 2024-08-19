
import 'package:flutter/material.dart';
import 'package:drivermoving2/pages/home.dart';
import 'package:drivermoving2/pages/login.dart';
import 'package:drivermoving2/pages/dashboard.dart';
import 'package:drivermoving2/pages/dashboard2.dart';
import 'package:drivermoving2/pages/dash3.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// void main() => runApp(MaterialApp(
//     initialRoute: '/login',
//     routes: {
//       '/home': (context) => Home(),
//       '/location': (context) => ChooseLocation(),
//       '/login': (context) => login2(),
//       '/dashboard': (context) => dash(),
//     }
// ));

//Global Initialization
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title// description
    importance: Importance.high,
    playSound: true);

// flutter local notification
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A Background message just showed up :  ${message.messageId}');
}


Future<void> main() async {
  // firebase App initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// // Firebase local notification plugin
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
// //Firebase messaging
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );


  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

  runApp(MaterialApp(
      initialRoute: '/login',
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => login2(),
        '/dashboard': (context) => dash(),
        // '/dashboard2': (context) => dash2(),
        '/ordertracking': (context) => OrderTrackingPage(),
      }
  ));
}