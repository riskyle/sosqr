import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/utils/locationCheck.dart';

Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .limit(1) // Adjust the limit as needed
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    print('Error fetching announcements: $e');
    return [];
  }
}

class SplashScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String userDocID;
  final String password;
  final String department;
  final String role;

  SplashScreen({
    required this.firstName,
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
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<List<Map<String, dynamic>>>? _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = fetchAnnouncements();
    _navigateToMainScreen();
  }

  void _navigateToMainScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Show splash for 3 seconds

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LocationScreen(
        firstName: widget.firstName,
        lastName: widget.lastName,
        username: widget.username,
        pictureURL: widget.pictureURL,
        accessKey: widget.accessKey,
        userDocID: widget.userDocID,
        password: widget.password,
        department: widget.department,
        role: widget.role,
      ), // Replace with your main screen widget
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Adjust as needed
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No announcements available.'));
          }

          var announcements = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (announcements.isNotEmpty)
                ...announcements.map((announcement) => Column(
                  children: [
                    Text(
                      announcement['title'] ?? 'No Title',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    SizedBox(height: 10),
                    if (announcement['imageUrl'] != null)
                      FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: announcement['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeOutDuration: Duration(milliseconds: 500),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Text(
                      announcement['description'] ?? 'No Description',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 20),
                  ],
                )),
            ],
          );
        },
      ),
    );
  }
}
