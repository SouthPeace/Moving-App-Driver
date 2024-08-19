import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:drivermoving2/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';



class OrderTrackingPage extends StatefulWidget {
   OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  String _value = '';
  LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation () {
    Location location = Location();

    location.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );

    location.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;

        setState((){});
      },
    );
  }

  void getPolyPoints()async{
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude)
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude )
        ),
      );
      setState((){

      });

    }
  }
  void _onClick(String value) => setState(() => _value = value);

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Image.asset(
                'assets/movisaTransparent.png',
                fit: BoxFit.fitWidth,
                height: 100,
                width: 100,
              ),
            ),
            Container(
                width: 100,
                child: Text('MDriver')
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[

                    Container(
                      height: 90.0,
                      width: 375.0,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      height: 40.0,
                      width: 375.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                    ),
                    Container(
                      height: 90.0,
                      width: 375.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
                            child: Container(
                              width: 50,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Icon(Icons.map),
                            ),
                            onPressed: () { Navigator.pushNamed(context, '/ordering_map'); } ,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
                            child: Container(
                              width: 50,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Icon(Icons.people),
                            ),
                            onPressed: () => _onClick('Button2'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
                            child: Container(
                              width: 50,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Icon(Icons.timer),
                            ),
                            onPressed: () => _onClick('Button3'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),

      ],
      body: currentLocation == null
          ? Center(child: Text("loading"))
          :GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 13.5,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: primaryColor,
            width: 6,
          ),
        },
        markers: {
          Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude! ),
          ),
          Marker(
            markerId: MarkerId("source"),
            position: sourceLocation,
          ),
          Marker(
            markerId: MarkerId("destination"),
            position: destination,
          ),
        },
      ),
    );
  }
}

