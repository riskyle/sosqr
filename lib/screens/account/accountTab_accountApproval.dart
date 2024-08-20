import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountApproval extends StatefulWidget {
  String pictureURL = 'https://clipart-library.com/images/ATbrxjpyc.jpg';
  @override
  _AccountApprovalState createState() => _AccountApprovalState();
}

class _AccountApprovalState extends State<AccountApproval> {

  Map<String, String?> _selectedAccessMap = {};
  Set<String> _selectedUsers = Set();
  bool _selectAll = false;
  Map<String, bool> _additionalCheckboxMap = {};

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      _additionalCheckboxMap.updateAll((key, val) => _selectAll);
      _selectedUsers.clear();
      if (_selectAll) {
        FirebaseFirestore.instance
            .collection('userPending')
            .get()
            .then((querySnapshot) {
          for (var userDoc in querySnapshot.docs) {
            var userData = userDoc.data() as Map<String, dynamic>;
            _selectedUsers.add(userData['username']);
            if (!_selectAll) {
              _additionalCheckboxMap.clear();
            } else {
              // Automatically check all users
              _additionalCheckboxMap = {
                for (var entry in _additionalCheckboxMap.entries)
                  entry.key: true
              };
            }
          }
        });
      }
    });
  }

  Future<void> _approveSelectedUsers() async {
    List<String> usersToApprove = [];
    for (var entry in _additionalCheckboxMap.entries) {
      if (entry.value == true) {
        usersToApprove.add(entry.key);
      }
    }

    if (usersToApprove.isEmpty) {
      _showNoUserSelectedDialog();
      return;
    }

    bool allUsersApproved = true; // Track if all users were approved

    for (var username in usersToApprove) {
      try {
        // Fetch additional data from Firestore to approve the users
        var querySnapshot = await FirebaseFirestore.instance
            .collection('usersPending')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs.first;
          var userData = userDoc.data();

          // Retrieve necessary fields from userData
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';
          String password = userData['password'] ?? '';
          String pictureURL = userData['pictureURL'] ?? '';
          String accessKey = _selectedAccessMap[username] ?? "";
          String department = userData['department'] ?? '';
          String role = userData['role'] ?? '';

          // Check if accessKey is provided
          if (accessKey.isEmpty) {
            allUsersApproved = false;
            // Display error message for missing access key
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('User $username cannot be approved without an access key.'),
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
              },
            );
            continue; // Skip this user
          }

          // Move user from 'usersPending' to 'users'
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .set({
            'username': username,
            'firstName': firstName,
            'lastName': lastName,
            'accessKey': accessKey,
            'password': password,
            'pictureURL': pictureURL,
            'userDocID': userDoc.id,
            'department': department,
            'role': role,
          });

          // Remove user from 'usersPending' collection
          await FirebaseFirestore.instance
              .collection('usersPending')
              .doc(userDoc.id)
              .delete();
        }
      } catch (e) {
        print('Error approving user $username: $e');
        allUsersApproved = false;
      }
    }

    // Clear selected checkboxes and refresh UI
    setState(() {
      _additionalCheckboxMap.clear();
      _selectAll = false;
    });

    // Provide feedback to the user about the approval action
    if (allUsersApproved) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Selected users have been approved and moved to the approved list.'),
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
        },
      );
    }
  }


  void _showNoUserSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No User Selected'),
          content:
              Text('Please select at least more than one user to approve.'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Account Approval',
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
        actions: [
          Checkbox(
            value: _selectAll,
            onChanged: _toggleSelectAll,
            activeColor: Colors.white,
            checkColor: Colors.blue,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('usersPending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userDocs = snapshot.data!.docs;
          if (userDocs.isEmpty) {
            return Center(child: Text('No pending users'));
          }

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              var userDoc = userDocs[index];
              var userData = userDoc.data() as Map<String, dynamic>;
              String firstName = userData['firstName'] ?? 'First Name';
              String lastName = userData['lastName'] ?? 'Last Name';
              String username = userData['username'] ?? 'Username';
              String password =
                  userData['password'] ?? 'password'; // This will be used later
              String pictureURL =
                  userData['pictureURL'] ?? '';
              String department = userData['department'] ?? 'Department';
              String role = userData['role'] ?? 'role';


              //Initialize the additional checkbox state

              _additionalCheckboxMap.putIfAbsent(username, () => false);

              return LayoutBuilder(
                builder: (context, constraints) {
                  return
                      Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  pictureURL), // Replace with your actual image URL
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firstName $lastName',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  DropdownButton<String>(
                                    value: _selectedAccessMap[username],
                                    hint: Text('Select user access'),
                                    items: <String>['Basic', 'Admin']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value
                                            .toLowerCase(), // Store as 'basic' or 'admin'
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(
                                        () {
                                          _selectedAccessMap[username] =
                                              newValue;
                                        },
                                      );
                                    },
                                    isExpanded: true,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Add user to the accepted users database
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.check),
                                    color: Colors.white,
                                    iconSize: 15,
                                    tooltip: 'Accept',
                                    onPressed: () async {
                                      String? accessKey =
                                          _selectedAccessMap[username];
                                      if (accessKey != null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0), // Customize the border radius here
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            content: SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      300, // Set the maximum width
                                                  maxHeight:
                                                      150, // Set the maximum height
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // Ensure the column takes only necessary space
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF00E5E5),
                                                            Color(0xFF0057FF)
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .vertical(
                                                          top: Radius.circular(
                                                              10.0),
                                                          bottom: Radius.zero,
                                                        ),
                                                      ),
                                                      height: 60,
                                                      child: Center(
                                                        child: Icon(
                                                            Icons
                                                                .error_outline_sharp,
                                                            color: Colors.white,
                                                            size: 30),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Text(
                                                        'Approve user?',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'Jost',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  // Add user to 'users' collection
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userDoc.id)
                                                      .set({
                                                    'username': username,
                                                    'firstName': firstName,
                                                    'lastName': lastName,
                                                    'accessKey': accessKey,
                                                    'password': password,
                                                    'pictureURL': pictureURL,
                                                    'userDocID': userDoc.id,
                                                    'department': department,
                                                    'role': role,
                                                  });

                                                  // Remove user from 'usersPending' collection
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'usersPending')
                                                      .doc(userDoc.id)
                                                      .delete();

                                                  // Show dialog box after the above operations are completed
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // Customize the border radius here
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        content:
                                                            SingleChildScrollView(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth:
                                                                  300, // Set the maximum width
                                                              maxHeight:
                                                                  150, // Set the maximum height
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min, // Ensure the column takes only necessary space
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Color(
                                                                            0xFF00E5E5),
                                                                        Color(
                                                                            0xFF0057FF)
                                                                      ],
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment
                                                                          .bottomRight,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              10.0),
                                                                      bottom: Radius
                                                                          .zero,
                                                                    ),
                                                                  ),
                                                                  height: 60,
                                                                  child: Center(
                                                                    child: Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          20.0),
                                                                  child: Text(
                                                                    'The user has been added.',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'Jost',
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF1F5EBD),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ).then((_) {
                                                    // Pop the current screen after the dialog is dismissed
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    color: Color(0xFF1F5EBD),
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Color(0xFF1F5EBD),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        String message =
                                            'Please select user access first.';
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AccountApprovalDialog(
                                                  message: message),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 3),

                                // Remove user application from the list of pending approvals.......
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.red[700],
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    color: Colors.white,
                                    iconSize: 15,
                                    tooltip: 'Decline',
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Customize the border radius here
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          content: SingleChildScrollView(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    300, // Set the maximum width
                                                maxHeight:
                                                    150, // Set the maximum height
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Ensure the column takes only necessary space
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF00E5E5),
                                                          Color(0xFF0057FF)
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            10.0),
                                                        bottom: Radius.zero,
                                                      ),
                                                    ),
                                                    height: 60,
                                                    child: Center(
                                                      child: Icon(
                                                          Icons
                                                              .error_outline_sharp,
                                                          color: Colors.white,
                                                          size: 30),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Text(
                                                      'Reject user?',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: 'Jost',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                // Add user to 'usersDeclined' collection
                                                await FirebaseFirestore.instance
                                                    .collection('usersDeclined')
                                                    .doc(userDoc.id)
                                                    .set({
                                                  'username': username,
                                                  'firstName': firstName,
                                                  'lastName': lastName,
                                                  'password': password,
                                                  'department': department,
                                                  'role': role,
                                                });

                                                // Remove user from 'usersPending' collection
                                                await FirebaseFirestore.instance
                                                    .collection('usersPending')
                                                    .doc(userDoc.id)
                                                    .delete();

                                                // Show dialog box after the above operations are completed
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0), // Customize the border radius here
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth:
                                                                300, // Set the maximum width
                                                            maxHeight:
                                                                150, // Set the maximum height
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min, // Ensure the column takes only necessary space
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xFF00E5E5),
                                                                      Color(
                                                                          0xFF0057FF)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            10.0),
                                                                    bottom: Radius
                                                                        .zero,
                                                                  ),
                                                                ),
                                                                height: 60,
                                                                child: Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 30),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20.0),
                                                                child: Text(
                                                                  'The user has been declined.',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontFamily:
                                                                        'Jost',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text(
                                                            "OK",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF1F5EBD),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ).then((_) {
                                                  // Pop the current screen after the dialog is dismissed
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                  color: Color(0xFF1F5EBD),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                "No",
                                                style: TextStyle(
                                                  color: Color(0xFF1F5EBD),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 1),
                                if (_selectAll) ...[
                                  Checkbox(
                                    value: _additionalCheckboxMap[username],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _additionalCheckboxMap[username] =
                                            value! ?? false;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                      Divider()
                          ],
                        ),
                      );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _approveSelectedUsers,
        child: Icon(Icons.done),
        tooltip: 'Approve Selected Users',
      ),
    );
  }
}

class AccountApprovalDialog extends StatelessWidget {
  final String message;

  const AccountApprovalDialog({Key? key, required this.message})
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
