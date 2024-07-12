import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePassword extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String password;
  final String userDocID;

  ChangePassword(
      {required this.firstName,
      required this.lastName,
      required this.username,
      required this.pictureURL,
      required this.accessKey,
      required this.password,
      required this.userDocID});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _obscureTextCurrent = true;
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;
  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  String? streamPassword;

  // For updating profile details
  Future<void> updatePassword() async {
    // Show the progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0057FF)),
              ),
              SizedBox(height: 10),
              Text(
                'Updating...',
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

    try {
      String checkCurrent = _currentPassword.text.trim();
      String checkNew = _newPassword.text.trim();
      String checkConfirm = _confirmPassword.text.trim();

      // For updating the firstName
      if (checkCurrent == streamPassword && checkNew == checkConfirm) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: widget.username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newFirstName
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'password': checkNew});
        } else {
          print('No user found with username: ${widget.username}');
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      // Dismiss the progress dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userDocID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text('No user data found');
              }

              var userDoc = snapshot.data!;
              var password = userDoc['password'];

              // Update the streamPassword variable with the latest password
              streamPassword = password;
              return Text('');
            },
          ),
          // First Name
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 30),
              Text(
                'Current Password',
                style: TextStyle(
                  fontFamily: 'Jost',
                  color: Color(0xFF0057FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _currentPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  color: Color(0xFF0057FF),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                hintText: 'Enter current password', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.normal,
                ),
                // Customize border
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0057FF)!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),

          SizedBox(height: 20),

          // Last Name
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 30),
              Text(
                'New Password',
                style: TextStyle(
                  fontFamily: 'Jost',
                  color: Color(0xFF0057FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _newPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  color: Color(0xFF0057FF),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                hintText: 'Enter new password', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.normal,
                ),
                // Customize border
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0057FF)!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.normal),
            ),
          ),

          SizedBox(height: 20),

          // Username
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 30),
              Text(
                'Confirm New Password',
                style: TextStyle(
                  fontFamily: 'Jost',
                  color: Color(0xFF0057FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _confirmPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.at,
                  color: Color(0xFF0057FF),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                hintText: 'Enter new password again', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.normal,
                ),
                // Customize border
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0057FF)!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 60, left: 40, right: 40, bottom: 60),
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
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  String checkCurrent = _currentPassword.text.trim();
                  String checkNew = _newPassword.text.trim();
                  String checkConfirm = _confirmPassword.text.trim();

                  if (checkCurrent.isEmpty ||
                      checkNew.isEmpty ||
                      checkConfirm.isEmpty) {
                    String message = 'Please fill out all necessary fields.';
                    showDialog(
                      context: context,
                      builder: (context) =>
                          UpdatePasswordDialog(message: message),
                    );
                  } else if (checkCurrent != streamPassword) {
                    String message =
                        "The entered password doesn't match with current password.";
                    showDialog(
                      context: context,
                      builder: (context) =>
                          UpdatePasswordDialog(message: message),
                    );
                  } else if (checkNew != checkConfirm) {
                    String message =
                        "The new password and confirm password do not match.";
                    showDialog(
                      context: context,
                      builder: (context) =>
                          UpdatePasswordDialog(message: message),
                    );
                  } else {
                    updatePassword();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      String checkCurrent = _currentPassword.text.trim();
                      String checkNew = _newPassword.text.trim();
                      String checkConfirm = _confirmPassword.text.trim();

                      if (checkCurrent.isEmpty ||
                          checkNew.isEmpty ||
                          checkConfirm.isEmpty) {
                        return Colors.grey;
                      } else if (states.contains(MaterialState.pressed)) {
                        return Colors.blue[200]!;
                      }
                      return Color(0xFF1F5EBD);
                    },
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 60)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Text(
                  'UPDATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Jost',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdatePasswordDialog extends StatelessWidget {
  final String message;

  const UpdatePasswordDialog({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(Icons.error_outline_sharp,
                      color: Colors.white, size: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Jost',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
  }
}
