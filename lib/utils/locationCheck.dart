import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:untitled1/screens/other/second_screen.dart';

class LocationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String userDocID;
  final String password;
  final String department;
  final String role;


  LocationScreen(
      {required this.firstName,
      required this.lastName,
      required this.username,
      required this.pictureURL,
      required this.accessKey,
      required this.userDocID,
      required this.password,
      required this.department,
        required this.role,
      });

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition; // Initialize with null
  final double targetLatitude = 10.316040151942078;
  final double targetLongitude = 123.90930328276583;
  final double thresholdDistanceKm = 2.0; // 2 km threshold,

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
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Customize the border radius here
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 300, // Set the maximum width
                maxHeight: 150, // Set the maximum height
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensure the column takes only necessary space
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                        bottom: Radius.zero,
                      ),
                    ),
                    height: 60,
                    child: Center(
                      child: Text(
                        'Enable Location Services',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.normal,
                            fontSize: 22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Please enable location services to continue!',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF1F5EBD),
                ),
              ),
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

  double _calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    const double earthRadiusKm = 6371.0;
    double dLat = _degreesToRadians(endLat - startLat);
    double dLng = _degreesToRadians(endLng - startLng);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _redirectToAnotherScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SecondScreen(
              username: widget.username,
              lastName: widget.lastName,
              firstName: widget.firstName,
              pictureURL: widget.pictureURL,
              accessKey: widget.accessKey,
              userDocID: widget.userDocID,
              password: widget.password,
              department: widget.department,
              role: widget.role,
          )),
    );
  }

  void _showErrorMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10.0), // Customize the border radius here
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 300, // Set the maximum width
                maxHeight: 150, // Set the maximum height
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensure the column takes only necessary space
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                        bottom: Radius.zero,
                      ),
                    ),
                    height: 60,
                    child: Center(
                      child: Text(
                        'Error',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.normal,
                            fontSize: 22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'User not in the building. App access denied.',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF1F5EBD),
                ),
              ),
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
        title: Text('Location Check...', style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, fontSize: 20),),
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
            : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0057FF))),
      ),
    );
  }
}
