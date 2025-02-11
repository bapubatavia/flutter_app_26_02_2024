import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomeLocation extends StatefulWidget {
  const MyHomeLocation({super.key});

  @override
  State<MyHomeLocation> createState() => _MyHomeLocationState();
}

class _MyHomeLocationState extends State<MyHomeLocation> {
  static const LatLng myHomeLocation = LatLng(-1.954036, 30.067519); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: myHomeLocation, 
          zoom: 15,
        ),
        markers: {
          const Marker(
            markerId: MarkerId("Bapu's Home"),
            position: myHomeLocation,
          ),
        },
      ),
    );
  }
}