import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePassword extends StatefulWidget {
  final String firstName, lastName, username, pictureURL, accessKey, password, userDocID, department, role;

  ChangePassword({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL,
    required this.accessKey,
    required this.password,
    required this.userDocID,
    required this.department,
    required this.role,
  });

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _obscureTextCurrent = true;
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;
  bool showStreamBuilder = false;


  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  late String streamPassword = '';

  @override
  void initState() {
    super.initState();
    //Fetch user data and set streamPassword
    FirebaseFirestore.instance
    .collection('users')
    .doc(widget.userDocID)
    .get()
    .then((DocumentSnapshot documentSnapshot){
      if (documentSnapshot.exists){
        setState(() {
          streamPassword = documentSnapshot['password'];
        });
      }
    });
  }


  Future<void> updatePassword() async {
    String checkCurrent = _currentPassword.text.trim();
    String checkNew = _newPassword.text.trim();
    String checkConfirm = _confirmPassword.text.trim();

    if (checkCurrent.isEmpty || checkNew.isEmpty || checkConfirm.isEmpty) {
      showMessageDialog('Please fill out all necessary fields.');

      return;
    } else if (checkCurrent != streamPassword) {
      showMessageDialog("The entered password doesn't match with current password.");

      return;
    } else if (checkNew != checkConfirm) {
      showMessageDialog("The new password and confirm password do not match.");
      return;
    } else if (checkNew.length < 8) {
      showMessageDialog("The new password must be at least 8 characters.");
      return;
    }

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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({'password': checkNew});

        // Dismiss the progress dialog
        Navigator.of(context).pop();

        // Show success message dialog
        showMessageDialog('Password successfully updated!', success: true);
      } else {
        Navigator.of(context).pop();
        showMessageDialog('No user found with username: ${widget.username}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      showMessageDialog('Error updating password: $e');
    }
  }

  void showMessageDialog(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (context) => UpdatePasswordDialog(
        message: message,
        icon: success ? Icons.check_circle_outline : Icons.error_outline_sharp,
        iconColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0057FF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userDocID)
                          .snapshots(),
                      builder: (context, snapshot) {
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

                        return Container();
                      },
                    ),

                    // Current Password
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
                        obscureText: _obscureTextCurrent,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF0057FF),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_obscureTextCurrent
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureTextCurrent = !_obscureTextCurrent;
                              });
                            },
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
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // New Password
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
                        obscureText: _obscureTextNew,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF0057FF),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_obscureTextNew
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureTextNew = !_obscureTextNew;
                              });
                            },
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
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Confirm New Password
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
                        obscureText: _obscureTextConfirm,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            FontAwesomeIcons.lock,
                            color: Color(0xFF0057FF),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_obscureTextConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureTextConfirm = !_obscureTextConfirm;
                              });
                            },
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
                            borderSide: BorderSide(color: Color(0xFF0057FF)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
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
                          onPressed:  updatePassword,
                          style: ButtonStyle(
                            backgroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                String checkCurrent =
                                _currentPassword.text.trim();
                                String checkNew = _newPassword.text.trim();
                                String checkConfirm =
                                _confirmPassword.text.trim();

                                if (checkCurrent.isEmpty ||
                                    checkNew.isEmpty ||
                                    checkConfirm.isEmpty) {

                                  return Colors.grey;
                                } else if (states.contains(WidgetState.pressed)) {

                                  return Colors.blue[200]!;
                                }
                                return Color(0xFF1F5EBD);
                              },
                            ),
                            minimumSize:
                            WidgetStateProperty.all<Size>(Size(200, 60)),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class UpdatePasswordDialog extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const UpdatePasswordDialog({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline_sharp,
    this.iconColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Customize the border radius here
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300, // Set the maximum width
            maxHeight: 150, // Set the maximum height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensure the column takes only necessary space
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
                  child: Icon(icon, color: Colors.white, size: 30),
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
