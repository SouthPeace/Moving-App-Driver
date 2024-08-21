
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:drivermoving2/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


//=========================
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
//=========================


// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

class dash extends StatefulWidget {

  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<dash> {
  int _counter = 0;
  int _counter2 = 0;
  int _counter3 = 0;
  //===============================
  //location declerations
  GoogleMapController? mapController;

  var check_for_map = 0;

  String? _sessionToken;
  var uuid = Uuid();

  Set<Marker> _markers = {};

   LatLng pickuplocation = LatLng(37.33500926, -122.03272188);
   LatLng dropofflocation = LatLng(37.33429383, -122.06600055);

  List<Marker> _makers_s = [
    Marker(
      markerId: MarkerId("currentLocation3"),
    ),
  ];
  List<Marker> _makers_t = [
    Marker(
      markerId: MarkerId("currentLocation"),
    ),
    Marker(
      markerId: MarkerId("currentLocation2"),
    )
  ];

  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  LocationData? currentLocation;

  double distance_ = 0.0;
  double t_amount = 0.0;
  //===============================

  var driver_id ;

  Map<String, dynamic> data = {};
  Map<String, dynamic> from_pre_page_data = {};

  String _value = '';

  var user_name;
  var user_email;
  var user_details = 0;

  late IO.Socket socket;
  String user_order_socketio_id = '';
  int user_socketio_counter = 0;
  var icon_destination;
  var icon_source;
  var icon_current;

  Set<Polyline>_polyline={};

  // custom markers
  getIcons() async {

    var i_des = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5),
        "assets/Pin_destination.png");

    var i_src = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5),
        "assets/Pin_source.png");

    setState(() {
      icon_destination = i_des;
      icon_source = i_src;
    });


  }

  //get the access firebase device token
  void get_token() async{
    await Firebase.initializeApp();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("token:");
   // print(fcmToken);
    print( fcmToken.toString() );
  }
