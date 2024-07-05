import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locationCheck.dart';
import 'createAccount.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureTextPassword = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    checkLoggedIn();
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // Fetch user data from preferences or Firebase if needed
      String username = prefs.getString('username') ?? '';
      String firstName = prefs.getString('firstName') ?? '';
      String pictureURL = prefs.getString('pictureURL') ?? '';
      String lastName = prefs.getString('lastName') ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
          ),
        ),
      );
    }
  }

  Future<void> _login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a login process with a delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // After login process is complete, you can navigate to another screen or show a success message
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final firstName = userDoc['firstName'];
        final lastName = userDoc['lastName'];
        final pictureURL = userDoc['pictureURL'];
        final logInTime = DateTime.now();
        final docId = '$username';


        //Save the timestamps of log in and out of the user in the database
        await FirebaseFirestore.instance
            .collection('logInandOut')
            .doc(docId)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'logInTime': logInTime,
          'username': username,
        });

        // Save login credentials to prevent from logging in once the app is turned off
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('username', username);
        prefs.setString('firstName', firstName);
        prefs.setString('lastName', lastName);
        prefs.setString('pictureURL', pictureURL);

        // Login successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LocationScreen(
              firstName: firstName,
              lastName: lastName,
              username: username,
              pictureURL: pictureURL,
            ),
          ),
        );
      } else{
        // Check if the user is pending for approval
        final pendingQuerySnapshot = await FirebaseFirestore.instance
            .collection('usersPending')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (pendingQuerySnapshot.docs.isNotEmpty) {
          // User pending for approval
          _showErrorDialog("User pending for approval!");
        } else {
          // Invalid username or password
          _showErrorDialog("Invalid username or password!");
        }
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(45.0), // Customize the border radius here
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
                      top: Radius.circular(45.0),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Image.asset('assets/SOS-logo.png'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily:
                              'Jost', // Check if 'Jost' is correctly defined
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily:
                                'Jost', // Check if 'Jost' is correctly defined
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, bottom: 30),
                            child: Container(
                              height: 60.0, // Set the desired height here
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(
                                    45.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Shadow color
                                    spreadRadius: 5, // Spread radius
                                    blurRadius: 7, // Blur radius
                                    offset: Offset(0,
                                        3), // Offset in the x and y directions
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.account_circle,
                                      color: Color(0xFF0057FF)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal:
                                      20.0), // Adjust padding to modify text field content position
                                  hintText: 'Enter username',
                                  hintStyle: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[400],
                                    fontFamily: 'Jost',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(45.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.blue[500]!),
                                    borderRadius: BorderRadius.circular(45.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Jost',
                                  color: Color(0xFF1F5EBD),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40, right: 40, bottom: 30),
                            child: Container(
                              height: 60.0, // Set the desired height here
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(
                                    45.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Shadow color
                                    spreadRadius: 5, // Spread radius
                                    blurRadius: 7, // Blur radius
                                    offset: Offset(0,
                                        3), // Offset in the x and y directions
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                controller: _passwordController,
                                obscureText: _obscureTextPassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(0xFF0057FF)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureTextPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureTextPassword =
                                        !_obscureTextPassword;
                                      });
                                    },
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal:
                                      20.0), // Adjust padding to modify text field content position
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[400],
                                    fontFamily: 'Jost',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(45.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.blue[500]!),
                                    borderRadius: BorderRadius.circular(45.0),
                                  ),

                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Jost',
                                  color: Color(0xFF1F5EBD),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: _isLoading
                                ? Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00E5E5)),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.only(
                                  left: 40, right: 40, bottom: 60),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  borderRadius:
                                  BorderRadius.circular(45.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    String username =
                                        _usernameController.text;
                                    String password =
                                        _passwordController.text;
                                    if (username.isEmpty ||
                                        password.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .error_outline_rounded,
                                                  color: Colors.red),
                                              SizedBox(width: 10),
                                              Text(
                                                  'Username or password cannot be empty.'),
                                            ],
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      _login(username, password);
                                    }
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
                                        Size(double.infinity, 60)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(45.0),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'LOGIN',
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
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateAccount()),
                              );
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jost',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )

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
    );
  }
}
