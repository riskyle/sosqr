import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/screens/admin_dashboard/adminDashboard.dart';
import 'package:untitled1/utils/locationCheck.dart';
import 'createAccount.dart';
import 'package:untitled1/screens/admin_dashboard/splash_screen/splashScreen.dart';
import 'package:untitled1/userDashboard.dart';


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
    checkLoggedIn();
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String username = prefs.getString('username') ?? '';
      String firstName = prefs.getString('firstName') ?? '';
      String pictureURL = prefs.getString('pictureURL') ?? '';
      String lastName = prefs.getString('lastName') ?? '';
      String accessKey = prefs.getString('accessKey') ?? '';
      String userDocID = prefs.getString('userDocID') ?? '';
      String password = prefs.getString('password') ?? '';
      String department = prefs.getString('department') ?? '';
      String role = prefs.getString('role') ?? '';


      if (accessKey == 'basic') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(
              username: username,
              firstName: firstName,
              lastName: lastName,
              pictureURL: pictureURL,
              department: department,
              accessKey: accessKey,
              role: role,
              password: password,
              userDocID: userDocID,
            )
          ),
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => (accessKey == 'admin') ? AdminDashboard(
                    firstName: firstName,
                    lastName: lastName,
                    username: username,
                    pictureURL: pictureURL,
                    department: department,
                    role: role,
                    accessKey: accessKey,
                    userDocID: userDocID,
                    password: password,
                )
                    : LocationScreen(
                    firstName: firstName,
                    lastName: lastName,
                    username: username,
                    pictureURL: pictureURL,
                    accessKey: accessKey,
                    userDocID: userDocID,
                    password: password,
                    department: department,
                    role: role,
                ),
            ),
        );
      }
    }
  }

  Future<void> _login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

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
        final accessKey = userDoc['accessKey'];
        final logInTime = DateTime.now();
        final docId = '$username';
        final userDocID = userDoc['userDocID'];
        final department = userDoc['department'];
        final role = userDoc['role'];

        await FirebaseFirestore.instance
            .collection('logInandOut')
            .doc(docId)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'logInTime': logInTime,
          'username': username,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('username', username);
        prefs.setString('firstName', firstName);
        prefs.setString('lastName', lastName);
        prefs.setString('pictureURL', pictureURL);
        prefs.setString('accessKey', accessKey);
        prefs.setString('userDocID', userDocID);
        prefs.setString('password', password);
        prefs.setString('department', department);
        prefs.setString('role', role);

        // Navigate based on access key
        if (accessKey == 'basic') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreen(
                firstName: firstName,
                lastName: lastName,
                username: username,
                pictureURL: pictureURL,
                department: department,
                accessKey: accessKey,
                role: role,
                password: password,
                userDocID: userDocID,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => (accessKey == 'admin')
                  ? AdminDashboard(
                firstName: firstName,
                lastName: lastName,
                username: username,
                pictureURL: pictureURL,
                department: department,
                accessKey: accessKey,
                role: role,
                password: password,
                userDocID: userDocID,
              )
                  : LocationScreen(
                firstName: firstName,
                lastName: lastName,
                username: username,
                pictureURL: pictureURL,
                department: department,
                accessKey: accessKey,
                role: role,
                password: password,
                userDocID: userDocID,
              ),
            ),
          );
        }
      } else {
        final pendingQuerySnapshot = await FirebaseFirestore.instance
            .collection('usersPending')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (pendingQuerySnapshot.docs.isNotEmpty) {
          _showErrorDialog("User pending for approval!");
        } else {
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
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: 150,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5044f8), Color(0xFF12163b)],
            end: Alignment(-1.0, 1.0),
            begin: Alignment(0.1, -1.0),
            stops: [0.29, 0.98],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Image.asset('assets/SOS-logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jost',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jost',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 10.0),
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jost',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle,
                                color: Color(0xFFFFFFFF)),
                            hintText: 'Username',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 10.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureTextPassword,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jost',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock,
                                color: Color(0xFFFFFFFF)
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureTextPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureTextPassword = !_obscureTextPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Jost',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF423190), Color(0xFF3F51B5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _login(_usernameController.text,
                                  _passwordController.text);
                            }
                          },
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Jost',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccount(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF00E5E5),
                                fontFamily: 'Jost',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
