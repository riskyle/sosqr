import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginScreen.dart'; // Adjust path as per your project structure
import 'second_screen.dart';
import 'logsTab.dart';
import 'accountTab_accountApproval.dart';
import 'accountTab_changePassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'accountTab_changePicture.dart';
import 'accountTab_allAccounts.dart';

class AccountTab extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String userDocID;
  final String password;

  AccountTab(
      {required this.firstName,
      required this.lastName,
      required this.username,
      required this.pictureURL,
      required this.accessKey,
      required this.userDocID,
      required this.password});

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  int _selectedIndex = 2;

  // Para maupdate dayon ang account tab once gi update sa edit profile
  Future<QuerySnapshot<Map<String, dynamic>>> getUserFuture() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userDocID', isEqualTo: widget.userDocID)
        .get();
  }

  // For bottom nav bar
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
              accessKey: widget.accessKey,
              userDocID: widget.userDocID,
              password: widget.password,
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
                accessKey: widget.accessKey,
                userDocID: widget.userDocID,
            password: widget.password),
          ),
        );
        break;
      case 2:
        break;
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clear all stored preferences, adjust as needed

    // Show a dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10.0), // Customize the border radius here
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0057FF)),
              ),
              SizedBox(height: 10),
              Text(
                'You will be logged out shortly.',
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
            ],
          ),
        );
      },
    );

    // Wait for 2 seconds before closing the dialog and navigating
    await Future.delayed(Duration(seconds: 2));

    // Dismiss the dialog box
    Navigator.of(context).pop();

    // Navigate to the MainScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Main Screen sa account tab
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Returning false disables the back button
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        // FutureBuilder para muchange dayon and profile pic display once giupdate
        body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: getUserFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data available'));
            }

            // Get the first document from the query snapshot
            var userData = snapshot.data!.docs.first.data();
            String pictureURL = userData['pictureURL'] ??
                'https://clipart-library.com/images/ATbrxjpyc.jpg';

            return Column(
              children: [
                Expanded(
                  child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(top: 80, bottom: 60, right: 20, left: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangePicture(username: widget.username,
                                lastName: widget.lastName,
                                firstName: widget.firstName,
                                pictureURL: widget.pictureURL,
                                accessKey: widget.accessKey,
                            userDocID: widget.userDocID,)),
                          );
                        },
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
                          backgroundImage: NetworkImage(pictureURL),
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
            ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(45.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChangePassword(
                                            username: widget.username,
                                            lastName: widget.lastName,
                                            firstName: widget.firstName,
                                            pictureURL: widget.pictureURL,
                                            accessKey: widget.accessKey,
                                        password: widget.password,
                                        userDocID: widget.userDocID)),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.blue[200]!;
                                      }
                                      return Color(0xFF1F5EBD);
                                    },
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(double.infinity, 60)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Change Password',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Jost',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Colors.white)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: widget.accessKey != 'basic'
                                ? Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(45.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllAccounts()),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty
                                      .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return Colors.blue[200]!;
                                      }
                                      return Color(0xFF1F5EBD);
                                    },
                                  ),
                                  minimumSize:
                                  MaterialStateProperty.all<Size>(
                                    Size(double.infinity, 60),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                            Icons.people,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'All Accounts',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Jost',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                                : SizedBox(
                                width:
                                10), // Return an empty widget if accessKey is 'basic'
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: widget.accessKey != 'basic'
                                ? Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(45.0),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AccountApproval()),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return Colors.blue[200]!;
                                            }
                                            return Color(0xFF1F5EBD);
                                          },
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                          Size(double.infinity, 60),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                  Icons.library_add_check_sharp,
                                                  color: Colors.white),
                                              SizedBox(width: 10),
                                              Text(
                                                'Account Approval',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Jost',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width:
                                        10), // Return an empty widget if accessKey is 'basic'
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(45.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _logout(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.blue[200]!;
                                      }
                                      return Color(0xFF1F5EBD);
                                    },
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(double.infinity, 60)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.logout_sharp,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Log out',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Jost',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
      ),
    );
  }
}
