import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();


  final _formField = GlobalKey<FormState>();


  // Checks if the username already exists in the database
  Future<void> _checkUserExists(String userName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Dialog box if User already exists
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                      'Username already taken. Please use another one.',
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
        ),
      );
    } else {
      // If username is not already in the database, application will be submitted
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
                  'Submitting application...',
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


      // Store user details in Firestore in usersPending collection with a random docID
      await FirebaseFirestore.instance.collection('usersPending').add({
        'firstName': firstName.text,
        'lastName': lastName.text,
        'username': _userNameController.text,
        'password': _passwordController.text,
      });
      // Proceed with signup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Application submitted. Wait for the admin's approval")),
      );
    }
  }

void clearText(){
  _textEditingController.clear();
}

  // Main Screen of Create Account
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Ensures the body extends behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Removes the shadow
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5044f8), Color(0xFF12163b)],
            end: Alignment(-1.0, 1.0),
            begin: Alignment(0.1, -1.0),
            stops: [0.29, 0.98],
          ),
        ),
        child: Center(
          child: Form(
            key: _formField,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Jost',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        'Full Name',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost'),
                      ),
                      Visibility(
                        visible:
                            firstName.text.isEmpty || lastName.text.isEmpty,
                        child: Text(
                          '*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter First Name";
                                    } else {
                                      bool isValidName =
                                          RegExp(r'^[a-zA-Z\s]+$')
                                              .hasMatch(value);
                                      if (!isValidName) {
                                        return "Invalid first name. It should not\ninclude numbers and symbols";
                                      }
                                    }
                                    return null;
                                  },
                                  controller: firstName,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person,
                                        color: Color(0xFF0057FF)),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    hintText: 'First Name',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[300],
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Color(0xFF0057FF)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    fontFamily: 'Jost',
                                    color: Color(0xFF1F5EBD),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter Last Name";
                                    } else {
                                      bool isValidName =
                                          RegExp(r'^[a-zA-Z\s]+$')
                                              .hasMatch(value);
                                      if (!isValidName) {
                                        return "Invalid last name. It should not\ninclude numbers and symbols";
                                      }
                                    }
                                    return null;
                                  },
                                  controller: lastName,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    prefixIcon: Icon(Icons.person,
                                        color: Colors.transparent),
                                    hintText: 'Last Name', // Placeholder text
                                    hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[300],
                                        fontFamily: 'Jost'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.transparent),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Color(0xFF0057FF)),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    fontFamily: 'Jost',
                                    color: Color(0xFF1F5EBD),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        'Username',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: _userNameController.text.isEmpty,
                        child: Text(
                          '*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //UserName
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter username";
                        } else {
                          bool isValidName =
                              RegExp(r'^[a-zA-Z0-9]+(?:[._-]?[a-zA-Z0-9]+)*$')
                                  .hasMatch(value);
                          if (!isValidName) {
                            return "Invalid username";
                          }
                        }
                        return null;
                      },
                      controller: _userNameController,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(FontAwesomeIcons.at, color: Color(0xFF0057FF)),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        hintText: (firstName.text.isEmpty ||
                                lastName.text.isEmpty)
                            ? 'Enter username'
                            : '${firstName.text.isNotEmpty ? firstName.text[0].toLowerCase() : ''}${lastName.text.toLowerCase()}', // Placeholder text
                        hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.normal,
                        fontFamily: 'Jost'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF0057FF)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        fontFamily: 'Jost',
                        color: Color(0xFF1F5EBD),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: _passwordController.text.isEmpty,
                        child: Text(
                          '*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter password";
                        } else if (value.length < 8){
                          return 'Password must be at least 8 characters';
                        } else if (!value.contains(RegExp(r'[A-Z]'))){
                          return 'Password must contain at least one uppercase letter';
                        } else if (!value.contains(RegExp(r'[0-9]'))){
                          return 'Password must contain at least one number';
                        }
                        return null;
                      },
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF0057FF)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF1F5EBD)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        fontFamily: 'Jost',
                        color: Color(0xFF1F5EBD),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: _confirmPasswordController.text.isEmpty,
                        child: Text(
                          '*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  //confirm password
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter password again to confirm your password";
                        } else {
                          if (value != _passwordController.text) {
                            return "Password does not match";
                          }
                        }
                        return null;
                      },
                      controller: _confirmPasswordController,
                      obscureText: _obscureTextConfirm,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF1F5EBD)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextConfirm = !_obscureTextConfirm;
                            });
                          },
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.transparent)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF1F5EBD)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        fontFamily: 'Jost',
                        color: Color(0xFF1F5EBD),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, bottom: 60),
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
                          if (_formField.currentState?.validate() ?? false) {
                            _checkUserExists(_userNameController.text);
                          }
                            firstName.clear();
                            lastName.clear();
                            _userNameController.clear();
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.blue[200]!;
                              }
                              return Colors.indigo;
                            },
                          ),
                          minimumSize: WidgetStateProperty.all<Size>(
                              Size(double.infinity, 60)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'SIGN UP',
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
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
