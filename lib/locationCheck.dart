import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'second_screen.dart';

class LocationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;

  LocationScreen({required this.firstName, required this.lastName, required this.username, required this.pictureURL});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition; // Initialize with null
  final double targetLatitude = 10.316040151942078;
  final double targetLongitude = 123.90930328276583;
  final double thresholdDistanceKm = 2.0; // 2 km threshold

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    while (!(await Geolocator.isLocationServiceEnabled())) {
      await _showEnableLocationDialog();
    }
    _getCurrentLocation();
  }

  Future<void> _showEnableLocationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Location Services'),
          content: Text('Please enable location services to continue.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {});
      _checkProximity();
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _checkProximity() {
    if (_currentPosition != null) {
      double distance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        targetLatitude,
        targetLongitude,
      );

      if (distance <= thresholdDistanceKm) {
        _redirectToAnotherScreen();
      } else {
        _showErrorMessage();
      }
    }
  }

  double _calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const double earthRadiusKm = 6371.0;
    double dLat = _degreesToRadians(endLat - startLat);
    double dLng = _degreesToRadians(endLng - startLng);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) * cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _redirectToAnotherScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(username: widget.username, lastName: widget.lastName, firstName: widget.firstName, pictureURL: widget.pictureURL)),
    );
  }

  void _showErrorMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('User not in the building. App access denied.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Location'),
      ),
      body: Center(
        child: _currentPosition != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latitude: ${_currentPosition!.latitude}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Longitude: ${_currentPosition!.longitude}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

