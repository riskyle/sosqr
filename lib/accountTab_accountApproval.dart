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
      appBar: AppBar(),
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
                            IconButton(
                              icon: Icon(Icons.check),
                              color: Colors.green,
                              iconSize: 25,
                              tooltip: 'Accept',
                              onPressed: () async {
                                String? accessKey =
                                    _selectedAccessMap[username];
                                if (accessKey != null) {
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
                                }
                              },
                            ),

                            // Remove user application from the list of pending approvals.......
                            IconButton(
                              icon: Icon(Icons.close),
                              color: Colors.red,
                              iconSize: 25,
                              tooltip: 'Decline',
                              onPressed: () async {
                                // Remove user from 'usersPending' collection
                                await FirebaseFirestore.instance
                                    .collection('usersPending')
                                    .doc(userDoc.id)
                                    .delete();
                              },
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
