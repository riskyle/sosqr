import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/screens/auth/loginScreen.dart';// Adjust path as per your project structure
import 'package:untitled1/screens/other/second_screen.dart';
import 'package:untitled1/utils/navigation_utils.dart';
import 'package:untitled1/screens/logs/logsTab.dart';
import 'accountTab_accountApproval.dart';
import 'accountTab_changePassword.dart';
import 'accountTab_changePicture.dart';
import 'accountTab_allAccounts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'dart:io' as io; // Import as io to avoid naming conflicts

class AccountTab extends StatefulWidget {
  final String firstName, lastName, username, pictureURL, accessKey, userDocID, password, department , role;

  const AccountTab({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL,
    required this.accessKey,
    required this.userDocID,
    required this.password,
    required this.department,
    required this.role,
  }) : super(key: key);

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  late String _firstName;
  late String _lastName;

  @override
  void initState(){
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
  }

  int _selectedIndex = 2;

  Future<QuerySnapshot<Map<String, dynamic>>> getUserFuture() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userDocID', isEqualTo: widget.userDocID)
          .get();
      print("Fetched user data: ${querySnapshot.docs.first.data()}");
      return querySnapshot;
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }


  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        NavigationUtils.navigateToScreen(
          context,
          index,
          username: widget.username,
          firstName: widget.firstName,
          lastName: widget.lastName,
          pictureURL: widget.pictureURL,
          accessKey: widget.accessKey,
          userDocID: widget.userDocID,
          password: widget.password,
          department: widget.department,
          role: widget.role,
        );
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _importCSV(BuildContext context) async {
    // Step 1: Pick the CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      String? csvString;
      // Step 2: Decode the CSV file based on the platform
      if (kIsWeb || file.bytes != null) {
        csvString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        csvString = await io.File(file.path!).readAsString();
      }

      // Step 3: Parse the CSV content
      if (csvString != null) {
        List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

        // Step 4: Initialize a Firestore batch to commit all operations together
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Step 5: Loop through each row in the CSV and add it to Firestore
        for (var row in csvTable.skip(1)) {
          if (row.length == 6) {
            DocumentReference docRef = FirebaseFirestore.instance.collection('usersPending').doc();
            batch.set(docRef, {
              'username': row[0],
              'firstName': row[1],
              'lastName': row[2],
              'password': row[3],
              'department': row[4],
              'role': row[5],
            });
          } else {
            print('Skipped row due to incorrect format: $row');  // Log skipped rows
          }
        }

        // Step 6: Commit the batch
        await batch.commit();

        // Step 7: Notify the user of the successful import
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV file imported successfully')),
        );
      } else {
        // Handle error if CSV content could not be read
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read the file.')),
        );
      }
    } else {
      // Handle case when no file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: getUserFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            var userData = snapshot.data!.docs.first.data();
            String pictureURL = userData['pictureURL'] ??
                'https://clipart-library.com/images/ATbrxjpyc.jpg';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 90, bottom: 80, right: 30, left: 30),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5044f8), Color(0xFF12163b)],
                          begin: Alignment(0.1, -1.0),
                          end: Alignment(-1.0, 1.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePicture(
                                    username: widget.username,
                                    lastName: widget.lastName,
                                    firstName: widget.firstName,
                                    pictureURL: widget.pictureURL,
                                    accessKey: widget.accessKey,
                                    userDocID: widget.userDocID,
                                    department: widget.department,
                                    role: widget.role,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 125,
                              height: 125,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 75,
                                backgroundImage: NetworkImage(widget.pictureURL ?? ''),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.firstName ?? ''} ${widget.lastName ?? ''}',
                                    style: const TextStyle(
                                      fontFamily: 'Jost',
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${widget.userDocID ?? ''})',
                                    style: const TextStyle(
                                      fontFamily: 'Jost',
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                '${widget.department ?? ''} (${widget.role ?? ''})',
                                style: const TextStyle(
                                  fontFamily: 'Jost',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildElevatedButton(
                          context,
                          icon: Icons.edit,
                          text: 'Change Password',
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
                                  userDocID: widget.userDocID,
                                  department: widget.department,
                                  role: widget.role,
                                ),
                              ),
                            );
                          },
                        ),
                        if (widget.accessKey != 'basic') ...[
                          _buildElevatedButton(
                            context,
                            icon: Icons.people,
                            text: 'All Accounts',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllAccounts()));
                            },
                          ),
                          _buildElevatedButton(
                            context,
                            icon: Icons.library_add_check_sharp,
                            text: 'Account Approval',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AccountApproval()));
                            },
                          ),
                          _buildElevatedButton(
                            context,
                            icon: Icons.upload_file,
                            text: 'Import Users',
                            onPressed: () => _importCSV(context),
                          ),

                        ],
                        _buildElevatedButton(
                          context,
                          icon: Icons.logout_sharp,
                          text: 'Log out',
                          onPressed: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.blue[200],
          items: widget.accessKey == 'admin' ?
          const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ]
              : const [
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
    );
  }

  Widget _buildElevatedButton(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(45.0),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.indigo;
                }
                return const Color(0xFF3F51B5);
              },
            ),
            minimumSize:
                WidgetStateProperty.all<Size>(const Size(double.infinity, 60)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