//===============================
  //location functions

  //===============================
  // set drivers firebase device access token to database
  void set_firebase_device_token(String driverid) async{
    try{
      await Firebase.initializeApp();
      final fcmToken = await FirebaseMessaging.instance.getToken();
  print("token : "+fcmToken.toString());
      print("driverid : "+driverid);
      var url = "https://www.site.com/driver_firebase_set";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'driverid': driverid,
          'device_token': fcmToken.toString(),
        }),
      );

      if(response.statusCode == 200){
        print("the token was set successfully");
      }
    }catch(e){
      print(e.toString());
    }
  }


  // location declerations


  // get the current location
  void getCurrentLocation () async {
    print("get current location function start");
    Location location_now = Location();

    var image = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/location.png"
    );

    location_now.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );

    location_now.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;
        print('response latitude runtype :');
       // print(currentLocation!.latitude!.runtimeType);
        getCurrentLocationAddress(
            currentLocation!.latitude!, currentLocation!.longitude!);

        // sourceLocation_lat = currentLocation!.latitude!;
        // sourceLocation_lng = currentLocation!.longitude!;

        //==========
        //transmit current location to user
        String hold_socketio = '';
        if(user_order_socketio_id == ''){
          multiple_routes();
          print("hitting the socket io emit if statement");
        }else{
          print("socket io emit, here is user socketio id: "+user_order_socketio_id);
          var coords = {
            "lat": currentLocation!.latitude!,
            "lng": currentLocation!.longitude!,
            "driverid": driver_id
          };
          var driver_id_ = {"driverid": driver_id};
          socket.emit("position-change",
            {
              "id": user_order_socketio_id,
              "message": jsonEncode(coords), // Message to be sent
            },
          );
          hold_socketio = user_order_socketio_id;
          setState(() {
            user_order_socketio_id=hold_socketio;
          });
        }


        _makers_s[0] =
            Marker(
              markerId: MarkerId("currentLocation"),
              icon: image,
              position: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
            );
        setState(() {
         // _markers = _makers_s.toSet();
        });
      },
    );

  }

  //=================
  //=================
  //get the gradient co ordinates

  // get the elevaation between two points
  getgradiant(List<String> allpoints, int sample_count, List<double> _distances2) async{
    print("inside get suggestion function");

    //String Testing = "https://maps.googleapis.com/maps/api/elevation/json?path=${allpoints.join('%7C')}&samples=${sample_count}&key=$google_api_key";

    String baseurl2 = 'https://maps.googleapis.com/maps/api/elevation/json';
    String request =
        '$baseurl2?path=${allpoints.join('%7C')}&samples=${sample_count+1}&key=$google_api_key&sessiontoken=$_sessionToken';


    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {

      var result = json.decode(response.body);
      print("print elevation here");
      print( result['results'].length );
      print( "DISTANCES:${_distances2.length}" );
      print(sample_count);

      //print/get gradient function
      for(var i = 0; i < result['results'].length-1; i++){
        // result['results'][i];
        // print("results::");
        // print(result['results'][i]);
        // print(result['results'][i+1]);
        // print("distance::${_distances2[i]}");

        double gradient = result['results'][i+1]['elevation']  - result['results'][i]['elevation'] / _distances2[i];

        List<LatLng> latlng = [];
        LatLng _new = LatLng(polylineCoordinates[i].latitude, polylineCoordinates[i].longitude);
        LatLng _news = LatLng(polylineCoordinates[i+1].latitude, polylineCoordinates[i+1].longitude);

        latlng.add(_new);
        latlng.add(_news);

        double slope = gradient / 10;

        print(" gradiant: ${gradient} ");
        print(" slope: ${slope} ");

        if(slope < 0){

          _polyline.add(Polyline(
            polylineId: PolylineId("there there$i"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.green,
            width: 6,
          ));

        }else if(slope <= 5){

          _polyline.add(Polyline(
            polylineId: PolylineId("there there$i"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: primaryColor,
            width: 6,
          ));

        }else if( slope > 5 && slope <= 9 ){

          _polyline.add(Polyline(
            polylineId: PolylineId("there there${i+i}"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.yellow,
            width: 6,
          ));

        }else if( slope > 9 && slope <= 30  ){

          _polyline.add(Polyline(
            polylineId: PolylineId("there there${i+i+i}"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.orange,
            width: 6,
          ));

        }else if( slope > 30 ){

          _polyline.add(Polyline(
            polylineId: PolylineId("there there${i+i+i+i}"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.red,
          ));

        }

      }


      setState((){ });

    } else {
      throw Exception('Failed to get elevstion');
    }
  }

  //=================

  //=================
  //get the multiple routes
  multiple_routes()async{

    //String tet = "https://maps.googleapis.com/maps/api/directions/" + output + "?" + parameters;

    String baseURL =
        'https://maps.googleapis.com/maps/api/geocode/json';
    // String request =
    //     '$baseURL?latlng=${lat},${lng}&key=$google_api_key&sessiontoken=$_sessionToken';
    // String tt = "https://www.google.com/maps/dir/"
    //     String gg = "?api=1&${}&destination=${}&travelmode=bicycling"

    String base1 = "https://maps.googleapis.com/maps/api/directions/json";
    String request2 = "$base1?origin=Disneyland&destination=Universal+Studios+Hollywood&key=$google_api_key&sessiontoken=$_sessionToken";
    var response = await http.get(Uri.parse(request2));

    if (response.statusCode == 200) {

      print("print directions result:");
      print( json.decode(response.body) );
      //Map<String, dynamic> data = json.decode(response.body);
      //print(data['results'][1]["formatted_address"]);

      //setState(() {
        //_placeList = json.decode(response.body)['predictions'];
        // checkedinputfinal = data['results'][1]["formatted_address"];
        // _controller1.text = data['results'][1]["formatted_address"];
     // });
    } else {
      throw Exception('Failed to load predictions');
    }

  }
  //=================

  void getCurrentLocationAddress(double lat,double lng) async{

    String kPLACES_API_KEY = google_api_key;

    String baseURL =
        'https://maps.googleapis.com/maps/api/geocode/json';
    String request =
        '$baseURL?latlng=${lat},${lng}&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {

      print("print geocode response:");
      //print( json.decode(response.body) );
      Map<String, dynamic> data = json.decode(response.body);
      //print(data['results'][1]["formatted_address"]);

      setState(() {
        //_placeList = json.decode(response.body)['predictions'];
       // checkedinputfinal = data['results'][1]["formatted_address"];
       // _controller1.text = data['results'][1]["formatted_address"];
      });
    } else {
      throw Exception('Failed to load predictions');
    }

  }

  Future<void> getPolyPoints(String s_lat,String s_lng,String d_lat ,String d_lng )async{
    print("polyine function start");
    //print("s_lat:${s_lat} ; ");
    double sourceLocation_lat = double.parse(s_lat);
    double sourceLocation_lng = double.parse(s_lng);
    double destination_lat = double.parse(d_lat);
    double destination_lng = double.parse(d_lng);

    //print("sourceLocation_lat:${sourceLocation_lat} ; sourceLocation_lng: ${sourceLocation_lng!}; destination_lat:${destination_lat}; destination_lng: ${destination_lng}");
    polylineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(sourceLocation_lat, sourceLocation_lng),
        //PointLatLng(destination_lat, destination_lng)
    );

    if (result.points.isNotEmpty) {
      print("in side POLYLINES:");
      //print(result);
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude )
        ),
      );
      // MOVE TO THE END
      setState((){

        LatLng newlatlang = LatLng(destination_lat,destination_lng);
        mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(target: newlatlang, zoom: 13.5)
              //17 is new zoom level
            )
        );

      });

    }

    //polulineCoordinates is the List of longitute and latidtude.
    double calculateDistance(lat1, lon1, lat2, lon2){
      var p = 0.017453292519943295;
      var a = 0.5 - cos((lat2 - lat1) * p)/2 +
          cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p))/2;
      return 12742 * asin(sqrt(a));
    }

    double totalDistance = 0;
    List<double> _distances = [];
    var outer = <List<double>>[];
    var ending_;
    int points_counter = 0;


    for(var i = 0; i < polylineCoordinates.length-1; i++){
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);

      var current_distance = calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);

      totalDistance += current_distance;

      points_counter = points_counter + 1;

      _distances.add(current_distance*1000);

      if( i < polylineCoordinates.length-1 ){
        ending_ = 1;
      }

    }

    List<String> poly_points= [];
    for(var i = 0; i < polylineCoordinates.length-1; i++){
      poly_points.add('${polylineCoordinates[i].latitude.toString()}%2C${polylineCoordinates[i].longitude}');
    }

    if( ending_ != null ) {

      getgradiant(poly_points, points_counter, _distances);

    }

    print("total distance:");
    print(totalDistance);
    distance_ =  double.parse(totalDistance.toStringAsFixed(2));

    // GET THE DISTANCE OF THE PICKUP AND DROP OFF POINT AND PRICE
    double totalDistance2 = 0;

    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
      //PointLatLng(, currentLocation!.longitude!),
      PointLatLng(sourceLocation_lat, sourceLocation_lng),
      PointLatLng(destination_lat, destination_lng)
    );

    if (result.points.isNotEmpty) {
      print("in side POLYLINES:");
      //print(result);
      result2.points.forEach(
            (PointLatLng point) => polylineCoordinates2.add(
            LatLng(point.latitude, point.longitude )
        ),
      );
      setState((){

      });

    }

    for(var i = 0; i < polylineCoordinates2.length-1; i++){
      totalDistance2 += calculateDistance(
          polylineCoordinates2[i].latitude,
          polylineCoordinates2[i].longitude,
          polylineCoordinates2[i+1].latitude,
          polylineCoordinates2[i+1].longitude);
    }

    t_amount = double.parse(totalDistance2.toStringAsFixed(2));
    t_amount = (t_amount * 11.90) + 200;
    t_amount = double.parse(t_amount.toStringAsFixed(2));

  }

  // accepting the order


  //get list of orders from the rest api that are in my area
  //and are not done
  void get_order_list(String email , password) async {

    try{
      var url = "https://www.site.com/flutter_driver_order_list";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'email': email,
          'password': password,
        }),
      );

      if(response.statusCode == 200){

        var data = jsonDecode(response.body.toString());
        // print(data['token']);
        // print('got orders successfully');
        // print('data:');
        // print(data);
        // print('result:');
        // print(data['result']);
        // print('lat');
        // print(data['result'][0]['pickup'].split(","));
        // print("time");
        // print(data['time']);
        // print( DateTime.parse('${data["time"]}') );
        // print( DateTime.parse('${data["time"]}').hour );

        // i need a time feild to check the time and have dynamic radiuses
        final now = DateTime.now();
        final later = now.add(const Duration(hours: 36));
        print(now);
        //if(data['application_progress'] == 'not_complete'){

          // setState(() {
          //   message = 'driver registration not complete';
          //   link_reg = 'go_register';
          // });

        //}else if(data['application_progress'] == 'being_processed'){

          // setState(() {
          //   message = 'driver registration being processed';
          //   link_reg = 'go_register';
          // });

        //}else if(data['application_progress'] == 'rejected'){

          // setState(() {
          //   message = 'we are sorry to inform you on your application being rejected';
          //   link_reg = 'go_register';
          // });

        //}else if(data['application_progress'] == 'approved'){
          // password_check ="";
          // message = '';
          // link_reg = '';
          // Navigator.pushNamed(context, '/dashboard', arguments: {
          //   'email': email,
          //   'password': password,
          // });
        //}


      }else if(response.statusCode == 202){
        print('there is no data coming back from the database exist');
        // passwordController.clear();
        // setState(() {
        //   password_check = "passward is not correct";
        // });
      }

    }catch(e){
      print(e.toString());
    }
  }

  void print_start() {
    print("data from login page:");
    print(from_pre_page_data);
  }

  // GET THE ORDER DETAILS

  void get_order_for_driver_response(String driverid) async {
    //String driverid = '124';
    try {
      //await Firebase.initializeApp();
      //final fcmToken = await FirebaseMessaging.instance.getToken();
      // print("token : "+fcmToken.toString());
      var url = "https://www.site.com/driver_order_gets";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'driverid': driverid,
        }),
      );
      //getCurrentLocation ();
      print('respnse code:${response.statusCode}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print("get driver set order for response:");
       // print(data['pickup'].split(","));
        //print(data['dropoff'].split(","));
        var pickup = data['pickup'].split(",");
        var dropoff = data['dropoff'].split(",");

        pickuplocation =
            LatLng(double.parse(pickup[0]), double.parse(pickup[1]));
        dropofflocation =
            LatLng(double.parse(dropoff[0]), double.parse(dropoff[1]));
        // _makers_t[0]=
        //     Marker(
        //       markerId: MarkerId("pickup point 1"),
        //       position: LatLng(double.parse(pickup[0]), double.parse(pickup[1])),
        //     );
        //
        // _makers_t[1]=
        //     Marker(
        //       markerId: MarkerId("dropoff point 2"),
        //       position: LatLng(double.parse(dropoff[0]), double.parse(dropoff[1])),
        //     );
        //var do =
        print(
            " pickup: ${pickup[0]} , pickup: ${pickup[1]}, dropoff: ${dropoff[0]}, dropoff: ${double
                .parse(dropoff[1])} ");
        getPolyPoints(pickup[0] , pickup[1], dropoff[0], dropoff[1] );

          setState(() {
            //_markers.clear();
            check_for_map = 1;
            _counter3 = 1;
            //_markers = _makers_t.toSet();
            //print('list:${_markers}');
            //_placeList = [];

          });

        } else if (response.statusCode == 202) {
          var data = jsonDecode(response.body.toString());
          print("error in getting order id");
          print(data);
        }

      } catch (e) {
      print(e.toString());
    }
  }


  //accept order
  void accept_order(String driverid) async{
    try{

      var url = "https://www.site.com/driver_order_accept";
      final response = await http.post(
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
        print("accept success");
        print("user_socketio_token: "+data['user_socketio_id']);

        setState((){

          user_name = data['user_name'].toString();
          user_email = data['user_email'].toString();
          user_order_socketio_id = data['user_socketio_id'].toString();
          user_socketio_counter = 1;
          user_details = 1;
          _counter3 = 0;
        });


      }else if(response.statusCode == 202){
        var data = jsonDecode(response.body.toString());
        print("error accepting function");
        print(data);
      }
    }catch(e){
      print(e.toString());
    }

  }


  //decline order
  void decline_order(String driverid) async{
    try{
      //await Firebase.initializeApp();
      //final fcmToken = await FirebaseMessaging.instance.getToken();
      // print("token : "+fcmToken.toString());
      var url = "https://www.site.com/driver_order_decline";
      final response = await http.post(
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
        print("declined success");
        setState((){
          _counter3 = 0;
          check_for_map = 0;
        });


      }else if(response.statusCode == 202){
        var data = jsonDecode(response.body.toString());
        print("error accepting function");
        print(data);
      }
    }catch(e){
      print(e.toString());
    }

  }
  void _onClick(String value) => setState(() => _value = value);
  //========================
  // everything notification
  @override
  void initState()  {

    fire_stuff();
    getCurrentLocation();
    getIcons();

    super.initState();

    initSocket();

    //  om message app open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print("_counter");

    // here we need to get the order details so driver can accept or decline
        get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );

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
        get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );
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
  //========================
  Future<void> initSocket() async {
    try{
      print('init done');
      socket = IO.io('https://www.site.com/',<String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },);

      socket.onConnect((_) {
        print('connect');
        socket.emit('msg', 'tests');
      });


      socket.onConnect((data) => {
        print('Connect: ${socket.id}')
      });
    }catch (e) {
      print(e.toString());
    }
  }

  //========================
  Color mainColor = Color(0xff247BA0);
  @override
  Widget build(BuildContext context) {

    //get firebase device token
    //get_token();

     //upon signing in set the device firebase token to drivers table
if(_counter2 == 0){
  from_pre_page_data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  print( from_pre_page_data["driver_id"].toString() );
 driver_id = from_pre_page_data["driver_id"].toString();
  set_firebase_device_token(from_pre_page_data["driver_id"].toString());
  _counter2++;
  print_start();
}

    // listen for order notification
    //get_order_list(from_pre_page_data['email'] , from_pre_page_data['password']);

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Image.asset(
                  'assets/bloommlogo.png',
                  fit: BoxFit.fitWidth,
                  height: 100,
                  width: 100,
                ),
              ),
              Container(
                  width: 100,
                  child: Text('MDriver', style: TextStyle(fontSize: 25))
              ),
              Spacer(),
              Spacer(),
            ],
          ),
        ),

        body: Container(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: <Widget>[
                (check_for_map == 0) ? Text("waiting on orders") :
                    Column(
                      children: <Widget>[
                      Container(
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            zoom: 13.5,
                            target:
                            LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
                            //LatLng(37.42224403259331, -122.05408679053782)

                        ),
                        polylines:_polyline,
                        markers: {
                          Marker(
                            markerId: MarkerId("currentLocation"),
                            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude! ),
                          ),
                          Marker(
                            markerId: MarkerId("source"),
                            position: pickuplocation,
                            icon: icon_source
                          ),
                          Marker(
                            markerId: MarkerId("destination"),
                            position: dropofflocation,
                            icon: icon_destination
                          ),
                        } ,
                        onMapCreated: (controller) { //method called when map is created
                          setState(() {
                            mapController = controller;
                          });
                        },
                      ),
                      ),

                        (_counter3 == 0) ? Text(""):
                        Row(
                          children: <Widget>[

                             ElevatedButton(onPressed: () { accept_order(from_pre_page_data["driver_id"].toString()); },child: Text("accept"),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                                  textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white))),
                              ),

                            Expanded(child: ElevatedButton(onPressed: () {},child: Text(""),style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.white),
                                ),
                            )
                            ),

                             ElevatedButton(onPressed: () { decline_order(from_pre_page_data["driver_id"].toString()); },child: Text("decline"),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(mainColor),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                                  textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white))),
                            ),

                          ],
                        ),

                        (user_details == 0)? Text('') : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:  <Widget>[
                                Text('user details:',
                                  style: TextStyle(height: 5, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children:  <Widget>[
                                Text('User Name:',
                                  style: TextStyle(height: 2, fontSize: 15),
                                ),
                                Text('User Contact Email:',
                                  style: TextStyle(height: 2, fontSize: 15),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children:  <Widget>[
                                Text('${user_name}km',
                                  style: TextStyle(height: 2, fontSize: 15),
                                ),
                                Text('${user_email}',
                                  style: TextStyle(height: 2, fontSize: 15),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ],
                    ),

              ],
            ),
          ),
        )

    );
  }
}
