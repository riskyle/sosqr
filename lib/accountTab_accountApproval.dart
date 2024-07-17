import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountApproval extends StatefulWidget {
  @override
  _AccountApprovalState createState() => _AccountApprovalState();
}

class _AccountApprovalState extends State<AccountApproval> {
  String pictureURL = 'https://clipart-library.com/images/ATbrxjpyc.jpg';
  Map<String, String?> _selectedAccessMap = {};

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
              String firstName = userData['firstName'];
              String lastName = userData['lastName'];
              String username = userData['username'];
              String password = userData['password']; // This will be used later

              _selectedAccessMap.putIfAbsent(username, () => null);

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              pictureURL), // Replace with your actual image URL
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedAccessMap[username],
                                hint: Text('Select user access'),
                                items: <String>[
                                  'Basic',
                                  'Admin'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value
                                        .toLowerCase(), // Store as 'basic' or 'admin'
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(
                                    () {
                                      _selectedAccessMap[username] = newValue;
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Row(
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
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF00E5E5),
                                                        Color(0xFF0057FF)
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(10.0),
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
                                                  padding: const EdgeInsets.all(
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
                                              });

                                              // Remove user from 'usersPending' collection
                                              await FirebaseFirestore.instance
                                                  .collection('usersPending')
                                                  .doc(userDoc.id)
                                                  .delete();

                                              // Show dialog box after the above operations are completed
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
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
                                                                child: Icon(Icons.check_circle,
                                                                    color: Colors.white, size: 30),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Text(
                                                                'The user has been added.',
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
                            SizedBox(width: 10),

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
                                                    begin: Alignment.topLeft,
                                                    end:
                                                    Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.vertical(
                                                    top:
                                                    Radius.circular(10.0),
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
                                                padding: const EdgeInsets.all(
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
                                            });

                                            // Remove user from 'usersPending' collection
                                            await FirebaseFirestore.instance
                                                .collection('usersPending')
                                                .doc(userDoc.id)
                                                .delete();

                                            // Show dialog box after the above operations are completed
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
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
                                                              child: Icon(Icons.check_circle,
                                                                  color: Colors.white, size: 30),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(20.0),
                                                            child: Text(
                                                              'The user has been declined.',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider()
                ],
              );
            },
          );
        },
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
