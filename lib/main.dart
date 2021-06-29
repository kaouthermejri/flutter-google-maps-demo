import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: GoogleMapsFlutter(),
    );
  }
}

class GoogleMapsFlutter extends StatefulWidget {
  @override
  _GoogleMapsFlutterState createState() => _GoogleMapsFlutterState();
}

class _GoogleMapsFlutterState extends State<GoogleMapsFlutter> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  BitmapDescriptor? _markerBitmap;
  Set<Marker>? _markers;

  @override
  void initState() {
    _loadMarkers();
    super.initState();
  }

  void _loadMarkers() async {
    _markerBitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/location_marker.png',
    );

    List<LatLng> positions = [
      LatLng(44.968046, -94.420307),
      LatLng(44.33328, -89.132008),
      LatLng(33.755787, -116.359998),
      LatLng(33.844843, -116.54911),
      LatLng(44.92057, -93.44786),
      LatLng(44.240309, -91.493619),
      LatLng(44.968041, -94.419696),
      LatLng(44.333304, -89.132027),
      LatLng(33.755783, -116.360066),
      LatLng(33.844847, -116.549069),
    ];

    _markers = Set.from(
      positions
          .map(
            (e) => Marker(
              icon: _markerBitmap ?? BitmapDescriptor.defaultMarker,
              markerId: MarkerId('${e.latitude}-${e.longitude}'),
              position: LatLng(e.latitude, e.longitude),
              infoWindow: InfoWindow(
                title: "You've tapped ${e.latitude}-${e.longitude}",
                snippet: 'Enjoy',
              ),
              onTap: () {
                print('Marker tapped');
              },
            ),
          )
          .toList(),
    );

    var bounds = _boundsFromLatLngList(positions);
    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bounds, 50);
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(u2);

    setState(() {});
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? double.infinity)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1 ?? 0, y1 ?? 0),
      southwest: LatLng(x0 ?? 0, y0 ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers ?? Set(),
      ),
    );
  }
}
