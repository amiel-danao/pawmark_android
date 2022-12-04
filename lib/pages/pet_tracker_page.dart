import 'dart:typed_data';

import 'package:auth_service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../api/customer_controller.dart';
import '../api/pet_controller.dart';
import '../env.sample.dart';
import '../models/device.dart';
import '../providers/auth_provider.dart';
import 'my_nav_drawer.dart';

class PetTrackerPage extends StatefulWidget {
  final Customer currentCustomer;
  const PetTrackerPage({Key? key, required this.currentCustomer})
      : super(key: key);

  @override
  _PetTrackerPageState createState() => _PetTrackerPageState();
}

class _PetTrackerPageState extends State<PetTrackerPage> {
  late GoogleMapController mapController;
  var mapIcons = Map<String, BitmapDescriptor>();
  late BitmapDescriptor defaultIcon;
  var defaultLocation = LatLng(14.578135, 121.0612);
  var devices = Map<String, Device>();
  var markers = Set<Marker>();
  var markerMap = Map<String, Marker>();
  late AuthProvider authProvider;
  var locationListener;
  final double latitudeOffset = -0.006567;
  final double longitudeOffset = -0.006711;
  final double defaultZoomLevel = 15;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    // make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(5, 5)), 'images/paw-marker.png')
        .then((d) {
      defaultIcon = d;
    });

    loadMyDevices(ownerId: FirebaseAuth.instance.currentUser!.uid)
        .then((fetchedDevices) {
      setState(() {
        devices = fetchedDevices;
      });

      attachLocationListener();
    });
  }

  @override
  void dispose() {
    super.dispose();
    locationListener.cancel();
  }

  void attachLocationListener() {
    locationListener = FirebaseFirestore.instance
        .collection("locations")
        .snapshots()
        .listen((event) async {
      for (var doc in event.docs) {
        print('reading firebase location data of : ${doc.id}');
        if (devices.containsKey(doc.id)) {
          var latitude = doc.data()['latitude'];
          var longitude = doc.data()['longitude'];
          var locationReceived =
              LatLng(latitude + latitudeOffset, longitude + longitudeOffset);

          var customIcon;
          if (mapIcons.containsKey(doc.id)) {
            customIcon = mapIcons[doc.id] ?? defaultIcon;
          } else {
            customIcon = await getMarkerIcon(
                devices[doc.id]?.mapIconUrl ?? Env.URL_DEFAULT_PET_IMAGE,
                Size(150.0, 150.0));
          }

          var newMarker = Marker(
              markerId: MarkerId(doc.id),
              position: locationReceived,
              icon: customIcon);

          if (markerMap.containsKey(doc.id)) {
            markers.remove(markerMap[doc.id]);
          }

          setState(() {
            markerMap[doc.id] = newMarker;
            markers.add(newMarker);
          });

          mapController.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(locationReceived.latitude, locationReceived.longitude),
              await mapController.getZoomLevel()));

          print(
              "location update received from : ${doc.id}, location is $locationReceived");
        }
      }
    });
  }

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
        drawer: MyNavDrawer(
          currentCustomer: widget.currentCustomer,
          signOutFunction: () {
            handleSignOut(context, authProvider);
          },
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(defaultLocation.latitude, defaultLocation.longitude),
            zoom: defaultZoomLevel,
          ),
          markers: markers,
        ),
      ),
    );
  }
}
