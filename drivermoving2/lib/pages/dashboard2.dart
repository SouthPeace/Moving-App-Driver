import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
Future<void> fire_stuff() async{
  // Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

//Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}



class dash2 extends StatefulWidget {
  @override
  _Dash2State createState() => _Dash2State();
}

class _Dash2State extends State<dash2> {

  int _counter = 0;

  void get_order_for_driver_response() async{
    String driverid = '124';
    try{
      //await Firebase.initializeApp();
      //final fcmToken = await FirebaseMessaging.instance.getToken();
      // print("token : "+fcmToken.toString());
      var url = "https://www.site.com/driver_order_gets";
      final response = await .post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'driverid': driverid,
        }),
      );
      print('respnse code:${response.statusCode}');
      if(response.statusCode == 200){
        var data = jsonDecode(response.body.toString());
        print("get driver set order for response:");
        print(data);
      }else if(response.statusCode == 202){
        var data = jsonDecode(response.body.toString());
        print("error in getting order id");
        print(data);
      }
    }catch(e){
      print(e.toString());
    }

  }



  @override
  void initState()  {

    fire_stuff();


    super.initState();
    //  om message app open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print("_counter");

        get_order_for_driver_response();

        print("_counter2");
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,

            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@drawable/ic_stat_justwater',
              ),
              iOS: IOSNotificationDetails(
                sound: 'default.wav',
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            )
        );
      }
    });
    //Message for Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new messageopen app event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() {
    setState(() {
      _counter++;
    });

    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $_counter",
        "This is an Flutter Push Notification",
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id, channel.name,
              importance: Importance.high,
              color: Colors.blue,
              playSound: true,
              icon: '@drawable/ic_stat_justwater'),
          iOS: IOSNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ));
  }

  @override



  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ElevatedButton.icon(
                onPressed: () {

                  //Navigator.pushNamed(context, '/location');
                },
                icon: Icon(Icons.edit_location),
                label: Text(
                    'Edit Location'
                )
            )
          ],
        ),
      ),
    );
  }
}
