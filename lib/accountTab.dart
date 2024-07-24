import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginScreen.dart'; // Adjust path as per your project structure
import 'second_screen.dart';
import 'logsTab.dart';
import 'accountTab_accountApproval.dart';
import 'accountTab_changePassword.dart';
import 'accountTab_changePicture.dart';
import 'accountTab_allAccounts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';

class AccountTab extends StatefulWidget {
  final String firstName, lastName, username, pictureURL, accessKey, userDocID, password;

  const AccountTab({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL,
    required this.accessKey,
    required this.userDocID,
    required this.password,
  }) : super(key: key);

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  int _selectedIndex = 2;

  Future<QuerySnapshot<Map<String, dynamic>>> getUserFuture() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userDocID', isEqualTo: widget.userDocID)
        .get();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _navigateToScreen(index);
      });
    }
  }

  void _navigateToScreen(int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = SecondScreen(
          username: widget.username,
          firstName: widget.firstName,
          lastName: widget.lastName,
          pictureURL: widget.pictureURL,
          accessKey: widget.accessKey,
          userDocID: widget.userDocID,
          password: widget.password,
        );
        break;
      case 1:
        screen = LogsTab(
          username: widget.username,
          firstName: widget.firstName,
          lastName: widget.lastName,
          pictureURL: widget.pictureURL,
          accessKey: widget.accessKey,
          userDocID: widget.userDocID,
          password: widget.password,
        );
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if(result != null){
      PlatformFile file = result.files.first;
      String csvString = utf8.decode(file.bytes!);
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

      for(var row in csvTable.skip(1)){
        // Assuming the CSV has columns in order: username, firstName, lastName, accessKey, userDocID, password
        if(row.length == 4){
          FirebaseFirestore.instance.collection('usersPending').add({
            'username': row[0],
            'firstName': row[1],
            'lastName': row[2],
            'password': row[3],
          });
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV file imported successfully'),
        ),
      );
    } else {
      // Show error message if no file was selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No file selected'),
        ),
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
            String pictureURL = userData['pictureURL'] ?? 'https://clipart-library.com/images/ATbrxjpyc.jpg';

            return Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 80, bottom: 60, right: 20, left: 20),
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
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundImage: NetworkImage(pictureURL),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.firstName} ${widget.lastName}',
                              style: const TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.username,
                              style: const TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.white,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AllAccounts()));
                            },
                          ),
                          _buildElevatedButton(
                            context,
                            icon: Icons.library_add_check_sharp,
                            text: 'Account Approval',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountApproval()));
                            },
                          ),
                          _buildElevatedButton(
                            context,
                            icon: Icons.upload_file,
                            text: 'Import CSV',
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
          items: const [
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

  Widget _buildElevatedButton(BuildContext context, {required IconData icon, required String text, required VoidCallback onPressed}) {
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
            minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 60)),
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
