import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PetTrackerPage extends StatefulWidget {
  const PetTrackerPage({Key? key}) : super(key: key);

  @override
  _PetTrackerPageState createState() => _PetTrackerPageState();
}

class _PetTrackerPageState extends State<PetTrackerPage> {
  late GoogleMapController mapController;
  static const String DEVICE_ID = "359339077128046";

  @override
  void initState() {
    super.initState();
    final docRef =
        FirebaseFirestore.instance.collection("locations").doc(DEVICE_ID);
    docRef.snapshots().listen(
          (event) => {
            print("current data: ${event.data()}"),
            setState(() {
              currentLocation =
                  LatLng(event.data()!['latitude'], event.data()!['longitude']);
            }),
            mapController.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(currentLocation.latitude, currentLocation.longitude),
                14))
          },
          onError: (error) => print("Listen failed: $error"),
        );

    // make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(5, 5)), 'images/paw-marker.png')
        .then((d) {
      customIcon = d;
    });
  }

  late BitmapDescriptor customIcon;

  var currentLocation = LatLng(14.578135, 121.0612);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pet Tracker'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 11.0,
          ),
          markers: {
            Marker(
                markerId: const MarkerId("currentLocation"),
                position:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                icon: customIcon)
          },
        ),
      ),
    );
  }
}
