import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginScreen.dart'; // Adjust path as per your project structure
import 'second_screen.dart';
import 'logsTab.dart';

class AccountTab extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;

  AccountTab({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL
  });

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex != index) {
        _selectedIndex = index;
        _navigateToScreen(index);
      }
    });
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(
              username: widget.username,
              firstName: widget.firstName,
              lastName: widget.lastName,
              pictureURL: widget.pictureURL,
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogsTab(
              username: widget.username,
              firstName: widget.firstName,
              lastName: widget.lastName,
              pictureURL: widget.pictureURL,
            ),
          ),
        );
        break;
      case 2:
        // Do nothing since we're already on AccountTab
        break;
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clear all stored preferences, adjust as needed

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    width: 150, // Container width (radius * 2)
                    height: 150, // Container height (radius * 2)
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.0, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: NetworkImage(
                          widget.pictureURL),
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.username}',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Account Information
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.0),
                          bottom: Radius
                              .zero, // This makes the bottom edges straight
                        ),
                        color: Colors.white,
                      ),
                      height: 100.0, // Adjust the height as needed
                      margin: EdgeInsets.only(
                          top: 30, left: 30, right: 30), // Example margin
                      padding: EdgeInsets.all(10.0), // Example padding
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.person_search_outlined,
                            size: 75, // Adjust the size of the icon as needed
                            color: Colors
                                .blue[700], // Adjust the color of the icon
                          ),
                          SizedBox(width: 10),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Add spacing between the text widgets
                                Text(
                                  'Account \nInformation',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      color: Colors.grey[300],
                      height: 100.0, // Adjust the height as needed
                      margin: EdgeInsets.only(
                          left: 30, right: 30), // Example margin
                      padding: EdgeInsets.all(10.0), // Example padding
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.edit_note,
                            size: 75, // Adjust the size of the icon as needed
                            color: Colors
                                .blue[700], // Adjust the color of the icon
                          ),
                          SizedBox(width: 10),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Add spacing between the text widgets
                                Text(
                                  'Edit Personal \nDetails',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Accomplished Deliveries
                    Container(
                      color: Colors.white,
                      height: 100.0, // Adjust the height as needed
                      margin: EdgeInsets.only(
                          left: 30, right: 30), // Example margin
                      padding: EdgeInsets.all(10.0), // Example padding
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.checklist_outlined,
                            size: 75, // Adjust the size of the icon as needed
                            color: Colors
                                .blue[700], // Adjust the color of the icon
                          ),
                          SizedBox(width: 10),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Add spacing between the text widgets
                                Text(
                                  'Account \nApproval',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Log Out
                    GestureDetector(
                      onTap: () {
                        _logout(context);
                      },
                      child: Container(
                        color: Colors.grey[300],
                        height: 100.0, // Adjust the height as needed
                        margin: EdgeInsets.only(
                            left: 30, right: 30), // Example margin
                        padding: EdgeInsets.all(10.0), // Example padding
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Icon(
                              Icons.logout_outlined,
                              size: 75, // Adjust the size of the icon as needed
                              color: Colors
                                  .blue[700], // Adjust the color of the icon
                            ),
                            SizedBox(width: 10),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Add spacing between the text widgets
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 100.0, // Adjust the height as needed
                      margin: EdgeInsets.only(
                          left: 30, right: 30), // Example margin
                      padding: EdgeInsets.all(10.0), // Example padding
                      child: Image.asset('assets/SOS-logo.png', width: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue[700],
              unselectedItemColor: Colors.blue[200],
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'QR Scanner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.note_alt),
                  label: 'Logs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
              onTap: _onItemTapped,
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 3 * _selectedIndex,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 3,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
