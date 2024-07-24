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
  bool _rememberMe = false; // Add a boolean for the "Remember Me" checkbox

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
          ),
        ),
      );
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

        // Save remember me state
        prefs.setBool('rememberMe', _rememberMe);

        if (!_rememberMe) {
          prefs.remove('username');
          prefs.remove('password');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LocationScreen(
              firstName: firstName,
              lastName: lastName,
              username: username,
              pictureURL: pictureURL,
              accessKey: accessKey,
              userDocID: userDocID,
              password: password,
            ),
          ),
        );
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
                            left: 40.0, right: 40.0, bottom: 30),
                        child: Container(
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
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
                                  vertical: 20.0, horizontal: 20.0),
                              hintText: 'Enter username',
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[300],
                                fontFamily: 'Jost',
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue[500]!),
                                borderRadius: BorderRadius.circular(10.0),
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
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
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
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF0057FF)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureTextPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureTextPassword = !_obscureTextPassword;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 20.0),
                              hintText: 'Enter password',
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[300],
                                fontFamily: 'Jost',
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue[500]!),
                                borderRadius: BorderRadius.circular(10.0),
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
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jost',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
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
                                              Icons.error_outline_rounded,
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
                                backgroundColor: WidgetStateProperty
                                    .resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(
                                        WidgetState.pressed)) {
                                      return Colors.grey[200]!;
                                    }
                                    return Colors.indigo;
                                  },
                                ),
                                minimumSize:
                                WidgetStateProperty.all<Size>(
                                    Size(double.infinity, 60)),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
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
                            MaterialPageRoute(
                                builder: (context) => CreateAccount()),
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
            ],
          ),
        ),
      ),
    );
  }
}
