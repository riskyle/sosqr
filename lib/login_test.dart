import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'second_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateAccount(),
    );
  }
}

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureTextPassword = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
        // Login successful
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SecondScreen(
                firstName: firstName,
                username: username,
              )),
        );
      } else {
        // Invalid username or password
        _showErrorDialog("Invalid username or password.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                      bottom: Radius.zero,
                    ),
                    color: Colors.blue[700],
                  ),
                  height: 60,
                  child: Center(
                    child: Icon(Icons.error_outline_sharp,
                        color: Colors.white, size: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(message,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0, bottom: 20.0),
                child: Image.asset('assets/SOS-globe.png'),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50.0),
                    bottom: Radius.zero,
                  ),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(top: 40.0, bottom: 40.0),
                            child:
                            Image.asset('assets/SOS-logo.png', height: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 60),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter your username";
                              }
                              return null;
                            },
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon:
                              Icon(Icons.person, color: Colors.blue[500]),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10.0),
                              labelText: 'Enter username',
                              labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue[500]!),
                              ),
                              floatingLabelStyle:
                              TextStyle(color: Colors.blue[500]!),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 80),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter your password";
                              }
                              // You can add more complex password validation here if needed
                              return null;
                            },
                            controller: _passwordController,
                            obscureText: _obscureTextPassword,
                            decoration: InputDecoration(
                              prefixIcon:
                              Icon(Icons.lock, color: Colors.blue[500]),
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
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10.0),
                              labelText: 'Enter password',
                              labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue[500]!),
                              ),
                              floatingLabelStyle:
                              TextStyle(color: Colors.blue[500]!),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: _isLoading
                              ? CircularProgressIndicator(
                              color: Colors.blue[700])
                              : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Validation passed, proceed with login logic
                                String username =
                                    _usernameController.text;
                                String password =
                                    _passwordController.text;
                                _login(username, password);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty
                                  .resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states
                                      .contains(MaterialState.pressed)) {
                                    return Colors.blue[200]!;
                                  }
                                  return Colors.blue[500]!;
                                },
                              ),
                              minimumSize:
                              MaterialStateProperty.all<Size>(
                                  Size(200, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
