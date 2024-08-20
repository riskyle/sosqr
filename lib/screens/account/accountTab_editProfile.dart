
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfile extends StatefulWidget {

  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String userDocID;
  final String department;
  final String role;

  EditProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.userDocID,
    required this.department,
    required this.role,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _userDocID = TextEditingController();
  TextEditingController _department = TextEditingController();
  TextEditingController _role = TextEditingController();

  // For updating profile details
  Future<void> updateProfile() async {
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
      String checkFirstName = _firstName.text.trim();
      String checkLastName = _lastName.text.trim();
      String checkUsername = _username.text.trim();
      String checkPassword = _password.text.trim();
      String checkDepartment = _department.text.trim();
      String checkRole = _role.text.trim();

      // For updating the firstName
      if (checkFirstName != widget.firstName && checkFirstName.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newFirstName
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'firstName': checkFirstName});
        } else {
          print('No user found with firstName: ${widget.firstName}');
        }
      }

      // For updating the lastName
      if (checkLastName != widget.lastName && checkLastName.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newlastName
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'lastName': checkLastName});
        } else {
          print('No user found with lastName: ${widget.lastName}');
        }
      }

      // For updating the Department
      if (checkDepartment != widget.department && checkDepartment.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newDepartment
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'department': checkDepartment});
        } else {
          print('No user found with Department: ${widget.department}');
        }
      }

      // For updating the Role
      if (checkRole != widget.role && checkRole.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newRole
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'role': checkRole});
        } else {
          print('No user found with Role: ${widget.role}');
        }
      }

      if (checkUsername != widget.username && checkUsername.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newFirstName
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'username': checkUsername});
        } else {
          print('No user found with username: ${widget.username}');
        }
      }

      if (checkPassword != widget.password && checkPassword.isNotEmpty) {
        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the newPassword
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'password': checkPassword});
        } else {
          print('No user found with password: ${widget.password}');
        }
      }
    } catch (e) {
      print('Error updating: $e');
    } finally {
      // Dismiss the progress dialog
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _firstName.text = widget.firstName;
    _lastName.text = widget.lastName;
    _userDocID.text = widget.userDocID;
    _username.text = widget.username;
    _password.text = widget.password;
    _department.text = widget.department;
    _role.text = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profile',
            style: TextStyle(
                fontFamily: 'Jost',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        backgroundColor: Color(0xFF0057FF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 30),
                        Text(
                          'First Name',
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
                        controller: _firstName,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter first name', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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
                          'Last Name',
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
                        controller: _lastName,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter last name', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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

                    // Department
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 30),
                        Text(
                          'Department',
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
                        controller: _department,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.maps_home_work_outlined,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter Department', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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

                    // Role
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 30),
                        Text(
                          'Role',
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
                        controller: _role,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.construction,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter Role', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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
                          'Username',
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
                        controller: _username,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            FontAwesomeIcons.at,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter username', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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

                    // Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 30),
                        Text(
                          'Password',
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
                        controller: _password,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF0057FF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          hintText: 'Enter password', // Placeholder text
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                          ),
                          // Customize border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
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
                      padding: const EdgeInsets.only(
                          top: 60, left: 40, right: 40, bottom: 60),
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
                            String checkFirstName = _firstName.text.trim();
                            String checkLastName = _lastName.text.trim();
                            String checkUserDocID = _userDocID.text.trim();
                            String checkDepartment = _department.text.trim();
                            String checkRole = _role.text.trim();
                            String checkUsername = _username.text.trim();
                            String checkPassword = _password.text.trim();

                            if (checkFirstName.isEmpty ||
                                checkLastName.isEmpty ||
                                checkUserDocID.isEmpty ||
                                checkDepartment.isEmpty ||
                                checkRole.isEmpty ||
                                checkUsername.isEmpty ||
                                checkPassword.isEmpty) {
                              String message =
                                  'Please fill out all necessary fields.';
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    UpdateProfileDialog(message: message),
                              );
                            } else if (checkFirstName == widget.firstName &&
                                checkLastName == widget.lastName &&
                                checkUserDocID == widget.userDocID &&
                                checkDepartment == widget.department &&
                                checkRole == widget.role &&
                                checkUsername == widget.username &&
                                checkPassword == widget.password) {
                              String message = 'No changes were made.';
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    UpdateProfileDialog(message: message),

                              );
                            } else {
                              updateProfile();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                String checkFirstName = _firstName.text.trim();
                                String checkLastName = _lastName.text.trim();
                                String checkUserDocID = _userDocID.text.trim();
                                String checkDepartment = _department.text.trim();
                                String checkRole = _role.text.trim();
                                String checkUsername = _username.text.trim();
                                String checkPassword = _password.text.trim();

                                if (checkFirstName.isEmpty ||
                                    checkLastName.isEmpty ||
                                    checkUserDocID.isEmpty ||
                                    checkDepartment.isEmpty ||
                                    checkRole.isEmpty ||
                                    checkUsername.isEmpty ||
                                    checkPassword.isEmpty) {

                                  return Colors.grey;
                                } else if (states
                                    .contains(MaterialState.pressed)) {
                                  return Colors.blue[200]!;
                                }
                                return Color(0xFF1F5EBD);
                              },
                            ),
                            minimumSize:
                            MaterialStateProperty.all<Size>(Size(200, 60)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class UpdateProfileDialog extends StatelessWidget {
  final String message;

  const UpdateProfileDialog({Key? key, required this.message})
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
